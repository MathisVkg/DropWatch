# Task 02.1 — v0.2.1 implementation report

Date: 2026-10-23. Project: C:/Users/zeyros/Documents/repository/loot-tracker.

## 1. Summary

Refined the existing interface: minimal native scrollbar, custom diagonal grip, original circular package/gear artwork, independently movable settings, readable fixed-opacity controls, and content-driven panel height. Added conservative account/Warband presentation filtering without rewriting the validated matching engine. Raw/observation/canonical evidence remains available. No Task 03 work.

## 2. Files created or modified

- Assets/LootTracker.tga
- Assets/README.md
- Assets/Settings.tga
- Config/Settings.lua
- Core/Namespace.lua
- LootTracker.toc
- Modules/Loot.lua
- Modules/Normalize.lua
- Modules/Presentation.lua
- Modules/Session.lua
- README.md
- UI/Diagnostics.lua
- UI/ItemRow.lua
- UI/Main.lua
- UI/Notification.lua
- UI/Settings.lua
- UI/Style.lua
- docs/API_REVIEW.md
- docs/NORMALIZATION.md
- docs/REPORT.md
- docs/TESTING.md
- docs/UI_ARCHITECTURE.md
- docs/VALIDATION.txt
- tests/interface.lua
- tests/polish.lua
- tests/run.py
- tests/spec.lua

New runtime module: Modules/Presentation.lua. New assets: Assets/LootTracker.tga and Assets/Settings.tga, with format notes. New regression suite: tests/polish.lua. The remaining edits integrate these narrowly into existing modules and update release documentation. Recipient/context/parser matching algorithms remain unchanged.

## 3. Scrollbar

Plain native ScrollFrame and vertical Slider, no arrow template on the main panel. Track/thumb width: 4 pixels, dark track, grey thumb, brighter hover. Native thumb/track input supplies dragging; wheel moves 51 pixels. Values map directly to scroll offsets. Thumb size follows viewport/content ratio with an 18-pixel floor, range clamps after content changes, and no overflow hides the control. The track ends above the 20-pixel grip and occupies a separate right gutter.

## 4. Adaptive sizing

Actual expanded height = min(preferredMaximum, max(128, 78 + contentHeight)). Content sums 48-pixel item rows, 36-pixel History headers and 3-pixel gaps, without a trailing gap. Default preferred maximum is 300, allowed preference 180–900; width stays entirely user-controlled, 360–1,000. Empty/one row: 128; three rows: 228; overflow: maximum with scrolling. Top-left pinning keeps the title stable while the panel grows downward. Expiration, tabs and group expansion/collapse invalidate layout. Mouse capture defers content/adaptive relayout until release. Manual resizing saves maximum and width; moving/closing/adaptation/minimize do not overwrite maximum.

## 5. Settings and icons

Settings default to screen center, drag by their own title bar, clamp natively to screen bounds and persist validated settingsPosition separately from main/diagnostic geometry. Close and Escape remain available. The compact 320×340 layout keeps controls aligned. Header buttons share 22×20 dimensions and thin hover borders. Original TGA gear/package textures replace the letter S and bag. Minimap retains the prior corner positioning, visibility setting, tooltip and left/right actions, with a circular presentation and no library dependency.

## 6. Opacity

Only main backdrop fill receives the configurable 20–100% value (default 88%). Equivalent native backdrop techniques keep border opacity independent. No parent SetAlpha is applied. Rows have fixed 90% fill, buttons 94%, settings 96%, and opaque text/icons/borders. Mocks explicitly verify 20/50/75/100%; real scenery/readability still requires the guide below.

## 7. Warbound research

See [API review and primary client-source references](API_REVIEW.md). Implementation uses readable full-link item-binding queries plus runtime account-binding enums from sanitized GetItemInfo bindType. An inventory ItemLocation is never fabricated for another player. Confirmed link-specific binding proof survives later transient cache failures. Remote instance-specific trade timers/eligible players are unavailable to this model.

## 8. Bonus-roll research

Existing localized BONUS_ROLL formats can identify a bonus source. Reviewed event payloads provide no definitive trading eligibility. The addon therefore excludes a bonus item only when independent account-binding evidence confirms ineligibility. Other bonus items remain visible, including ordinary Soulbound awards. No extra award producer or speculative source correlation was added.

## 9. Presentation filtering

Visible(record) excludes only confirmed-ineligible records with confirmed classification and an exclusion reason. Runtime classification currently establishes this through account/Warband binding. Unknown and ordinary Soulbound equipment remain visible; no confirmed-tradeable state is introduced. Optional category/source/tradeability/confidence/reason/evidence strings are additive and survive whitelisted session snapshots. Same canonical ID updates in place after asynchronous classification. Both Recent/History and new-award displays use the filter; delayed exclusion retracts its outstanding notification contribution. Matching, recipients, complete links, grouping and independent 900-second expiry retain existing semantics.

## 10. Limitations

Mock frames cannot certify visual rendering, native mouse capture, UI scaling, combat taint, tooltip/chat focus or actual item-specific API behavior. Link classification does not inspect a remote inventory instance. Missing/restricted data stays visible and gets bounded retry only when supported; unresolved binding is not continuously polled. Bonus source alone cannot prove non-tradeability, and some reward sources remain unknown. The existing fixed minimap corner anchor is preserved. Existing session/diagnostic caps and conservative reload lifecycle remain. No permanent multi-session database, automatic trades/whispers, upgrade advice, communication protocol, external runtime API or publication.

## 11. Automated validation

255 assertions passed: baseline 62, refinement 66, interface/session 68, polish/filter 59. All 18 manifest Lua modules compile and load in fresh Lua 5.1 VMs through lupa 2.8. Requested scenarios 1–24 are covered, including both tabs, expansion/collapse, width/max-height persistence, independent settings, four opacity levels, minimized/notification states, top anchoring, Warbound/Soulbound/unknown/bonus behavior, retained diagnostics, delayed classification, deduplication and distinct recipients. Additional cases cover absent/error/secret APIs, missing runtime enums, no inherited arrows, cache retry and notification retraction. Two previous height assertions were updated for the intentional adaptive/max-preference semantics.

## 12. Installable package

LootTracker-0.2.1.zip contains a single LootTracker/ addon root with its manifest, runtime modules and original TGA assets, plus documentation/development tests. It carries no third-party runtime dependency. Previous release packages remain available. Extract into _retail_/Interface/AddOns and verify LootTracker/LootTracker.toc.

## 13. In-game validation

Follow [the detailed validation guide](TESTING.md), covering installation/version, overflow wheel and native dragging, resize/lock/outside release, stable downward adaptation, History collapse, exact 15-minute expiration, settings movement/reload, four opacity levels, minimap controls, real item links/whisper, two dungeon runs, genuine Warbound and bonus evidence, asynchronous updates, lifecycle recovery and combat/other-addon integration. Start with /loottracker demo, then turn demo off before genuine loot checks. Capture exact build/UI scale, steps/screenshots and original-link diagnostic evidence for feedback. The v0.2.1 client checks remain pending; wait for that feedback before any additional feature task.
