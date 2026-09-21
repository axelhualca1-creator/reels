# Sigma Grind Simulator

A deliberately simple, low-art "tapper/simulator" Roblox game: tap to earn
coins, buy upgrades, rebirth for a permanent multiplier, repeat. This genre
(tappers, simulators, tycoons) is the standard low-budget Roblox format —
it's quick to build and can monetize, but it succeeds or fails almost
entirely on discovery (ads, being featured, going viral on TikTok/YouTube
Shorts), not on code. Nothing here can guarantee income; it gives you a
real, working game to launch, iterate on, and market.

What this intentionally does **not** include: gacha/loot-box mechanics
(randomized rewards for real money), fake countdown timers, or other
manipulative dark patterns. Those are increasingly regulated as gambling
in several countries and Roblox's own audience is largely minors — not
worth the legal/reputational risk. Everything monetizable here is a
fixed-price, clearly-labeled purchase (game pass or coin pack), same as
any legitimate simulator game on the platform.

## Structure (Rojo project)

```
roblox-game/
  default.project.json
  src/
    ReplicatedStorage/Config.lua        -- all game balance in one file
    ServerScriptService/Main.server.lua -- currency, upgrades, rebirths, purchases
    StarterPlayer/StarterPlayerScripts/ClientMain.client.lua -- UI, built in code
```

## Running it in Roblox Studio

1. Install [Rojo](https://rojo.space/) (`rojo` CLI) and the Rojo Studio plugin.
2. From `roblox-game/`, run:
   ```
   rojo serve
   ```
3. In Roblox Studio, open the Rojo plugin panel and click **Connect**.
   Your whole game tree syncs in.
4. Press Play to test. Tapping, upgrades, and rebirth all work immediately
   with no setup — game passes/dev products safely no-op until you wire
   up real asset IDs (next section).

## Turning on real monetization

1. Publish the place to Roblox (File > Publish to Roblox, or via
   `rojo build -o game.rbxlx` and upload it).
2. In the [Creator Dashboard](https://create.roblox.com/dashboard/creations)
   for your game, go to **Monetization**:
   - Create Game Passes: "2x Coins", "Auto Tapper", "VIP" (or whatever you
     want — these are just examples).
   - Create Developer Products: one or more coin packs (e.g. 5,000 coins
     for a small Robux price, 30,000 for a bigger one).
3. Copy the numeric IDs it gives you into `src/ReplicatedStorage/Config.lua`:
   - `Config.GamePassIds.DoubleCoins`, `.AutoTapper`, `.VIP`
   - `Config.DeveloperProducts[<productId>] = <coinsGranted>`
4. Re-sync/republish. Purchases now actually grant the pass/coins and
   Roblox takes its standard revenue cut automatically — no extra billing
   code needed.

## Tuning the economy

Everything that affects how fast players progress (and how tempting it is
to spend Robux to skip the grind) lives in `Config.lua`:
`StartingCoinsPerTap`, each upgrade's `baseCost`/`costGrowth`/`tapAdd`, and
the rebirth requirement curve. Raise `costGrowth` to make grinding slower
(more pressure to buy passes); lower it to keep it free-friendly. This is
the actual lever for revenue — not the art, which is intentionally minimal.

## What actually drives revenue on games like this

The game mechanics above are table stakes, not the differentiator. What
tends to matter more in practice:
- A thumbnail/icon and game name that reads instantly on a phone screen.
- The first 10 seconds of gameplay (a new player must understand and enjoy
  tapping before you ask for anything).
- Off-platform traffic: short-form video (TikTok/Shorts/Reels) showing
  the game, since Roblox's own discovery algorithm favors games that
  already have concurrent players.
- Iterating the shop/rebirth pacing based on real player retention data
  (Roblox Analytics tab), not guessing once and walking away.

None of that can be scripted for you in one shot — it's ongoing product
work. Happy to keep iterating on specific pieces (new upgrade tiers, a
codes/rewards system, a UI redesign, leaderboard, referral rewards, etc.)
once you've got this running and see what players actually do with it.
