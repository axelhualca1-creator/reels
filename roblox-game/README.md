# Sigma Grind Simulator

A collector-tycoon Roblox game with a steal-from-other-players twist — the
same core format as "Steal a Brainrot", currently the biggest genre on the
platform (25M+ concurrent players at its peak). Each player gets a plot,
buys units that generate cash per second, must physically visit their own
vault to collect the accumulated bank, and can raid other players' vaults
if they're not shielded. Original units/theme only — no copied characters
or trademarks.

Nothing here includes gacha/loot-box mechanics (randomized rewards for real
money) — those are increasingly regulated as gambling and Roblox's audience
is largely minors. Every Robux purchase in this game is a fixed-price,
clearly-labeled item (game pass or coin/shield pack), same as any
legitimate simulator/tycoon on the platform.

## How you (the developer) actually get paid

Two separate revenue streams, both real, both already wired up in this
project:

1. **Direct purchases** — game passes (VIP, Extra Vault, Auto-Collect) and
   developer products (cash packs, timed shields) that players buy with
   Robux. Roblox takes its cut (~30%), you keep the rest in Robux.
2. **Roblox Creator Rewards** (replaced the old Engagement-Based Payouts
   program in July 2025) — Roblox pays you Robux **just for players
   spending time in your game**, no purchase required: currently a flat 5
   Robux per "Active Spender" per day, plus a 35% revenue share, when your
   game is one of the first 3 experiences that player visits for 10+
   minutes that day. ("Active Spender" = anyone who spent $9.99+ anywhere
   on Roblox in the last 60 days.) This is why session length and daily
   retention matter as much as in-game purchases — the steal mechanic
   exists specifically to keep players coming back to check on their base.

Robux from either stream converts to real cash through **Developer
Exchange (DevEx)** once you meet Roblox's eligibility requirements (13+,
identity verification, Premium membership, and a minimum Robux balance —
check [Roblox's current DevEx page](https://create.roblox.com/docs) since
the threshold has changed over time).

## Structure (Rojo project)

```
roblox-game/
  default.project.json
  src/
    ReplicatedStorage/Config.lua        -- all game balance in one file
    ServerScriptService/Main.server.lua -- plots, units, steal, rebirth, purchases
    StarterPlayer/StarterPlayerScripts/ClientMain.client.lua -- shop/rebirth/monetization UI
```

The playable world (plots, vaults, unit models) is built entirely by
`Main.server.lua` at runtime — there are no binary Studio files to keep in
sync in git.

## Running it in Roblox Studio

1. Install [Rojo](https://rojo.space/) (`rojo` CLI) and the Rojo Studio plugin.
2. From `roblox-game/`, run:
   ```
   rojo serve
   ```
3. In Roblox Studio, open the Rojo plugin panel and click **Connect**.
4. Press Play (use "Play Here" with a couple of test accounts, or Studio's
   multi-player test tool, to see the steal mechanic work between two
   plots). Everything works immediately — game passes/dev products safely
   no-op until you wire up real asset IDs.

## Turning on real monetization

1. Publish the place to Roblox (File > Publish to Roblox).
2. In the [Creator Dashboard](https://create.roblox.com/dashboard/creations),
   go to **Monetization**:
   - Create Game Passes: VIP, Extra Vault, Auto-Collect (or your own names).
   - Create Developer Products: cash packs and/or timed shields.
3. Copy the IDs into `src/ReplicatedStorage/Config.lua`:
   - `Config.GamePassIds.VIP` / `.ExtraVault` / `.AutoCollect`
   - `Config.DeveloperProducts[<productId>] = { kind = "cash", amount = ... }`
     or `{ kind = "shield", seconds = ... }`
4. Re-sync/republish.

## Tuning the economy

Everything lives in `Config.lua`: unit costs/production (`Config.Units`),
how fast the bank fills and caps out (`Config.Bank`), how punishing steals
are (`Config.Steal.stealPercent`, cooldowns, grace shield), and the rebirth
curve (`Config.Rebirth`). Raising `stealPercent` or lowering the grace
shield makes the game more PvP-aggressive (more session time, more shield
purchases); lowering it makes it more relaxed/idle-friendly.

## What actually drives revenue on games like this

- **Session length and daily return rate** matter more than anything in
  the code — that's literally what Roblox pays you for now via Creator
  Rewards, independent of purchases.
- A thumbnail/icon and name that reads instantly on a phone screen.
- Off-platform traffic (TikTok/Shorts clips of a base getting raided) —
  Roblox's own discovery algorithm favors games that already have
  concurrent players, so early traction has to come from somewhere else.
- Iterating shield/steal pacing based on real player retention data
  (Roblox Analytics), not guessing once and walking away.

Happy to keep iterating — more unit tiers, a trading system, leaderboards,
referral rewards, a proper base-building layout — once this is live and
you can see what players actually do with it.
