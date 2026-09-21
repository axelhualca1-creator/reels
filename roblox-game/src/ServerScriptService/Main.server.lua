-- Server-authoritative collector-tycoon: each player gets a plot, buys units
-- that generate cash/sec, must physically visit their own vault to "collect"
-- the bank into spendable cash, and other players can steal from an
-- uncollected, unshielded bank. This is the "tycoon + PvP steal" format
-- that's currently the most-played/most-viral genre on Roblox. Nothing here
-- is trusted from the client except "which unit id do you want to buy" /
-- "rebirth please" -- every number is computed and stored server-side.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local SaveStore = DataStoreService:GetDataStore("SigmaGrind_PlayerSave_v2")

-- ===== Remotes =====
local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = ReplicatedStorage

local function newRemoteEvent(name)
	local re = Instance.new("RemoteEvent")
	re.Name = name
	re.Parent = remotesFolder
	return re
end

local function newRemoteFunction(name)
	local rf = Instance.new("RemoteFunction")
	rf.Name = name
	rf.Parent = remotesFolder
	return rf
end

local BuyUnitEvent = newRemoteEvent("BuyUnit")
local RebirthEvent = newRemoteEvent("Rebirth")
local PromptGamePassEvent = newRemoteEvent("PromptGamePass")
local StateChangedEvent = newRemoteEvent("StateChanged")
local GetStateFunction = newRemoteFunction("GetState")
local SpinWheelEvent = newRemoteEvent("SpinWheel")
local ClaimDailyRewardEvent = newRemoteEvent("ClaimDailyReward")
local BuyGemItemEvent = newRemoteEvent("BuyGemItem")

-- ===== Helpers =====
local function getUnit(id)
	for _, u in ipairs(Config.Units) do
		if u.id == id then
			return u
		end
	end
	return nil
end

-- Gamepass ownership is cached per player (fetched once on join, refreshed
-- on purchase) instead of polled every tick -- hitting UserOwnsGamePassAsync
-- once per second per player per pass would get rate-limited fast with any
-- real player count.
local gamePassCache = {} -- userId -> { [passKey] = bool }

local function refreshGamePassCache(player)
	local cache = {}
	for passKey, passId in pairs(Config.GamePassIds) do
		if passId and passId ~= 0 then
			local ok, owns = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
			end)
			cache[passKey] = ok and owns or false
		else
			cache[passKey] = false
		end
	end
	gamePassCache[player.UserId] = cache
end

local function ownsGamePass(player, passKey)
	local cache = gamePassCache[player.UserId]
	return cache ~= nil and cache[passKey] == true
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	if not purchased then
		return
	end
	for passKey, id in pairs(Config.GamePassIds) do
		if id == passId then
			local cache = gamePassCache[player.UserId]
			if cache then
				cache[passKey] = true
			end
		end
	end
end)

local function bankCapFor(player)
	local cap = Config.Bank.baseCap
	if ownsGamePass(player, "ExtraVault") then
		cap += Config.Bank.capPerSlotUpgrade
	end
	return cap
end

local function cashPerSecondFor(state, player)
	local total = 0
	for _, unitId in ipairs(state.ownedUnitIds) do
		local unit = getUnit(unitId)
		if unit then
			total += unit.cashPerSecond
		end
	end
	total *= 1 + (state.rebirths * Config.Rebirth.multiplierPerRebirth)
	if ownsGamePass(player, "VIP") then
		total *= 1.5
	end
	return total
end

local function rebirthRequirement(state)
	return math.floor(Config.Rebirth.baseRequirement * (Config.Rebirth.requirementGrowth ^ state.rebirths))
end

-- ===== Daily calendar / playtime-wheel helpers (all UTC-based) =====
local function todayDateString()
	return os.date("!%Y-%m-%d")
end

local function dateStringToEpoch(dateString)
	local y, m, d = dateString:match("(%d+)-(%d+)-(%d+)")
	return os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12, min = 0, sec = 0 })
end

local function daysBetween(fromDate, toDate)
	return math.floor((dateStringToEpoch(toDate) - dateStringToEpoch(fromDate)) / 86400 + 0.5)
end

local function grantReward(state, reward)
	if reward.kind == "cash" then
		state.cash += reward.amount
	elseif reward.kind == "gems" then
		state.gems += reward.amount
	end
end

local function currentDailyRewardIndex(state)
	return ((state.loginStreak - 1) % #Config.DailyRewards) + 1
end

-- Forward-declared so the plot prompts below (built before player state
-- exists) can close over the real implementations assigned further down.
local playerStates = {}
local pushState

-- ===== Plot construction (all procedural -- no binary Studio assets) =====
local plotsFolder = Instance.new("Folder")
plotsFolder.Name = "Plots"
plotsFolder.Parent = Workspace

local plots = {} -- index -> plot data
local freePlotIndices = {}
local plotIndexByUserId = {}

local COLUMNS = 5

for i = 1, Config.Plot.count do
	local col = (i - 1) % COLUMNS
	local row = math.floor((i - 1) / COLUMNS)
	local centerX = col * Config.Plot.spacing
	local centerZ = row * Config.Plot.spacing

	local base = Instance.new("Part")
	base.Name = "Base_" .. i
	base.Anchored = true
	base.Size = Vector3.new(Config.Plot.size, 2, Config.Plot.size)
	base.Position = Vector3.new(centerX, 0, centerZ)
	base.Color = Color3.fromRGB(60, 60, 65)
	base.TopSurface = Enum.SurfaceType.Smooth
	base.Parent = plotsFolder

	local vault = Instance.new("Part")
	vault.Name = "Vault"
	vault.Anchored = true
	vault.Shape = Enum.PartType.Cylinder
	vault.Orientation = Vector3.new(0, 0, 90)
	vault.Size = Vector3.new(3, 5, 5)
	vault.Position = base.Position + Vector3.new(0, 3.5, -Config.Plot.size / 2 + 5)
	vault.Color = Color3.fromRGB(255, 210, 0)
	vault.Material = Enum.Material.Neon
	vault.Parent = base

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "Prompt"
	prompt.ObjectText = "Vault"
	prompt.ActionText = "Interact"
	prompt.HoldDuration = Config.Steal.promptHoldDuration
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = vault

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Info"
	billboard.Size = UDim2.new(0, 160, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = vault

	local ownerLabel = Instance.new("TextLabel")
	ownerLabel.Size = UDim2.new(1, 0, 1, 0)
	ownerLabel.BackgroundTransparency = 1
	ownerLabel.TextColor3 = Color3.new(1, 1, 1)
	ownerLabel.Font = Enum.Font.GothamBold
	ownerLabel.TextScaled = true
	ownerLabel.Text = "Empty plot"
	ownerLabel.Parent = billboard

	local spawnPosition = base.Position + Vector3.new(0, 5, Config.Plot.size / 2 - 4)

	local unitSlotOffsets = {}
	local slotsPerRow = 4
	for s = 1, Config.Plot.maxUnitSlots do
		local sc = (s - 1) % slotsPerRow
		local sr = math.floor((s - 1) / slotsPerRow)
		local offset = Vector3.new(
			(sc - (slotsPerRow - 1) / 2) * 4,
			2,
			(sr * 5) - Config.Plot.size / 2 + 14
		)
		table.insert(unitSlotOffsets, base.Position + offset)
	end

	local plotData = {
		index = i,
		base = base,
		vault = vault,
		prompt = prompt,
		ownerLabel = ownerLabel,
		spawnPosition = spawnPosition,
		unitSlotOffsets = unitSlotOffsets,
		unitParts = {}, -- unitId -> Part currently placed
		ownerUserId = nil,
	}
	plots[i] = plotData
	table.insert(freePlotIndices, i)

	prompt.Triggered:Connect(function(triggeringPlayer)
		if not plotData.ownerUserId then
			return
		end
		if triggeringPlayer.UserId == plotData.ownerUserId then
			-- COLLECT: move own bank into spendable cash
			local state = playerStates[triggeringPlayer.UserId]
			if not state or state.bank <= 0 then
				return
			end
			state.cash += state.bank
			state.bank = 0
			pushState(triggeringPlayer, state)
		else
			-- STEAL: take a cut of the victim's uncollected bank
			local victimUserId = plotData.ownerUserId
			local victimState = playerStates[victimUserId]
			local stealerState = playerStates[triggeringPlayer.UserId]
			if not victimState or not stealerState then
				return
			end
			local now = os.time()
			if victimState.shieldUntil and now < victimState.shieldUntil then
				return
			end
			if victimState.bank <= 0 then
				return
			end
			stealerState.lastStealAt = stealerState.lastStealAt or {}
			local last = stealerState.lastStealAt[victimUserId] or 0
			if now - last < Config.Steal.sameTargetCooldownSeconds then
				return
			end
			stealerState.lastStealAt[victimUserId] = now

			local stolen = math.floor(victimState.bank * Config.Steal.stealPercent)
			victimState.bank -= stolen
			stealerState.cash += stolen
			victimState.shieldUntil = now + Config.Steal.graceShieldSeconds

			stealerState.lastStolenAmount = stolen
			pushState(triggeringPlayer, stealerState)
			local victimPlayer = Players:GetPlayerByUserId(victimUserId)
			if victimPlayer then
				pushState(victimPlayer, victimState)
			end
		end
	end)
end

-- ===== Player state =====

local function defaultState()
	return {
		cash = 0,
		bank = 0,
		gems = 0,
		ownedUnitIds = {},
		rebirths = 0,
		shieldUntil = 0,
		lastStealAt = {},
		-- Free-time engagement rewards (never tied to real money spend):
		dailyPlaySeconds = 0,
		lastPlayDate = "",
		wheelEligible = false,
		wheelClaimedToday = false,
		loginStreak = 0,
		lastLoginDate = "",
		dailyRewardClaimedDate = "",
	}
end

-- Fills in any fields a save from before a feature existed is missing, so
-- old saves keep working instead of erroring on a nil field.
local function withDefaults(saved)
	local defaults = defaultState()
	for key, value in pairs(defaults) do
		if saved[key] == nil then
			saved[key] = value
		end
	end
	return saved
end

local function loadState(player)
	local key = "Player_" .. player.UserId
	local ok, saved = pcall(function()
		return SaveStore:GetAsync(key)
	end)
	if ok and saved then
		return withDefaults(saved)
	end
	return defaultState()
end

local function saveState(player)
	local state = playerStates[player.UserId]
	if not state then
		return
	end
	local key = "Player_" .. player.UserId
	pcall(function()
		SaveStore:SetAsync(key, state)
	end)
end

local function placeUnitPart(plotData, unit, slotIndex)
	local part = Instance.new("Part")
	part.Name = "Unit_" .. unit.id
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(3, 3, 3)
	part.Position = plotData.unitSlotOffsets[slotIndex] or plotData.base.Position
	part.Color = unit.color
	part.Material = Enum.Material.Neon
	part.Parent = plotData.base

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 30)
	billboard.StudsOffset = Vector3.new(0, 2.2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.Gotham
	label.TextScaled = true
	label.Text = unit.name
	label.Parent = billboard

	return part
end

local function assignPlot(player, state)
	local index = table.remove(freePlotIndices)
	if not index then
		return nil -- server full of plots; player waits or should join another server
	end
	local plotData = plots[index]
	plotData.ownerUserId = player.UserId
	plotData.ownerLabel.Text = player.Name .. "'s Vault"
	plotIndexByUserId[player.UserId] = index

	for slot, unitId in ipairs(state.ownedUnitIds) do
		local unit = getUnit(unitId)
		if unit and slot <= Config.Plot.maxUnitSlots then
			plotData.unitParts[unitId] = placeUnitPart(plotData, unit, slot)
		end
	end

	return plotData
end

local function releasePlot(player)
	local index = plotIndexByUserId[player.UserId]
	if not index then
		return
	end
	local plotData = plots[index]
	for _, part in pairs(plotData.unitParts) do
		part:Destroy()
	end
	plotData.unitParts = {}
	plotData.ownerUserId = nil
	plotData.ownerLabel.Text = "Empty plot"
	plotIndexByUserId[player.UserId] = nil
	table.insert(freePlotIndices, index)
end

pushState = function(player, state)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		leaderstats.Cash.Value = math.floor(state.cash)
		leaderstats.Rebirths.Value = state.rebirths
	end
	local today = todayDateString()
	StateChangedEvent:FireClient(player, {
		cash = math.floor(state.cash),
		bank = math.floor(state.bank),
		bankCap = bankCapFor(player),
		gems = state.gems,
		cashPerSecond = cashPerSecondFor(state, player),
		ownedUnitIds = state.ownedUnitIds,
		rebirths = state.rebirths,
		rebirthRequirement = rebirthRequirement(state),
		shieldUntil = state.shieldUntil,
		lastStolenAmount = state.lastStolenAmount,
		wheelEligible = state.wheelEligible,
		dailyPlaySeconds = state.dailyPlaySeconds,
		lastWheelReward = state.lastWheelReward,
		loginStreak = state.loginStreak,
		dailyRewardAvailable = state.dailyRewardClaimedDate ~= today,
		dailyRewardIndex = currentDailyRewardIndex(state),
		lastDailyRewardLabel = state.lastDailyRewardLabel,
	})
	state.lastStolenAmount = nil
	state.lastWheelReward = nil
	state.lastDailyRewardLabel = nil
end

Players.PlayerAdded:Connect(function(player)
	local state = loadState(player)
	playerStates[player.UserId] = state
	refreshGamePassCache(player)

	-- Login streak: consecutive UTC days logged in advances it, any gap resets
	-- it to 1. Rejoining the same day just leaves it as-is.
	local today = todayDateString()
	if state.lastLoginDate == "" then
		state.loginStreak = 1
	elseif state.lastLoginDate ~= today then
		local gap = daysBetween(state.lastLoginDate, today)
		state.loginStreak = (gap == 1) and (state.loginStreak + 1) or 1
	end
	state.lastLoginDate = today
	if state.lastPlayDate ~= today then
		state.lastPlayDate = today
		state.dailyPlaySeconds = 0
		state.wheelClaimedToday = false
		state.wheelEligible = false
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local cashStat = Instance.new("IntValue")
	cashStat.Name = "Cash"
	cashStat.Value = math.floor(state.cash)
	cashStat.Parent = leaderstats

	local rebirthsStat = Instance.new("IntValue")
	rebirthsStat.Name = "Rebirths"
	rebirthsStat.Value = state.rebirths
	rebirthsStat.Parent = leaderstats

	local plotData = assignPlot(player, state)

	player.CharacterAdded:Connect(function(character)
		if plotData then
			character:WaitForChild("HumanoidRootPart")
			character:PivotTo(CFrame.new(plotData.spawnPosition))
		end
	end)

	pushState(player, state)
end)

Players.PlayerRemoving:Connect(function(player)
	saveState(player)
	releasePlot(player)
	playerStates[player.UserId] = nil
	gamePassCache[player.UserId] = nil
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		saveState(player)
	end
	task.wait(RunService:IsStudio() and 1 or 3)
end)

task.spawn(function()
	while true do
		task.wait(60)
		for _, player in ipairs(Players:GetPlayers()) do
			saveState(player)
		end
	end
end)

-- ===== Passive income + playtime-wheel tick =====
task.spawn(function()
	while true do
		task.wait(1)
		local today = todayDateString()
		for userId, state in pairs(playerStates) do
			local player = Players:GetPlayerByUserId(userId)
			if player then
				local production = cashPerSecondFor(state, player)
				if ownsGamePass(player, "AutoCollect") then
					state.cash += production
				else
					state.bank = math.min(state.bank + production, bankCapFor(player))
				end

				-- Rolls over mid-session for anyone still connected at UTC midnight.
				if state.lastPlayDate ~= today then
					state.lastPlayDate = today
					state.dailyPlaySeconds = 0
					state.wheelClaimedToday = false
					state.wheelEligible = false
				end
				state.dailyPlaySeconds += 1
				if not state.wheelClaimedToday and state.dailyPlaySeconds >= Config.SessionWheel.requiredMinutes * 60 then
					state.wheelEligible = true
				end
			end
		end
	end
end)

-- Throttled UI sync so clients see cash ticking up without flooding remotes.
task.spawn(function()
	while true do
		task.wait(2)
		for userId, state in pairs(playerStates) do
			local player = Players:GetPlayerByUserId(userId)
			if player then
				pushState(player, state)
			end
		end
	end
end)

-- ===== Purchases =====
BuyUnitEvent.OnServerEvent:Connect(function(player, unitId)
	local state = playerStates[player.UserId]
	local unit = getUnit(unitId)
	if not state or not unit then
		return
	end
	if #state.ownedUnitIds >= Config.Plot.maxUnitSlots then
		return
	end
	if state.cash < unit.cost then
		return
	end
	state.cash -= unit.cost
	table.insert(state.ownedUnitIds, unit.id)

	local index = plotIndexByUserId[player.UserId]
	if index then
		local plotData = plots[index]
		plotData.unitParts[unit.id] = placeUnitPart(plotData, unit, #state.ownedUnitIds)
	end

	pushState(player, state)
end)

RebirthEvent.OnServerEvent:Connect(function(player)
	local state = playerStates[player.UserId]
	if not state then
		return
	end
	local requirement = rebirthRequirement(state)
	if state.cash < requirement then
		return
	end
	state.cash = 0
	state.rebirths += 1
	pushState(player, state)
end)

PromptGamePassEvent.OnServerEvent:Connect(function(player, passKey)
	local passId = Config.GamePassIds[passKey]
	if passId and passId ~= 0 then
		MarketplaceService:PromptGamePassPurchase(player, passId)
	end
end)

-- Free 15-minutes-played wheel spin. The outcome is rolled here on the
-- server (never the client) and is paid for with time, not Robux, so it's
-- a loyalty bonus rather than a gambling mechanic.
SpinWheelEvent.OnServerEvent:Connect(function(player)
	local state = playerStates[player.UserId]
	if not state or not state.wheelEligible or state.wheelClaimedToday then
		return
	end

	local totalWeight = 0
	for _, reward in ipairs(Config.SessionWheel.rewards) do
		totalWeight += reward.weight
	end
	local roll = math.random() * totalWeight
	local chosen = Config.SessionWheel.rewards[1]
	local accumulated = 0
	for _, reward in ipairs(Config.SessionWheel.rewards) do
		accumulated += reward.weight
		if roll <= accumulated then
			chosen = reward
			break
		end
	end

	grantReward(state, chosen)
	state.wheelClaimedToday = true
	state.wheelEligible = false
	state.lastWheelReward = chosen.label
	pushState(player, state)
end)

-- Daily login calendar. Advancing the streak happens once at join
-- (PlayerAdded); this just grants today's slot in the 7-day cycle, once.
ClaimDailyRewardEvent.OnServerEvent:Connect(function(player)
	local state = playerStates[player.UserId]
	if not state then
		return
	end
	local today = todayDateString()
	if state.dailyRewardClaimedDate == today then
		return
	end
	local reward = Config.DailyRewards[currentDailyRewardIndex(state)]
	grantReward(state, reward)
	state.dailyRewardClaimedDate = today
	state.lastDailyRewardLabel = reward.label
	pushState(player, state)
end)

-- Gems (earned only from the wheel/calendar above) spent on shields.
BuyGemItemEvent.OnServerEvent:Connect(function(player, itemKey)
	local state = playerStates[player.UserId]
	local item = Config.GemShop[itemKey]
	if not state or not item then
		return
	end
	if state.gems < item.gems then
		return
	end
	state.gems -= item.gems
	local now = os.time()
	state.shieldUntil = math.max(state.shieldUntil, now) + item.seconds
	pushState(player, state)
end)

GetStateFunction.OnServerInvoke = function(player)
	local state = playerStates[player.UserId]
	if not state then
		return nil
	end
	local today = todayDateString()
	return {
		cash = math.floor(state.cash),
		bank = math.floor(state.bank),
		bankCap = bankCapFor(player),
		gems = state.gems,
		cashPerSecond = cashPerSecondFor(state, player),
		ownedUnitIds = state.ownedUnitIds,
		rebirths = state.rebirths,
		rebirthRequirement = rebirthRequirement(state),
		shieldUntil = state.shieldUntil,
		wheelEligible = state.wheelEligible,
		dailyPlaySeconds = state.dailyPlaySeconds,
		loginStreak = state.loginStreak,
		dailyRewardAvailable = state.dailyRewardClaimedDate ~= today,
		dailyRewardIndex = currentDailyRewardIndex(state),
	}
end

-- Developer products: deterministic effects only (cash packs, timed shields).
-- No randomized/gacha rewards are ever sold for real money.
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local state = playerStates[player.UserId]
	if not state then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local product = Config.DeveloperProducts[receiptInfo.ProductId]
	if product then
		if product.kind == "cash" then
			state.cash += product.amount
		elseif product.kind == "shield" then
			local now = os.time()
			state.shieldUntil = math.max(state.shieldUntil, now) + product.seconds
		end
		pushState(player, state)
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end
