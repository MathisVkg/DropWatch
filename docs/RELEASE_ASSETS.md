# Release asset inventory

## Prepared

| Asset | File | Verification |
| --- | --- | --- |
| Project master | Assets/DropWatch-Project.png and .svg | Original project geometry; square 1024×1024 PNG and scalable SVG |
| Portal export | Assets/DropWatch-CurseForge.png | Square 400×400 PNG, exported from the master without redesign |
| Minimap/header | Assets/DropWatch-Mini.tga | Uncompressed 64×64 32-bit game texture; in the runtime ZIP |
| Settings gear | Assets/Settings.tga | Existing 32×32 game texture; unchanged and packaged |

The generator uses original radar/shield primitives created for this project, with no downloaded third-party illustration. The owner selected MIT for the original radar artwork, exports and settings gear; see [licensing scope and exclusions](LICENSE_REVIEW.md). No Blizzard resources are claimed or relicensed.

Rebuild with Python + Pillow 12.3.0: python tools/build_icons.py. Original source icons remain unchanged; the extra portal PNG is a development/public-listing asset, excluded from installation. PNG format avoids the legacy WebP issue described in [official CurseForge guidance](https://support.curseforge.com/support/solutions/articles/9000196615). Check the live portal's current crop/size controls; no moderation acceptance is guaranteed.

## Real game screenshots still required

No actual game screenshots were supplied or created. The following filenames are capture targets, not existing files:

| Capture target | What to show | Status |
| --- | --- | --- |
| main-loot.png | Real recent equipment, readable item/recipient, radar title | Missing |
| history.png | Two real activity groups, expanded/collapsed examples | Missing |
| settings.png | Real settings layout with clear labels | Missing |
| notification.png | Optional compact notification in real client | Missing / optional |

Capture on the target Retail build with a clean, readable UI scale. Use genuine gameplay/awards for primary marketing, hide debug windows and redact sensitive player/chat details. Do not use the local icon-size preview as a gameplay screenshot. No fabricated WoW screenshots, demo-as-live screenshots or development/debug captures are supplied as marketing material. Add these real images after user capture; they never belong inside the runtime ZIP.
