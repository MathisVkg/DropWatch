# DropWatch 0.3.1 manual validation

Existing Loot Tracker users: follow [MIGRATION.md](MIGRATION.md) with WoW closed before installation; a folder rename alone does not load the old preferences.

Automated mocks verify model calculations and callbacks, not WoW rendering, mouse capture, taint, trading rules, protected values or real chat behavior. The user validated v0.2.0 in game; all refinements below still need a Retail client check.

## Install and prepare

1. Exit WoW. Back up the existing DropWatch addon folder and SavedVariables if desired.
2. Extract DropWatch-0.3.1.zip into _retail_/Interface/AddOns. Confirm DropWatch/DropWatch.toc is directly inside AddOns and both Assets TGA files exist.
3. Enable the addon. Run /console scriptErrors 1, /reload, then /dropwatch status. Expect 0.3.1 and interface 120105; report the exact game build if different. Keep other addons unchanged first to catch integration problems.
4. Record any Lua error with its stack. Commands below collect no synthetic real loot and send no messages automatically.

## Layout, scrollbar and sizing

1. Open /dropwatch with no recent loot. Expect a compact 128-pixel expanded panel, Loot/History tabs and readable empty state, no scrollbar. Header top stays at its chosen screen position.
2. Open settings with the gear. Reset panel geometry. Unlock if needed. Resize width to a comfortable value and drag vertically to a maximum around 400 pixels. Release: a short list shrinks immediately. This is expected; the larger maximum remains saved.
3. Run /dropwatch demo. Loot initially has four recent simulated rows and History has a second older activity. The panel grows with rows up to the configured maximum. Repeat /dropwatch demo burst until content overflows.
4. Inspect the scrollbar: 4-pixel dark track, grey thumb, brighter hover, no arrows. Wheel in either direction, drag thumb slowly from top to bottom, click the track, and release outside the panel. Expect correct direction, full last-row access, a proportional thumb and no content/resize-grip overlap. Test high and low UI scale.
5. Change to History. Collapse one group, expand it, then collapse all. Expect downward growth/shrink from the same title position, correct scrollbar visibility, clamped offsets and no blank overflow. Switch tabs while scrolled.
6. Grab the thumb and, while held, create a demo burst using a command macro/key if convenient. Content relayout should wait until release. Resize while content changes; expect no adaptive fight with the drag.
7. Test the grip from its visible strokes and surrounding invisible 20-pixel target. It must resize both axes, stop on release outside, honor width bounds and save preferences. Lock it: grip disappears and title dragging/resizing are disabled. Unlock restores it.
8. Move the panel, close/reopen, minimize to 32 pixels, restore with + and by clicking the title. Width/top position and maximum height remain stable. Reload with a short list, then add enough demo rows: growth should still reach your configured maximum.
9. Stop demo with /dropwatch demo off. With genuine loot, collect at least three awards separated in time. Note acquisition times; wait a full 15 minutes per award. Each expires independently, reducing Recent height; History retains it. Do not use a new award to extend an older deadline.

## Controls, settings and opacity

1. Confirm matching 22×20 header controls, thin borders and hover feedback. The gear should appear as a gear; the minimap button as a circular teal radar, without a bag or square frame. Check along the circular minimap border at different UI scales.
2. Minimap left-click toggles the panel; right-click toggles settings; hover describes controls. Hide/show via settings; verify persistence after reload.
3. On a fresh settings configuration the window opens centered. Drag its title independently; move the main panel afterward. Close/reopen and /reload: settings retain their own location. Drag toward each screen edge and confirm clamping. Test its close button and Escape.
4. In genuine or demo rows, set background opacity to 20%, 50%, 75%, then 100%, testing against bright game scenery. Only the main backdrop fill should change. Item/name/player/level text, icons, borders, tabs, Whisper, header controls and scrollbar remain opaque/readable. Settings stay dark and readable. Restore 88% if desired.
5. Exercise automatic, compact-notification and manual modes using demo bursts. Notifications combine counts, dismiss after ten seconds and open Loot on click. Closed/minimized/notification/expanded states remain distinct. Demo must say DEMO/SIMULATED.

## Genuine loot and filtering

1. Turn demo off and start with /dropwatch clear. Enable detailed diagnostics using /dropwatch debug and open /dropwatch diag. Use the Normalized Loot view for binding, reward, tradeability, confidence, reason and evidence.
2. In a dungeon/raid group, receive ordinary Soulbound equipment. It must remain in Recent and History and follow the chosen display mode. Hover and modified-click the real full hyperlink. Click Whisper for a different recipient: verify an empty native input with the right realm; do not send unless intended. Own loot hides Whisper.
3. Obtain fresh Warbound, Warbound Until Equipped or other account-only equipment through genuine loot, ideally also observe another group member receiving it. Compare the native tooltip and diagnostic classification. Confirm account binding produces a reason/evidence line, no player row in either tab and no automatic opening/notification for that item. Raw and canonical diagnostic entries remain.
4. Where item data loads late, watch the same canonical ID update. Unknown equipment may appear initially; later confirmed account binding must remove it from both views and reduce/dismiss its live compact notification. Confirm no duplicate row or second automatic opening. If metadata stays unreadable, the item remains visible.
5. Observe two event notifications of one award and two players receiving identical items. Canonical reconciliation must still produce one award for the first case and distinct recipients for the second. Record ambiguity rather than force a merge if counterpart evidence is uncertain.
6. Observe an actual bonus-roll reward if available. A matching localized bonus chat format should label bonus-roll in diagnostics. Ordinary/unknown-tradeability bonus equipment remains visible. A confirmed account-bound bonus is excluded. A bonus event/toast alone cannot prove non-tradeability; absence of a matching chat format can leave source unknown. Never expect all Soulbound or post-Mythic+ equipment to disappear.
7. Complete two distinguishable dungeon runs. Verify separate History groups and preserved 15-minute retention. Test group departures, another realm and missing class information. No automatic whisper/trade occurs.
8. Reload during the session: genuine History recovers and new canonical IDs do not collide. Settings geometry/opacity/lock/minimap persist; demo does not. Log out and back in: prior-login History must not be admitted. Clear removes all session/demo/diagnostic data.
9. Repeat key mouse/tooltip/whisper checks in combat and with your normal UI addons. Record security/taint errors instead of bypassing restrictions.

## Report feedback

Include addon/game versions, UI scale, other UI addons, active tab/mode, preferred dimensions, steps, expected/actual behavior, screenshot for layout, and copied diagnostic lines for affected awards. For filtering, include the complete original item link and source observations with binding/source/confidence/reason. Unknown metadata is intentionally retained. Stop here; Task 03 starts only after user feedback.

## Automated suite

Development only: Python with lupa 2.8 (Lua 5.1 backend), then python tests/run.py. Fresh VM per suite: baseline detection, normalization/refinement, interface/session, and polish/filter. No test runtime library is shipped as an addon dependency. Tests cover all 24 requested Task 02.1 scenarios, plus restricted/missing APIs, native offset mapping, arrow-free construction, delayed cached binding and notification retraction.

## Task 02.2 focused minimap validation

1. Install v0.3.1 and check /dropwatch status. Check the new radar icon; it should sit across the actual circular minimap rim, initially at the upper-right 45° when no angle was saved.
2. Left-drag slowly through the top, left, bottom and right sides and across the angle wrap at 0°/360°. The icon must stay on the rim, never cut across the map or float outward. Release outside the original button; it must stop following the cursor and must not toggle the panel.
3. Make ordinary left/right clicks after releasing: panel toggle/settings still work. Hover shows controls including dragging; leaving or starting a drag hides the tooltip.
4. Choose a distinctive angle such as lower-left. Run /reload, then log out/in. Both must restore the same angle. Moving/resizing the main window must not affect it.
5. Hide/show the icon with settings; confirm angle preservation and persistence after reload/login. Hide while dragging if practical: no stuck movement or update should remain. Main-panel locking continues to affect only that panel.
6. Test supported UI scales, for example 64% and 100%, and any independent minimap scale available in your normal UI addon. With a minimap-size setting, test a smaller and larger circular minimap. Repeat full-circle drag and reload. The icon should remain attached with no scale-dependent cursor offset. Automated geometry tests also cover effective scale 1.5 and map sizes 120, 150 and 240, independently.
7. Change resolution/window size, hide/show the minimap, and change its size if your UI supports it. Check that the border position refreshes. Map zoom should not shift the icon because it does not change frame geometry.
8. Check with your usual UI addons and in/out of combat. Custom square or nonstandard mask shapes are not added in this fix; report the actual map frame size/scale, skin and screenshot if the circular rim differs. Client rendering/native drag behavior remains a manual check; mocks cannot certify it.

Automated v0.2.2 coverage adds a minimap geometry/drag suite plus six fresh-VM login/reload boot cases. Prior loot, normalization, session/UI and filtering suites remain unchanged in their expectations.

## Task 02.3 focused rebranding checks

1. Follow MIGRATION.md with WoW closed, then confirm only DropWatch is installed/enabled. Check the addon list Title/Notes and /dropwatch status for version 0.3.1/interface 120105.
2. Verify every migrated preference before changing it: main and settings positions, width/preferred maximum height, display mode, background opacity, lock, mount preference, minimap angle and visibility. Reload and log out/in; preferences should remain. Session history is allowed to start fresh.
3. Test /dropwatch, /dw and /loottracker. Exercise status, debug, diag, clear, settings, demo, demo burst and demo off through the aliases. Each must invoke the same addon without duplicate detection or notifications.
4. Inspect minimap at your usual UI scales: radar circle/sweep and gold shield, no missing green texture, rectangular halo or old cube. Header must show radar plus DropWatch, with the existing layout and button behavior. Settings, notifications, diagnostics and command feedback must use DropWatch.
5. Drag around the full minimap rim, release outside, reload/login and hide/show. The saved angle, pointer alignment and old controls must behave as v0.2.2.
6. Recheck demo isolation, genuine loot/deduplication, two-run History, 15-minute Recent expiry, full native item tooltip, empty Quick Whisper and confirmed-Warbound exclusion using the preceding detailed cases. Do not send chat solely for this test.
7. Capture addon/client version, UI scale, screenshot for icon issues and diagnostic evidence for loot issues. Real-client rendering, Lua SavedVariables file loading/writes and native slash dispatch are not certified by mocks.

The install ZIP intentionally omits this documentation and development sources. Get them from the source tree. The source has detailed project/minimap artwork and reproducible build tools. Do not publish to GitHub Releases or CurseForge as part of validation.

## Release-candidate sign-off

Use [RELEASE_VALIDATION.md](RELEASE_VALIDATION.md) as the final 20-case sign-off matrix. Prior user-reported successes are distinguished from tests not yet performed on this exact hardened 0.3.1 ZIP; raid coverage remains incomplete. No publication is performed by the build/test scripts.
