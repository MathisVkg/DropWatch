# GitHub preparation and draft release

## Reviewed state

- Local source: C:/Users/zeyros/Documents/repository/loot-tracker.
- HEAD at review: 7c369ce (rename), with initial import 8e71b59; no version tags.
- Origin: https://github.com/MathisVkg/loot-tracker.git. No rename/push/visibility change performed.
- README, build instructions, changelog, .gitignore and issue template prepared.
- LICENSE is absent, pending owner decision. Public source/Issues accessibility was not confirmed by the web fetch; verify in a signed-out browser.
- No hosted release/build workflow or external credentials are required.

## Remaining owner setup

1. Review the local diff, approve a license and complete final client validation/assets.
2. Confirm repository About title/description/topics, public source access as intended, and Issues. Suggested About text: Standalone group loot tracker for WoW Retail Midnight.
3. Confirm support links before publishing. If renaming the repository, follow REPOSITORY_RENAME.md and update all source/issues links after the rename; none was made here.
4. Commit only reviewed source/docs/assets, with no caches/archives. Create a v0.3.0 tag on the validated commit only after approval. Do not tag the previous commit accidentally.
5. Run python tests/run.py, then python tools/package.py <output-directory>. Attach the runtime ZIP and its SHA256/manifest if creating an approved GitHub release later.
6. Select Beta/prerelease status or Release consciously. No tag, commit, push or release is created by this task.

## Draft release title

DropWatch 0.3.0

## Draft release body

DropWatch is a standalone group equipment tracker for WoW Retail Midnight. It provides Recent Loot, grouped session History, native item links, empty Quick Whisper actions, configurable display modes and conservative Warbound filtering.

This candidate includes the radar identity, /dropwatch and /dw commands with /loottracker compatibility, and bounded notification tracking fixes. Install by extracting DropWatch/ into _retail_/Interface/AddOns. Follow the settings migration guide when upgrading from Loot Tracker.

Target: Retail 12.1.5, interface 120105. Mythic+ behavior was reported working in development; raid-specific validation remains incomplete. No automatic messaging/trading or tradeability guarantee. See CHANGELOG.md, RELEASE_VALIDATION.md and LICENSE_REVIEW.md before approval.

Draft only. Final license, screenshots, manual results and author release decision must be resolved before posting this text as an announcement.
