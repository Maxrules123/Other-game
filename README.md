# Download and play on your PC

1. On this GitHub page, click the green **Code** button, then **Download ZIP**.
2. Right-click the downloaded ZIP and choose **Extract All**.
3. Open **CreditCardStealer.rbxl** from the extracted folder in Roblox Studio.
4. Press **Play**. The city is built when the server starts.

The source project is at the root of this repository. For Rojo, open this extracted folder in VS Code and run `rojo serve default.project.json` using your installed Rojo executable. The original self-contained delivery is also included as **CreditCardStealer.zip**.

Studio uses temporary test profiles by default. Published servers use production saving. Gameplay still needs Studio validation; audio assets have not been configured. All 17 Luau files compile, 107 mocked domain assertions pass, and Rojo builds successfully.

---

# Credit Card Stealer Simulator — Card City

A fictional, low-poly Roblox arcade simulator implemented in Luau. All banks, cards, and currency are invented. No payment details or real theft methods are involved.

Start with **START-HERE.md** for new-PC instructions and **TESTING.md** for release checks.

## Implemented

- A connected five-district city with primitive-built storefronts, office towers, estates, lighting, streets, props, hideouts, 30 walking/pausing targets, and ten guards.
- A server-owned, single-sweep timing interaction. Target reservations, reach/line-of-sight checks, capacity checks, cooldowns, server-received input scoring, and request rate limits prevent duplicate claims and client-selected rewards.
- Per-player Heat and suspicion, target cooldowns/reactions, guard patrol, field of view, unobstructed sight, chase/search behavior, bounded pathfinding, escape events, safe-zone recovery, capture penalties, and immunity windows.
- Separate carried loot and permanent collection. 22 obtainable designs, six rarity labels, four variants with multipliers, brief skippable reveals, silhouettes, and automatic milestone rewards.
- Six capped upgrade tracks, Cash purchases, Reputation-gated district access, a guided seven-job starter chain, and three rotating daily missions at 00:00 UTC. Daily claims are idempotent.
- A separate-room Vault Run with five pulsing obstacles, ordered traversal checks, a collectible vault card, timer, exit, failure, early leave, room cleanup, replay cooldown, and server-awarded rewards.
- New Identity with a short-lived confirmation token, explicit reset/keep explanation, prerequisite checks, permanent capped bank multiplier, and in-game identity badges. These badges are profile cosmetics, not Roblox platform BadgeService awards.
- A responsive programmatic HUD and menus, keyboard/touch/gamepad input, card reveals, currency color feedback, particles, brief optional camera feedback, reduced motion, volume settings, and a scrollable prestige explanation.
- Versioned profiles with defaults, UpdateAsync leases and ownership checks, bounded retries, autosaves, shutdown saves, safe load rejection, and a separate nonpersistent Studio development mode.

## Architecture

```
src/shared/Config.luau          Economy, difficulty, catalog, districts, audio slots
src/shared/Rules.luau           Pure timing, cost, inventory, value, and daily rules
src/shared/Types.luau           Profile, settings, and loot types
src/server/PlayerDataService    Profiles, leases, saving, failure handling
src/server/WorldService         Runtime city and interaction kiosks
src/server/NPCService           Targets, reservations/state presentation, actor geometry
src/server/InventoryService     Loot generation, value, permanent discoveries
src/server/MissionService       Starter progression, daily rotation, reward claims
src/server/SecurityService      Patrol, perception, pursuit, bounded pathfinding
src/server/VaultService         Private-room arcade runs and cleanup
src/server/GameService          Server transactions, Heat, upgrades, unlocks, prestige
src/client/UIController         HUD, reusable controls, panels, timing, reveals, dialogs
src/client/InputController      Proximity prompts and keyboard/gamepad actions
src/client/AudioController      Central configurable audio and volumes
src/client/EffectsController    Tweens, particles, optional camera feedback
```

The suggested smaller services for Heat, upgrades, districts, economy, and interaction are kept as focused methods in GameService to avoid unnecessary wiring. Both entry scripts are `init` files; Rojo places their controllers/services beneath the entry script.

## Adjust the game

Edit `src/shared/Config.luau` for card values and weights, variant multipliers, inventory limits, upgrade prices/caps, timing speed/windows, suspicion rates, Heat thresholds, capture loss, district requirements, guard speed/range, mission rewards, prestige prerequisites/bonus, Vault Run reward/time, and audio IDs. World layout and primitive styling are in WorldService. UI sizing, typography, and panels are in UIController; palette colors are in Config.

All listed cards are obtainable: districts omit catalog entries whose drop weight is zero. Perfect hits multiply the positive rarity weights above Common by 1.3 before rolling. Terminal and identity bonuses apply to banked cards; fixed mission and Vault rewards use their explicit configuration values.

Game inventory is deliberately **unbanked session loot**: it is not saved across leaving the server. The UI warns about capture loss, and banking converts loot to saved Cash. Discoveries are permanent when saved. Autosaving is every 60 seconds; an abrupt server loss can lose changes since the last successful save. Shutdown saving is best effort within Roblox's close deadline.

Resetting/dying also applies the same unbanked-loot penalty so respawning cannot bypass the risk. Capture removes a count of cards from the end of carried inventory, rounded up; it never debits saved Cash. A captured trip cannot fulfill the clean-trip starter objective. Reputation is a district requirement, not a spent currency. Purchases and reward transactions do not yield between validation and mutation.

New Identity resets Cash, Reputation, all upgrades, districts except Starter, carried loot, Heat, and starter jobs. It preserves collection, milestone claims, daily progress/claims, settings, prior identity badges, and identity count. It awards one new identity badge and 5% additional card banking value per identity up to 50%. There is no separate purchasable cosmetics system in this version.

## Audio and remaining limitations

**No sound asset IDs are included.** All slots in Config.Audio are intentionally empty, so the game is silent until you assign permitted asset IDs (`rbxassetid://...`). The controller supports looping music and Click, Success, Failure, Bank, Reveal, Alert, and Capture cues. Do not use assets without permission.

The map and actors use Roblox primitives; there are no external textures, custom rig animations, or imported art dependencies. Actor movement and reactions are simple programmatic motion and status changes. Vault rooms are isolated spatial rooms in the same server, not reserved servers.

The timing server uses receipt time minus Roblox-reported network ping, capped at 180 ms. It never accepts a client-provided result or reward. Very high-latency connections need Studio/device testing and may see harsher timing. This validates awards but is not a claim of comprehensive anti-exploit protection against client movement or automated timing input.

The runnable source compiles and builds. Domain tests use mocked engine boundaries; they cannot verify rendering, actual Roblox DataStore concurrency, character physics, streamed instances, or pathfinding. **Studio playtesting and device checks are still required before calling this a finished release.** See TESTING.md for the exact outstanding checks.

## Verification tools

Install Luau CLI from https://github.com/luau-lang/luau/releases and Rojo 7.7.1. Then run:

```sh
python tools/check.py --luau /path/to/luau --rojo /path/to/rojo
```

Use `.exe` paths on Windows. Python 3 is required only for this developer check script, not for playing or syncing the game. The script compiles every source file, bundles the actual production module text into a mocked test harness, executes domain assertions, and builds a temporary Roblox place. It does not run Roblox Studio or a Roblox-aware static type checker.
