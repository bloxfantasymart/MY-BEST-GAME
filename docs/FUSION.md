# Ascension forge

The forge is the orange station in the **main plaza**, not the showcase hub. Use **TRAVEL → FUSION FORGE** or walk there. You must be at least rebirth 15.

## Recipe

1. Own three **different**, non-ascended creatures, each at level 10 or higher. Remove all three from their stands.
2. Their Head, Chest, Arms and Legs must match exactly: same archetype, rarity, mutation and part income for each position. The three creatures must also have the same base income. Their individual levels can differ, but all must be at least 10. The original purchase price of the parts does not need to match.
3. The fee is `max($10,000, floor(one creature's base income × 100))`. The menu shows the fee for the first selected creature. The server checks the recipe, ownership, distance and balance again on confirmation.
4. Select all three, tap **FUSE SELECTED** and read the warning, then confirm. **All three creatures and the fee are permanently consumed.** You receive one ascended creature starting at level 1, with five times the original base income. Higher input levels are not preserved. You cannot fuse already-ascended creatures.

This game's current level cap is 1,000, so the minimum is level 10 rather than the original specification's proposed max-level-10 requirement. An ascended creature has a simple gold crown. It resells for half the original prices of its one retained set of parts, not the value of all three consumed creatures. Standard rebirths require a **non-ascended** sacrifice so an ascended creature is not removed by accident.

## Neighbor bonuses

The 24 stands form four rows of six. An ascended creature on a stand adds 20% to the income of each occupied stand directly above, below, left or right. Diagonals do not count, and the ends of rows do not wrap. Two ascended neighbors add 40%, three add 60%, and four add 80%. Each ascended creature can also receive a neighbor bonus from a different ascended creature; it does not boost itself.

Stand labels show the creature's income including neighboring bonuses but excluding temporary events and VIP. Sigma, weekend and VIP multipliers are applied to that amount when income is earned. Offline income includes the neighbor bonuses, but not events or VIP, and pays at 25% for at most 24 hours. The backpack and showcase list display an individual creature's rate without neighboring bonuses.

This is an unfinished development build. Test fusion, persistence, rejoin and hub display in a private test experience before trusting it with valuable creatures. Both places must be updated to the current code. See [TESTING.md](TESTING.md).
