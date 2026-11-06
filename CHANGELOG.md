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

Verification: 28 sources compile; 236 gameplay/data, 792 world/model/environment, 391 UI and 165 asset checks pass under mocks/static checks; Rojo builds. Real Studio graphics/rig APIs/physics/pathfinding/streaming/live persistence/device checks remain pending. Imported meshes/PBR images still require the account owner's Studio import/upload step; configured audio assets remain absent.
