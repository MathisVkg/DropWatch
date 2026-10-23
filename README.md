# Loot Tracker — v0.2.2

Standalone group-loot addon for World of Warcraft Retail Midnight **12.1.5**, interface **120105**. A compact charcoal panel presents the validated canonical loot feed with Recent Loot, grouped session History, native item tooltips and empty whisper shortcuts. ElvUI is not required. Task 03 is not included.

Task 01/01.1 detection and reconciliation were validated in game by the user. The user validated the v0.2.0 interface in game. **The v0.2.2 minimap positioning fix requires fresh in-game validation.** Automated native-frame mocks cannot certify rendering, taint/security behavior, actual tooltips or chat focus.

## Install / update

1. Exit WoW and locate its installation in Battle.net → WoW → gear menu → Show in Explorer.
2. Extract `LootTracker-0.2.2.zip` into `<WoW>\_retail_\Interface\AddOns`, or copy the project's contents into `AddOns\LootTracker`.
3. Verify `AddOns\LootTracker\LootTracker.toc` exists directly, without another nested folder.
4. Enable Loot Tracker, log in, run `/loottracker status` and confirm **0.2.2**. No external library or UI framework is needed.
5. Start with `/loottracker demo` for safe layout checks, then follow [manual validation](docs/TESTING.md).

## Main interface

`/loottracker` now toggles the **main player panel**. The header contains the addon-owned package icon/title, the gear (settings), minimize and close buttons. Loot/History tabs sit immediately below. Drag the title bar and use the bottom-right resize handle while unlocked. Default width is 420 UI pixels and preferred maximum height is 300. Width is user-controlled (360–1,000); preferred height is saved separately (180–900). Actual expanded height adapts from 128 up to the preferred maximum. Position and settings persist. Background opacity defaults to 88%.

Minimize collapses to a title bar at the same top-left location; click the bar or `+` to restore. Close hides the panel, settings and compact notification. Both continue collecting loot. A genuinely new award can display again according to the selected mode; enriching/reconciling an existing award does not repeat its notification.

Each item row uses the real icon when available, rarity-colored name/border, effective item level, and class-colored recipient where roster information is readable. Unknown metadata has neutral/loading placeholders. Hover the item/icon for its native tooltip; Shift/Ctrl modified item clicks use Blizzard's standard handler with the complete original link. No award link is rebuilt from an item ID.

**Recent Loot** is newest first. Each qualifying award expires independently exactly 900 seconds after its acquisition timestamp. New drops never extend older deadlines. There are no row countdowns, and instance changes/completion do not clear the list. The empty state is “No recent loot”.

**History** keeps up to **1,000** qualifying canonical award snapshots for the current login session, independently of the engine's 200-record diagnostic cap. It groups by observed instance/difficulty/activity scope, newest first, with expandable headers, equipment/mount counts and activity time. Distinguishable repeated keystones remain separate. Uncertain run assignments are labelled `run unconfirmed`; missing context goes to an unassigned group. Same-instance runs without a distinguishing event cannot be reliably separated.

## Whisper, display modes and settings

Click **Whisper** to open/focus Blizzard's native whisper input for that recipient, with a normalized realm-qualified target and an **empty body**. Nothing is inserted or sent. Own-loot shortcuts are hidden; incomplete identities and demo shortcuts are disabled. Departed players may be offline/unreachable; the addon does not predict deliverability or tradeability.

the gear, minimap right-click or `/loottracker settings` opens the lightweight settings panel:

- **Automatic panel** (default): a new qualifying award opens Loot, retaining other recent rows.
- **Compact notification**: one horizontal notification batches new awards and dismisses ten seconds after the latest new award; clicking it opens Loot. Its duration is independent of Recent retention.
- **Manual**: collect quietly; open the panel yourself.
- Equipment is always enabled. Mounts are optional, off by default; enabling affects future canonical mount detection, while retained mount snapshots are shown/hidden by the setting.
- Opacity (20–100%), position/resize lock, reset position/size, and minimap visibility.

The circular addon-owned package minimap button has left-click panel toggle and right-click settings. Its center sits on the circular minimap border; left-drag moves it around the edge and saves its angle for reload/login. It can be hidden. Normal UI scale is inherited from UIParent; no custom scaling system is introduced.

## Commands

| Command | Action |
| --- | --- |
| `/loottracker` | Toggle main Loot/History panel (changed from the old diagnostic toggle) |
| `/loottracker diag` | Toggle the original five-view diagnostic window |
| `/loottracker settings` | Toggle settings |
| `/loottracker demo` | Start/toggle isolated simulated data |
| `/loottracker demo burst` | Add three close-together simulated awards; exercise the chosen display mode |
| `/loottracker demo off` | Remove demo and restore genuine session presentation |
| `/loottracker debug` | Toggle detailed diagnostics; default off |
| `/loottracker clear` | Clear genuine History, Recent, diagnostics, counters and demo data |
| `/loottracker status` | Version, interface, event status, store sizes, mode and counters |

Demo uses fictional recipients/items and native placeholder icons, with no fabricated item hyperlink. It has multiple activity groups and an expired-History example. Its title/notification says DEMO/SIMULATED, whispers are disabled, and it never touches inventory or the detection engine. Genuine loot continues collecting in the background while demo is visible, without mixing into it or interrupting it. Demo never enters the reload cache and disappears on reload. Native item-link interactions must be tested with genuine loot.

## Session lifecycle and limits

`LootTrackerSession` is a bounded reload-recovery cache, not a permanent multi-session database. On PLAYER_LOGOUT (also used for reload), only whitelisted lightweight genuine snapshots are serialized. The next PLAYER_ENTERING_WORLD restores them **only** for explicit initialLogin=false, reloadingUi=true and a matching character identity. A new login, unknown/conflicting flags, another character, or invalid data discards the cache. In-memory SavedVariables are then cleared until the next save. Disk data can remain until WoW next writes SavedVariables; it is not admitted into a new login's History. Crashes may lose unsaved records. Native lifecycle flags and write order require client validation.

Reload reserves recovered canonical IDs to avoid collisions. New activity context after reload is conservative and can split an ongoing run into an additional unconfirmed group. The oldest History snapshot is evicted above 1,000; Recent shares this session bound. Raw events, observations and live canonicals remain capped at 200 each and are never serialized as verbose history. No messages, addon communication, trades, external integration, recommendations or publication are added.

See [architecture](docs/UI_ARCHITECTURE.md), [canonical model](docs/NORMALIZATION.md), [API review](docs/API_REVIEW.md), [implementation report](docs/REPORT.md), and [testing](docs/TESTING.md). Run development tests with Python + `lupa`: `python -m pip install lupa`, then `python tests/run.py`. These are development-only dependencies. Await interface/gameplay feedback before Task 03.

## v0.2.1 refinements

The main list uses a native 4-pixel dark track and grey proportional thumb with a brighter hover state, wheel scrolling and native dragging. It has no arrow buttons and hides when content fits. The bottom-right grip draws three subtle diagonal lines in a separate 20-pixel hit area. Locking hides the grip.

Expanded height is min(preferredMaximum, max(128, 78 + contentHeight)). Equipment rows are 48 pixels, History headers 36, with 3-pixel gaps. At the default maximum, an empty list or one row uses 128 pixels, three rows 228, and overflow stops at 300. Height changes pin the top edge and never change width. Expiration, tab switches and group collapse/expansion all recalculate. Dragging/resizing suspends content relayout until release. Manual resizing saves the maximum; moving, closing and minimizing do not replace it with the smaller adaptive height.

Settings open centered by default, drag independently by their title bar, clamp to the screen, and save their own position. Close and Escape work. The opacity slider changes only the main backdrop fill: borders retain full opacity, rows use a fixed 90% fill, buttons 94%, and settings 96%. Parent-frame alpha is never changed.

Presentation filtering hides confirmed account/Warband-bound equipment from both player lists and new-award displays. Unknown binding and ordinary Soulbound equipment remain visible. Delayed confirmation updates the same canonical ID and retracts its pending compact notification; raw observations and canonical diagnostic evidence are preserved. Canonical diagnostics show binding/source/confidence/exclusion evidence.

Bonus-roll identity alone never causes exclusion. A bonus reward with confirmed account binding is excluded under the same rule; other bonus rewards remain visible because available events do not prove non-tradeability. No positive tradeability badge is shown. Read [API research](docs/API_REVIEW.md) and [the v0.2.1 report](docs/REPORT.md), then follow [the detailed in-game checks](docs/TESTING.md). Task 03 awaits feedback.

## v0.2.2 minimap positioning fix

The custom icon now anchors CENTER to the actual Minimap CENTER using radius = min(width, height)/2 and the saved angle (45° by default). Center anchoring lets half the icon overlap the circular rim, accounting for icon dimensions without an extra outward gap. Left-drag moves it around that rim; the angle is stored in LootTrackerDB.minimapAngle and restored on reload and login. Pointer coordinates are converted using Minimap effective scale, while anchor offsets remain in local UI units. Size/show hooks and scale/display events refresh position. Left/right click, tooltip, visibility and existing artwork remain. Dragging uses a temporary update handler only. See [implementation, modified files and tests](docs/MINIMAP_FIX.md).
