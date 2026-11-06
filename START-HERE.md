# Get the game running on your new PC

This is a fresh project because the supplied workspace had no existing repository or Rojo setup. It contains a playable implementation, but it still needs the Roblox Studio checks in TESTING.md before release.

## Fastest way: open the included place

1. Install Roblox Studio from https://create.roblox.com/ and sign into your Roblox account.
2. Extract the delivery ZIP. Open **CreditCardStealer.rbxl** in Studio using **File → Open from File**. The `.rbxlx` is an equivalent XML copy; open either one.
3. Press **Play**. The city is generated when the server starts. Seeing an empty edit view before Play is expected.
4. Walk to a tourist across from the mint hideout. Use **E**, the controller **X** button, or the touch prompt.
5. Stop the moving timing marker in the mint zone with **Space**, **A**, or the large **STOP** button. A gold-center hit improves rarity odds.
6. Bring cards to the mint **Hideout Terminal**, bank them, then buy **Sleight** at the equipment kiosk. The objective banner guides the rest.
7. Stop the test before editing scripts. Use **File → Publish to Roblox** when you want to save the experience to your account. Publishing is your action; this delivery has not published anything.

**Studio uses temporary test profiles by default.** Leaving and rejoining a Studio test resets those test profiles. Published servers use the production DataStore automatically.

## Set up the source workflow with Rojo

The ZIP contains a `CreditCardStealer` source folder. Keep that entire folder together. Source files are the editable source of truth; the bundled place files are snapshots of that source.

1. Install VS Code if you want a code editor: https://code.visualstudio.com/
2. Install Rojo **7.7.1**, using the Windows release from https://github.com/rojo-rbx/rojo/releases/tag/v7.7.1 and add its extracted folder to your PATH. Alternatively install Rokit and run `rokit install` in the source folder to use the pinned `rokit.toml`.
3. Open a terminal in the **CreditCardStealer** source folder. Check `rojo --version`.
4. Close Studio, run `rojo plugin install`, then reopen Studio. This installs the matching local Rojo plugin.
5. Open a **new empty place** or the bundled place and run:

   ```powershell
   rojo serve default.project.json
   ```

6. In Studio, open the **Rojo** plugin and connect to `localhost:34872`. Review the sync changes and connect. Use a dedicated place for this project because the project sync manages its mapped scripts and settings.
7. Keep the terminal running while you edit. Rojo syncs source changes into Studio. Stop and restart the Play test after code changes.

To make a fresh place snapshot without a running sync:

```powershell
rojo build default.project.json -o CreditCardStealer.rbxl
```

Rojo's installation documentation: https://rojo.space/docs/v7/getting-started/installation/

## Studio and publishing settings

- StreamingEnabled is included in the Rojo project. Client world lookups tolerate missing streamed actors; interface and configuration live outside Workspace.
- Set the experience's **maximum players to 12** in its publishing settings. There are 12 separate Vault Run rooms per server.
- No HTTP requests, external packages, paid assets, or API keys are needed by the game.
- For normal Studio tests, leave `Config.StudioTestData = true`. No DataStore API access is needed.
- Test production persistence in a private published experience first. Its server sessions save normally without Studio API access.
- If you intentionally test actual persistence *inside Studio*, use a separate test experience, change `Config.StoreName` to a development-only name, set `StudioTestData = false`, publish the place, and enable **Game Settings → Security → Enable Studio Access to API Services**. Restore the default development mode afterwards. Do not point this test configuration at a live production store.
- A profile-load failure disconnects the player with a useful message instead of substituting or saving a fresh profile. Concurrent sessions are blocked by a renewable lease.

## Controls

| Action | Keyboard | Gamepad | Touch |
| --- | --- | --- | --- |
| Nearby prompt | E | X | Tap Roblox prompt |
| Stop timing | Space | A | STOP button |
| Open pockets/menu | Tab or bottom tabs | Y, then focus navigation | Bottom tabs; swipe horizontally |
| Close menu | X button, Escape where unconsumed | B | X button |
| Cancel timing | Cancel button | B | Cancel button |

Move with normal Roblox controls. Avoid loitering beside one tourist: suspicion rises. Failures raise Heat faster. At 55 Heat or above, a guard who sees you can chase. Hide behind buildings to break sight, or reach a mint safe zone. Capture or resetting/dying removes half your carried cards, rounded up; banked Cash and permanent upgrades stay safe.

The city runs east from Starter Street through Shopping Plaza, Business District, Luxury Heights, and Neon Financial Center. Unlock districts in the bottom **Districts** tab. Targets require increasing **Sleight** levels, shown before an attempt.

At 90 Reputation, use the purple Starter Street kiosk for Vault Run. Bank your cards first. Cross security beams when they fade, collect the golden card, then reach the exit. Use **Missions → Leave Vault Run** to exit early. Rewards and obstacle checks are on the server.
