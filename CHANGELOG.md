# City Shift

- Replaced timing-only street rounds with READ / changing lane phases / one STABILIZE recovery / SECURE-or-BONUS decisions, bounded input-time validation, one-charge tool assistance, medals, per-mode/district records and fixed daily drills. Rewards remain server-owned and exactly once.
- Added an Activities page explaining Practice, Careful, Bold, Daily Drill and the movement-based Vault; all rounds share input language and results. Training supports fast retries, and Vault keeps its existing reward/eligibility rules.
- Replaced workshop instruction blocks with modeled intake lockers, printer, tool/supply benches, training/contract terminals, route board, collection case and garage intercom. Moved register screens onto their counters and staff behind them. Removed an overlapping old desk.
- Added WorldService-derived road/footprint/service metadata, discovered-service saving, a rotating/north-up minimap and full map, facing/distance/edge goals, accessible service pins and mission/processing navigation. Hidden souvenirs and other players are not exposed.
- Added properly mounted street/parking/speed signs, restrained facade/curb colors, a complete parked van and smaller environmental labels.
- Added shared pedestrian obstruction/path budgets, stuck-route recovery, crossing waits, local reactions, distance-based updates, named roles and short contact dialogue. Existing traffic also yields to crossing citizens.
- Added braking/coasting/capped reverse and speed-sensitive steering, ground probes/wheel response, obstacle stops, clear garage bays, recovery/abandonment cleanup, speed display, follow-camera setting, cabin detail and reverse lamps.
- Added shared hover/focus rings, responsive lane/results controls, portrait actions clear of standard touch controls, saved map/camera settings and rate-limited bundled UI sound feedback. Optional loop assets remain configurable.
- Migrated schemas 1/2/3 to schema 4 in the same save store, preserving existing money, inventories, batches, van ownership/stash, cosmetics and progression.

Validation: 37 production scripts compile; 253 domain, 1,162 world/model/environment, 491 UI, 13,585 City Shift assertions (1,200 generated round cases), and 165 asset checks pass. Rojo builds; source/package/download integrity is checked. Studio rendering, avatar access, physics, actual device input and live persistence still need the focused TESTING.md checks.

# Citizen interaction fix

- Moved citizen/contact prompts to a dedicated attachment above the torso and removed camera occlusion by their own bodies. All use E/controller X and support clicking/tapping.
- Added a named nearby-target hint and a mint SCOUT button. E/controller X also work when the native prompt is absent, with fresh streamed-target lookup, distance and world-obstruction filtering.
- Shared one request/debounce path across native prompts, keyboard/controller and touch; visible shop/machine prompts retain their input key.
- Replicated target reservation/recovery availability so native prompts and the fallback action hide/recover together. Server checks for obstruction, range, cooldown, ownership, district, gear and capacity still apply.
- Added native/R15 prompt, streamed target, touch/input arbitration and server-validation regressions. 29 sources compile; 244 domain, 991 world/model/environment, 423 UI and 165 asset checks pass. Studio runtime remains untested here.

# After Hours overhaul

- Expanded the footprint to approximately 1,200 × 390 studs, adding cross/perimeter roads, residential terraces, service alleys, native surface textures, details and additional planting.
- Concealed furnished workshops behind closed repair-shop frontages, adding usable sofas, tables, lockers, rugs, kitchen pieces, warm lights, machines, wardrobe cabinets and external van docks.
- Added detailed reusable vehicle/furniture/tree/street models, optional imported skin bindings, and an original nine-OBJ/fifteen-map source pack with checked UVs/normals/bounds/materials and an import/pivot normalizer.
- Added 24 circulating traffic models with spacing, signals, yielding, acceleration/braking, turn slowdown, wheel/headlight/brake presentation and smooth client motion.
- Added R15 citizen construction with original clothing detail, faces/hair/skin palettes, phone/umbrella props and shop/laundry/bus routines; expanded to 65 unique targets plus guards and contacts.
- Added a dynamic lighting/day/night/weather service with weighted conditions, varied duration, blended transitions, atmosphere/cloud/wind/grading, automatic street/window/headlights, roof-aware local rain and optional vegetation sway.
- Replaced instant banking with saved fictional intake/press/rinse/payout stages, bounded queues, immutable job payouts and replay-safe claims.
- Added a purchasable physically drivable van with saved private card storage, proximity/capacity/occupant validation, dock unloading and delivery activity.
- Added Press/Rinse/Yield/Van Slots/Engine, grouped gear, harder district/stage scaling and bounded equipment bonuses.
- Added twelve linked story contracts, quest giver interactions, pause/resume and one-time server rewards alongside existing daily/starter/Vault progression.
- Rebuilt every interface around a shared City Desk component library, including equipment comparisons, operations progress, storage cards, quest journal, full-size compact controls and settings.
- Added five modelled outfitters, ten appearance-only cosmetics, shop previews, full-avatar wardrobe previews and four persistent wearable slots with safe headwear restoration.
- Migrated earlier schemas into version 3 without changing the production store or discarding existing progression.

Verification: 29 sources compile; 244 gameplay/data, 991 world/model/environment, 423 UI and 165 asset checks pass under mocks/static checks; Rojo builds. Real Studio graphics/rig APIs/physics/pathfinding/streaming/live persistence/device checks remain pending. Imported meshes/PBR images still require the account owner's Studio import/upload step; configured audio assets remain absent.
