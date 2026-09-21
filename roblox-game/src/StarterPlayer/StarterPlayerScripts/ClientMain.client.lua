-- Builds the entire UI in code (no binary Studio files to keep in git) and
-- talks to the server through the Remotes it creates in Main.server.lua.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TapEvent = Remotes:WaitForChild("Tap")
local BuyUpgradeEvent = Remotes:WaitForChild("BuyUpgrade")
local RebirthEvent = Remotes:WaitForChild("Rebirth")
local StateChangedEvent = Remotes:WaitForChild("StateChanged")
local GetStateFunction = Remotes:WaitForChild("GetState")
local PromptGamePassEvent = Remotes:WaitForChild("PromptGamePass")

local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ===== Top bar: coins + rebirth =====
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 60)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
topBar.BorderSizePixel = 0
topBar.Parent = screenGui

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Size = UDim2.new(0.5, 0, 1, 0)
coinsLabel.BackgroundTransparency = 1
coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinsLabel.Font = Enum.Font.GothamBold
coinsLabel.TextScaled = true
coinsLabel.Text = "0 coins"
coinsLabel.Parent = topBar

local rebirthButton = Instance.new("TextButton")
rebirthButton.Size = UDim2.new(0.3, 0, 0.8, 0)
rebirthButton.Position = UDim2.new(0.68, 0, 0.1, 0)
rebirthButton.BackgroundColor3 = Color3.fromRGB(160, 40, 200)
rebirthButton.Font = Enum.Font.GothamBold
rebirthButton.TextScaled = true
rebirthButton.TextColor3 = Color3.new(1, 1, 1)
rebirthButton.Text = "REBIRTH (0 / 100000)"
rebirthButton.Parent = topBar

-- ===== Center tap button =====
local tapButton = Instance.new("TextButton")
tapButton.Size = UDim2.new(0, 220, 0, 220)
tapButton.AnchorPoint = Vector2.new(0.5, 0.5)
tapButton.Position = UDim2.new(0.5, 0, 0.55, 0)
tapButton.BackgroundColor3 = Color3.fromRGB(230, 60, 60)
tapButton.Font = Enum.Font.GothamBold
tapButton.TextScaled = true
tapButton.TextColor3 = Color3.new(1, 1, 1)
tapButton.Text = "TAP\n+1/tap"
local tapCorner = Instance.new("UICorner")
tapCorner.CornerRadius = UDim.new(1, 0)
tapCorner.Parent = tapButton
tapButton.Parent = screenGui

local function punchTap()
	tapButton.Size = UDim2.new(0, 200, 0, 200)
	TweenService:Create(tapButton, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 220, 0, 220),
	}):Play()
end

tapButton.MouseButton1Click:Connect(function()
	TapEvent:FireServer()
	punchTap()
end)

-- ===== Shop panel =====
local shopFrame = Instance.new("ScrollingFrame")
shopFrame.Size = UDim2.new(0, 260, 1, -140)
shopFrame.Position = UDim2.new(1, -270, 0, 70)
shopFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
shopFrame.BorderSizePixel = 0
shopFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
shopFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
shopFrame.ScrollBarThickness = 6
shopFrame.Parent = screenGui

local shopLayout = Instance.new("UIListLayout")
shopLayout.Padding = UDim.new(0, 6)
shopLayout.Parent = shopFrame

local upgradeRows = {}

for _, upgrade in ipairs(Config.Upgrades) do
	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, -10, 0, 56)
	row.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	row.AutoButtonColor = true
	row.Font = Enum.Font.Gotham
	row.TextColor3 = Color3.new(1, 1, 1)
	row.TextScaled = true
	row.Text = upgrade.name
	row.Parent = shopFrame

	row.MouseButton1Click:Connect(function()
		BuyUpgradeEvent:FireServer(upgrade.id)
	end)

	upgradeRows[upgrade.id] = row
end

-- ===== Monetization panel =====
local passFrame = Instance.new("Frame")
passFrame.Size = UDim2.new(0, 200, 0, 100)
passFrame.Position = UDim2.new(0, 10, 1, -110)
passFrame.BackgroundTransparency = 1
passFrame.Parent = screenGui

local passLayout = Instance.new("UIListLayout")
passLayout.Padding = UDim.new(0, 6)
passLayout.Parent = passFrame

local function makePassButton(text, passKey)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 40)
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

makePassButton("2x Coins", "DoubleCoins")
makePassButton("Auto Tapper", "AutoTapper")
makePassButton("VIP", "VIP")

-- ===== State sync =====
local function formatNumber(n)
	return string.format("%d", math.floor(n))
end

local function applyState(state)
	if not state then
		return
	end
	coinsLabel.Text = formatNumber(state.coins) .. " coins  (" .. formatNumber(state.coinsPerTap) .. "/tap)"
	tapButton.Text = "TAP\n+" .. formatNumber(state.coinsPerTap) .. "/tap"
	rebirthButton.Text = string.format(
		"REBIRTH (%s / %s)  [x%d]",
		formatNumber(state.coins),
		formatNumber(state.rebirthRequirement),
		state.rebirths
	)

	for _, upgrade in ipairs(Config.Upgrades) do
		local row = upgradeRows[upgrade.id]
		local level = (state.upgradeLevels and state.upgradeLevels[upgrade.id]) or 0
		local cost = math.floor(upgrade.baseCost * (upgrade.costGrowth ^ level))
		row.Text = string.format("%s (Lv %d)\nCost: %s", upgrade.name, level, formatNumber(cost))
	end
end

rebirthButton.MouseButton1Click:Connect(function()
	RebirthEvent:FireServer()
end)

StateChangedEvent.OnClientEvent:Connect(applyState)

local initial = GetStateFunction:InvokeServer()
applyState(initial)
