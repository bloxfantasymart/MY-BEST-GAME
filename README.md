# Roll a Brainrot — stage 1 playable prototype

This repository contains the first stage of your Roblox game. It generates a world and six plots, lets you roll and buy parts, assemble mixed creatures, put them on 12 stands, collect their income and unlock up to nine roll slots. All gameplay decisions are made by the server.

**Important: progress is temporary and resets whenever you leave. This is not a finished or production-ready game. Do not sell paid items or publish it as finished yet.** Roblox Studio is required to test; the project has not been tested in Studio in this environment.

## Beginner setup, step by step

1. Install [Roblox Studio](https://create.roblox.com/) and sign in. Create a new **Baseplate** experience.
2. Install [Rojo 7.7](https://rojo.space/docs/v7/getting-started/installation/) on your computer and install its Roblox Studio plugin. Download this repository to your computer (GitHub → **Code** → **Download ZIP**, then extract it).
3. Open a terminal in the extracted folder (the folder containing `default.project.json`) and run `rojo serve`.
4. In Studio open the **Plugins** tab, select **Rojo**, and connect to the server (normally `localhost:34872`). This syncs the scripts into the appropriate Roblox services. Keep Rojo running while editing.
5. Press **Play**. Walk to your red roll station and use its prompt. Click **PULL LEVER**, then buy parts. You start with $200; rolling itself is free. Reroll until you have a Head, Chest, Arms and Legs. Walk to the purple assembly pod, select each part, and assemble. Walk to a yellow stand and select the creature. Use the cash HUD or green ATM to collect income. Buy extra roll slots with the **SLOTS +** button.
6. To test with friends, publish the place using **File → Publish to Roblox**, and set the experience's maximum players to **6** in Creator Dashboard. This setting is not controlled by the scripts. Test with Studio's **Test → Server & Clients** mode too.

Alternative: `rojo build default.project.json -o RollABrainrot.rbxlx` creates a place file you can open in Studio. Do not copy scripts into arbitrary folders: their locations matter.

## What is and isn't included

See [the implementation roadmap](docs/ROADMAP.md) for scope, limitations, assumptions and future stages. The 50 requested catalog entries are present, but only the eight rebirth-0 entries can currently roll. Starter models are colored geometric placeholders, not branded characters. Some requested names may involve third-party intellectual property; review them before publishing.

## Troubleshooting

- **No world or UI:** make sure Rojo is connected and press Play, not Run. Check **View → Output** for errors. The three synced locations are ReplicatedStorage/Shared, ServerScriptService/Game, and StarterPlayer/StarterPlayerScripts/GameClient.
- **Cannot roll or assemble:** use your own plot and stand within 20 studs of the station. The station prompt opens its menu; then use the button inside it.
- **Cannot buy:** check your balance and the 100-part inventory limit. Rerolling replaces any unpurchased offers.
- **Nothing saves:** expected in stage 1. Do not enable Studio API access expecting it to save yet.
