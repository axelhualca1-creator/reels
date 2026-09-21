-- Server-authoritative game loop: currency, upgrades, rebirths, monetization.
-- Nothing about a player's coin total is ever trusted from the client;
-- the client only says "I tapped" or "I want to buy upgrade X", and the
-- server decides whether that's legal and what it's worth.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local SaveStore = DataStoreService:GetDataStore("SigmaGrind_PlayerSave_v1")

-- RemoteEvents/Functions, created here so nothing binary needs to live in git.
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

local TapEvent = newRemoteEvent("Tap")
local BuyUpgradeEvent = newRemoteEvent("BuyUpgrade")
local RebirthEvent = newRemoteEvent("Rebirth")
local StateChangedEvent = newRemoteEvent("StateChanged")
local GetStateFunction = newRemoteFunction("GetState")
local PromptGamePassEvent = newRemoteEvent("PromptGamePass")

-- In-memory per-player state, keyed by UserId. Persisted to DataStore on
-- leave/close and periodically autosaved.
local playerStates = {}

local function defaultState()
	return {
		coins = 0,
		totalCoinsEarned = 0,
		upgradeLevels = {},
		rebirths = 0,
		lastTapAt = 0,
	}
end

local function getUpgrade(id)
	for _, u in ipairs(Config.Upgrades) do
		if u.id == id then
			return u
		end
	end
	return nil
end

local function upgradeCost(upgrade, currentLevel)
	return math.floor(upgrade.baseCost * (upgrade.costGrowth ^ currentLevel))
end

local function coinsPerTap(state)
	local total = Config.StartingCoinsPerTap
	for _, u in ipairs(Config.Upgrades) do
		local level = state.upgradeLevels[u.id] or 0
		total += level * u.tapAdd
	end
	local rebirthMultiplier = 1 + (state.rebirths * Config.Rebirth.multiplierPerRebirth)
	return math.floor(total * rebirthMultiplier)
end

local function rebirthRequirement(state)
	return math.floor(Config.Rebirth.baseRequirement * (Config.Rebirth.requirementGrowth ^ state.rebirths))
end

local function ownsGamePass(player, passId)
	if not passId or passId == 0 then
		return false
	end
	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
	end)
	return ok and owns
end

local function pushState(player, state)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		leaderstats.Coins.Value = state.coins
		leaderstats.Rebirths.Value = state.rebirths
	end
	StateChangedEvent:FireClient(player, {
		coins = state.coins,
		rebirths = state.rebirths,
		upgradeLevels = state.upgradeLevels,
		coinsPerTap = coinsPerTap(state),
		rebirthRequirement = rebirthRequirement(state),
	})
end

local function loadState(player)
	local key = "Player_" .. player.UserId
	local ok, saved = pcall(function()
		return SaveStore:GetAsync(key)
	end)
	if ok and saved then
		return saved
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

Players.PlayerAdded:Connect(function(player)
	local state = loadState(player)
	playerStates[player.UserId] = state

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coinsStat = Instance.new("IntValue")
	coinsStat.Name = "Coins"
	coinsStat.Value = state.coins
	coinsStat.Parent = leaderstats

	local rebirthsStat = Instance.new("IntValue")
	rebirthsStat.Name = "Rebirths"
	rebirthsStat.Value = state.rebirths
	rebirthsStat.Parent = leaderstats

	pushState(player, state)
end)

Players.PlayerRemoving:Connect(function(player)
	saveState(player)
	playerStates[player.UserId] = nil
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		saveState(player)
	end
	if RunService:IsStudio() then
		task.wait(1)
	else
		task.wait(3)
	end
end)

-- Periodic autosave so a crash doesn't lose much progress.
task.spawn(function()
	while true do
		task.wait(60)
		for _, player in ipairs(Players:GetPlayers()) do
			saveState(player)
		end
	end
end)

TapEvent.OnServerEvent:Connect(function(player)
	local state = playerStates[player.UserId]
	if not state then
		return
	end
	local now = os.clock()
	if now - state.lastTapAt < Config.TapCooldownSeconds then
		return -- silently drop taps that are faster than humanly possible
	end
	state.lastTapAt = now

	local reward = coinsPerTap(state)
	if ownsGamePass(player, Config.GamePassIds.DoubleCoins) then
		reward *= 2
	end

	state.coins += reward
	state.totalCoinsEarned += reward
	pushState(player, state)
end)

BuyUpgradeEvent.OnServerEvent:Connect(function(player, upgradeId)
	local state = playerStates[player.UserId]
	local upgrade = getUpgrade(upgradeId)
	if not state or not upgrade then
		return
	end
	local level = state.upgradeLevels[upgrade.id] or 0
	local cost = upgradeCost(upgrade, level)
	if state.coins < cost then
		return
	end
	state.coins -= cost
	state.upgradeLevels[upgrade.id] = level + 1
	pushState(player, state)
end)

RebirthEvent.OnServerEvent:Connect(function(player)
	local state = playerStates[player.UserId]
	if not state then
		return
	end
	local requirement = rebirthRequirement(state)
	if state.coins < requirement then
		return
	end
	state.coins = 0
	state.upgradeLevels = {}
	state.rebirths += 1
	pushState(player, state)
end)

GetStateFunction.OnServerInvoke = function(player)
	local state = playerStates[player.UserId]
	if not state then
		return nil
	end
	return {
		coins = state.coins,
		rebirths = state.rebirths,
		upgradeLevels = state.upgradeLevels,
		coinsPerTap = coinsPerTap(state),
		rebirthRequirement = rebirthRequirement(state),
		upgrades = Config.Upgrades,
	}
end

PromptGamePassEvent.OnServerEvent:Connect(function(player, passKey)
	local passId = Config.GamePassIds[passKey]
	if passId and passId ~= 0 then
		MarketplaceService:PromptGamePassPurchase(player, passId)
	end
end)

-- Auto-tapper gamepass: passive income tick for anyone who owns it.
task.spawn(function()
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			local state = playerStates[player.UserId]
			if state and ownsGamePass(player, Config.GamePassIds.AutoTapper) then
				local passive = math.floor(Config.AutoTapperCoinsPerSecond * (1 + state.rebirths * Config.Rebirth.multiplierPerRebirth))
				state.coins += passive
				state.totalCoinsEarned += passive
				pushState(player, state)
			end
		end
	end
end)

-- Developer products (consumable coin packs bought with Robux).
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local state = playerStates[player.UserId]
	if not state then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local coinsToGrant = Config.DeveloperProducts[receiptInfo.ProductId]
	if coinsToGrant then
		state.coins += coinsToGrant
		state.totalCoinsEarned += coinsToGrant
		pushState(player, state)
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end
