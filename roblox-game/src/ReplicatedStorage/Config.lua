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

-- Free (no real money involved) engagement rewards. The wheel is a random
-- pick, but it's paid for with playtime, not Robux -- that's the line that
-- keeps this from being a gambling mechanic instead of a loyalty bonus.
Config.SessionWheel = {
	requiredMinutes = 15, -- connected+playing time today before a spin unlocks
	rewards = {
		{ label = "$200 Cash", kind = "cash", amount = 200, weight = 40 },
		{ label = "$500 Cash", kind = "cash", amount = 500, weight = 25 },
		{ label = "$1,500 Cash", kind = "cash", amount = 1500, weight = 15 },
		{ label = "10 Gems", kind = "gems", amount = 10, weight = 12 },
		{ label = "50 Gems", kind = "gems", amount = 50, weight = 6 },
		{ label = "$10,000 JACKPOT", kind = "cash", amount = 10000, weight = 2 },
	},
}

-- Daily login calendar. Logging in on consecutive UTC days advances the
-- streak; missing a day resets it to 1. The reward cycles through this list
-- (day 8 = this list's day 1 again, etc.) so the streak counter can climb
-- forever while the rewards stay a fixed weekly loop.
Config.DailyRewards = {
	{ day = 1, kind = "cash", amount = 500, label = "$500" },
	{ day = 2, kind = "gems", amount = 5, label = "5 Gems" },
	{ day = 3, kind = "cash", amount = 1500, label = "$1,500" },
	{ day = 4, kind = "gems", amount = 10, label = "10 Gems" },
	{ day = 5, kind = "cash", amount = 4000, label = "$4,000" },
	{ day = 6, kind = "gems", amount = 20, label = "20 Gems" },
	{ day = 7, kind = "cash", amount = 15000, label = "$15,000 Weekly Bonus" },
}

-- Gems (earned only from the wheel/daily calendar above, never sold for
-- Robux) can be spent on shields -- gives the login/playtime loop a use
-- that feeds back into the steal mechanic.
Config.GemShop = {
	shield1Hour = { gems = 5, seconds = 3600, label = "1-Hour Shield" },
	shield24Hour = { gems = 30, seconds = 86400, label = "24-Hour Shield" },
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
