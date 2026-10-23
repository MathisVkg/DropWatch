# Midnight API review — Task 01.1

Reviewed again on 21 October 2026. GitHub's `live` revision remains [b9be9379719047977fca4dba1bb1d9988e8840b3](https://github.com/Gethe/wow-ui-source/tree/b9be9379719047977fca4dba1bb1d9988e8840b3), labelled **12.1.5 (70448)**. Retain Retail TOC **120105**; see [current interface](https://warcraft.wiki.gg/wiki/Template:API_LatestInterface) and [12.1.5 API changes](https://warcraft.wiki.gg/wiki/Patch_12.1.5/API_changes). Task 01/01.1 gameplay validation was supplied by the user; Task 02's UI, chat and session lifecycle changes remain pending client validation.

## Contracts used

| Event/API | Payload/return contract used |
| --- | --- |
| `CHAT_MSG_LOOT` | arg1 text, arg2 playerName, arg11 lineID; other arguments retained in bounded snapshots. arg12 sender GUID is not assumed to be the loot recipient. |
| `ENCOUNTER_LOOT_RECEIVED` | encounterID, itemID, itemLink, quantity, arg5, arg6. Generated docs call arg5 `itemName` and arg6 `fileName`; user tests establish arg5's recipient interpretation for observed Heroic/M+ awards. Raw fields remain available for further verification. |
| `ENCOUNTER_START` / `ENCOUNTER_END` | ID, name, difficulty, group size; end also supplies success and encounterUnitStatus. Only success=1 updates lastSuccessfulEncounter. |
| `CHALLENGE_MODE_START` / `RESET` | mapID; update local activity scope. |
| `CHALLENGE_MODE_COMPLETED` | No documented payload; retain completed run context. |
| `CHALLENGE_MODE_COMPLETED_REWARDS` | mapID, medal, timeMS, money, rewards; diagnostic summary only, no fabricated recipient awards. |
| `PLAYER_ENTERING_WORLD` | initial-login/reloading booleans; refresh current instance and roster. |
| `GROUP_ROSTER_UPDATE` | No documented payload; refresh recipient index. |
| `ITEM_DATA_LOAD_RESULT` | itemID, success; enrich existing pending observations/canonical records. |
| `C_ChallengeMode.GetActiveChallengeMapID()` | Nullable mapChallengeModeID. Store separately from event mapID/rewardsMapID; never assume these identifier namespaces are interchangeable. |
| `UnitFullName(unit)` / `UnitGUID(unit)` | Name/realm and GUID for matched current player/party/raid tokens. These can be identity-restricted; scrub before use. |
| `IsInRaid()` / `GetNumGroupMembers()` | No-argument boolean/number usage to enumerate the current raid, otherwise inspect party1–party4. Both results are sanitized and the loop is capped. |

Primary references: [loot](https://github.com/Gethe/wow-ui-source/blob/b9be9379719047977fca4dba1bb1d9988e8840b3/Interface/AddOns/Blizzard_APIDocumentationGenerated/LootDocumentation.lua), [chat](https://github.com/Gethe/wow-ui-source/blob/b9be9379719047977fca4dba1bb1d9988e8840b3/Interface/AddOns/Blizzard_APIDocumentationGenerated/ChatInfoDocumentation.lua), [encounters](https://github.com/Gethe/wow-ui-source/blob/b9be9379719047977fca4dba1bb1d9988e8840b3/Interface/AddOns/Blizzard_APIDocumentationGenerated/EncounterInfoDocumentation.lua), [challenge modes](https://github.com/Gethe/wow-ui-source/blob/b9be9379719047977fca4dba1bb1d9988e8840b3/Interface/AddOns/Blizzard_APIDocumentationGenerated/ChallengeModeInfoDocumentation.lua), [unit identities](https://github.com/Gethe/wow-ui-source/blob/b9be9379719047977fca4dba1bb1d9988e8840b3/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua), [roster event](https://github.com/Gethe/wow-ui-source/blob/b9be9379719047977fca4dba1bb1d9988e8840b3/Interface/AddOns/Blizzard_APIDocumentationGenerated/PartyInfoDocumentation.lua), and [Blizzard group-finder usage](https://github.com/Gethe/wow-ui-source/blob/b9be9379719047977fca4dba1bb1d9988e8840b3/Interface/AddOns/Blizzard_GroupFinder/Mainline/LFGList.lua).

## Item and UI behavior retained

`C_Item.GetItemInfo(query)` may return nothing; use name(1), quality(3), slot(9), icon(10), class(12), subclass(13). Its returned link(2) and base level(4) never replace award-specific evidence. `GetItemInfoInstant(query)` supplies ID(1), slot(4), icon(5), class(6), subclass(7). `GetDetailedItemLevelInfo(originalLink)` supplies the effective level as its first return; without an original link the effective level remains unavailable. `RequestLoadItemDataByID(id)` requests missing data. `C_MountJournal.GetMountFromItem(id)` returns nullable mountID. See [items](https://github.com/Gethe/wow-ui-source/blob/b9be9379719047977fca4dba1bb1d9988e8840b3/Interface/AddOns/Blizzard_APIDocumentationGenerated/ItemDocumentation.lua) and [mounts](https://github.com/Gethe/wow-ui-source/blob/b9be9379719047977fca4dba1bb1d9988e8840b3/Interface/AddOns/Blizzard_APIDocumentationGenerated/MountJournalDocumentation.lua).

`GetInstanceInfo()` supplies instance name/type/difficulty/difficulty name as returns 1–4 and instanceID as return 8. `GetBuildInfo()` supplies client version and TOC version (1,4). GetTime/time/date provide monotonic windows, epoch timestamps and local display. Existing native frame templates, drag/close/scroll/EditBox behavior remain; only diagnostic content/view cycling changed. No protected actions are introduced.

Localized parser families are `LOOT_ITEM`, `LOOT_ITEM_BONUS_ROLL`, `LOOT_ITEM_PUSHED`, and `LOOT_ITEM_CREATED`, with self/multiple variants when the actual client defines them. No English sentence is used as a fallback. The exact item placeholder must contain one complete extracted link before a single-item format can imply quantity=1. Missing constants are unsupported rather than synthesized. Actual locale strings and pushed-message coverage require client verification; synthetic tests do not establish the specific original cause of every earlier unmatched message.

## Midnight limitations

Item APIs require suitable readable arguments; unit identities can be secret under current restrictions. The unchanged `Core/Safe` guard checks `issecretvalue` before comparisons, formatting or keys, sanitizes API results, and checks `canaccesstable`/`issecrettable` before traversing received tables. Missing secret guard disables capture. Snapshots cap arguments at 32, table entries at 256 per event and depth at 3; nil positions/count are preserved. No raw secret object is kept in diagnostic history or SavedVariables. See [secret values](https://warcraft.wiki.gg/wiki/Secret_Values).

No secret decoding, delayed restriction bypass, combat-log workaround, addon messaging, automatic trading or external integration exists. API failures produce neutral markers without formatting restricted error objects. Loss of recipient/quantity/link evidence prevents confident reconciliation; it never causes a guessed award to be silently deleted. Mocks cannot emulate the real secrecy/taint engine or guarantee event delivery.


## Task 02 review — 22 October 2026

Rechecked the live GitHub revision today: it remains `b9be9379719047977fca4dba1bb1d9988e8840b3`, 12.1.5 (70448). TOC remains 120105. The addon uses only owned native frames; no ElvUI or external UI framework is loaded. Source validation does not certify rendering or taint behavior.

Native [ChatFrameUtil](https://github.com/Gethe/wow-ui-source/blob/b9be9379719047977fca4dba1bb1d9988e8840b3/Interface/AddOns/Blizzard_ChatFrameBase/Shared/ChatFrameUtil.lua) defines `SendTell(name, chatFrame)` by forwarding an empty message to the native parsing/open-chat helper. Task 02 uses this on a button click and then FocusActiveWindow. It does not transmit. Native [loot UI usage](https://github.com/Gethe/wow-ui-source/blob/b9be9379719047977fca4dba1bb1d9988e8840b3/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/LootFrame.lua) confirms modified item clicks through `HandleModifiedItemClick(link)`; item hover uses `GameTooltip:SetOwner` and `SetHyperlink(originalLink)`.

[System documentation](https://github.com/Gethe/wow-ui-source/blob/b9be9379719047977fca4dba1bb1d9988e8840b3/Interface/AddOns/Blizzard_APIDocumentationGenerated/SystemDocumentation.lua) provides the two PLAYER_ENTERING_WORLD booleans and no-payload PLAYER_LOGOUT. Recovery is admitted only on explicit initial=false/reload=true for the matching character; missing flags do not imply reload. SavedVariables writes on logout/reload and real keyboard focus require manual confirmation.

[Native frame definitions](https://github.com/Gethe/wow-ui-source/blob/b9be9379719047977fca4dba1bb1d9988e8840b3/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleFrameAPIDocumentation.lua) include SetResizeBounds and StartSizing. Sizing is initiated only by a user handle on the owned frame; protected-frame/combat restrictions are not bypassed. Scroll scripts are hooked to preserve native template behavior. C_Timer.NewTimer/Cancel schedule the next Recent deadline and the independent compact-notification expiry. UnitClass supplies a sanitized matched-roster class token; C_Item.GetItemQualityColor supplies sanitized rarity RGB values.

The cosmetic canonical recipient-provenance gap is fixed by copying the contributing observation notes and API error summary. The existing name/realm matching is unchanged. Main/session views show only canonical snapshots, and demo records stay in a separate in-memory store. Runtime history is bounded; only whitelisted genuine fields enter the conditional reload cache. No verbose raw events are serialized.

## Task 02.1 review — 2026-10-23

Reviewed Blizzard-generated Retail API definitions from the live client-source mirror:

- [Item functions](https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/ItemDocumentation.lua)
- [ItemBind enumeration](https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/ItemConstantsDocumentation.lua)
- [Loot events](https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/LootDocumentation.lua)

C_Item.IsBoundToAccountUntilEquip requires ItemLocation; it cannot inspect another player's inventory. IsItemBindToAccountUntilEquip(itemInfo) and IsItemBindToAccount(itemInfo) accept link-based queries. The implementation passes only the readable original full link. GetItemInfo bindType is compared with runtime Enum.ItemBind account-binding members, never guessed numeric constants. OnAcquire records category only.

True account-binding evidence excludes. False, nil, secret values, API absence and errors never establish tradeability. Existing safe-call guards remain. Link queries describe binding category, not remote inventory-instance trading timers, equip state or eligible-player lists. Unreadable responses get bounded retries. No localized tooltip scan or remote ItemLocation is fabricated.

BONUS_ROLL_RESULT includes item link/quantity, specialization, sex, personalLootToast, optional currency, secondary-result and corruption information; it has no tradeability field. Toast flags do not establish eligibility. Existing localized BONUS_ROLL chat formats identify source; the event is not added as another award producer. Bonus source alone stays visible; confirmed account-bound bonus equipment is excluded. No inference uses timing, item level, rarity, Soulbound status or Mythic+ completion.

Tooltip binding text can reflect localization, cache/restrictions and player-specific instance state. It is not a classification fallback. Definitions verify signatures, not real-client rendering/security or item-specific semantics; test genuine awards in game.
