# Verification and release gate

## Checks executed in this environment

- All 19 Luau source files compiled using Luau CLI 0.745.
- Rojo 7.7.1 successfully built the complete DataModel.
- 183 automated assertions exercised actual Config, Rules, PlayerDataService, InventoryService, MissionService, InteractionService, SecurityService, and GameService source using mocked engine boundaries.
- Tests cover receipt-time scoring, early/late misses, capacity, reachable catalog entries, variant/bank multipliers, capped identity bonuses, load/reload, overlapping save sessions, stale and expired leases, load failures, unsupported schemas, simultaneous claims, replayed tokens, timeouts, Heat/suspicion increments, banking, purchases, district requirements, capture rounding/immunity, clean-trip eligibility, daily rotation/idempotent claims, duplicate discovery rewards, and prestige reset/preserve behavior.

No Roblox Studio session was run. No device test, production DataStore test, pathfinding test, or Roblox-aware strict type analysis is claimed.

Additional executed check: 362 city-generation assertions ran actual WorldService and NPCService under lightweight instance/vector mocks. They check five safe-room checkpoints, every station, fifteen open-entry shops, 45 route/style definitions and actors, fifteen guards, fifteen secrets, starter inventory props, actor updates, and rebuild cleanup. These checks do not simulate collision or rendering.

Expansion domain tests also cover schema-1 migration, phase tokens/replays, no partial rewards, drifting/reverse/bounce scoring, perfect-zone attainability, capped quality streaks, cancellation, zero-reward practice, facility affordability, decoy charges/cooldown/pursuit/reacquisition, courier risk restrictions, one-time/distant secret rewards, rarity luck without Common drops, and preservation of permanent home/journal/stats through prestige.

## Required Studio checks

Use Output to watch for runtime errors throughout. These are pending, not passed.

### Starter loop and environment

- [ ] Open the included place; press Play; spawn at Starter Street without errors or falling.
- [ ] A new player can attempt a nearby target within about 30 seconds.
- [ ] Read target difficulty, rarity range, duration, suspicion, and equipment requirement.
- [ ] Land a good and perfect timing hit; miss and time out; cancel an interaction.
- [ ] Bank cards, receive Cash, buy Sleight, and advance onboarding.
- [ ] Fill capacity and verify additional attempts are rejected.
- [ ] Check paths, sign faces, occlusion, benches, car collision, lighting, district landmarks, and hideout safe-zone borders.
- [ ] Visit each district, verify locked entry is returned to an unlocked checkpoint, and verify tougher targets require Sleight.

### Security and capture

- [ ] Successful attempts add 9 Heat; failed attempts add 24; lingering suspicion can add 12.
- [ ] Guards patrol, see a hot player in their field of view, and do not see through buildings.
- [ ] Guards chase their selected player, route around solid geometry, lose sight, search, and drop pursuit.
- [ ] Heat decays only after quiet time while unseen; mint hideouts recover reliably.
- [ ] Capture removes ceil(carried cards × 0.5), returns to the checkpoint, and preserves saved Cash/upgrades/collection.
- [ ] Ten seconds of capture grace prevent immediate repeat captures. Resetting/dying applies the same loot penalty so respawn cannot bypass risk.
- [ ] Capture does not count as escape; a captured trip cannot finish the clean-trip objective.

### Multiplayer and lifecycle

Use Studio **Test → Server & Clients** with at least two players.

- [ ] Two players attempting the same target get one reservation and one possible reward.
- [ ] Different targets can be attempted independently.
- [ ] One player's Heat does not make guards select a cool bystander.
- [ ] Leaving mid-interaction releases the reservation; targets recover after attempts.
- [ ] Reset/respawn and rejoin do not duplicate HUDs, inputs, target rewards, or handlers.
- [ ] Simulate poor network conditions to assess timing/ping allowance.
- [ ] Verify streamed districts and actors appearing/disappearing do not error on the client.

### Persistence

Use a private published test experience and development-only DataStore name when appropriate. Default Studio mode intentionally does not persist.

- [ ] Bank, buy upgrades, unlock a district, discover variants, progress/claim missions, change settings; leave/rejoin and verify each saved field.
- [ ] Confirm production leases reject an overlapping session and allow rejoin after release.
- [ ] Confirm autosaving and normal shutdown save; observe failure logs/messages under simulated API outages.
- [ ] Studio test mode does not open the production store.
- [ ] No profile load failure replaces prior data with defaults.

### Activities and progression

- [ ] Starter chain progresses through collect, bank, upgrade, Heat/risk, district unlock, escape, and clean-trip jobs.
- [ ] Three daily jobs rotate together at the UTC date boundary; claims cannot be duplicated.
- [ ] Collection silhouettes and progress match actual discoveries; variant multipliers match value calculations.
- [ ] Vault entry requires Reputation, proximity to kiosk, empty pockets, an available room, and completed cooldown.
- [ ] Test every beam, ordered traversal, card pickup, exit, timeout, out-of-bounds failure, early leave, death/respawn, leaving server, cleanup, and replay.
- [ ] Two simultaneous Vault Runs use different rooms and cannot award each other's rewards.
- [ ] New Identity prerequisite failures preserve all data. Confirmation states the exact reset; one confirmation awards one badge/bonus; repeated requests cannot award more.

### Interface, performance, and assets

- [ ] Desktop, narrow portrait phone, landscape phone, tablet, and gamepad can reach every tab, button, and confirmation.
- [ ] Test automatic gamepad focus navigation and scrolling in all panels and modal dialogs.
- [ ] Check UI against Roblox top bar, chat, thumbstick, jump button, and notched safe areas.
- [ ] Card reveal is short, skippable, and does not block movement.
- [ ] Reduced motion and camera shake settings work and persist. No flashing effects.
- [ ] Add permitted sound assets and verify both volume controls and all cue names.
- [ ] Profile with 12 players, 45 targets, fifteen guards, and concurrent Vault Runs; check pathfinding load and frame/network cost.

Do not mark the game release-ready until these engine/device checks pass and any resulting issues are corrected.

## Clubhouse Update checks

- [ ] Enter all fifteen shops and five clubhouses; inspect open door clearance, roof/camera occlusion, stocked interiors, tables, furniture, lighting and sign directions.
- [ ] Traverse alleys, back lanes and each courtyard; find all fifteen souvenirs without clipping into props.
- [ ] Verify normal NPC routes and new limb motion do not cross street furniture; scouting pauses an NPC for eight seconds without blocking another player's claim.
- [ ] Choose both approaches, clear every stage/personality, miss later stages, cancel and attempt token replays. Award exactly one card on a full clear.
- [ ] Compare target styles, equipment effects and endgame rarity luck. Check tier costs/requirements/current-next text on every upgrade.
- [ ] Verify the practice arcade and live cancellation cannot farm rewards or streaks.
- [ ] Buy all clubhouse levels; verify recovery, display multiplier, supply capacity, courier fares and personal decorations for two different profiles.
- [ ] Confirm only the decoy owner's pursuers are distracted, and a hot player can be reacquired after 3.5 seconds.
- [ ] Test travel proximity, locked destinations, fares, cooldowns, Heat/chase rejection and carried-card rejection.
- [ ] Verify souvenirs disappear only for the discovering player, pay once, reappear correctly for newcomers/streamed models, and persist after rejoin/prestige.
- [ ] Load an actual schema-1 test profile into the new published private-test build; retain all existing progress and save/rejoin with schema-2 fields.
- [ ] Open target previews, upgrade and Hideout menus on narrow portrait and landscape screens; test the close button, long scrolling descriptions, focus navigation, stage transitions and decoy touch button.
- [ ] Profile with twelve players, 45 targets, fifteen guards, concurrent practice/Vault runs and live streaming before release.
