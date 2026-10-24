# DropWatch 0.3.1 — loot filtering and upgrade detection

## Outcome and cause analysis

Confirmed Poor-quality equipment is excluded before canonical creation or removed after delayed classification. Unknown/secret quality is deferred safely and cannot open Loot, enter History or notify. Other non-Poor equipment and optional mounts remain supported.

Only recognized, non-conflicting CHAT_MSG_LOOT / ENCOUNTER_LOOT_RECEIVED evidence can create acquisition candidates. Unknown linked messages, created items and conflicting payloads stay diagnostic-only. Cache callbacks can only enrich captured candidates, observation replay is idempotent and stable chat line replay remains bounded by the existing observation store. Captured original hyperlinks and the first readable effective levels are retained; later metadata refreshes do not rewrite old awards.

The unchanged 0.3.0 source reproduced the grey bug, the unknown-format normalization gap and refresh overwriting a captured level. It also confirmed callbacks alone do not create awards. These are confirmed source/mock findings, not proof of the exact live Steelbark Cloak sequence.

**Remaining uncertainty:** no original NPC event trace was supplied. If the client emits a recognized acquisition-style message for an upgrade, this candidate may still accept it. No NPC-wide, self-loot, pushed-loot or global item-ID/name suppression was added. Use [the focused in-game checklist](IN_GAME_031_CHECKLIST.md) to capture the sequence. See [full investigation](LOOT_ACQUISITION_REVIEW.md) for evidence and hypotheses.

## Tests and archive

All 921 assertions pass, including 81 new acquisition/quality/upgrade checks and all existing suites. All 19 modules compile/load with Lua 5.1 (lupa 2.8); the exact ZIP boots with mocked native APIs. Normal/raid boss awards, M+ multi-recipient/multi-source rewards, separate repeated acquisitions, Warbound, mounts, whisper, History, expiry, display modes and secret/missing data regressions pass. Four additional baseline assertions cover optional event registration.

Existing tools/package.py builds DropWatch-0.3.1.zip deterministically: one DropWatch/ root and 23 files (TOC, 19 Lua modules, two required TGA textures and MIT LICENSE). Source/payload bytes, CRC, fixed ZIP metadata, sidecar hashes/manifest, exclusions and changed-mtime reproducibility pass. LICENSE is unchanged and packaged exactly. Original artwork and all UI design files are unchanged; only diagnostic text was added to the existing diagnostic view.

SHA256: a9c38834c22a4fd36a6b652ef808f0d5faba71ea439645045a443a445c35f05e

Toolchain: Python 3.12.14, zlib 1.3.2, lupa 2.8 / Lua 5.1. Version 0.3.1 is consistent in manifest, namespace, packager and current release docs/tests; historical version references are retained. Interface 120105 is unchanged.

## Files modified

- CHANGELOG.md
- Core/Events.lua
- Core/Namespace.lua
- docs/BUILD_RELEASE.md
- docs/CODE_REVIEW.md
- docs/COMPATIBILITY_AUDIT.md
- docs/CURSEFORGE_DESCRIPTION.md
- docs/CURSEFORGE_RELEASE_CHECKLIST.md
- docs/CURSEFORGE_RELEASE_NOTES.md
- docs/GITHUB_RELEASE.md
- docs/IN_GAME_031_CHECKLIST.md
- docs/LOOT_ACQUISITION_REVIEW.md
- docs/MIGRATION.md
- docs/RELEASE_VALIDATION.md
- docs/REPORT.md
- docs/SECURITY_PRIVACY_REVIEW.md
- docs/TESTING.md
- docs/VALIDATION.txt
- DropWatch.toc
- Modules/Loot.lua
- Modules/Normalize.lua
- Modules/Presentation.lua
- README.md
- tests/acquisition.lua
- tests/branding.lua
- tests/packaging.py
- tests/polish.lua
- tests/refinement.lua
- tests/release.lua
- tests/release_packaging.py
- tests/run.py
- tools/package.py
- UI/Diagnostics.lua

## Remaining validation and publication

No new live-client test is claimed. NPC acquisition-style message reproduction, grey-drop and real dungeon/raid checks, final smoke/upgrade validation, screenshots, public source/Issues verification and author publication approval remain pending.

The initial Git worktree was clean at 85da5e1. Changes remain in the working tree for review; no history rewrite, commit, tag, push, GitHub release or CurseForge publication is performed.
