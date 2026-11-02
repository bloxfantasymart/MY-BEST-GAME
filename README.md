# Roll a Brainrot — playable development build

This repository contains an **unfinished Roblox game**: a generated six-plot world, server-owned rolling and crafting, stands and income, mutations, leveling, rebirths, timed events and a first persistence implementation. Trading, Robux purchases and many polish features are not yet implemented. See [the roadmap](docs/ROADMAP.md).

**Please test this in a private test experience first.** It has not been run in Roblox Studio in this environment. Do not sell paid items or advertise it as complete. We cannot guarantee saving or prevent data loss until Studio and live multiplayer tests have passed.

## Setup for beginners

1. Install [Roblox Studio](https://create.roblox.com/) and sign in. Create a new **Baseplate** experience.
2. Install [Rojo 7.7](https://rojo.space/docs/v7/getting-started/installation/) on your computer and install the Rojo Studio plugin. Download this repository from GitHub using **Code → Download ZIP** and extract it. Make sure you download the branch `arena/323aed2b-my-best-game`, not `main`.
3. Open a terminal in the extracted folder (containing `default.project.json`) and run `rojo serve`.
4. In Studio, open **Plugins → Rojo** and connect (normally `localhost:34872`). Keep Rojo running while editing. The scripts sync into the Roblox services automatically.
5. Press **Play**. At your red station, use the prompt, press **PULL LEVER**, and buy parts. Reroll for a Head, Chest, Arms and Legs. At the purple pod, select one of each and assemble. Use a yellow stand's prompt to place your creature. Click the cash HUD or use the green ATM to collect income. Use **UPGRADES** for roll slots and extra stands. In **BACKPACK**, tap a creature to choose whether to level or sell it; parts can be sold there too. Use **REBIRTH** to see its requirements, and **TRAVEL** to get around your plot.
6. For multiplayer testing, publish via **File → Publish to Roblox**, then set maximum players to **6** in Creator Dashboard. Use Studio's **Test → Server & Clients** too. You must configure the player limit yourself.

Alternative: `rojo build default.project.json -o RollABrainrot.rbxlx` creates a place file you can open in Studio. Do not move scripts into different folders.

### More gameplay controls

- **Auto-roll:** at your roll station, tap the rarity filter to choose the minimum rarity, then start auto-roll. It buys matching drops every two seconds using your cash, and stops when you move away, run out of cash or fill your part inventory. This is currently a free prototype feature, not a gamepass.
- **Auto-fill:** in the assembly menu, this chooses an estimated strongest owned part for each socket. You can change its selections before assembling.
- **Extra stands:** buy stands 13–24 in UPGRADES. Stand 13 requires rebirth 1, stand 14 rebirth 2, and so on. Your extra stands persist through rebirth.
- **Selling:** choose an item in BACKPACK and confirm the sale. Remove a creature from its stand before selling it. Sales are permanent.

## Saving and Studio testing

- Published servers attempt to save in Roblox DataStore `RollABrainrotProfiles_v1`, with a session lease, periodic saves, retries and a shutdown save. A failed load kicks the player instead of silently overwriting data. Offline income is not implemented.
- **Studio defaults to temporary in-memory data**, so progress resets on leaving. To test real persistence, publish a **separate test experience**, enable **Game Settings → Security → Enable Studio Access to API Services**, then set `DataService.TestPersistence = true` in `src/server/Services/DataService.luau` and sync with Rojo. Studio API access can affect the published experience's actual data, so never test on your live game. Set the flag back to `false` after testing.
- Verify rejoin, two concurrent sessions, save errors and shutdown in the test experience before trusting the system with real players. Roblox services can fail; unsuccessful final saves can lose progress.

## Troubleshooting

- **No world or UI:** check Rojo connection and press Play, not Run. Open **View → Output** for errors. The synced locations are ReplicatedStorage/Shared, ServerScriptService/Game and StarterPlayer/StarterPlayerScripts/GameClient.
- **Cannot roll or assemble:** use your own plot and stay within 20 studs of the station. The prompt opens the menu; use its button to act.
- **Cannot buy:** check your balance and 100-part limit. Rerolling discards unpurchased offers.
- **Kicked while loading:** DataStore may be unavailable or the previous server's lease is still active; wait a few minutes and retry. Check Output for errors.
- **Studio data resets:** this is the default. See the saving section above.

The catalog contains names that may involve third-party intellectual property; review names and obtain appropriate rights before publishing.

## Developer checks

`python3 tests/check_config.py` checks catalog structure. With the standalone Luau CLI installed, run `python3 tests/run_luau_tests.py` and `python3 tests/run_persistence_tests.py` (or pass the path to `luau` as an argument). The persistence test uses a synchronous mock, **not** Roblox DataStore services. These checks do not replace Studio or published multiplayer tests.
