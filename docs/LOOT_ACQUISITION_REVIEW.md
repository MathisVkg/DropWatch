# DropWatch 0.3.1 — acquisition and upgrade investigation

Reviewed 2026-10-24 against the clean 0.3.0 checkout (85da5e1). This is a source/mock-test investigation, not a new live-client test.

## Confirmed findings

1. In 0.3.0, equipment eligibility used the inventory slot/class without checking quality. A synthetic party-member grey equippable reproduces a canonical award in the unchanged source. 0.3.1 rejects confirmed quality 0 (Enum.ItemQuality.Poor) in normalization and applies the same gate to session presentation/reload recovery. It does not require Epic rarity.
2. Only CHAT_MSG_LOOT and ENCOUNTER_LOOT_RECEIVED call Loot:Observe's acquisition parser. ENCOUNTER_START/END and challenge completion/rewards update context only. No inventory, equipment-level-change, socket/reforge or upgrade event independently submits an acquisition.
3. ITEM_DATA_LOAD_RESULT calls Loot:Loaded, which iterates captured pending observations. Normalize:Update can promote a previously unclassifiable observation after item data arrives, but it does not parse a new acquisition event. Version 0.3.1 requires the candidate already be captured and have recognized, non-conflicting acquisition evidence.
4. Previously, Normalize:Eligible accepted equipment even when the chat format was unknown or item/recipient fields conflicted. A linked modification message delivered on CHAT_MSG_LOOT could therefore become a canonical record. This is a confirmed permissive path, but the actual NPC message has not been captured.
5. Previously, every metadata refresh re-queried the effective level and could overwrite a previously captured observation while it remained pending for binding/metadata. Version 0.3.1 fills a missing level once for the original hyperlink, then freezes it at both observation and canonical level. It never substitutes a rebuilt GetItemInfo hyperlink or a base level.
6. Stable chat line IDs are checked across the bounded observation store, removing the previous five-second limit. Repeated ingestion of the same canonical observation is idempotent. No item-name/item-ID global deduplication is added.

## What remains unknown

No raw event trace, chat text/format, line ID, original hyperlink payload or ordering was supplied for the Steelbark Cloak upgrades at levels 282 and 285. The item name/levels alone cannot establish whether the client emitted an unrecognized modification message, a recognized LOOT_ITEM_PUSHED/LOOT_ITEM acquisition-style message, repeated event notifications, or another sequence.

Item-data callbacks by themselves are not demonstrated as the source of multiple awards. No observed item-level increase proves a new acquisition or identifies an item instance.

If an NPC upgrade emits a fully recognized acquisition-style chat notification with the same evidence as real loot, 0.3.1 may still accept it. This remains an explicit live reproduction gap. The addon does not suppress all self loot, all pushed loot, all loot at an NPC, or later awards sharing an item ID. Those guesses could hide legitimate dungeon/M+ rewards.

## New narrowly scoped diagnostics

With /dropwatch debug enabled, ITEM_UPGRADE_MASTER_SET_ITEM and ITEM_UPGRADE_MASTER_UPDATE add local raw markers with only the selected item ID, current upgrade level, event/time and optional open/closed state. No player identity, full inventory, NPC identity, currency balance or external transmission is added by these markers. Selected-item APIs are read-only, protected by Safe.Call and primitive/secret guards. The marker does not create an observation, canonical award or notification.

Optional legacy ITEM_UPGRADE_MASTER_OPENED/CLOSED markers are registered through the existing pcall mechanism; availability is visible in /dropwatch status. Open state remains unknown until an event is observed and is cleared on world entry. Unsupported registration or unavailable/restricted API data does not disable ordinary loot tracking. There is no suppression based on this state.

Debug-off upgrade events make no selected-item API queries and add no upgrade markers. All markers share the existing 200-row raw bound; they are not SavedVariables history. Existing acquisition raw/processed views still contain potentially identifying chat/recipient data: inspect and redact manually before sharing. /dropwatch clear, reload and login clear the diagnostic stores.

The current [primary client API definitions](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/ItemUpgradeDocumentation.lua) document the two SET_ITEM/UPDATE events and read-only hyperlink/current-level APIs. This community mirror of Blizzard client source is a moving reference, not a guarantee for the user's exact build; the optional OPENED/CLOSED events were not verified against the pinned 12.1.5 snapshot. The retained interface is 120105. No protected upgrade API, ItemLocation construction, hooks or restricted-table traversal is added.

## Filtering and pending data

Quality is accepted only as a readable nonnegative integer. Missing, secret, malformed or unavailable quality is not guessed from hyperlink color. Known equipment without quality can retain an internal acquisition candidate, but stays absent from Recent, History and notifications until quality is confirmed. The existing 15-second retry/deadline remains bounded; timeout stays hidden. ID-only encounter evidence can be retained without inventing a link or effective level.

Confirmed Poor equipment is rejected before canonical creation where metadata is ready, or removed after delayed classification. Raw observations remain available in diagnostics. Rare, Epic, other non-Poor equipment, optional mounts, Warbound rules, original links, recipient-specific awards, separate genuine acquisitions and existing activity-context reconciliation remain supported.

## Reconciliation rules

Recognized chat loot/pushed formats or a readable encounter award must supply item identity, recipient and positive integral quantity without field conflicts. Unknown/creation/conflicting messages remain diagnostic-only.

Pairing still requires opposite event sources, a unique counterpart, the same readable recipient, full hyperlink item payload, quantity, instance/difficulty/run and the ten-second pairing window. A missing or conflicting context does not force a match. Multiple possible counterparts remain ambiguous rather than using global item-ID/name deduplication. No acquisition is fabricated from M+ reward-summary events.
