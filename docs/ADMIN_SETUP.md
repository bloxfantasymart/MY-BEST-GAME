# Developer admin tools

The admin menu is **disabled by default**. It can change real saved player profiles and kick players. Use it only with people you trust and test in a separate private experience first. Authorization is checked by the server for every request; hiding or showing the client menu does not grant permission.

## Enable for your test account

1. Find your numeric Roblox **user ID** (the number in your Roblox profile URL). This is not your username, place ID or an authentication token.
2. Open `src/shared/Config.luau` in your downloaded repository. Find `Config.AdminUserIds = {}` and put your numeric user ID inside the braces. To authorize more than one trusted developer, separate their IDs with commas. Do not use example numbers.
3. Sync the main place with Rojo and publish to your **private test experience**. Join the main place using an authorized account. Open **REWARDS → DEVELOPER ADMIN**. The admin UI is not present in the showcase hub.
4. To disable access, remove the ID from the configuration, sync and republish. Existing servers may keep the old configuration until they close; shut them down. The list is visible to clients and is **not a secret**. Never put passwords, tokens or API keys in this file.

## Available actions

Select an online player to inspect their cash, rebirths, slots, parts and creatures. Enter a whole number and choose **Grant Cash**, **Set Cash** or **Set Rebirth**, then confirm. Cash actions are limited to 1 trillion per command; rebirth is limited to 0–100. A rebirth override changes the player's tier without a normal rebirth or sacrifice, clears their unpurchased offers, stops auto-roll, updates their title and resets a now-locked plot theme to Classic. It does not reset their cash, stands or inventory.

You can choose a catalog entry and part type to grant a **Standard** body part, or kick a player from this server after confirmation. Part grants respect inventory capacity; grants can bypass normal rebirth unlocks for testing. Fusion, creature grants, bans, offline players and permanent moderation are not provided by this menu.

You can also trigger Frenzy, Eclipse, Sigma or Storm for **120 seconds in this server only**. A new admin event replaces the previous admin override; scheduled UTC events can still overlap. Admin events do not propagate across servers and are not saved.

The server validates permissions, targets and numbers, and writes basic action details to Roblox server output using warnings. These logs are **not** a durable audit trail. Normal profile autosave and its failure limitations still apply. Never enable broad admin access or use these tools on live player data until you have a tested moderation policy, backups and appropriate access controls.

## Verify security

In a private test server, join with one authorized and one unauthorized account. The unauthorized account must not see the menu and must not be able to invoke actions by sending remote events. Test invalid IDs, NaN/infinite/fractional amounts, out-of-range rebirths, full inventories, player departure during inspection and an unavailable profile. Verify confirmations, audit messages, persistence and event expiry. The repository's pure-logic tests do not simulate all Roblox networking or establish production security.
