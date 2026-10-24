# Upgrading from Loot Tracker

DropWatch was renamed in 0.3.0; the current installation is 0.3.1. Do not keep both versions active: they would each process loot and share legacy preference globals.

## Preserve preferences with WoW closed

1. Exit the WoW client completely. A /reload alone is insufficient for this filesystem upgrade: running WoW may overwrite SavedVariables on exit.
2. Back up your old AddOns/LootTracker folder and the account-level settings file:
   _retail_/WTF/Account/<ACCOUNT>/SavedVariables/LootTracker.lua
   Move the addon backup outside AddOns.
3. In that same account SavedVariables directory, copy LootTracker.lua to DropWatch.lua. Keep the original backup. If DropWatch.lua already exists, back it up before replacing it and decide which settings you want to retain.
4. Do not change the assignments inside the copied file. DropWatch intentionally still declares LootTrackerDB and LootTrackerSession. Its validated settings loader preserves window position/preferred size, independent settings/diagnostic positions, mode, opacity, locks, mount preference, minimap angle and visibility. Current session loot recovery across this rename is not required; a fresh login discards the old cache.
5. Remove the old LootTracker folder from AddOns (or move it outside AddOns), then extract DropWatch-0.3.1.zip there. Confirm AddOns/DropWatch/DropWatch.toc exists directly. There should be one installed addon.
6. Start WoW, enable DropWatch, and run /dropwatch status. Expect DropWatch 0.3.1. Verify your preferences and minimap angle, then /reload to check persistence. /dw and /loottracker are aliases.
7. For additional WoW accounts on the same installation, repeat the account-level settings-file copy for each account you use. This addon has no per-character SavedVariables declaration.

The TOC keeps legacy variable names to make the copy sufficient without editing Lua or executing a migration helper. The addon cannot read an arbitrary old settings file from disk. Merely renaming the folder or declaring an old global does not make WoW load the previous addon's file. No automatic file migration is claimed. No bridge addon, forced old-addon loading or duplicate event feed is introduced.

If the old settings file is unavailable, DropWatch starts with safe defaults. If something looks wrong, exit WoW before restoring a backup. Do not delete the whole WTF folder. No migration script reads or writes your WoW installation as part of this development task.

File-per-addon storage is described in this [Blizzard forum developer response](https://us.forums.blizzard.com/en/wow/t/easiest-way-to-synch-up-several-add-ons-between-two-computers/2131901/2). The documented copy is also tested by loading an unmodified legacy global assignment before the new ADDON_LOADED event; actual WoW file loading/writing still requires the manual check above.
