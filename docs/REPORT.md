# Task 03 — release readiness report

## Assessment

**DropWatch 0.3.0 is prepared for owner review as a local release candidate. It is not cleared for automatic public release.** Technical checks pass; remaining owner actions are license selection/approval, real game screenshots, exact-candidate manual validation and verification of public source/issue access. Raid-specific coverage remains incomplete and must be tested or explicitly accepted/disclosed. No publication occurred.

Version 0.3.0 and interface 120105 are unchanged. Candidate folder naming outside the ZIP is an artifact label, not an addon version bump.

## Changes

- Bounded continuous compact-notification tracking by retracting session-capacity evictions.
- Retracted notification contributions when delayed classification removes a record.
- Hid stale native tooltip content after failed hyperlink lookup.
- Made packaging deterministic with fixed ZIP metadata, CRC/payload checks, SHA256 and per-file manifests.
- Added release regressions, clean-ZIP mocked boot, .gitignore, issue template and 400px project PNG.
- Prepared CurseForge/GitHub descriptions, changelog, licensing comparison, asset inventory, privacy/API audits, author checklist and final manual plan.

No validated recipient/reconciliation/binding rules, UI layout, minimap geometry, expiry duration or new feature was changed. Diagnostics/demo remain intentional runtime tools; no dead runtime module, redundant third-party runtime library or unrelated installed file was found.

## Files modified or created

- .github/ISSUE_TEMPLATE/bug_report.md
- .gitignore
- Assets/DropWatch-CurseForge.png
- Assets/README.md
- CHANGELOG.md
- Modules/Session.lua
- README.md
- UI/ItemRow.lua
- docs/API_REVIEW.md
- docs/BUILD_RELEASE.md
- docs/CODE_REVIEW.md
- docs/COMPATIBILITY_AUDIT.md
- docs/CURSEFORGE_DESCRIPTION.md
- docs/CURSEFORGE_RELEASE_CHECKLIST.md
- docs/CURSEFORGE_RELEASE_NOTES.md
- docs/GITHUB_RELEASE.md
- docs/LICENSE_REVIEW.md
- docs/RELEASE_ASSETS.md
- docs/RELEASE_VALIDATION.md
- docs/REPORT.md
- docs/SECURITY_PRIVACY_REVIEW.md
- docs/TESTING.md
- docs/UI_ARCHITECTURE.md
- docs/VALIDATION.txt
- tests/release.lua
- tests/release_packaging.py
- tests/run.py
- tools/build_icons.py
- tools/package.py

## Tests and package

**830 assertions pass**, preserving all 644 previous assertions and adding 13 stability plus 173 release/security checks. All 19 runtime modules compile/load in Lua 5.1. Regression-first checks reproduced the notification-growth issue before the fixes. The initial managed-temp test harness path was changed to an explicitly writable scratch directory; no unresolved failure remains.

Runtime ZIP: DropWatch-0.3.0.zip, exactly one DropWatch/ root and 22 files (manifest, Lua, two required textures). No tests/docs/caches/Git metadata/old releases. A future owner-approved LICENSE/NOTICE is included automatically after being added. Source timestamp variation yields identical ZIP bytes on the tested toolchain; archive contents/CRC and installed mocked boot are verified.

SHA256: 7e0ae2ec7822025d77c5c24ea497420b83ca16c4cbf9f129ff1fbc3e587caa9d

The ZIP, .sha256 and .manifest.json are adjacent in the candidate output directory. Previous release artifacts are preserved.

## Compatibility, security and limitations

[COMPATIBILITY_AUDIT.md](COMPATIBILITY_AUDIT.md) pins generated API/native chat sources to Retail 12.1.5 build 70529. All core and UI event names were located, and safe values/item links/SavedVariables/native input reviewed. Generated encounter recipient labels differ from observed working behavior; proven behavior is retained and raid validation remains explicit. No bypass of secret restrictions or guarantee of future client support is made.

[SECURITY_PRIVACY_REVIEW.md](SECURITY_PRIVACY_REVIEW.md) found no external transmission, credentials, automatic chat/trade/gameplay, downloaded code, external process or addon messaging in runtime Lua. Debug information stays local unless the user deliberately shares it. WoW can persist bounded lightweight history for reload recovery; this is not secure erasure or permanent multi-session history.

User-reported prior in-game successes: Mythic+ equipment/recipients/reconciliation, expiry, History, Warbound exclusion, main UI, minimap and branding. No actual client test/screenshot, exact-candidate combat/other-addon validation, raid test, moderation or post-publication installation was performed by the agent.

## License recommendation

No LICENSE is present or selected. Recommend **MIT for owner review** if permissive community reuse is desired; Apache-2.0 and restrictive source-visible alternatives are compared in [LICENSE_REVIEW.md](LICENSE_REVIEW.md), with primary terms and Blizzard policy references. Owner must approve holder/artwork terms, add the selected legal material, match the portal selection and rebuild before public release. No legal compatibility guarantee is claimed.

## Public materials and next actions

- [CurseForge description](CURSEFORGE_DESCRIPTION.md) and [concise release notes](CURSEFORGE_RELEASE_NOTES.md).
- [Verified development changelog](../CHANGELOG.md): Git has initial 0.2.2 import and 0.3.0 rename, not invented older tags.
- [Assets/screenshots inventory](RELEASE_ASSETS.md): original 1024px master, 400px portal PNG, game textures ready; real captures missing.
- [20-case final client checklist](RELEASE_VALIDATION.md), with automation, user reports and untested cases separated.
- [Officially sourced author portal procedure](CURSEFORGE_RELEASE_CHECKLIST.md); do not upload before owner approval.
- [GitHub draft/setup actions](GITHUB_RELEASE.md) and [reproducible build instructions](BUILD_RELEASE.md).

Existing Git history and origin https://github.com/MathisVkg/loot-tracker.git remain unchanged. No license file, tag, commit, push, remote rename, account/project creation, upload or release was made. Wait for owner review/approval before releasing.
