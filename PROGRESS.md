# City Shift implementation checkpoint

Base: After Hours prompt fix, commit d5757785d4b7591cd661fbabd626eb4ca34eaedb. Source: /workspace/work/AfterHours. Delivery: existing Maxrules123/Other-game repository. Rojo 7.7.1 maps src/server to GameServer, src/client to GameClient and src/shared to Shared. No Roblox Studio connector or engine is available.

Player-impact task order:
1. Replace repetitive timing-only rounds with readable lane sequences, fair timestamp validation, one recovery, optional bonus risk, medals, personal bests and quick practice retry. Preserve server-owned rewards and cancellation.
2. Give practice, street approaches, daily drill and the existing movement-based Vault distinct explanations; replace hideout text blocks with modeled functional stations.
3. Derive public navigation metadata from generated city geometry; add accurate minimap, objectives, discovered services and saved map settings.
4. Improve vehicle acceleration/braking/reverse, grounded steering, collision/overturn/spawn recovery, cleanup and vehicle HUD/camera. Refine pedestrian roles, local reactions, obstacle avoidance and distance-based updates.
5. Replace instructional map signs and parked placeholder vehicles; unify proportions/materials, add purposeful street signs, finish responsive shared UI and original feedback audio.
6. Extend meaningful logic/integration checks, rebuild/place/package, verify downloads and publish to the existing branch.

Inspection findings: main rounds currently repeat 1–3 single-button moving-zone taps with no recovery or bonus choice; scoring uses receipt time less ping. NPC movement ignores obstacles. Player van forces commanded speed without wall checks, reverse limit or spawn occupancy protection. Hideout station helper creates labeled blocks even where modeled equipment exists. The city is rebuilt by WorldService, so edits belong in generators. Native R15/fallback citizens, model factory, 14 gear tracks, schema-3 saved processing/van/cosmetics, leased DataStore, contracts, weather and day/night already exist. No minimap metadata/controller exists. All audio configuration slots are empty. Baseline: 29 production sources compile; 244 domain, 991 world/model/environment, 423 UI, 165 asset checks pass under mocked/static boundaries.

Save strategy: same CCSS_Production_v1 store, additive schema-4 defaults/reconciliation for round records, service discoveries and map/camera settings. Do not reset existing currencies, cosmetics, inventory, processing or contracts.

Status: implementation and available regression verification complete; publishing the place and source; the full downloadable ZIP is the GitHub archive of the same commit. Publishing to the existing After Hours branch. All new code stays in the original project. No Studio playtest occurred.

Completed: lane-sequence round state machine and results; recovery/tools/bonus; saved records/daily drill; mode explanations; modeled stations/intercom/registers and revised signs; accurate map metadata/minimap/objective/discovery/pins; vehicle control/recovery/HUD/camera/light updates; pedestrian paths/LOD/crossings/local reactions/contact dialogue; responsive common UI and bundled UI audio; additive save migration and updated guides.

Verification: 37 sources compile. 253 domain, 1,162 generated-world/model/environment, 491 UI, 13,585 City Shift assertions across 1,200 generated round cases, and 165 art-source checks pass. Unexpected-global-name scan found zero new names. Real Studio graphics, physics, avatar API, streaming, controller/touch rendering and persistence tests remain pending; TESTING.md gives focused steps. Optional music/engine/ambient audio and custom published mesh/PBR imports require the owner's Studio asset setup; native models/materials and bundled UI pings need no external IDs.
