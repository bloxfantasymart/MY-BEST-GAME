# Roll a Brainrot — playable development build

This repository contains an **unfinished Roblox game**: a generated six-plot world, server-owned rolling and crafting, stands and income, mutations, leveling, rebirths, UTC-synchronized events, daily quests, timed session gifts and rewards, a guided tutorial, plot themes and titles, an ascension forge, capped offline earnings, animated placeholder displays and a first persistence implementation. The separate hub currently supports showcases only; item trading, developer products and many polish features are not yet implemented. Optional gamepass hooks exist but are disabled until configured. See [the roadmap](docs/ROADMAP.md).

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

- **Tutorial:** follow the goal at the top left and the highlighted station. Complete all six server-verified steps for a one-time $1,000 bonus. The tutorial state is saved with your profile; older profiles can complete it too.
- **Plot themes and titles:** choose **UPGRADES → PLOT THEMES**. Themes unlock at rebirth 0, 10, 25, 50 and 100 and are cosmetic. Rebirth titles appear above your character automatically.
- **Rare announcements:** Mythic or higher roll offers can be announced to the current server. An announced offer has not necessarily been purchased.
- **Auto-roll:** at your roll station, tap the rarity filter to choose the minimum rarity, then start auto-roll. It buys matching drops every two seconds using your cash, and stops when you move away, run out of cash or fill your part inventory. It unlocks at rebirth 5, or earlier with the optional AutoRoll gamepass (if configured).
- **Auto-fill:** in the assembly menu, this finds the highest-income four-part combination in your current inventory, including the identical-mutation bonus. You can change the selection before assembling.
- **Fusion forge:** at rebirth 15+, use the orange forge in the plaza. Select three different, unplaced, non-ascended creatures at level 10 or higher with exactly matching four components and mutations. Confirming permanently consumes all three and the displayed cash fee. The result starts at level 1 with five times one input's base income. Place it to boost each occupied neighboring stand by 20%; boosts from multiple neighbors add. Rebirth sacrifices require a non-ascended creature. See the [forge guide](docs/FUSION.md) before using it.
- **Extra stands:** buy stands 13–24 in UPGRADES. Stand 13 requires rebirth 1, stand 14 rebirth 2, and so on. Your extra stands persist through rebirth.
- **Selling:** choose an item in BACKPACK and confirm the sale. Bulk-sale controls can sell selected rarity tiers, including mutated parts, after confirmation. Remove a creature from its stand before selling it. Sales are permanent; a creature resells for half the total original prices of its four parts.
- **REWARDS** opens daily rewards, quests and eight timed session gifts; its **HOW TO PLAY** button explains the loop. Plaza leaderboards show only the current server, not all players worldwide. Roll offer odds are for a rarity tier, not a specific item or mutation.
- **Developer admin:** disabled by default. Trusted developers can configure their numeric user IDs and use a server-checked test menu; see [the admin guide](docs/ADMIN_SETUP.md). Its actions can change real saved data.
- **Gamepasses:** the shop is under **UPGRADES**. All pass IDs are zero by default, so purchases are disabled. See [gamepass setup and limitations](docs/GAMEPASS_SETUP.md) before changing them.
- **Showcase hub:** there is a disabled-by-default portal to a separate place with 15 booths. Configure it using [the hub setup guide](docs/TRADING_HUB_SETUP.md). There are no sales or trades yet.
- **Audio:** the game is silent by default. To add sounds you have permission to use, replace the `0` values in `Config.AudioIds` in `src/shared/Config.luau` with your Roblox audio asset IDs; sync using Rojo. Roblox must allow your experience to use the assets.

### Daily rewards, session gifts and offline cash

- Open **REWARDS** for daily login rewards and three daily objectives. UTC midnight starts a new day; missing a day resets the seven-day streak. The seven rewards are $1,000, three 15-minute 3x luck potions, Golden Lever, $50,000, three free-part vouchers, $250,000, and Sigma Statue. Duplicate lever/statue unlocks pay $5,000/$100,000 instead. Existing cash-only streaks continue from their saved day; past claims are not changed retroactively.
- The Golden Lever multiplies non-Common rarity weights by 1.05, not the final probability. The Sigma Statue multiplies stand income (including offline income) by 1.5. Potions multiply non-Common weights by 3 for 15 minutes; active potions add duration, and combine with other weight boosts. These items and expiry times are saved with the profile. The visuals are simple procedural placeholders.
- Eight session gifts are claimable at 1, 3, 5, 10, 15, 40, 60 and 90 minutes: $500, five free-part vouchers, a random Uncommon part, $15,000, a 10-minute 2x luck boost, $100,000, a random Epic+ part, and the Ohio Crown. An already-owned crown pays $100,000 instead. Session timers and claims reset on leaving or entering the hub; rejoining allows gifts to be earned again, so this needs economy balancing before release. Part gifts require space and can bypass normal rebirth unlocks. The Epic+ gift uses fixed weights 600:200:50:10:1 for Epic through Secret, unaffected by luck, and always has Standard mutation. The requested blueprint and three unspecified gift tiers remain unimplemented.
- Rolls already cost nothing: a **free-part voucher** instead buys one currently displayed offer without cash. At the roll station select the voucher button for a part before the offer expires; normal distance and inventory limits apply. Vouchers can be used on expensive parts, which retain their normal resale value. Potions are used from **REWARDS**; saved boosts continue counting down while offline. Inventories cap at 100 potions and 1,000 vouchers; use some before claiming a reward that would exceed the cap.
- **REWARDS → OPEN FREE SEASON TRACK** shows a prototype 50-tier free track. Every 100 season XP unlocks a tier; claim tiers in order. Each rolled part earns 1 XP, each assembly 20, each rebirth 100, and the three daily quest claims add 50, 75 and 100 XP. Progress starts when this update is installed, is not retroactive, and is capped at 5,000 XP. Tiers cycle through cash ($1,000 times the tier number), a 3x potion, and two free-part vouchers. Use inventory items first if a claim would exceed a cap. This is a permanent prototype track, not a time-limited season; premium rewards, backpack slots and crates are not implemented.
- The same screen has a repeatable objective: roll 250 body parts and claim one free-part voucher. Multi-slot pulls count each generated part, including offers you don't buy; excess progress carries over, up to 250,000 unclaimed rolls. The requested multi-roll token is substituted by a free-part voucher because rolls already cost nothing. Existing daily quests remain fixed rather than randomized and still award cash, plus the season XP above.
- Your placed creatures earn 25% of their normal base stand income while you are away, for up to 24 hours. This amount is added to your pending bank when you return to the main place. Adjacent ascension bonuses are included; event multipliers and offline EXP are not. If a server crashes or the final save fails, offline time may not be recorded.
- Events use a shared UTC schedule across servers. Every Friday 17:00 UTC through Sunday 23:59 UTC, Weekend Frenzy increases non-common rarity weights by 1.5 and stand income by 2. See the roadmap for how multipliers stack.

## Saving and Studio testing

- Published servers attempt to save in Roblox DataStore `RollABrainrotProfiles_v1`, with a session lease, periodic saves, retries and a shutdown save. A failed load kicks the player instead of silently overwriting data. Offline income requires a successfully recorded departure; it is capped at 24 hours and is credited atomically when loading the main place.
- **Studio defaults to temporary in-memory data**, so progress resets on leaving. To test real persistence, publish a **separate test experience**, enable **Game Settings → Security → Enable Studio Access to API Services**, then set `DataService.TestPersistence = true` in `src/server/Services/DataService.luau` and sync with Rojo. Studio API access can affect the published experience's actual data, so never test on your live game. Set the flag back to `false` after testing.
- Verify rejoin, two concurrent sessions, save errors and shutdown in the test experience before trusting the system with real players. Roblox services can fail; unsuccessful final saves can lose progress.

## Troubleshooting

- **No world or UI:** check Rojo connection and press Play, not Run. Open **View → Output** for errors. The synced locations are ReplicatedStorage/Shared, ServerScriptService/Game and StarterPlayer/StarterPlayerScripts/GameClient.
- **Cannot roll or assemble:** use your own plot and stay within 20 studs of the station. The prompt opens the menu; use its button to act.
- **Cannot buy:** check your balance and body-part capacity (100 normally; 200 with the configured Backpack pass). Rerolling discards unpurchased offers, and remaining offers expire after 60 seconds.
- **Kicked while loading:** DataStore may be unavailable or the previous server's lease is still active; wait a few minutes and retry. Check Output for errors.
- **Studio data resets:** this is the default. See the saving section above.

The catalog contains names that may involve third-party intellectual property; review names and obtain appropriate rights before publishing.

For a more detailed step-by-step verification list, see [Studio testing](docs/TESTING.md).

## Developer checks

`python3 tests/check_config.py` checks catalog structure. With the standalone Luau CLI installed, run `python3 tests/run_luau_tests.py`, `python3 tests/run_persistence_tests.py`, `python3 tests/run_booth_tests.py`, `python3 tests/run_progression_tests.py`, `python3 tests/run_pass_tests.py`, `python3 tests/run_inventory_tests.py`, `python3 tests/run_tutorial_tests.py`, `python3 tests/run_fusion_tests.py`, `python3 tests/run_autofill_tests.py`, `python3 tests/run_session_tests.py`, `python3 tests/run_admin_tests.py`, `python3 tests/run_reward_tests.py` and `python3 tests/run_season_tests.py` (or pass the path to `luau` as an argument). The persistence test uses a synchronous mock, **not** Roblox DataStore services. These checks do not replace Studio or published multiplayer tests.
