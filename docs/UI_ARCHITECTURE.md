# Tasks 02 / 02.1 — UI and session architecture

The validated loot engine remains the only producer of awards. There is no second parser/detection path. UI code consumes the private `ns:Subscribe(kind, canonical, detail)` API and its stable canonical IDs.

## Module responsibilities

| File | Responsibility |
| --- | --- |
| `Modules/Session.lua` | Whitelisted canonical snapshots, bounded genuine history, recent deadlines, run grouping and reload cache |
| `UI/Style.lua` | Native flat charcoal frames, thin borders, teal accents, compact type and safe text/link helpers |
| `UI/ItemRow.lua` | Shared icon/name/level/recipient row, rarity/class colors, native tooltip/modified click and empty whisper action |
| `UI/Main.lua` | One movable/resizable panel, tabs, minimize/close, virtualized list/group headers and window persistence |
| `UI/Minimap.lua` | Circular minimap anchor, scale-aware drag, saved angle and native minimap interactions |
| `UI/Notification.lua` | One batched ten-second clickable notification, distinct from minimized main panel |
| `UI/Settings.lua` | Display mode, optional mounts, opacity, lock/reset and minimap visibility |
| `UI/Demo.lua` | Separate bounded simulated records; no real canonical feed, inventory action, whisper or serialization |

`Core/Events.lua` initializes the subscriber, routes session lifecycle and commands, and refreshes dirty visible UI alongside the existing half-second diagnostic update. There is no new per-row OnUpdate handler.

## Feed integration and identity

Session snapshots are indexed by canonical ID. The first qualifying creation (or first later equipment classification) inserts a session entry and can trigger display. Enrichment, classification and reconciliation replace its data in place; they do not notify again. Capacity eviction from the engine is ignored by session History. Actual filtering/removal is propagated. Clear/reset clears all session/recent/demo data. Genuine notifications are suppressed only while the user explicitly views isolated demo data; genuine records continue collecting.

Row frames are keyed by visible record ID and updated in place. A small reusable viewport pool handles scrolling instead of allocating frames for all 1,000 records. Group headers have a separate small pool. Model descriptor arrays can be rebuilt on a dirty change, but native row frames are not destroyed/recreated on every metadata event. A plain native ScrollFrame and separately styled vertical Slider synchronize pixel offsets; no Blizzard scrollbar template is used on the main panel. Collapsed-group keys are pruned to current groups.

Recipient class tokens are additive metadata from matched roster units; missing or restricted class information uses neutral colors. Normalization additionally propagates recipient provenance and API-error summaries for diagnostics, correcting the cosmetic `recipient: ? | API: ?` line without changing recipient matching.

## Time and History

Recent membership is `now < acquiredEpoch + 900`. The 900-second constant is fixed. A single cancellable timer targets the next acquisition deadline; closed windows do not stop it. Expiration invalidates the recent view and schedules the next deadline, without deleting History. Notification uses its own independent timer, resetting to ten seconds on new award batches only.

History groups use known instance ID, difficulty and existing activity scope. Challenge state adds the Mythic+ designation. Same-name activities with different scopes remain separate. No distinguishing run context means an unconfirmed/unassigned label rather than a guessed association. Reloaded records retain their old scopes; canonical/activity counters are reserved before new events, and newly recovered context can form an additional conservative group.

Snapshots retain only IDs/timestamps, original link and small item/recipient/class/context fields, capped at 1,000. They omit raw arguments, observation graphs, callbacks and demo flags/records. The SavedVariables cache is admitted only with explicit reload flags and a matching owner; initial-login/unknown flags never restore a previous login. There is no reliable way to know at the save event alone whether the next load will be reload or a real login, so admission is decided on entry. Crashes, addon disable/enable and uncertain lifecycle flags may lose recovery; safety favors a fresh session.

## User actions and safety

Quick Whisper calls current `ChatFrameUtil.SendTell(target, DEFAULT_CHAT_FRAME)` from the clicked button, followed by native focus. Blizzard's helper creates an empty-message whisper and parses the recipient. No SendChatMessage, addon messaging or automatic whisper call is used. Targets require readable name and realm; own loot and demo are blocked. Names with command/control delimiters are rejected. Offline/realm chat restrictions remain native behavior.

Item hover passes the complete verified stored hyperlink to GameTooltip:SetHyperlink. Modified clicks pass the same link to HandleModifiedItemClick. Missing/unreadable links do nothing; no ID-only hyperlink is synthesized. Demo deliberately has no link. Native errors are guarded without bypassing restrictions. Ordinary display strings escape WoW markup characters; stored original item links are unchanged. UI frames are addon-owned and resizing starts only on a user's resize handle action. Native combat restrictions and real chat/tooltip behavior remain manual test requirements.

Configuration keeps diagnostic position separate from the new main `window` geometry. The preferred maximum height remains distinct from actual height during adaptation and minimize, and a top-left pin preserves header position. Locking blocks dragging/resizing. Reset restores centered 420×300 defaults. Opacity is applied to the background, not to child text/icons. UIParent scale is inherited throughout.

## Adaptive layout and interaction

Main descriptors compute content height with no trailing gap. Actual height is min(saved maximum, max(128, 78 + content)). The 78-pixel allowance is the 64-pixel header/tab area plus 14-pixel bottom padding. Width never derives from content. Before changing height the panel pins its current top-left to UIParent and saves position without replacing preferred height. Resize bounds allow the compact 128-pixel expanded state; manual preferences clamp to 180–900. Minimize uses a separate 32-pixel state. Reset restores preferred 420×300 geometry.

The scrollbar track is 4 pixels wide, inset 7 pixels from the right and ends 22 pixels above the bottom, clear of the 20-pixel grip. The list ends 18 pixels from the right. A 5-pixel horizontal hit extension eases dragging. Native Slider values map directly to vertical scroll pixels. Thumb height is trackHeight × viewport/content, bounded to 18 pixels and track height. Wheel steps are 51 pixels. Range/offset clamp on layout changes; no overflow means no scrollbar.

Mouse capture during title dragging, native thumb dragging and resizing defers descriptor/adaptive relayout. Release renders pending changes. GLOBAL_MOUSE_UP handles releases outside the original control; the resize handler guards against saving twice after global release. Visible rows still update when scrolling. UIParent scaling and native screen clamping remain authoritative.

Style.Backdrop defaults to fixed 96% fill. Only Main passes configured opacity explicitly, leaving independent row/button fills and opaque borders intact. No parent SetAlpha call exists. Settings have a separate saved settingsPosition (validated point/offset whitelist), a native draggable title bar, screen clamping and Escape registration.

## Filtering and persistence

Modules/Presentation.lua classifies canonical records and exposes Visible(record); it does not change matching, selection or delete evidence. Loot resolution retains bindType and requests bounded re-evaluation when a present binding API returns unreadable data. Rebuild recalculates optional metadata before publishing revisions. Existing ITEM_DATA_LOAD_RESULT and the 15-second deadline apply; unavailable APIs do not create an endless retry.

Session snapshots whitelist new classification strings. Qualifies applies equipment/mount selection and Visible for Recent, History, grouping, expiration scheduling and new-award display. A delayed exclusion updates the stored snapshot in place and removes its notification contribution. Notification IDs prevent repeated contributions. Filtered entries already in session may stay in its bounded internal snapshot cache; presentation omits them. Initially excluded records remain in engine diagnostics and need no session row. Old snapshots missing metadata remain visible. The diagnostic canonical view includes classification evidence even with debug disabled.

Confirmed account-binding evidence is retained for the same full original link across later transient query/cache failures. This prevents an already excluded item reappearing merely because a later query is unreadable. New/unclassified links remain unknown until positive evidence exists.

## v0.2.2 minimap geometry

UI/Minimap.lua owns the existing custom button. Main retains its minimap reference for existing callers and delegates initialization/visibility refresh. Button parent and anchor target are the actual Minimap, with CENTER-to-CENTER offsets r*cos(theta), r*sin(theta), where r=min(mapWidth,mapHeight)/2. Center anchoring automatically accommodates button width/height: its center stays on the rim instead of adding an outward half-diameter offset. Non-square map bounds use the inscribed circle; square-map skin support is outside this circular-border fix.

Both frames inherit the same effective scale, so anchor offsets stay in map-local units. Dragging converts physical cursor pixels by Minimap:GetEffectiveScale(), subtracts Minimap:GetCenter(), and stores atan2 in degrees modulo 360. Saved settings validate finite readable numbers, normalize angles, and default to 45° without touching other preferences. Initial settings load is shared by reload and login.

Only active drag uses OnUpdate. Drag-stop, left mouse-up, global outside release and hide stop it. A short release-click guard prevents the same drag gesture opening the panel. Native size/show hooks and UI_SCALE_CHANGED/DISPLAY_SIZE_CHANGED events recompute geometry. Artwork, right-click settings, visibility and tooltips are preserved; no icon library is added.

## DropWatch 0.3.0 identity boundary

The private namespace still comes from the addon's varargs, now loaded as DropWatch. Visible strings, native frame names, Escape registrations and texture paths use DropWatch consistently. The validated engine modules and minimap Position/Drag implementation are unchanged. Three native slash aliases share one DROPWATCH handler: /dropwatch, /dw and /loottracker. Settings continue using the documented legacy SavedVariables globals to support manual filename-copy migration without rewriting serialized data. There is one addon/event feed and no bridge loader.

Main/minimap use Assets/DropWatch-Mini.tga; the settings gear remains Assets/Settings.tga. PNG/SVG source art is for development/project use, excluded from the runtime ZIP. See MIGRATION.md and Assets/README.md.

## Release-candidate lifecycle hardening

Session capacity eviction and actual record removal now retract outstanding notification identities/counts, bounding notification state during continuous awards and hiding removed provisional items. Native tooltip failures hide stale content. Matching, layout, expiry and minimap geometry are unchanged. See CODE_REVIEW.md and RELEASE_VALIDATION.md.
