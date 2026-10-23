# DropWatch minimap geometry

The circular positioning introduced in v0.2.2 is preserved in v0.3.0. Only the visible name and texture path changed for the rebrand.

UI/Minimap.lua anchors the button CENTER to the actual Minimap CENTER at r*cos(angle), r*sin(angle), where r=min(width,height)/2. CENTER anchoring handles icon dimensions naturally; the icon center sits on the circular rim. Cursor pixels are divided by Minimap effective scale before computing atan2 relative to its center.

The saved minimapAngle is normalized to 0–360 degrees and defaults to upper-right 45°. Size/show hooks and UI_SCALE_CHANGED/DISPLAY_SIZE_CHANGED refresh the live anchor. Only dragging uses OnUpdate; normal/outside release and hide stop it. A brief drag-release guard prevents a release-generated click. Normal clicks, tooltip and visibility work as before.

Regression coverage retains 294 geometry/drag assertions plus 30 fresh login/reload assertions: map sizes 120/150/240, effective scales 0.64/1/1.5, orbit/drag directions, changed button dimensions, invalid angles, missing geometry, visibility interruption, outside release and no idle polling. Real native rendering/drag behavior still needs the current client test.

See TESTING.md for focused checks and MIGRATION.md for keeping the saved angle when renaming the addon. Non-circular skin support is outside this model.
