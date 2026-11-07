# Play City Shift on your PC

You already installed Roblox Studio and Rojo earlier. To try this version, you do not need to reinstall them.

1. Download the **latest City Shift project ZIP** from GitHub and choose **Extract All**.
2. Open Roblox Studio → **File → Open from File** → choose the extracted **CreditCardStealer.rbxl**.
3. Press **Play (F5)**, which spawns your character. You begin in the hidden alley workshop. The city generates when testing starts.
4. Walk out of the workshop, turn left through the side alley beside the closed repair shop, then approach a citizen on the avenue.
5. Walk close until the bottom hint names the citizen. Press **E / controller X**, tap the floating prompt, or tap the mint **SCOUT** button to scout. Choose Careful or Bold. **Read the numbered route**, then press **J/K/L** or tap its next lane when the marker is in mint. Arrows select a lane; **Space/controller A** confirms. One mistake gives one stabilize phase. After the route, SECURE or try the bonus risk.
6. Return with cards. Use the intake, ink press, cartoon rinse, then Cash printer. Operations in the City Desk shows the job and explains every stage.
7. Press **M** for the map. It tracks your actual position, facing, discovered services and current objective; destinations outside the minimap stay on its edge.
8. Use the City Desk button (or Tab / Y) for gear, quests, van, outfits, wardrobe and settings. Shops and machines require actual proximity, so close the menu and walk to them when prompted.

The native build is playable immediately. The custom OBJ/PBR pack is delivered separately as `assets/AfterHours-Art.zip`; see **ASSET-IMPORT.md** for the Studio import/account step. Those custom mesh/image assets have not already been uploaded to Roblox. Native models/materials and R15 citizens/fallback work while ArtAssets is empty.

## Things to try

- Sit on the workshop sofa; inspect its kitchen, desk, lockers, wardrobe and warm lighting.
- Try safe Workshop Practice or the fixed Daily Route at the modeled training console; results have medals, personal bests and immediate training retries.
- Buy gear at the bench. Press/Rinse/Yield improve the processing operation; other tracks affect field timing, risk and capacity.
- Buy a van at an alley garage for $650 and 30 REP. Summon it, use the driver-seat prompt, drive with WASD/controller/touch thumbstick and jump to exit. Press R or use the Van menu to recover when stopped/overturned; recovery uses a clear bay and keeps your stash. Store cards at the rear; park at the external west-wall dock to unload them into processing.
- Talk to Mara/Jax/Wren/Iris for story contracts. Visit Outfitters for cosmetics and a workshop wardrobe to wear them. Clothes are appearance-only and saved.
- Explore residential/back lanes and district courtyards; watch traffic, changing light/weather, citizen stops and the fifteen souvenirs.
- Keep the Output window open and use TESTING.md for actual Studio acceptance checks.

## Saving/settings

Studio uses temporary test profiles by default, so a new Studio session starts fresh. Published servers use the production DataStore. Set published max players to 12. There are no runtime HTTP services, API keys, or invented asset IDs.

Test persistence in a private published test experience first. If testing real DataStores *inside Studio*, use a separate test experience and development-only Config.StoreName, set StudioTestData=false, publish, then enable Studio access to API services. Restore StudioTestData=true afterwards. Do not use a development test against live production progress.

## Rojo editing workflow

The GitHub ZIP has source at its root. Open the folder containing **default.project.json** in VS Code. The Roblox place and source are together at the root of the extracted project folder.

Run Rojo from a terminal in that folder:

```powershell
rojo serve default.project.json
```

If rojo.exe is not on PATH, copy the executable into the project folder and use:

```powershell
.\rojo.exe serve default.project.json
```

In Studio's Rojo plugin, connect to **localhost:34872**. Review the sync and connect to this project's dedicated place. Keep the terminal open; stop/restart Play after code changes. ArtAssets preserves your manually imported models when syncing.

To build another snapshot:

```powershell
rojo build default.project.json -o CreditCardStealer.rbxl
```

Publishing to Roblox is separate from uploading source to GitHub. After Studio validation, use **File → Publish to Roblox** to publish the experience to your Roblox account.
