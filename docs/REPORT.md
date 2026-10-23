# Task 02.3 — DropWatch rebranding report

## Summary

Loot Tracker is now DropWatch 0.3.0: Group Loot Tracker for Dungeons, Raids & Mythic+. Visible names, native frame identifiers, installation folder/TOC, texture paths and recommended commands use DropWatch. The validated detection modules and working v0.2.2 minimap positioning remain unchanged. No layout redesign or unrelated feature was added.

## Files modified or created

- Assets/DropWatch-Mini.png
- Assets/DropWatch-Mini.svg
- Assets/DropWatch-Mini.tga
- Assets/DropWatch-Project.png
- Assets/DropWatch-Project.svg
- Assets/README.md
- Config/Settings.lua
- Core/Events.lua
- Core/Namespace.lua
- DropWatch.toc
- README.md
- UI/Demo.lua
- UI/Diagnostics.lua
- UI/Main.lua
- UI/Minimap.lua
- UI/Notification.lua
- UI/Settings.lua
- docs/MIGRATION.md
- docs/MINIMAP_FIX.md
- docs/REPORT.md
- docs/REPOSITORY_RENAME.md
- docs/TESTING.md
- docs/UI_ARCHITECTURE.md
- docs/VALIDATION.txt
- tests/branding.lua
- tests/interface.lua
- tests/minimap.lua
- tests/packaging.py
- tests/polish.lua
- tests/refinement.lua
- tests/run.py
- tests/spec.lua
- tools/build_icons.py
- tools/package.py

Removed/replaced legacy files:
- Assets/LootTracker.tga
- LootTracker.toc

The local source remains in C:/Users/zeyros/Documents/repository/loot-tracker and retains its existing .git history. The source root now has DropWatch.toc. Packaging wraps it once in DropWatch/; the old TOC is not left as a second addon.

## Icon assets

Assets/DropWatch-Project.svg and 1024×1024 PNG provide detailed original project artwork: charcoal ground, teal radar circles/sweep, gold equipment shield and two detections. Assets/DropWatch-Mini.svg/PNG/TGA provide the simplified 64×64 variant with thick details and transparent circular corners. Main header and minimap load the new TGA through Interface/AddOns/DropWatch/Assets/DropWatch-Mini.tga. Settings.tga is unchanged. No arbitrary PNG/SVG game loading is assumed.

tools/build_icons.py generates both vector scenes and supersampled PNGs, then saves uncompressed 32-bit TGA through Pillow. All five generated files reproduce byte-for-byte with Pillow 12.3.0. The SVG sources are resolution-independent; the high-resolution export is suitable for future project listings. No artwork is uploaded. Local visual QA inspected 16/24/30/32px previews. WoW rendering remains untested for this rebrand.

## SavedVariables migration

Legacy global names LootTrackerDB and LootTrackerSession intentionally remain declared. With WoW completely closed, copy the account SavedVariables/LootTracker.lua to DropWatch.lua unchanged, back up any existing new file, remove/move the old addon folder outside AddOns and install only DropWatch. Its loader preserves the same validated preference schema. No automatic access to the old filename, bridge addon or dual-active installation is claimed. Current-session history need not survive. See [the complete migration procedure](MIGRATION.md).

## Commands and namespace

One DROPWATCH slash handler serves /dropwatch, /dw and legacy /loottracker, including settings/status/debug/diag/clear/demo/demo burst/demo off. The private namespace is still provided by addon varargs and now initializes for DropWatch. Native frames/Escape names use DropWatch consistently. No second event handler or parser was added. Interface 120105 is retained unchanged from the tested client.

## Automated results

644 assertions pass in the complete suite: prior 579, new branding/migration/alias 25, and TOC/path/artwork 40. All 19 manifest Lua modules compile/load in fresh Lua 5.1 VMs. Existing tests still cover loot detection, reconciliation, expiration, History, empty whisper actions, Warbound/unknown behavior, demo isolation and minimap position/scale. Migration tests load an unmodified legacy preference assignment, then initialize the new addon and verify dimensions, positions, modes, opacity, lock, mount preference and minimap settings.

Additional release checks verify a single DropWatch/ root and 22 runtime files, byte-matching the source; only manifest, Lua modules and the two required game textures are installed. Documentation, tests, SVG/PNG source art, generators, .git metadata and caches are excluded. Scope audit confirms all engine modules/Core/Safe.lua are byte-identical and minimap code changes only name/art strings.

## Package and in-game validation

Install DropWatch-0.3.0.zip. Source artwork/docs/tools remain separately available in the source folder. Follow [TESTING.md](TESTING.md), especially the focused Task 02.3 steps: migration with one active addon, title/version/commands, small-size radar rendering at your UI scale, minimap drag/reload/visibility, existing UI controls, genuine loot/History/expiry/whisper and diagnostic filtering. Capture client build, scale and screenshots/errors. Native texture rendering, file writes and slash registration cannot be certified by frame mocks.

## GitHub rename

Current origin remains https://github.com/MathisVkg/loot-tracker.git. Nothing was renamed/pushed remotely. Recommended optional target: https://github.com/MathisVkg/dropwatch.git after an administrator renames the repository in GitHub Settings; then update origin and any repository links/badges/workflows/project sites. The local directory may retain its old name. See [officially sourced steps and affected URLs](REPOSITORY_RENAME.md). No GitHub release or CurseForge publication is performed.

## Known limits

Manual preference-file transfer is necessary unless the correct file already exists. Missing old files use defaults. Do not load both versions together. Current-login history recovery across the rename is not promised. Existing event restrictions, conservative unknown tradeability, bounded history, uncertain run associations and circular-only minimap geometry remain. No positive tradeability prediction, automated messaging/trading, external service or synchronization was added. Task 03 has not begun; wait for client feedback.
