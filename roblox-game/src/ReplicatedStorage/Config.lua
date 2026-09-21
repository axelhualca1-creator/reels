-- Shared game balance/config. Tune these numbers to change the whole game's economy.
-- Genre: collector-tycoon with steal-from-other-players (the "Steal a Brainrot" /
-- tycoon-meets-PVP format that's currently the biggest thing on Roblox). Original
-- units/names only -- no copied characters or trademarks.
local Config = {}

Config.Plot = {
	count = 20, -- how many plots exist on the server (= max players per server)
	spacing = 44, -- studs between plot centers, keep >= size + gap
	size = 36, -- plot footprint (studs, square)
	maxUnitSlots = 8, -- how many units fit on a plot before buying more slots
}

-- Units generate cash per second just by sitting on your plot. Rarity only
-- affects color/label; the numbers are what actually matter.
Config.Units = {
	{ id = "tapling", name = "Tapling", rarity = "Common", cost = 0, cashPerSecond = 1, color = Color3.fromRGB(150, 150, 150) },
	{ id = "grindler", name = "Grindler", rarity = "Common", cost = 50, cashPerSecond = 3, color = Color3.fromRGB(120, 200, 120) },
	{ id = "auraboi", name = "Auraboi", rarity = "Rare", cost = 400, cashPerSecond = 15, color = Color3.fromRGB(80, 140, 255) },
	{ id = "gyatling", name = "Gyatling", rarity = "Rare", cost = 2200, cashPerSecond = 70, color = Color3.fromRGB(160, 90, 255) },
	{ id = "rizzler", name = "Rizzler Prime", rarity = "Epic", cost = 12000, cashPerSecond = 350, color = Color3.fromRGB(255, 140, 30) },
	{ id = "sigmax", name = "Sigmax Colossus", rarity = "Legendary", cost = 60000, cashPerSecond = 1600, color = Color3.fromRGB(255, 215, 0) },
}

-- Bank fills up passively from your units; you must physically visit your
-- vault to "collect" it into spendable cash. Until collected, other players
-- can steal from your bank if you're not shielded.
Config.Bank = {
	baseCap = 2000, -- starting max bank size before it stops filling
	capPerSlotUpgrade = 1500, -- extra cap granted by the ExtraVault gamepass
}

Config.Steal = {
	stealPercent = 0.5, -- fraction of the victim's bank the thief takes
	graceShieldSeconds = 45, -- free shield granted to a just-robbed player
	sameTargetCooldownSeconds = 20, -- can't rob the same victim again this often
	promptHoldDuration = 1.5,
}

-- Rebirthing resets spendable cash (not your owned units) for a permanent
-- income multiplier -- a prestige layer on top of the collector loop.
Config.Rebirth = {
	baseRequirement = 50000,
	requirementGrowth = 2.2,
	multiplierPerRebirth = 0.4, -- +40% cash-per-second per rebirth, stacking
}

-- Fill these in from the Roblox Creator Dashboard after you publish
-- (Monetization > Passes / Developer Products). Left at 0 they safely no-op.
Config.GamePassIds = {
	VIP = 0, -- +50% cash-per-second, cosmetic aura
	ExtraVault = 0, -- bigger bank cap, less need to babysit collecting
	AutoCollect = 0, -- bank auto-collects into cash every tick, no vault trips needed
}

-- Deterministic Robux purchases -- no randomized/gacha rewards for real money.
-- id -> effect handled in Main.server.lua's ProcessReceipt.
Config.DeveloperProducts = {
	-- [111111111] = { kind = "cash", amount = 5000 },
	-- [111111112] = { kind = "cash", amount = 30000 },
	-- [111111113] = { kind = "shield", seconds = 3600 },
	-- [111111114] = { kind = "shield", seconds = 86400 },
}

return Config
