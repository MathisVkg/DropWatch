# Midnight compatibility audit — 0.3.0 candidate

Audit date: 2026-10-23. API snapshot: [Gethe client-source mirror commit e7aa82019dc298e0351c7159d60c2a9b916b9b67](https://github.com/Gethe/wow-ui-source/commit/e7aa82019dc298e0351c7159d60c2a9b916b9b67), identified as Retail 12.1.5 build 70529. This is a community mirror of primary client code, not a Blizzard endorsement or in-game test.

TOC interface **120105** and addon version **0.3.0** remain unchanged. Final validation records /dump GetBuildInfo() on the actual client before upload; no future patch compatibility or extra game flavors are claimed.

## Registered events verified in source

| Event | Pinned definition |
| --- | --- |
| ADDON_LOADED | [AddOnsDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/AddOnsDocumentation.lua) |
| CHAT_MSG_LOOT | [ChatInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/ChatInfoDocumentation.lua) |
| ENCOUNTER_LOOT_RECEIVED | [LootDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/LootDocumentation.lua) |
| ENCOUNTER_START | [EncounterInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/EncounterInfoDocumentation.lua) |
| ENCOUNTER_END | [EncounterInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/EncounterInfoDocumentation.lua) |
| CHALLENGE_MODE_START | [ChallengeModeInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/ChallengeModeInfoDocumentation.lua) |
| CHALLENGE_MODE_COMPLETED | [ChallengeModeInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/ChallengeModeInfoDocumentation.lua) |
| CHALLENGE_MODE_COMPLETED_REWARDS | [ChallengeModeInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/ChallengeModeInfoDocumentation.lua) |
| CHALLENGE_MODE_RESET | [ChallengeModeInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/ChallengeModeInfoDocumentation.lua) |
| PLAYER_ENTERING_WORLD | [SystemDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/SystemDocumentation.lua) |
| ITEM_DATA_LOAD_RESULT | [ItemDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/ItemDocumentation.lua) |
| GROUP_ROSTER_UPDATE | [PartyInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/PartyInfoDocumentation.lua) |
| PLAYER_LOGOUT | [SystemDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/SystemDocumentation.lua) |
| GLOBAL_MOUSE_UP | [SystemDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/SystemDocumentation.lua) |
| UI_SCALE_CHANGED | [UIManagerDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/UIManagerDocumentation.lua) |
| DISPLAY_SIZE_CHANGED | [VideoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/VideoDocumentation.lua) |

The twelve core post-initialization events register through pcall, exposing unavailable registration in /dropwatch status. ADDON_LOADED checks the runtime addon name once; main/minimap UI use their own release/scale events without adding a second loot feed.

Payload review: chat text/recipient and line-ID positions are preserved; item loading uses itemID/success; encounter start/end use ID/name/difficulty/group size/success; challenge rewards are context only, never fabricated item awards. World-entry's initial-login/reloading-UI booleans govern bounded cache recovery; logout writes through WoW's SavedVariables lifecycle.

**Known definition discrepancy:** ENCOUNTER_LOOT_RECEIVED generated argument labels call slots 5/6 itemName/fileName. The existing implementation uses arg5 as recipient, validated by prior Heroic/Mythic+ observations and the user's working detection. That proven interpretation is preserved rather than changed from the generated labels. Raid-specific behavior remains an explicit validation gap; capture raw/canonical evidence before claiming full raid support.

## API and restriction review

Item lookups use C_Item functions and the original full hyperlink for effective variant level/tooltips. Account-binding classification uses readable link-based APIs and runtime bind enums; another player's ItemLocation is never fabricated. False/unavailable/restricted values never prove tradeability. See the prior API_REVIEW.md for binding details.

[FrameScript definitions](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_APIDocumentationGenerated/FrameScriptDocumentation.lua) retain issecretvalue and table-access guards. Values are checked before comparison/formatting, scalar API calls use protected safe wrappers, and raw table snapshots have depth/item budgets. If the secret guard is absent, event capture fails closed. No bypass or attempt to access secret data is introduced.

[ChatFrameUtil source](https://github.com/Gethe/wow-ui-source/blob/e7aa82019dc298e0351c7159d60c2a9b916b9b67/Interface/AddOns/Blizzard_ChatFrameBase/Shared/ChatFrameUtil.lua) verifies SendTell(name, chatFrame), its empty-body initialization and FocusActiveWindow(). DropWatch invokes them only from the clicked Whisper button; it never calls SendChatMessage. Native modified-click helpers and full-link tooltip calls remain; failed tooltip queries now hide stale content.

Addon-owned frames use native movement, resize and clipping with no secure action template or automatic protected gameplay. Combat/native chat/tooltip restrictions can still reject an action; guarded calls do not certify taint freedom. Existing supported global roster helpers and current namespaced item/chat APIs are retained; no justified deprecation migration was identified.

## SavedVariables and limits

Only LootTrackerDB and LootTrackerSession are declared, intentionally retaining migration-compatible global names. Preference fields are rebuilt from a whitelist; session snapshots are bounded, owner-checked and admitted only on explicit reload. A genuine login starts fresh. Folder/TOC renaming does not automatically load an old SavedVariables filename: MIGRATION.md documents the closed-client copy.

Raw/observed/canonical stores: 200 each; canonical contributors: at most two; candidate IDs: eight; session snapshots: 1,000; demo: 60; notification identities: retained session capacity after this fix. UI pools recycle visible frames. Matching/pending scans remain bounded, and only active minimap drag has its own update callback. Core refresh cadence remains 0.5 seconds; no per-item countdown or perpetual metadata polling is added.

Source review and mocks support these conclusions; current-client registration, actual event semantics in raids, native input behavior and final disk migration still need RELEASE_VALIDATION.md.
