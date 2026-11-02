# Testing the development build

These steps are for a **private test experience**, not your public game. The automatic checks in the README do not run Roblox Studio or prove that the game is safe to release.

## 1. Start the game

1. Follow the Rojo connection steps in the README. In Roblox Studio, use **View → Output** to see errors.
2. Click **Play**. Your character should appear near your plot. Check that the plot has a nameplate, three stations and 24 stands; the first 12 should be yellow and the rest gray.
3. Check the tutorial goal and station highlight. Walk to the red station and use its prompt. Pull the lever; check that a tray shows an offer. Buy it or press its Skip button. Try walking away and trying to roll: the server should reject the action.
4. Keep rolling and buying until you have a Head, Chest, Arms and Legs. Go to the purple pod. Select each part (or use auto-fill), then assemble. Verify the parts disappear and the creature appears in the backpack.
5. Use a yellow stand prompt and select the creature. It should appear, move gently and earn pending cash. Step on the green pad or tap the cash counter to collect. Check the displayed balance and level increase over time. Verify tutorial completion grants $1,000 once, stays complete after rejoining, and does not pay again.
6. Open **UPGRADES → PLOT THEMES** and select an unlocked theme; locked themes must not apply. Check the title above your avatar after respawning. Test inventory filtering, selling confirmation, paid leveling, travel and upgrades. Selling is permanent. Auto-roll requires rebirth 5 or the configured pass. Test it only after reading its warning: it spends cash. Move away from the station and check it stops.
7. Open **REWARDS → HOW TO PLAY**, check the two plaza leaderboards and the event countdown. The leaderboards cover the current server only. Use Studio's device emulator and a real mobile device to check that buttons and text remain usable.

### Fusion and neighboring stands

In a private test profile at rebirth 15 or above, prepare three distinct, unplaced, non-ascended creatures with the same four components and mutations, each at level 10 or higher. At the plaza forge, check that too little cash, different mutations, a placed creature, repeated selections and rebirth below 15 cannot consume anything. Confirm a valid fusion; verify exactly three inputs and the fee disappear, and one level-1 ascended creature with 5x base income appears. Place it next to another creature: the adjacent stand's displayed rate should rise by 20%. Test corners, row edges, multiple ascended neighbors and removal. Save/rejoin and visit the hub to check the flag and appearance survive. Also verify offline income includes adjacency once. These behaviors need real Studio and published-environment testing, not just the pure-logic checks.

### Session gifts and roll expiry

In a private server, open **REWARDS** and try claiming each session gift early; it must not grant anything. After one minute, claim the cash gift twice and verify only the first claim pays. After five minutes, claim the Uncommon part with space available; repeat with a full inventory and ensure it remains claimable after freeing space. At 15 minutes, claim the timed luck boost, verify the countdown and boosted tier odds, then rejoin or visit the hub and check the boost continues until its saved expiry. Rejoining resets the session gift timer and allows gifts to be earned again. The rest of the specified gifts have not been implemented.

Roll a part and leave the offer unpurchased for more than 60 seconds. Its tray should clear and a late buy request must not deduct cash or grant the item. Check that auto-roll still refreshes its own offers. Compare auto-fill's selected income against different mixed and same-mutation combinations.

### Daily rewards and objectives

Open **REWARDS**, claim the daily reward twice, and check that only the first claim pays. Roll 50 parts (multi-slot rolls count each part), then claim the roll objective once. Complete the other objectives and verify each can only pay once. UTC midnight resets the objectives. Verify a missed UTC day resets the login streak; Studio clock changes alone should not be trusted as a server-time test.

## 2. Test multiple players

In Studio's **Test** tab start a server with two or more clients. Each player should get a different plot. A player must not be able to buy from another player's roll station, place creatures on another plot, or collect another plot's bank. Check that leaderboards update. Studio's default test profiles are temporary, even after a rejoin.

## 3. Test real saving carefully

1. Publish a **separate private test experience**, then follow the README's instructions to enable Studio API access and `DataService.TestPersistence`. Studio can modify real DataStore data for that experience.
2. Earn cash, buy parts, craft and place a creature, then stop and rejoin. Check cash, inventory, levels and placements. Leave a creature on a stand, leave for a few minutes, then return and verify the 25% capped offline amount appears in pending cash only once. Test entering and returning from the hub too. Test upgraded stands when you've earned them. Do not assume a single successful test proves saving is reliable.
3. Try a second session on the same account: it must not load while the first session holds its lease. If a server crashes, the lease can take up to 180 seconds to expire. A failed load should not create a fresh profile.
4. Test server shutdown, disconnect during saves, service errors, and retry/rejoin behavior in a controlled private environment. Check Output for warnings. An unsuccessful final save can still lose progress.
5. Restore `DataService.TestPersistence = false` after testing in Studio. Published servers use the live DataStore regardless of this Studio-only switch.

## 4. Before publishing broadly

The optional [showcase hub](TRADING_HUB_SETUP.md) is not a marketplace yet. Trading and developer products are not implemented. Optional gamepass hooks are disabled by default; see the [gamepass guide](GAMEPASS_SETUP.md) and do not enable public sales before testing. Complete and test them separately before charging players. Review third-party character names, licensed assets and Roblox policies. Check performance with a full six-player server, including many placed creatures and events. Event timings are based on UTC, so servers should agree when their clocks agree.

## Deploying schema changes

Update and publish both the main place and the hub when scripts or profile fields change. Existing servers can continue running older code after publishing; shut down old private test servers before testing new profile fields, or an old server could save without them. Do not rely on production data until save/rejoin and cross-place compatibility have been verified.
