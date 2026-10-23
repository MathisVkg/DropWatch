# Task 02.2 — minimap positioning fix (v0.2.2)

## Cause and change

v0.2.1 anchored the icon's TOPRIGHT to Minimap's rectangular TOPRIGHT. That positions it by the surrounding box rather than its circular border. UI/Minimap.lua now anchors the button CENTER to the actual Minimap CENTER at (r*cos(angle), r*sin(angle)), with r=min(width,height)/2. The icon center lies on the rim, so its dimensions are handled by CENTER anchoring and half its diameter overlaps the border. No extra outward icon-radius offset is added.

Left-drag derives angle from the physical cursor divided by Minimap effective scale, relative to the minimap center. This correctly incorporates inherited UI scale and separate minimap scale. Anchor offsets use the map's own coordinate units and never receive a second scale multiplier. Frame size/show hooks and scale/display events reposition the button using live dimensions. Non-square bounds use the inscribed circle.

SavedVariables retain only minimapAngle (finite normalized degrees, default 45°); neither screen coordinates nor drag state persist. Reload/login both load the same configuration before button creation. Existing artwork is byte-identical. Left click, right click, tooltip, visibility, panel settings and loot behavior are preserved. No library/dependency is added. The update callback exists only during drag; release outside and hide stop it, with a brief guard against a release-generated click.

## Modified and new files

- UI/Minimap.lua — new isolated geometry/drag module.
- UI/Main.lua — delegates minimap initialization and visibility; retains the existing button reference.
- Config/Settings.lua — validated saved minimapAngle.
- Core/Namespace.lua and LootTracker.toc — version 0.2.2, new module in load order.
- tests/minimap.lua — geometry/interaction/persistence regression suite.
- tests/spec.lua — adds minimal frame level/center/effective-scale mocks.
- tests/run.py — runs new suite and fresh login/reload boot cases.
- README.md, docs/UI_ARCHITECTURE.md, docs/TESTING.md, docs/VALIDATION.txt and this report — release behavior, validation and instructions.

## Validation

Previous 255 assertions pass unchanged. Added 294 minimap assertions and 30 fresh-VM boot assertions: **579 total**, with **19** manifest Lua modules compiled/loaded in Lua 5.1. Geometry covers 120/150/240-pixel maps, effective scales 0.64/1/1.5, seven orbit angles, eight drag directions, a rectangular map and changed button dimensions. Additional cases cover frame resize/show, scale/display events, missing/zero geometry, center cursor, invalid/secret saved angles, visibility interruption, outside release, drag-click suppression, ordinary clicks/tooltips, idempotent initialization and no idle polling.

Fresh VMs restore saved angles/visibility for both genuine-login and reload world-entry flags at all three size/scale pairs. Tests use mocked frame geometry and native callbacks; rendering, actual cursor capture, combat/other-addon integration and real SavedVariables disk writes need the [in-game validation guide](TESTING.md). No real-client compatibility claim is made from mocks.

Coordinate-conversion conventions were checked against [LibDBIcon's published source](https://github.com/Questie/Questie/blob/master/Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua); no library code/dependency is included. Custom non-circular minimap skins are outside the requested circular-border fix.

## Package

LootTracker-0.2.2.zip has a single LootTracker/ addon root, includes the unchanged custom TGA files, and requires no external runtime dependency. Project files are updated after checking the baseline for concurrent changes; packaged files are verified against the project. No unrelated features or Task 03 work.
