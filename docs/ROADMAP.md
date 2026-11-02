# Implementation roadmap and decisions

## Stage 1 — prototype in this repository
- Procedural plaza, six assigned plots, lever/pod/ATM and 12 stands per plot.
- Server-generated weighted rolls, four body-part types, 50 catalog rows, nine slot prices, server-owned purchase/assembly/income/placement and basic remote throttling/proximity checks.
- Starting cash $200 and part price `max(10, floor(base income * 5))` are prototype balancing choices because the specification does not define them. Slot upgrades and the HUD collect button work from anywhere. Rolls select a weighted eligible rarity then an archetype uniformly in that tier; luck adjusts tier weights. The requested exact chance labels are not displayed because actual odds depend on unlocked tiers and luck.
- Income is the sum of four part base incomes times the highest rarity multiplier times 0.4. Ties use the first component in Head, Chest, Arms, Legs order. Only whole pending dollars are collected; fractions remain in the bank.
- A player's in-memory data and plot are discarded on leaving; no offline income. No mutation, level, rebirth, saving, animation, sound, trading, shop, admin, live events or monetization yet. The UI is functional placeholder UI and hasn't been validated on devices.

## Stage 2 — durability and progression
Add session-locked, migration-aware persistence and safe save/retry/shutdown behavior, tests for data loss and concurrent sessions, mutation and level progression, and a defined reachable rebirth sacrifice table. The prompt's example requiring a rebirth-5 locked part for rebirth 5 is unreachable if that means moving from tier 4 to 5; choose and document a corrected rule before implementation. Consider retention, storage limits and economy balancing.

## Stage 3 — presentation and accessibility
Polish responsive touch/PC UI, physical displays, visual effects, animations, sound, live events and expanded stands. Obtain or create properly licensed assets. Test real devices.

## Stage 4 — trading and monetization
Implement a separately configured trading place, secure atomic transfers, booth and direct trades, and extensive exploit/data-loss tests before enabling. Roblox DataStores do not provide a transaction spanning two player profiles; design a recoverable transaction protocol rather than assuming two independent saves are atomic. Set experience/place IDs, server limits, product IDs and prices in Creator Dashboard. Developer product rewards must use server receipt handling and idempotency. Do not enable paid purchases before testing fulfillment and recovery.

## Release checklist
Run Studio multiplayer tests including rejoin, shutdown, proximity abuse, malformed requests and simultaneous purchase attempts. Audit all copyrighted names and assets, platform policy and paid-random-item rules. Publish only after persistence and paid flows are independently verified. Exact event behavior, mutations, 24-stand upgrades, auto-roll, pass benefits, per-tier skip products, admin permissions, and the complete rebirth target mapping still require implementation and/or design decisions.
