# DropWatch 0.3.0 — MIT and final archive

The owner selected MIT. The complete standard license is in root LICENSE with Copyright (c) 2026 Mathis Vankoekelberg. Original DropWatch radar/master/minimap/portal artwork and the settings gear are covered; native Blizzard resources and third-party intellectual property are excluded. See [license and provenance review](LICENSE_REVIEW.md).

## Changes

Added LICENSE; updated README, CHANGELOG, Assets/README and release/license/validation documentation. Canonical GitHub links now use https://github.com/MathisVkg/DropWatch. Added explicit packaging regressions for license bytes, copyright, completeness and the 23-file allowlist. Existing optional-notice coverage remains.

No addon functionality, runtime Lua, manifest, texture or icon bytes changed. Version 0.3.0 and interface 120105 are retained. Existing Git history is preserved; this task commits the changes locally and aligns origin with the supplied URL.

## Validation

All 836 automated assertions pass: 62 baseline, 66 refinement, 68 interface/session, 59 UI polish/filter, 294 minimap geometry/scale/drag, 30 fresh login/reload, 25 rebrand/migration/slash, 40 manifest/path/artwork, 13 release stability and 179 release/security checks. All 19 modules compile/load using lupa 2.8 with Lua 5.1. The packaged modules boot in a fresh mocked client.

The existing tools/package.py produced DropWatch-0.3.0.zip with one DropWatch/ root and exactly 23 files: TOC, 19 Lua modules, two required TGA textures and LICENSE. No development files or unnecessary artwork exports are installed. Payload/source equality, CRC integrity, fixed metadata, sidecar manifest/checksum and byte-identical builds despite changed source mtimes pass.

Toolchain: Python 3.12.14, zlib 1.3.2, lupa 2.8. No runtime dependency added.

SHA256: dd054c32e29da74bb01a1e1f05ee4c84be737ee259ff3fc6d0bc401a8e4f1523

The checksum and manifest are adjacent to the ZIP. LICENSE inside the archive exactly matches the repository file.

## Remaining publication blockers

Final exact-candidate WoW smoke/upgrade and gameplay checks, raid validation or explicit acceptance/disclosure, real gameplay screenshots, public source/Issues accessibility, final author publication approval and CurseForge account/project setup remain pending. Mock tests do not establish live-client rendering or combat behavior.

No GitHub release, push, tag or CurseForge publication is performed. License selection is complete; publication is a separate owner decision.
