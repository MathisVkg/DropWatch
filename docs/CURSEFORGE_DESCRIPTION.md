# DropWatch

**Group Loot Tracker for World of Warcraft**

See group loot without searching through the chat log.

DropWatch displays equipment received by party and raid members, helping you see who received an item and open a whisper when you want to ask about it. It runs on its own and does not require ElvUI or another addon framework.

## Features

- Group equipment tracking for dungeons, Mythic+ and raid loot events.
- Recent Loot keeps each observed award for 15 minutes.
- Session History groups awards by observed instance and run context.
- Original item hyperlinks support native tooltips and modified clicks.
- Quick Whisper opens an empty native whisper input for the selected player. Nothing is sent automatically.
- Choose an automatic panel, a compact notification or manual display.
- Move/resize the panel; adaptive height fits the content up to your preferred maximum.
- Confirmed Warbound/account-bound equipment is filtered from player views. Unknown and ordinary Soulbound equipment remain visible.
- Optional mount tracking, independent settings, background opacity and a draggable radar minimap button.

## Install and use

Extract the ZIP into World of Warcraft/_retail_/Interface/AddOns. Confirm DropWatch/DropWatch.toc exists directly and enable DropWatch.

Use /dropwatch to toggle the panel and /dropwatch settings to configure it. /dw and /loottracker are aliases. Other commands: status, diag, debug, clear, demo, demo burst and demo off.

Upgrading from Loot Tracker? Close WoW before copying the old account SavedVariables/LootTracker.lua to DropWatch.lua unchanged. Back up existing settings first, remove/move the old addon folder outside AddOns, and enable only DropWatch. [Migration guide](https://github.com/MathisVkg/DropWatch/blob/main/docs/MIGRATION.md).

## Compatibility and limitations

Prepared for WoW Retail Midnight 12.1.5, interface 120105. Mythic+ detection, recipients, reconciliation, expiration, History, Warbound exclusion, interface rendering, minimap position and branding have been reported working in game during development. **Raid-specific validation remains incomplete.** This does not promise compatibility with future patches.

Only readable client events/data can be displayed. Tradeability is not guaranteed: item links do not reveal another player's complete trading eligibility. Bonus-roll source alone does not cause exclusion. History is bounded to the login session, with conservative reload recovery; it is not a permanent collection log. The addon does not automatically whisper, trade or communicate with other addons.

## Support

[Report an issue](https://github.com/MathisVkg/DropWatch/issues) with addon/client version, steps and relevant diagnostic details. Review copied logs before sharing and redact player identifiers if needed. Debug data is never uploaded automatically.

---

Author preparation note — remove this separator/note when pasting: description is a draft, not an announced publication. Verify the support/source links are publicly accessible and Issues are enabled; their web accessibility could not be confirmed in this session. MIT is selected; finish the remaining release checklist before publication. No CurseForge project ID or listing URL is invented.
