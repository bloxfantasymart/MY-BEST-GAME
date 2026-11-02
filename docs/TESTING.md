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

In a private server, open **REWARDS** and try claiming each session gift early; it must not grant anything. After one minute, claim the cash gift twice and verify only the first claim pays. After five minutes, claim the Uncommon part with space available; repeat with a full inventory and ensure it remains claimable after freeing space. At 15 minutes, claim the timed luck boost, verify the countdown and boosted tier odds, then rejoin or visit the hub and check the boost continues until its saved expiry. Rejoining resets the session gift timer and allows gifts to be earned again. At 3 minutes, test vouchers as described below; at 60 minutes test the Epic+ gift with a full bag and with space; at 90 minutes claim the crown, respawn, rejoin and visit the hub. A duplicate crown pays $100,000. At 25 minutes claim the rare blueprint and test it as described below. Three unspecified gift tiers remain unimplemented.

Roll a part and leave the offer unpurchased for more than 60 seconds. Its tray should clear and a late buy request must not deduct cash or grant the item. Check that auto-roll still refreshes its own offers. At the roll station, use a voucher on an offer and verify no cash is deducted; retry the same offer, move away, fill inventory, and wait for expiry to check no voucher is consumed. Check auto-roll still uses cash. Compare auto-fill's selected income against different mixed and same-mutation combinations.

### Daily rewards and objectives

Open **REWARDS**, claim the daily reward twice, and check that only the first claim pays. With controlled test profiles, check all seven streak days, potion/voucher caps, duplicate unlock cash, 3x potion countdown and stacking, Golden Lever odds, and Sigma Statue income online and offline. Verify the unlock visuals, save/rejoin, hub round trip and plot cleanup. Verify the 60-minute gift tier distribution against the shown weights. Roll 50 parts (multi-slot rolls count each part), then claim the roll objective once. Complete the other objectives and verify each can only pay once. UTC midnight resets the objectives. Verify a missed UTC day resets the login streak; Studio clock changes alone should not be trusted as a server-time test.

### Catalog and roll odds

From **REWARDS → CATALOG & ROLL ODDS** or the roll station, browse all 50 entries, search by name, change rarity and unlocked-only filters, and test both page arrows. At several rebirths check locked/unlocked entries, current tier percentages, unlocked archetype counts, base prices and uniform per-archetype chances. Refresh during Frenzy, weekend, and timed luck boosts, and (only in a private pass-test experience) after verifying the Luck pass. Golden Lever changes non-Common weights by 1.05; it does not multiply the displayed probability by 1.05. Compare the server snapshot with the tier probability printed on newly rolled offers, allowing for event or boost changes between requests. Verify mutation percentages total 100% and each part type is 25%; session gift odds use a different calculation. Snapshots are timestamped and can become stale: refresh after rebirth or modifier changes. Test on mobile as well as PC. Automated statistical sampling is not a substitute for Roblox testing.

### Blueprint and backpack upgrades

Claim the 25-minute blueprint in a private server. At the assembly pod, toggle it on and check that Auto-Fill selects only unprotected Rare+ parts. Try a missing, protected, duplicate, Common or Uncommon part, no blueprint, a full creature inventory and a forged non-boolean setting: none should consume the blueprint or any parts. Confirm a valid four-Rare+ assembly and compare its base income with the same recipe without a blueprint: it should be 25% higher, in addition to any matching-mutation bonus. Check it persists after rejoin and the hub, earns income on a stand, and can fuse only with matching blueprint-boosted creatures. Test the blueprint cap without consuming an unclaimable gift.

Buy backpack upgrades under **UPGRADES** with sufficient and insufficient cash. Each should charge once and add five part slots, up to ten upgrades; check the maximum, save/rejoin, rebirth, auto-roll, gift claims and hub round trip. A verified Backpack pass adds 100 slots, up to 250 total; do not enable public sales. Test a temporary entitlement failure with extra items present: existing items must remain, but capacity can be reduced until ownership is verified. **Update and publish both places and shut down old servers first**, because older servers may reject or discard the new fields or expanded inventory.

### Auto-roll safety and per-rarity rules

In a private test profile at rebirth 5, start with no current offers and open **CONFIGURE AUTO-ROLL**. Verify the defaults skip Common/Uncommon and hold all higher tiers, and that starting with existing offers is refused until you buy, skip or confirm discarding them. Check Skip removes only unpurchased offers; Hold stops and leaves that and later slots for review until their normal 60-second expiration. Configure Buy on several tiers, enter low total and per-part cash limits and a small batch limit, review and confirm; ensure slot order, amounts spent, counters and stopping reason are correct. Test exact budget/price boundaries, insufficient cash, full inventory, multiple slots, a held item after earlier purchases, manual-buy requests during a run, stopping, moving away, entitlement loss and repeated starts. Test malformed/forged settings, missing rules, fractional or negative limits and an oversized batch count; none should start a run. Auto-roll uses cash, not vouchers; manually buying after stopping is outside the run budget. Leave/rejoin and confirm it never starts automatically. Repeat with two players near different stations. Use small test amounts: sales and purchases are real profile changes.

### Auto-collector and income breakdown

In a private test experience, open **UPGRADES** below rebirth 10 and verify the auto-collector cannot be enabled, including by a forged request. At rebirth 10, turn it on and place a creature. Verify whole dollars transfer approximately every 10 seconds, fractional pending cash remains, an empty bank is not repeatedly collected, and daily ATM collection progress advances exactly once. Test the tutorial, manual collection just before the timer, rapid toggles, leaving/rejoining, travelling through the hub, and a failed profile load. While offline or in the hub there is no auto-collection; normal offline earnings still apply on main-place load. Disable the drone and confirm collection stops and its placeholder visual disappears. If using the private admin tool, reduce rebirth below 10 and check it switches off. Make sure a departing player's drone does not appear for the next plot owner.

Open **UPGRADES → PLOT INCOME BREAKDOWN**, compare the displayed rates with placed creatures, level changes and ascension neighbors, then check the Sigma Statue and available events. Test VIP only in an appropriate private pass-testing environment. The online estimate should reflect live bonuses; offline excludes VIP and events, includes the statue and caps at 24 hours. Verify the display on mobile and check actual collection under server load: rates are estimates and delays can lower real online income.

### Backpack safety and browsing

In a private test profile, obtain several parts and creatures. Open **BACKPACK** and test all four tabs, literal name/type/mutation search, each protection filter and sort order, and both page arrows with more than 20 matching items. Select an item and protect it, then try individual sale, bulk sale, assembly/autofill, fusion and rebirth sacrifice as applicable. None may consume a protected item, even with forged or stale requests; verify an attempted mixed bulk sale cancels completely. A protected creature should still be placeable and levelable. Unprotect and repeat a sale or craft deliberately. Bulk sale ignores browsing filters and covers all unprotected parts up to the selected rarity; review the count and value and cancel once before confirming. Check protection after save/rejoin and hub visits, and test on mobile as well as PC. Always update both places and shut down old servers before testing new saved fields.

### Free season track and repeatable rolls

In a private test place, open **REWARDS → OPEN FREE SEASON TRACK**. Roll parts with one and multiple slots and check +1 XP and one objective count per generated part, including unpurchased offers and auto-roll. Assemble a creature (+20 XP), rebirth (+100 XP), and claim each daily objective (50/75/100 XP, only once). Verify a tier cannot be claimed early, earned tiers are claimed in order exactly once, cash/potions/vouchers match the shown reward, and full potion or voucher inventories prevent the relevant claim without consuming it. Roll at least 500 parts and claim the repeatable objective twice, verifying excess carries over and the voucher cap blocks a claim without losing progress. Save/rejoin and visit the hub to check XP, claims and progress survive; old profiles should start at zero. Also test two clients and forged/repeated requests. This permanent prototype has no premium purchase or season reset.

## 2. Test multiple players

In Studio's **Test** tab start a server with two or more clients. Each player should get a different plot. A player must not be able to buy from another player's roll station, place creatures on another plot, or collect another plot's bank. Check that leaderboards update. Studio's default test profiles are temporary, even after a rejoin.

## 3. Test real saving carefully

1. Publish a **separate private test experience**, then follow the README's instructions to enable Studio API access and `DataService.TestPersistence`. Studio can modify real DataStore data for that experience.
2. Earn cash, buy parts, craft and place a creature, then stop and rejoin. Check cash, inventory, levels and placements. Leave a creature on a stand, leave for a few minutes, then return and verify the 25% capped offline amount appears in pending cash only once. Test entering and returning from the hub too. Test upgraded stands when you've earned them. Do not assume a single successful test proves saving is reliable.
3. Try a second session on the same account: it must not load while the first session holds its lease. If a server crashes, the lease can take up to 180 seconds to expire. A failed load should not create a fresh profile.
4. Test server shutdown while joins are in flight in both places, duplicate join attempts, disconnect during saves, copy/validation errors, service errors, and retry/rejoin behavior in a controlled private environment. Verify new joins do not start once shutdown begins, late successful loads are released, shutdown waits for in-flight joins up to its 25-second deadline, and invalid snapshots never overwrite valid data. Check Output for warnings. An unsuccessful final save can still lose progress.
5. Restore `DataService.TestPersistence = false` after testing in Studio. Published servers use the live DataStore regardless of this Studio-only switch.

## 4. Optional admin and performance tests

Follow [ADMIN_SETUP.md](ADMIN_SETUP.md) in a private test experience. Confirm an unauthorized account cannot open the panel or execute forged remote requests, and check numeric boundaries, confirmations, the selected target, event expiry and save/rejoin. Admin actions affect real profile data. Test display motion and mutation effects at distances below and above 100 studs with multiple players; repeat with streaming enabled and check that models load correctly. This lightweight LOD has not been validated on devices.

## 5. Before publishing broadly

The optional [showcase hub](TRADING_HUB_SETUP.md) is not a marketplace yet. Trading and developer products are not implemented. Optional gamepass hooks are disabled by default; see the [gamepass guide](GAMEPASS_SETUP.md) and do not enable public sales before testing. Complete and test them separately before charging players. Review third-party character names, licensed assets and Roblox policies. Check performance with a full six-player server, including many placed creatures and events. Event timings are based on UTC, so servers should agree when their clocks agree.

## Deploying schema changes

Update and publish both the main place and the hub when scripts or profile fields change. Existing servers can continue running older code after publishing; shut down old private test servers before testing new profile fields, or an old server could save without them. Do not rely on production data until save/rejoin and cross-place compatibility have been verified.
