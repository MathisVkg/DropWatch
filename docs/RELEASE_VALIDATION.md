# DropWatch 0.3.0 final release validation

## Evidence status

**Automated:** 836 assertions pass, including all prior tests, new notification regressions, byte-identical packaging across timestamp changes, MIT license inclusion, safe archive contents/checksums and booting the exact ZIP in fresh mocked Lua 5.1. All 19 runtime modules load. This is not a WoW client test.

**User-reported in game before this RC hardening:** Mythic+ equipment, recipient identification, deduplication, 15-minute Recent expiry, History grouping, Warbound exclusion, main rendering, minimap position and DropWatch branding. No new live test is claimed by the agent.

**Still unperformed for this exact candidate:** final client smoke/upgrade, the two notification fixes under real gameplay, raid-specific awards, broad combat/other-addon coverage, real release screenshots and CurseForge-installed file. Source/Issues access also needs owner verification.

## Record each run

Record date, addon version/checksum, /dump GetBuildInfo() output, character/realm (may redact), UI scale, active addons, mode, steps and result. Mark each case Pass/Fail/Not Run; leave boxes unchecked until actually performed. For a failure copy the Lua stack and relevant diagnostic record, reviewing identifiers before sharing.

## Manual plan

| # | Case | Expected result | RC result |
| --- | --- | --- | --- |
| 1 | Fresh install with backed-up preferences, clean AddOns/DropWatch folder | Exact ZIP extracts directly to DropWatch/DropWatch.toc, no old active copy | Not Run |
| 2 | Upgrade from Loot Tracker via MIGRATION.md with WoW closed | Geometry/mode/opacity/mount/minimap preferences retained; one addon active | Not Run |
| 3 | Enable script errors, login, /dropwatch status | 0.3.0, interface 120105 on tested client; no handler/registration errors | Not Run |
| 4 | Open/close/minimize Loot/History; resize and overflow | Stable top edge, saved maximum/width, correct wheel/thumb/grip behavior | Not Run |
| 5 | Move independent settings, change all options, reload | Settings position and values persist; 20/50/75/100% affect only background | Not Run |
| 6 | Minimap full-circle drag, outside release, scale/size, hide/show | Rim attachment, correct pointer alignment, angle survives reload/login | Not Run |
| 7 | /dropwatch demo, demo burst, demo off through all aliases | Clearly simulated, isolated from real/session persistence, whisper disabled | Not Run |
| 8 | Hover genuine item/name/icon | Native tooltip receives full original variant link | Not Run |
| 9 | Shift/Ctrl modified click on genuine item | Native modified-click action; original link preserved | Not Run |
| 10 | Click Quick Whisper for another realm/player | Correct native recipient and empty body; nothing sent until user chooses | Not Run |
| 11 | Normal dungeon awards, duplicate notifications, identical separate drops | One canonical per supported matched award; separate real awards/players retained | Not Run |
| 12 | Mythic+ completion and delayed loot after completion | Validated detection preserved; no fabricated reward-summary awards | Not Run |
| 13 | Raid boss/group loot when available | Correct recipients, variants, quantities and reconciliation; collect raw evidence | Not Run |
| 14 | Ordinary Soulbound, confirmed Warbound, unknown/bonus metadata | Confirmed exclusions absent from player views; unknown/Soulbound retained; diagnostics remain | Not Run |
| 15 | Two distinguishable activity runs; leave/disband group | Correct History groups; old snapshots stable; no guessed run merge | Not Run |
| 16 | Two awards with distinct times; wait 900 seconds each | Independent expiry/shrinking Recent; History remains | Not Run |
| 17 | /reload with real History and demo active | Matching-owner real snapshots recover; demo removed; no duplicate new-award notifications | Not Run |
| 18 | Genuine logout/login, disable/re-enable with required reload | New login starts fresh; preferences retained; no duplicate handlers | Not Run |
| 19 | Usual addons and combat/noncombat | No Lua/taint errors or automatic protected gameplay actions | Not Run |
| 20 | After approved publication, install through CurseForge cleanly | Correct addon/version/runtime files; smoke, links, minimap and settings work | Not Run |

For modes test automatic opening, manual silence and one compact notification per batch. Specifically test an item that becomes irrelevant/excluded after loading: its outstanding count must decrease/dismiss. A stream exceeding retained History capacity must not retain more notification IDs than retained entries; avoid synthetic client event injection and use normal diagnostic evidence.

## Release decision

- [x] Owner-selected MIT and original artwork terms documented; LICENSE included by a rebuild.
- [ ] Current-client smoke and upgrade/notification fixes passed.
- [ ] Raid testing completed, or owner explicitly accepts and publicly discloses the remaining gap.
- [ ] Real screenshots captured; public source/support links checked.
- [ ] Final ZIP checksum matches the author-selected source revision.
- [ ] Owner explicitly approves publication.

License approval is recorded above. No publication approval, upload, game screenshot or raid test is implied by this document. Use the focused older TESTING.md cases for detailed UI/loot checks.
