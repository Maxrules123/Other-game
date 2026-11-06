# Card City / After Hours

A substantially rebuilt Roblox arcade city with moving traffic, articulated citizens, hidden furnished workshops, fictional card processing, a drivable storage van, dynamic lighting/weather, story contracts, and a consistent City Desk interface.

**All banks, cards, tokens and Cash are invented.** The token press and cartoon rinse are game activities, with no real payment data or financial methods.

## Download and play

1. Download the ZIP of the **After Hours branch**, then Extract All.
2. Open **CreditCardStealer.rbxl** in Roblox Studio.
3. Press **Play**. The city builds when the server starts.
4. You spawn in the hidden workshop. Leave the door, turn left through the alley, and scout a citizen on the avenue.
5. Choose Careful/Bold and finish every timing stage. Bring cards back to the intake, use the ink press, then the cartoon rinse, then claim the Cash printer payout.

Use this branch's place, not an earlier downloaded build. The original nine-mesh/fifteen-texture source pack is in `assets/AfterHours-Art.zip`; extract it as described in **ASSET-IMPORT.md** to use custom imported skins. The place works immediately with detailed original Roblox models, native material textures, and a Roblox-generated R15 citizen rig with a fallback if that API is unavailable.

## A larger, living city

- Five connected districts now cover approximately **1,200 × 390 studs**, with 960 studs between the centers of the first and last district.
- Main avenues, two perimeter circulation routes, cross streets, residential terraces, service alleys, courtyards and fifteen enterable shops replace a single narrow strip.
- Native textured brick, concrete, asphalt, metal, wood and fabric, plus trim, shutters, windows, downpipes, street furniture, trees and planted edges add surface and silhouette detail.
- **65 targets**, fifteen guards and four story contacts populate the blocks. Standard Roblox R15 base rigs receive original clothing details, faces, hair, bags, phones and umbrellas. They walk routes, pause, browse interiors, visit the laundry, wait at bus stops and react to rain. No unknown Toolbox scripts are loaded.
- **24 ambient cars** circulate on opposite routes with bounded acceleration/braking, turning slowdown, spacing, pedestrian yielding, crossing signals, headlights, brake lights and client wheel animation. They are simulated traffic models, not physical crash vehicles; they intentionally do not damage pedestrians.
- A full **24-minute day/night cycle** shifts ambient light, atmosphere and grading. Streetlights, vehicle lights and upper windows respond to night/rain. Weighted Clear/Overcast/Rain/Fog transitions blend over 24 seconds and vary in duration. Rain particles stop under roofs and support reduced-motion/particle settings. Fog/rain affect guard visibility; rain reduces driving speed.
- Additional trees and planting have restrained client-side sway. Interior lighting stays warm and usable at night.

## The hidden workshop and money loop

The workshop sits **behind the closed Bubble Repairs frontage**, reached through a service alley. It has sofas with actual seats, a rug, coffee table and mugs, storage lockers, a planning desk, kitchen counter/fridge, hanging lights, exposed brick, conduit, wardrobes and operating stations.

Carried cards are vulnerable and session-only. Depositing moves their server-valued contents into a **saved, capture-protected queue**, without granting instant Cash. Start the **Imaginary Ink Press** (18 seconds baseline), then the **Cartoon Token Rinse** (14 seconds baseline), then claim the printer. Batches and timers persist across rejoins; progression/rewards are server-owned and idempotent. Yield upgrades lock the payout when the batch begins. Machine indicators/spindles reflect your own active job.

Fourteen equipment tracks are grouped into Field Gear, Operations and Van, with current/next effect comparisons, costs and Reputation gates. Permanent home improvements still upgrade recovery, supplies, displays and courier travel. See **UPGRADE-GUIDE.md** for exact effects.

## A usable courier van

Buy at an alley garage for **$650 / 30 REP**, then summon it. Use the driver-seat prompt; WASD, gamepad or touch thumbstick supplies validated input. The physical van has a VehicleSeat, chassis/wheel contacts, capped acceleration/steering and collision separation from players. Jump exits. Server ownership, occupant checks, input throttling and a watchdog protect control.

Rear storage transfers cards between pockets and a **saved private stash**, with slot limits and no duplicated copies. Capture does not debit that stash. Park by the workshop's **external west-wall dock** to transfer it into processing. Courier story contracts use the van and Plaza delivery bay. Van ownership survives New Identity; stash contents reset as stated in its confirmation.

Vehicle handling, camera, seat behavior, collision and network feel still need actual Studio/device testing; passing source/mocked tests is not a physics claim.

## Quests, cosmetics and interface

- Seven starter objectives, three UTC daily jobs, **twelve linked story contracts** from Mara/Jax/Wren/Iris, fifteen permanent souvenirs, and the existing replayable Vault Run provide progression.
- Five **Second Shift Outfitters** registers sell **ten appearance-only cosmetics**: canvas caps, a knit beanie, round frames, canvas packs and utility jackets.
- A modeled open wardrobe in every workshop equips owned items into Head / Face / Back / Outfit slots. Original shared geometry drives both 3D item previews and actual wearable models; a full-avatar wardrobe preview lets you check your look. Conflicting original headwear is temporarily hidden and restored on removal. Clothes are massless/noncolliding, with no movement or reward benefits.
- Ownership/equipped styles persist through rejoin, respawn and New Identity. Purchases and equipment are validated against prices, ownership and physical shop/wardrobe proximity.
- The new **City Desk** contains Overview, Pockets, Collection, Equipment, Operations, Hideout, Van, Style Shop, Wardrobe, Districts, Quests and Settings. It uses one palette/component system, item cards, viewport previews, responsive navigation, scrollable descriptions and 44-pixel-or-larger action targets. Small landscape views keep controls full-size rather than scaling buttons down.
- Timing difficulty decreases window width and stage time by district; Focus helps within limits. Perfect grades, drift/reverse/bounce patterns, limited streak bonuses and approach choices remain server-scored.

## Saving and compatibility

Schema **3** reconciles schema-1/2 profiles in the same `CCSS_Production_v1` store. Existing Cash, unlocks, equipment, discoveries and missions remain; new processing, van, cosmetics, contracts and weather-setting fields receive safe defaults. Session leases, retries, autosave, shutdown save and safe load rejection remain.

Default Studio sessions use temporary test profiles. Published servers save normally. Unbanked pockets, streak and decoy charges remain session state; bank/secure cards before leaving. Saved queue/stash data is subject to the existing 60-second save interval and best-effort close save, so an abrupt crash can lose changes since the latest successful save.

New Identity resets Cash, Reputation, normal equipment, districts, pockets, van stash, processing queue/batch, Heat/streak and starter jobs. It preserves van ownership, home improvements, cosmetics/equipped outfits, collection, souvenirs, career stats, contract and daily progress/claims, settings and identity badges. Its confirmation lists these rules.

## Assets and verification

- **9 original OBJ models**: sedan body, van body, wheel, sofa, chair, locker, tree, streetlamp and dumpster; **15 original 512×512 maps** for brick/asphalt/wood/fabric/paint. Materials, UVs, normals and an import normalizer are included. The software model preview is not a Roblox screenshot.
- The meshes/images are source assets; **they have not been uploaded to Roblox**. Studio's 3D importer/account is required for that step. Read ASSET-IMPORT before claiming the imported skin/PBR presentation is active. Native detailed models/materials remain the automatic fallback.
- No external sound IDs are invented. Audio slots remain empty until permitted assets are assigned.
- Configure economy, difficulty, weather, wardrobe, shops, vehicle and processing in `src/shared/Config.luau`. Shared Rules and CosmeticModels keep calculations/geometry consistent.

Executed checks: **28 sources compiled; 236 gameplay/data assertions, 792 world/environment/model assertions, 391 UI component assertions, and 165 asset checks passed; Rojo built the complete place.** Module tests execute the actual code under mocked engine boundaries. They do not verify Roblox rendering, real R15 API access, vehicle physics, pathfinding, live DataStore concurrency, UGC outfit fit or touch/gamepad feel. Those Studio checks are still pending in TESTING.md.

```sh
python tools/check.py --luau /path/to/luau --rojo /path/to/rojo
```

No Python is needed to play or sync. The check script needs Python 3 plus Luau CLI and Rojo. Regenerating the original art additionally needs Pillow and NumPy. See START-HERE for the existing new-PC/Rojo setup.
