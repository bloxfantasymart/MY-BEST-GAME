# Testing the development build

These steps are for a **private test experience**, not your public game. The automatic checks in the README do not run Roblox Studio or prove that the game is safe to release.

## 1. Start the game

1. Follow the Rojo connection steps in the README. In Roblox Studio, use **View → Output** to see errors.
2. Click **Play**. Your character should appear near your plot. Check that the plot has a nameplate, three stations and 24 stands; the first 12 should be yellow and the rest gray.
3. Walk to the red station and use its prompt. Pull the lever; check that a tray shows an offer. Buy it or press its Skip button. Try walking away and trying to roll: the server should reject the action.
4. Keep rolling and buying until you have a Head, Chest, Arms and Legs. Go to the purple pod. Select each part (or use auto-fill), then assemble. Verify the parts disappear and the creature appears in the backpack.
5. Use a yellow stand prompt and select the creature. It should appear, move gently and earn pending cash. Step on the green pad or tap the cash counter to collect. Check the displayed balance and level increase over time.
6. Test inventory filtering, selling confirmation, paid leveling, travel and upgrades. Selling is permanent. Test auto-roll only after reading its warning: it spends cash. Move away from the station and check it stops.
7. Check the **HELP** menu, the two plaza leaderboards and the event countdown. The leaderboards cover the current server only. Use Studio's device emulator and a real mobile device to check that buttons and text remain usable.

## 2. Test multiple players

In Studio's **Test** tab start a server with two or more clients. Each player should get a different plot. A player must not be able to buy from another player's roll station, place creatures on another plot, or collect another plot's bank. Check that leaderboards update. Studio's default test profiles are temporary, even after a rejoin.

## 3. Test real saving carefully

1. Publish a **separate private test experience**, then follow the README's instructions to enable Studio API access and `DataService.TestPersistence`. Studio can modify real DataStore data for that experience.
2. Earn cash, buy parts, craft and place a creature, then stop and rejoin. Check cash, inventory, levels and placements. Test upgraded stands when you've earned them. Do not assume a single successful test proves saving is reliable.
3. Try a second session on the same account: it must not load while the first session holds its lease. If a server crashes, the lease can take up to 180 seconds to expire. A failed load should not create a fresh profile.
4. Test server shutdown, disconnect during saves, service errors, and retry/rejoin behavior in a controlled private environment. Check Output for warnings. An unsuccessful final save can still lose progress.
5. Restore `DataService.TestPersistence = false` after testing in Studio. Published servers use the live DataStore regardless of this Studio-only switch.

## 4. Before publishing broadly

Trading, paid products and passes are not implemented. Complete and test them separately before charging players. Review third-party character names, licensed assets and Roblox policies. Check performance with a full six-player server, including many placed creatures and events. Event timings are relative to each server's start, so two servers need not have the same event.
