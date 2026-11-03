# Optional gamepasses — setup and safety

**All gamepasses are disabled by default. The shop is an unfinished development feature and has not been tested against Roblox's live MarketplaceService here. Do not enable public sales until you have tested ownership, prompts, benefits, persistence, service errors and your compliance obligations in a private test experience.** Developer products, receipt handling, paid rebirth skips and trading purchases are not implemented.

## What currently works in code

| Config key | Benefit in this development build |
| --- | --- |
| `Luck` | Doubles the weights of non-common rarity tiers; it does not necessarily double the final probability of each tier. Stacks with event weight multipliers. |
| `AutoRoll` | Allows auto-roll before rebirth 5. Everyone can use auto-roll at rebirth 5. It spends in-game cash. |
| `KeepSlots` | Keeps unlocked roll slots after a standard rebirth. Cash still resets and the sacrifice is still consumed. |
| `Backpack` | Adds 100 body-part slots to the cash-upgraded capacity of 100–150 and up to 15 season milestone slots, for a maximum of 265. It does not expand the 100-creature cap. |
| `VIP` | Adds 20% to **online** stand income. VIP chat tags, booth skins and improved offline income are not yet implemented. |

Only sell a pass if its actual listing description accurately describes the benefits that are implemented and you are ready to support it. The full specification requests additional benefits not yet present. The current code displays the descriptions above; Roblox's purchase dialog supplies the actual price.

## Configure a private test experience

1. Publish the latest main place **and** showcase hub code to your private test experience. The hub shares the profile schema: older hub code may reject an inventory containing more than 100 parts. Update both places before testing the expanded backpack.
2. In Creator Dashboard, create a **gamepass** for the same experience for each benefit you wish to test. Follow Roblox's current instructions to set the pass name, image, availability and price. A gamepass ID is **not** a developer-product ID, place ID or universe ID.
3. Copy each unique numeric gamepass ID. In `src/shared/Config.luau`, find:

   ```lua
   Config.GamePasses = {Luck=0, AutoRoll=0, KeepSlots=0, Backpack=0, VIP=0}
   ```

   Replace only the zero for each pass you created with its own real gamepass ID. Leave unwanted passes at zero. Never use example IDs. Duplicate, negative, missing or otherwise invalid IDs are marked unavailable; invalid KeepSlots configuration can block rebirth as a safety measure.
4. Sync and publish the main place. If using the hub, sync and publish it too so both places have the same configuration and current profile validation. Server limits and prices are configured in Creator Dashboard, not in these scripts.
5. Open **UPGRADES → OPEN GAMEPASS SHOP**. A configured pass initially shows **CHECKING**, then **TAP TO VIEW** or **OWNED** after a server ownership lookup. Only the official Roblox dialog should ask for a purchase confirmation. Actual purchases can cost real Robux; do not confirm unless you intend to purchase and understand Roblox's current testing options.

## Verify before any release

- Test an existing owner, a non-owner, successful and cancelled prompts, rejoin, teleport, shutdown and ownership-service failure. Check that each promised benefit works after ownership is verified and cannot be obtained by sending a client remote.
- Check auto-roll access before and after rebirth 5. Confirm the backpack accepts up to 265 parts with the pass, all cash upgrades and all season milestones and that all remain after rejoining and visiting the hub. If ownership cannot be checked temporarily, existing items are retained, but buying more may be blocked until verification succeeds.
- Test KeepSlots after upgrading slots and completing rebirth. When ownership cannot be verified and no prior confirmed entitlement was saved, rebirth is blocked rather than risking a destructive reset. A confirmed entitlement is retained in the saved profile. **Do not change or remove IDs after people have bought passes:** doing so can break verification and access; a previously unsaved entitlement could still be affected.
- Test the VIP online multiplier and Luck's actual displayed tier odds during and outside events. Neither gives the unimplemented benefits listed above. On an ownership lookup failure the game may temporarily omit bonuses and lets the player retry from the shop; it does not assume an unverified pass is owned.
- Mock tests included in the repo do not prove Roblox billing, entitlement callbacks, persistence or compliance work correctly. Paid features require published-environment validation, policy review and a support/refund plan.
