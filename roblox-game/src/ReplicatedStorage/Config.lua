-- Shared game balance/config. Tune these numbers to change the whole game's economy.
local Config = {}

Config.StartingCoinsPerTap = 1
Config.TapCooldownSeconds = 0.12 -- server-side anti-spam; real taps aren't faster than this

-- Each upgrade adds flat coins-per-tap. Cost grows exponentially per level.
Config.Upgrades = {
	{ id = "grip", name = "Grip Strength", baseCost = 25, costGrowth = 1.16, tapAdd = 1 },
	{ id = "focus", name = "Sigma Focus", baseCost = 150, costGrowth = 1.17, tapAdd = 5 },
	{ id = "aura", name = "Aura Farm", baseCost = 900, costGrowth = 1.18, tapAdd = 25 },
	{ id = "gyat", name = "GYAT Multiplier", baseCost = 6000, costGrowth = 1.19, tapAdd = 120 },
	{ id = "rizz", name = "Unspoken Rizz", baseCost = 40000, costGrowth = 1.2, tapAdd = 600 },
}

-- Rebirthing resets coins + upgrades but grants a permanent multiplier.
Config.Rebirth = {
	baseRequirement = 100000, -- coins needed for first rebirth
	requirementGrowth = 2.5, -- each rebirth needs this much more than the last
	multiplierPerRebirth = 0.5, -- +50% coins per tap per rebirth, stacking
}

-- Fill these in from the Roblox Creator Dashboard after you publish the game
-- (Monetization > Passes / Developer Products). Until you set real IDs,
-- the purchase prompts will safely no-op instead of erroring.
Config.GamePassIds = {
	DoubleCoins = 0, -- e.g. 123456789
	AutoTapper = 0,
	VIP = 0,
}

-- id -> how many coins that developer product grants
Config.DeveloperProducts = {
	-- [987654321] = 5000,
	-- [987654322] = 30000,
}

Config.AutoTapperCoinsPerSecond = 10 -- scales with player's own tap value below

return Config
