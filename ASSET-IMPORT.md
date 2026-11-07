# Original model and texture pack

The native game is playable without an asset import. This pack provides real authored mesh/PBR sources for higher-detail skins. These files are original project assets, not unknown Toolbox models. They have not been published to Roblox; that action needs your Studio account.

## Files and provenance

Extract `assets/AfterHours-Art.zip` to `assets/source/`. That folder should contain nine `.obj` files, `AfterHours.mtl`, `manifest.json`, and `textures/` with fifteen PNG maps. The ZIP entries already start at the model files; do not create another `source/source` level.

| Template name | Geometry role |
| --- | --- |
| SedanBody | Beveled vehicle shell, windows, mirrors, grille, trim; wheels are separate |
| VanBody | Cargo shell, rear doors/handles, cab, windows and trim; wheels are separate |
| Wheel | Tire, rim and hub geometry; reused on four contacts |
| Sofa | Upholstered seats/back, padded arms, beveled edges and wooden feet |
| Chair | Beveled seat/back and metal legs/supports |
| Locker | Three doors, latches and vent slots |
| Tree | Trunk and four original canopy meshes |
| Streetlamp | Pole, arm, cast housing and lens |
| Dumpster | Bin, lid, handles and wheels |

All are Y-up, front -Z, dimensions measured in Roblox studs. The pack has 8,234 triangles total. Every file has indexed triangles, unit normals, UVs, and material references checked by tools/check_assets.py. Color/normal/roughness maps are 512×512. No third-party art files are included. The project owner may use, edit and publish these original assets with the game.

`assets/MODEL-PREVIEW.png` is a software visualization of four mesh models, not an in-engine screenshot.

## Import once in Roblox Studio

1. Open the updated place in **Edit mode**, not during Play.
2. Use Studio's **3D Importer** / **Import 3D**. Select the OBJ files from the extracted `assets/source` folder. Keep the MTL and textures alongside them. Import without adding rotation; use Y-up and preserve the model hierarchy/material groups. Retain separate Glass materials rather than merging everything into one opaque object.
3. Check the imported materials. Assign the adjacent color/normal/roughness maps if the importer does not recognize a map automatically. Glass groups should use transparent Glass. Roblox may upload mesh/texture assets under your account as part of import; wait for permissions/moderation before publishing the experience.
4. Select the imported top-level models in Explorer. Their names must be exactly the nine names above (the installer also accepts `.obj` suffixes). Open Studio's **Command Bar** and paste/run the contents of `tools/InstallArt.command.luau`.
5. The installer checks proportions, normalizes scale, restores the source-origin pivot and moves templates into **ReplicatedStorage → ArtAssets**. It strips script objects from selected art. Unexpected dimensions/orientation are rejected with a useful message.
6. Stop/restart Play. ModelFactory substitutes those skins for new vehicles/furniture/trees/lights/props, retaining native interaction/collision/seat logic. Cosmetic model geometry remains in Shared.CosmeticModels, so purchased styles match their previews.
7. Save/publish the place to retain the imported objects. Rojo's ArtAssets folder is configured to preserve unknown imported instances during reconnects. Starting over from an earlier snapshot will not magically include later Studio imports; keep your saved updated place.

Do not change the model pivots after installing. Sedan/Van bodies exclude wheels; the runtime attaches and animates Wheel instances separately. Native gameplay colliders remain, so an imported skin cannot change the vehicle's speed or storage rules.

## Optional custom material overrides

The city already uses Roblox's native Brick, Concrete, Asphalt, Wood, Fabric, Glass and Metal surface detail. To apply this pack's published PBR maps globally, add permitted texture IDs to Config.MaterialAssets, for example:

```lua
C.MaterialAssets = {
 Brick = {
  ColorMap = "rbxassetid://YOUR_PUBLISHED_BRICK_COLOR_ID",
  NormalMap = "rbxassetid://YOUR_PUBLISHED_BRICK_NORMAL_ID",
  RoughnessMap = "rbxassetid://YOUR_PUBLISHED_BRICK_ROUGHNESS_ID",
 },
}
```

Replace placeholders with your actual imported/published IDs. Leave the table empty until those exist. EnvironmentService creates the MaterialVariants and base-material overrides. Mesh skins can use their imported SurfaceAppearance maps independently of the city material overrides. Validate tiling, scale, opacity and material permissions in Studio.

## Regenerate or edit

`python tools/build_assets.py` creates the original geometry/material maps using NumPy and Pillow. `python tools/check_assets.py` validates the results using the Python standard library. The installer embeds dimensions from the manifest: if you alter the size/origin of a model, update its installer bounds too. Source geometry changes are not automatically uploaded to Roblox; reimport them.
