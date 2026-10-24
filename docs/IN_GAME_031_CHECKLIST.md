# DropWatch 0.3.1 in-game validation

All cases below are **Not Run** for this exact candidate. Record client build (/dump GetBuildInfo()), addon version, UI scale, date, display mode and ZIP checksum. Enable Lua errors. Use genuine client actions; the automated synthetic fixtures are not live gameplay evidence.

## NPC upgrade reproduction

1. Start with /dropwatch clear, then /dropwatch debug and /dropwatch status. Confirm version 0.3.1 and note upgrade-event registration availability. Open /dropwatch diag, Raw events.
2. Before opening the upgrade NPC, record current Loot/History counts and capture the existing cloak's full hyperlink and item level privately.
3. Open the upgrade NPC and select an existing item. Upgrade one rank at a time (including the reported 282/285 sequence if available). Wait between ranks and close the NPC. Repeat several ranks/items.
4. Expect only upgrade/cache diagnostics and no new loot awards without an acquisition event. Existing awards must retain their captured link, level and timestamp. Compare notification, automatic and manual modes.
5. If an award still appears, copy the immediately adjacent raw CHAT_MSG_LOOT / ENCOUNTER_LOOT_RECEIVED / ITEM_DATA_LOAD_RESULT and upgrade markers. In Parsed observations capture source, matched localized format/acquisition kind, raw/observation/canonical IDs, line ID from raw arguments, item link, level, quantity, status and context; in Normalized view capture source pairing.
6. Preserve exact event order and text/format/link payload while redacting recipient names/realms/GUIDs consistently in a copy. Existing raw chat contains personal identifiers. No automatic upload occurs.
7. Do not conclude that a recognized pushed/loot message is a false award solely from item ID, level increase or NPC-open state. Supply the trace for a focused follow-up if the client uses acquisition-style text for an upgrade. This candidate deliberately retains such indistinguishable evidence.
8. Repeat with debug off; verify no added NPC markers. Toggle debug off after collection. /dropwatch clear or reload clears diagnostic data.

## Poor-quality and pending metadata

- Have a party member genuinely receive Frayed Guise or another confirmed grey equippable. It must appear in neither Recent nor History, trigger no notification and not open the panel. With debug on, verify the retained processed record says Poor-quality equipment.
- Repeat with cold/uncached data if practical: unknown quality must stay hidden, then confirmed grey must remain excluded. No Lua/secret-value errors. If data never becomes available, the item stays deferred rather than guessed.
- Receive Rare/Epic and other legitimate non-Poor equipment: verify visibility. Check ordinary Soulbound/unknown binding remains supported and confirmed Warbound remains excluded.
- Enable/disable mount tracking with genuine mount awards; confirm no equipment-quality regression.

## Legitimate dungeon/M+ and raid loot

- In a normal dungeon and, when available, a raid, obtain a real boss drop. Verify recipient, full link and acquisition level, and one award where chat/encounter events are safely paired.
- Complete M+ with rewards for two party members, including identical item IDs if available. Each recipient must retain a separate award; corresponding chat/encounter observations must reconcile, and delayed end-of-run rewards remain supported.
- Obtain the same item twice as one recipient at separate times: two real acquisitions must remain possible.
- Upgrade an item that already has a DropWatch award. Its old History/Recent link and level must not change; genuine later acquisitions with another level must still create their own awards.
- Check native tooltips, modified item clicks and empty Quick Whisper; nothing sends automatically.
- Verify automatic/manual/notification modes, Recent expiry 15 minutes from each acquisition, History retention, settings and reload behavior. Capture errors or discrepancies with the event trace.

Publication still requires author approval, real screenshots, exact-client validation and remaining release checklist items. No release/tag or CurseForge upload is performed by this task.
