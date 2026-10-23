# GitHub preparation and draft release

Canonical repository: https://github.com/MathisVkg/DropWatch
Issue reporting: https://github.com/MathisVkg/DropWatch/issues

The existing local repository and Git history are preserved. Task 03.1 commits the approved MIT license, artwork provenance, documentation and packaging tests locally. Origin is aligned with the owner's canonical URL. No push, tag, server-side rename, visibility change or GitHub release is performed.

## Remaining owner setup

1. Complete exact-candidate client validation, address/disclose the raid gap and supply real screenshots.
2. Confirm public source access and Issues in a signed-out browser, and review repository About/title/topics.
3. Review the committed candidate and approve publication separately. MIT is already selected and LICENSE is packaged.
4. For a later authorized release, run python tests/run.py and python tools/package.py <output-directory> from the selected revision. Review the resulting checksum/manifest.
5. Only after approval, tag the validated commit v0.3.0, choose the intended prerelease/release type and publish the ZIP with its checksum. None of those publication steps is executed here.

## Draft release title

DropWatch 0.3.0

## Draft release body

DropWatch is a standalone group equipment tracker for WoW Retail Midnight. It provides Recent Loot, grouped session History, native item links, empty Quick Whisper actions, configurable display modes and conservative Warbound filtering.

This candidate includes the original radar identity, /dropwatch and /dw commands with /loottracker compatibility, bounded notification tracking fixes and the MIT license. Install by extracting DropWatch/ into _retail_/Interface/AddOns. Follow the settings migration guide when upgrading from Loot Tracker.

Target: Retail 12.1.5, interface 120105. Mythic+ behavior was reported working in development; raid-specific validation remains incomplete. No automatic messaging/trading or tradeability guarantee. See CHANGELOG.md, RELEASE_VALIDATION.md and LICENSE_REVIEW.md before approval.

Draft only. Screenshots, manual results and the author release decision remain pending.
