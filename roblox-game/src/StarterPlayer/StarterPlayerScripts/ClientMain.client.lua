-- Builds the entire UI in code (no binary Studio files to keep in git) and
-- talks to the server through the Remotes it creates in Main.server.lua.
-- Collecting your bank and stealing from others happens by walking up to a
-- Vault in the world (ProximityPrompt, server-authoritative) -- this UI only
-- covers the shop, rebirth, and monetization buttons.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyUnitEvent = Remotes:WaitForChild("BuyUnit")
local RebirthEvent = Remotes:WaitForChild("Rebirth")
local StateChangedEvent = Remotes:WaitForChild("StateChanged")
local GetStateFunction = Remotes:WaitForChild("GetState")
local PromptGamePassEvent = Remotes:WaitForChild("PromptGamePass")
local SpinWheelEvent = Remotes:WaitForChild("SpinWheel")
local ClaimDailyRewardEvent = Remotes:WaitForChild("ClaimDailyReward")
local BuyGemItemEvent = Remotes:WaitForChild("BuyGemItem")

local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local function formatNumber(n)
	return string.format("%d", math.floor(n or 0))
end

-- ===== Top bar: cash / bank / shield =====
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 70)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
topBar.BorderSizePixel = 0
topBar.Parent = screenGui

local cashLabel = Instance.new("TextLabel")
cashLabel.Size = UDim2.new(0.4, 0, 0.5, 0)
cashLabel.Position = UDim2.new(0, 10, 0, 0)
cashLabel.BackgroundTransparency = 1
cashLabel.TextXAlignment = Enum.TextXAlignment.Left
cashLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
cashLabel.Font = Enum.Font.GothamBold
cashLabel.TextScaled = true
cashLabel.Text = "$0 cash"
cashLabel.Parent = topBar

local bankLabel = Instance.new("TextLabel")
bankLabel.Size = UDim2.new(0.4, 0, 0.5, 0)
bankLabel.Position = UDim2.new(0, 10, 0.5, 0)
bankLabel.BackgroundTransparency = 1
bankLabel.TextXAlignment = Enum.TextXAlignment.Left
bankLabel.TextColor3 = Color3.fromRGB(150, 220, 255)
bankLabel.Font = Enum.Font.Gotham
bankLabel.TextScaled = true
bankLabel.Text = "Vault: 0 / 0 (walk to your Vault to collect)"
bankLabel.Parent = topBar

local shieldLabel = Instance.new("TextLabel")
shieldLabel.Size = UDim2.new(0.3, 0, 1, 0)
shieldLabel.Position = UDim2.new(0.4, 0, 0, 0)
shieldLabel.BackgroundTransparency = 1
shieldLabel.TextColor3 = Color3.fromRGB(120, 255, 150)
shieldLabel.Font = Enum.Font.GothamBold
shieldLabel.TextScaled = true
shieldLabel.Text = ""
shieldLabel.Parent = topBar

local rebirthButton = Instance.new("TextButton")
rebirthButton.Size = UDim2.new(0.28, 0, 0.8, 0)
rebirthButton.Position = UDim2.new(0.71, 0, 0.1, 0)
rebirthButton.BackgroundColor3 = Color3.fromRGB(160, 40, 200)
rebirthButton.Font = Enum.Font.GothamBold
rebirthButton.TextScaled = true
rebirthButton.TextColor3 = Color3.new(1, 1, 1)
rebirthButton.Text = "REBIRTH"
rebirthButton.Parent = topBar

-- Free spin button: only visible once 15 minutes of playtime today is
-- banked (state.wheelEligible). The prize is decided server-side; this is
-- just the reveal animation for a reward already rolled with math.random
-- on the server, paid for with time rather than money.
local wheelButton = Instance.new("TextButton")
wheelButton.Size = UDim2.new(0, 220, 0, 50)
wheelButton.AnchorPoint = Vector2.new(0.5, 0)
-- Fixed pixel offset (not a screen-height fraction), stacked directly above
-- the daily calendar strip -- see the matching offsets on dailyFrame,
-- shopFrame and passFrame below, all laid out in this same column.
wheelButton.Position = UDim2.new(0.5, 0, 0, 76)
wheelButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
wheelButton.Font = Enum.Font.GothamBold
wheelButton.TextScaled = true
wheelButton.TextColor3 = Color3.new(1, 1, 1)
wheelButton.Text = "🎡 FREE SPIN!"
wheelButton.Visible = false
wheelButton.Parent = screenGui

-- ===== Toast for steal notifications =====
local toastLabel = Instance.new("TextLabel")
toastLabel.Size = UDim2.new(0, 400, 0, 40)
toastLabel.AnchorPoint = Vector2.new(0.5, 0)
toastLabel.Position = UDim2.new(0.5, 0, 0.12, 0)
toastLabel.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
toastLabel.TextColor3 = Color3.new(1, 1, 1)
toastLabel.Font = Enum.Font.GothamBold
toastLabel.TextScaled = true
toastLabel.Visible = false
toastLabel.Parent = screenGui

local function showToast(text)
	toastLabel.Text = text
	toastLabel.Visible = true
	task.delay(3, function()
		toastLabel.Visible = false
	end)
end

-- ===== Daily login calendar =====
local dailyFrame = Instance.new("Frame")
dailyFrame.Size = UDim2.new(0, 470, 0, 80)
dailyFrame.AnchorPoint = Vector2.new(0.5, 0)
dailyFrame.Position = UDim2.new(0.5, 0, 0, 132) -- leaves room for wheelButton above it
dailyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
dailyFrame.BackgroundTransparency = 0.1
dailyFrame.Parent = screenGui

local dailyLayout = Instance.new("UIListLayout")
dailyLayout.FillDirection = Enum.FillDirection.Horizontal
dailyLayout.Padding = UDim.new(0, 4)
dailyLayout.VerticalAlignment = Enum.VerticalAlignment.Center
dailyLayout.Parent = dailyFrame

local dailyCells = {}
for order, reward in ipairs(Config.DailyRewards) do
	local cell = Instance.new("Frame")
	cell.Size = UDim2.new(0, 50, 0, 60)
	cell.LayoutOrder = order
	cell.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
	cell.Parent = dailyFrame

	local dayLabel = Instance.new("TextLabel")
	dayLabel.Size = UDim2.new(1, 0, 0.4, 0)
	dayLabel.BackgroundTransparency = 1
	dayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	dayLabel.Font = Enum.Font.Gotham
	dayLabel.TextScaled = true
	dayLabel.Text = "Day " .. reward.day
	dayLabel.Parent = cell

	local rewardLabel = Instance.new("TextLabel")
	rewardLabel.Size = UDim2.new(1, 0, 0.6, 0)
	rewardLabel.Position = UDim2.new(0, 0, 0.4, 0)
	rewardLabel.BackgroundTransparency = 1
	rewardLabel.TextColor3 = Color3.new(1, 1, 1)
	rewardLabel.Font = Enum.Font.GothamBold
	rewardLabel.TextScaled = true
	rewardLabel.Text = reward.label
	rewardLabel.Parent = cell

	dailyCells[order] = cell
end

local claimDailyButton = Instance.new("TextButton")
claimDailyButton.Size = UDim2.new(0, 90, 0, 60)
claimDailyButton.LayoutOrder = 99
claimDailyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 90)
claimDailyButton.Font = Enum.Font.GothamBold
claimDailyButton.TextScaled = true
claimDailyButton.TextColor3 = Color3.new(1, 1, 1)
claimDailyButton.Text = "Claim"
claimDailyButton.Parent = dailyFrame

claimDailyButton.MouseButton1Click:Connect(function()
	ClaimDailyRewardEvent:FireServer()
end)

-- ===== Shop panel =====
local shopFrame = Instance.new("ScrollingFrame")
shopFrame.Size = UDim2.new(0, 280, 1, -302)
shopFrame.Position = UDim2.new(1, -290, 0, 222)
shopFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
shopFrame.BorderSizePixel = 0
shopFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
shopFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
shopFrame.ScrollBarThickness = 6
shopFrame.Parent = screenGui

local shopLayout = Instance.new("UIListLayout")
shopLayout.Padding = UDim.new(0, 6)
shopLayout.Parent = shopFrame

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, -10, 0, 30)
shopTitle.BackgroundTransparency = 1
shopTitle.TextColor3 = Color3.new(1, 1, 1)
shopTitle.Font = Enum.Font.GothamBold
shopTitle.TextScaled = true
shopTitle.Text = "Units Shop"
shopTitle.LayoutOrder = 0
shopTitle.Parent = shopFrame

local unitRows = {}

for order, unit in ipairs(Config.Units) do
	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, -10, 0, 56)
	row.LayoutOrder = order
	row.BackgroundColor3 = unit.color
	row.AutoButtonColor = true
	row.Font = Enum.Font.GothamBold
	row.TextColor3 = Color3.new(1, 1, 1)
	row.TextScaled = true
	row.Text = unit.name
	row.Parent = shopFrame

	row.MouseButton1Click:Connect(function()
		BuyUnitEvent:FireServer(unit.id)
	end)

	unitRows[unit.id] = { row = row, unit = unit }
end

-- ===== Monetization panel =====
local passFrame = Instance.new("Frame")
passFrame.Size = UDim2.new(0, 220, 0, 270)
passFrame.Position = UDim2.new(0, 10, 1, -280)
passFrame.BackgroundTransparency = 1
passFrame.Parent = screenGui

local passLayout = Instance.new("UIListLayout")
passLayout.Padding = UDim.new(0, 6)
passLayout.Parent = passFrame

local function makePassButton(text, passKey)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.BackgroundColor3 = Color3.fromRGB(0, 170, 90)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = text
	btn.Parent = passFrame
	btn.MouseButton1Click:Connect(function()
		PromptGamePassEvent:FireServer(passKey)
	end)
end

makePassButton("VIP (+50% income)", "VIP")
makePassButton("Extra Vault Space", "ExtraVault")
makePassButton("Auto-Collect", "AutoCollect")

for productId in pairs(Config.DeveloperProducts) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = "Buy Product #" .. tostring(productId)
	btn.Parent = passFrame
	btn.MouseButton1Click:Connect(function()
		MarketplaceService:PromptProductPurchase(player, productId)
	end)
end

-- Gem shop: spends gems earned from the wheel/daily calendar, never Robux.
local function makeGemButton(itemKey, item)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.BackgroundColor3 = Color3.fromRGB(160, 90, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = item.label .. " (💎" .. item.gems .. ")"
	btn.Parent = passFrame
	btn.MouseButton1Click:Connect(function()
		BuyGemItemEvent:FireServer(itemKey)
	end)
end

for itemKey, item in pairs(Config.GemShop) do
	makeGemButton(itemKey, item)
end

-- ===== Hint text =====
local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(0, 500, 0, 30)
hint.AnchorPoint = Vector2.new(0.5, 1)
hint.Position = UDim2.new(0.5, 0, 1, -10)
hint.BackgroundTransparency = 1
hint.TextColor3 = Color3.new(1, 1, 1)
hint.Font = Enum.Font.Gotham
hint.TextScaled = true
hint.Text = "Walk to YOUR vault to collect. Walk to someone ELSE's vault to steal (if unshielded)."
hint.Parent = screenGui

-- ===== State sync =====
local currentShieldUntil = 0
local spinInFlight = false

local function applyState(state)
	if not state then
		return
	end
	cashLabel.Text = "$" .. formatNumber(state.cash) .. "  (" .. formatNumber(state.cashPerSecond) .. "/sec)  |  💎" .. formatNumber(state.gems)
	bankLabel.Text = "Vault: " .. formatNumber(state.bank) .. " / " .. formatNumber(state.bankCap)
	rebirthButton.Text = string.format(
		"REBIRTH\n%s / %s  [x%d]",
		formatNumber(state.cash),
		formatNumber(state.rebirthRequirement),
		state.rebirths
	)

	currentShieldUntil = state.shieldUntil or 0

	for _, entry in pairs(unitRows) do
		local owned = false
		for _, id in ipairs(state.ownedUnitIds or {}) do
			if id == entry.unit.id then
				owned = true
				break
			end
		end
		if owned then
			entry.row.Text = entry.unit.name .. " (owned, +" .. entry.unit.cashPerSecond .. "/s)"
		else
			entry.row.Text = entry.unit.name .. "\nCost: $" .. formatNumber(entry.unit.cost) .. "  (+" .. entry.unit.cashPerSecond .. "/s)"
		end
	end

	if state.lastStolenAmount and state.lastStolenAmount > 0 then
		showToast("You stole $" .. formatNumber(state.lastStolenAmount) .. "!")
	end

	-- Free 15-minute wheel
	if not spinInFlight then
		wheelButton.Visible = state.wheelEligible == true
	end
	if state.lastWheelReward then
		showToast("🎡 You won " .. state.lastWheelReward .. "!")
	end

	-- Daily login calendar
	for order, cell in ipairs(dailyCells) do
		if order == state.dailyRewardIndex then
			cell.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
		else
			cell.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
		end
	end
	if state.dailyRewardAvailable then
		claimDailyButton.Text = "Claim\nDay " .. tostring(state.loginStreak or 1)
		claimDailyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 90)
		claimDailyButton.Active = true
	else
		claimDailyButton.Text = "Claimed\n✓"
		claimDailyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
		claimDailyButton.Active = false
	end
	if state.lastDailyRewardLabel then
		showToast("📅 Daily reward: " .. state.lastDailyRewardLabel .. "!")
	end
end

task.spawn(function()
	while true do
		task.wait(1)
		local remaining = currentShieldUntil - os.time()
		if remaining > 0 then
			shieldLabel.Text = "SHIELDED " .. remaining .. "s"
		else
			shieldLabel.Text = ""
		end
	end
end)

rebirthButton.MouseButton1Click:Connect(function()
	RebirthEvent:FireServer()
end)

wheelButton.MouseButton1Click:Connect(function()
	if spinInFlight then
		return
	end
	spinInFlight = true
	SpinWheelEvent:FireServer()

	-- Purely cosmetic suspense -- the real reward was already rolled
	-- server-side; this just delays the reveal a beat so it feels like a spin.
	task.spawn(function()
		local labels = {}
		for _, reward in ipairs(Config.SessionWheel.rewards) do
			table.insert(labels, reward.label)
		end
		local endTime = os.clock() + 1.2
		while os.clock() < endTime do
			wheelButton.Text = "🎡 " .. labels[math.random(1, #labels)]
			task.wait(0.1)
		end
		wheelButton.Visible = false
		wheelButton.Text = "🎡 FREE SPIN!"
		spinInFlight = false
	end)
end)

StateChangedEvent.OnClientEvent:Connect(applyState)

local initial = GetStateFunction:InvokeServer()
applyState(initial)
