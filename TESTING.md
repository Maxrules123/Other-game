# After Hours verification and Studio release gate

## Executed here

- Luau CLI 0.745 compiled all **28** production source files.
- **236** domain assertions executed actual Config, Rules, Data, Inventory, Missions, Interaction, Security, Processing, Vehicle storage and Cosmetic transaction code under mocked engine boundaries.
- **792** world/model/environment assertions executed actual map/model constructors, NPC routes, traffic and weather logic, R15 construction using an API fixture, wearable construction/restoration, and physical-van model setup under lightweight instance/vector mocks.
- **391** UI component assertions executed every panel at desktop, portrait and compact-landscape mock sizes, including shop/item/full-avatar previews, touch-target dimensions, staged input, modal reset wording and cleanup. This does not render Roblox UI or validate actual device focus.
- **165** asset checks validated nine OBJ models, triangle/vertex/UV/normal indices and bounds, unit normals, fifteen 512×512 PNG maps, and material references. These are source checks, not Roblox import tests.
- Rojo 7.7.1 built the full DataModel. The packaged place is checked against the source text, and ZIP integrity is checked separately.
- An offline unexpected-global-name scan found no undeclared names outside the known Roblox globals. This is not Roblox-aware strict type analysis.

The domain suite covers migration, save/lease failures, timing bounds/scaling and phase replays, no partial/duplicate rewards, capture protections, safe transactions, queue/full-capacity handling, processing stage order/offline timer/one-time payout, van ownership/transfers/capacity, story prerequisites/one-time rewards, cosmetic ownership/proximity/slot rules, and prestige preservation/reset behavior. The generated-world suite caught and prevented duplicate target identifiers.

**No actual Roblox Studio session was available.** None of the following boxes is marked passed. Real R15 API permission/access, physics, navigation, lighting/rendering, platform persistence/concurrency, streaming and input must be verified before calling this release-ready.

## First play and tutorial

- [ ] Open this version's CreditCardStealer.rbxl; Play; build city without runtime errors in Output.
- [ ] Spawn on the workshop floor, use the clear doorway, reach the avenue through the side alley and complete the first successful target interaction in roughly 30 seconds.
- [ ] Complete Careful/Bold, every personality and each district's stage count. Verify narrower/faster/drifting endgame challenges stay attainable with gear, including high-ping simulation.
- [ ] Miss later stages, time out, cancel, leave/rejoin and attempt simultaneous claims with two players. Award one card only after the full clear; a replayed phase token must not advance or award again.
- [ ] Check first-time objective guidance through deposit, pressing, rinsing, payout and first upgrade.

## Processing and persistence

- [ ] Deposit pockets without receiving instant Cash. Queue count/value match server-calculated cards.
- [ ] Press → Pressed → Rinse → Ready → Claim; each button requires the correct nearby machine. Verify no action bypasses a phase or pays twice.
- [ ] Upgrade Press/Rinse/Yield. Current jobs keep their locked payout and timing; future jobs use the improvements.
- [ ] Queue cards while a different batch runs; handle intake capacity without losing the remaining pockets.
- [ ] Leave during both timed stages, rejoin after the timer and resume correctly. Keep queue/batch protected from capture.
- [ ] Use a private published test experience/store to migrate real schema-1/2 fixtures to schema 3, retain all old fields and save/rejoin new queue, van, cosmetics and contract data.
- [ ] Verify autosave, normal leave, lease ownership, concurrent-session rejection, shutdown and failure messages. Studio development mode must not open the production store.

## City, assets and people

- [ ] Traverse the entire 1,200×390 layout and every alley/courtyard. Check corner/perimeter road alignment, shop entrances, floor heights, walls, tree trunks, interior camera/roof occlusion and path clearance.
- [ ] Check all 65 unique targets, fifteen guards and four contacts. Verify R15 API success and fallback behavior; clothing/face/hair/phone/umbrella parts stay aligned to the actor.
- [ ] Follow shopping/laundry/bus/phone routes. Confirm no repeated clipping through planters, furniture, doors or glass, and that rain/idle presentations make sense.
- [ ] Test imported skins using ASSET-IMPORT.md; verify pivots, scale, glass opacity, material maps, native colliders/seats, and wheel spin. Confirm the original native fallback remains usable when ArtAssets is empty.
- [ ] Check planted areas, vegetation sway, garden lighting, sign readability and workshop furniture/seats. Reduced motion should disable optional sway/rain motion.
- [ ] Collect all fifteen souvenirs; enforce distance/district/one-time rewards, per-player hiding, streaming/rejoin and journal clues.

## Traffic, van and security

- [ ] Observe both traffic directions, turning slowdown, acceleration/braking, headway, red-light stopping/committed crossing, pedestrian yielding, wheel spin, headlights and brake lights. Traffic should not damage/push pedestrians.
- [ ] Buy/summon/enter the owner's van, drive/reverse/steer/stop/exit using keyboard, controller and touch. Verify its four wheel contacts, stability, camera, ground friction, turning response, server latency and collision groups in the actual engine.
- [ ] Nonowners cannot drive, withdraw or deposit another player's stash. Occupied vehicles cannot be remotely re-summoned. Stop stale/invalid input, bound speed and handle falling/locked districts.
- [ ] Store/withdraw near rear doors with each capacity boundary; never duplicate cards. Stash saves across leave and remains protected from capture.
- [ ] Park by the external west-wall intake and transfer stash to processing. No street/remote deposit from elsewhere. Verify all five workshops' external intakes and garages, not only the last district.
- [ ] Finish the actual driving/delivery contracts; delivered/claimed rewards cannot repeat.
- [ ] Guards patrol and detect the intended hot player by sight/FOV, route around geometry, lose/search/capture, and cannot see through walls/imported cover. Weather visibility limits and decoy-owner suppression work without affecting cool bystanders.
- [ ] Capture/death only removes the stated portion of pockets, breaks streak, marks surviving captured cards ineligible for clean batches, safely unseats players and grants grace. Cash, processing, stash and cosmetics stay safe.

## Quests, fashion and UI

- [ ] Follow all twelve story contracts, accepting/claiming near their actual giver; pausing/resuming keeps progress, prerequisites hold, and owned-van/souvenir/facility objectives do not deadlock returning players.
- [ ] Daily UTC reset and all claims are server validated and idempotent. Starter clean-card objective uses one completed batch.
- [ ] Browse each Outfitters register. Prices/REP are visible, purchases are one-time, balances stay nonnegative and no cosmetic gives gameplay bonuses.
- [ ] Equip/remove all ten styles in every wardrobe. Slots, owned-only rules, full-avatar/item previews, respawn/rejoin, original headwear restoration and normal/layered/UGC avatar fit work. Wearables must stay massless/noncolliding.
- [ ] Test every page at desktop, tablet, narrow portrait and landscape sizes against actual Roblox top bar/chat/thumbstick/jump controls. Test gamepad focus/scrolling, modal closure, text wrapping and 44px touch actions.
- [ ] Rejoin/respawn without duplicating HUD, input handlers, effects or machine claims. Open a menu while driving; control input should stop the van safely.
- [ ] Prestige confirmation matches every field reset/preserved, including queued processing, stash, ownership, cosmetics and contract progress. Cancel/expired/replayed confirmations cannot reset or grant again.

## Weather, lighting and performance

- [ ] Observe a full 24-minute day/night cycle and weighted weather transitions over several periods. Density, cloud cover, grading, ambient light and rain intensity blend instead of popping or flashing.
- [ ] Street/window/vehicle lights respond to darkness; workshop lights remain usable. Rain particles stop under roofs and follow the local camera without accumulating after respawn or weather changes.
- [ ] Settings persist: volumes, reduced motion, optional shake and rain effects. Add permitted audio IDs before checking actual sound cues; slots are currently empty.
- [ ] Profile a 12-player session with 65 articulated targets, fifteen guards, 24 traffic models, owned vans, vegetation, cosmetics, queues and Vault Runs. Check server raycasts/pathfinding, network replication, streamed object lifetime, client wheel/joint/preview render cost and memory over a long session.

The mocked tests establish implementation behavior at their boundaries. They cannot replace these Studio checks.
