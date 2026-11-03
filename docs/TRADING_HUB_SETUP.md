# Set up the showcase hub

The hub is a **separate place inside the same Roblox experience**, not a separate experience. At this stage it is a showcase: players can claim a booth, display up to four owned creatures, inspect booths and return to the main game. **There are no purchases, prices, item transfers or direct trades yet.** Do not advertise it as a working trading market.

## Before you start

- Follow the main [README](../README.md), and get the main place working in a private **test** experience first.
- Install Rojo 7.7 and its Studio plugin. Keep your Rojo source folder; you will sync two different project files into two different places.
- Publish both places inside the **same experience**. DataStores are scoped to the experience. Using separate experiences would give the places separate player data.

## Create the second place

1. In Creator Dashboard or Studio's **Asset Manager → Places**, create a new place within your existing test experience. Name it `Trading Hub`. Open that new place in Studio. Leave your main place as the experience's starting place.
2. Note the numeric **place ID** of the main place and the numeric **place ID** of the Trading Hub. These are not the experience/universe ID. You can find each place in Creator Dashboard; its URL/details identify its place ID.
3. On your computer, open `src/shared/Config.luau`. Find `Config.PlaceIds = {Main=0, TradingHub=0}` and replace each zero with the correct numeric place ID, for example `Main=123456789, TradingHub=987654321` (those numbers are examples only; do not use them). Save the file. Both places must receive the same updated config.
4. Stop any Rojo server that is using the main project. In a terminal in the repository folder run:

   ```sh
   rojo serve hub.project.json
   ```

5. In the **Trading Hub place**, connect the Rojo Studio plugin. Confirm `ServerScriptService/Hub` and `StarterPlayer/StarterPlayerScripts/HubClient` appear. Then **File → Publish to Roblox** to update the hub place. Do not sync `hub.project.json` into the main place.
6. Stop that Rojo server. Open the **main** place in Studio. Run `rojo serve default.project.json`, connect the plugin, and publish the main place again so it gets the same updated `Config.PlaceIds`. Do not sync `default.project.json` into the hub place.
7. In Creator Dashboard, set the main place server size to **6** and hub place server size to **15**. The scripts do not configure these Roblox settings.

Alternative: use `rojo build hub.project.json -o TradingHub.rbxlx`, open the generated file, then publish it **to the hub place within the existing experience**. Be careful not to overwrite your main place. Build/publish the main project separately.

## Test the portal and booths

1. Publish both places and join the **main place through the Roblox app**, not just Studio Play. Roblox TeleportService does not support ordinary cross-place teleport testing in Studio. Keep the experience private and test with a trusted second account.
2. Craft a creature, then visit the purple plaza portal. If the ID is still zero, the portal tells you it is not configured. Use the hub's cyan portal to return.
3. In the hub, approach an unclaimed booth and use its prompt. Search, sort and page your creature list and choose up to four to display. You can hide already displayed creatures. Another player can approach and inspect the displayed rarity, level, components and mutations; the full inventory is visible only to the owner. Standalone income excludes plot bonuses. Visitors use **REFRESH BOOTH** to fetch changes. The creatures remain in the owner's saved inventory and cannot be purchased or transferred.
4. Review and confirm **RELEASE BOOTH**, rejoin, and verify your saved inventory is unchanged. Booth ownership and displays are temporary and clear on leaving. Check that characters do not collide with each other.
5. On rapid travel, the new server may wait briefly for the previous server to save and release its profile. If loading fails, wait and rejoin; a crashed server's lease can take up to 180 seconds to expire. Test failures and shutdowns thoroughly before using real player data.

The hub uses the same profile lease and saves the unchanged profile on exit. Time in the hub counts toward the main place’s capped offline income, which is credited only when the main place next loads the profile. Studio defaults to separate in-memory data for each server, so showcasing your main-place inventory requires published testing or carefully configured Studio DataStore testing in a private test experience. See [TESTING.md](TESTING.md). Buying, fees, direct trades and paid features need a separately designed recoverable transaction system and extensive tests before implementation.
