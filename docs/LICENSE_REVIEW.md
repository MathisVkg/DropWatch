# MIT license and artwork review

The project owner selected MIT for DropWatch 0.3.0. The root [LICENSE](../LICENSE) contains the complete standard [OSI MIT text](https://opensource.org/license/mit), with copyright notice:

Copyright (c) 2026 Mathis Vankoekelberg

The standard permission, notice-preservation and warranty/liability wording is unchanged. LICENSE is included in the installable ZIP.

## Original artwork provenance and scope

The radar artwork was created specifically for DropWatch during the rebranding task. Review of tools/build_icons.py and Assets/*.svg shows original circles, radar sweep, detection marks and shield geometry drawn programmatically with Python/Pillow. No downloaded illustration, external logo, font or third-party artwork input is used. The project/master SVG and PNG, simplified minimap SVG/PNG/TGA and CurseForge PNG export are original DropWatch artwork and are included under the project's MIT license to the extent controlled by the project owner. The original procedurally drawn Settings.tga gear is covered on the same basis. The generator source is also covered.

This review establishes the recorded creation workflow and absence of imported artwork in the reviewed assets; it is not a trademark clearance search or an independent legal determination of third-party rights.

## Third-party exclusions

The addon references Blizzard-provided item icons, fonts, native UI textures and APIs through game resource paths. Those resources are supplied by the WoW client, are not copied into the archive, and are not relicensed or claimed as DropWatch property. World of Warcraft/Blizzard names and trademarks, game screenshots and other third-party intellectual property remain subject to their respective owners' rights.

Pillow and lupa are development dependencies with their own licenses; neither is bundled in the addon ZIP. The archive contains only DropWatch's manifest, Lua modules, two original TGA textures and LICENSE. MIT grants no additional rights to third-party resources or marks.
