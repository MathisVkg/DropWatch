# DropWatch — v0.3.0

**Local release candidate — not published.** Start with [release readiness](docs/REPORT.md), [manual validation](docs/RELEASE_VALIDATION.md) and the [CurseForge author checklist](docs/CURSEFORGE_RELEASE_CHECKLIST.md). License selection and real gameplay screenshots are pending owner action.

**Group Loot Tracker for Dungeons, Raids & Mythic+**

Automatically track equipment received by group members, review recent drops, and quickly whisper other players.

DropWatch is a standalone WoW Retail Midnight addon with an ElvUI-inspired charcoal interface. It requires no UI framework or external runtime library. The existing loot engine and minimap geometry are preserved. Interface 120105 remains unchanged from the client-tested v0.2.2; no new client version is claimed.

## Install

Exit WoW. Extract DropWatch-0.3.0.zip into _retail_/Interface/AddOns. Verify AddOns/DropWatch/DropWatch.toc exists directly, with no nested duplicate folder. Enable DropWatch and run /dropwatch status to confirm version 0.3.0.

The install ZIP contains runtime files only. Documentation, test fixtures, source artwork and development tools are available in the source tree.

## Upgrading from Loot Tracker

While WoW is fully closed, back up the old addon and account SavedVariables. Copy _retail_/WTF/Account/<ACCOUNT>/SavedVariables/LootTracker.lua to DropWatch.lua in the same directory, leaving its assignments unchanged. Back up any existing DropWatch.lua first. Move the old AddOns/LootTracker folder outside AddOns, then install DropWatch. Enable only one version.

The existing LootTrackerDB and LootTrackerSession global names are intentionally retained. The filename copy preserves preferences without editing Lua. The addon cannot automatically read the old file after a folder rename; no automatic migration is claimed. Session loot need not survive the rename. Verify positions, dimensions, settings and minimap angle, then /reload.

Read [the complete migration instructions](docs/MIGRATION.md) before updating an existing installation.

## Features and configuration

- Recent group equipment is displayed newest-first. Each award expires independently after 900 seconds; later awards do not extend it.
- Session History groups observed instance/difficulty/run context, including separate distinguishable keystones. Expired Recent awards remain in History.
- Native item icons, rarity colors, class-colored recipients when readable, full-link tooltips and modified clicks are preserved.
- Quick Whisper opens an empty native input for the clicked recipient. It never sends a message. Own-loot shortcuts are hidden; incomplete identities and demo shortcuts are disabled.
- Confirmed account/Warband-bound equipment is excluded from Recent, History and new-award displays; diagnostics retain the evidence. Unknown and ordinary Soulbound equipment remain visible. Bonus-roll identity alone does not prove non-tradeability.
- Automatic panel, compact notification and manual display modes are available. Notifications last ten seconds, independently of Recent retention.
- The main panel moves/resizes while unlocked. Default width is 420, preferred maximum height 300. Actual expanded height follows content from 128 up to the maximum; width remains user-controlled. A minimal scrollbar handles overflow. Minimize is a separate 32-pixel title-bar state.
- Independent settings position, opacity (20–100%, default 88%), lock, optional mounts and minimap visibility persist. Opacity affects only the main backdrop fill.
- The radar minimap icon sits on the circular rim. Left-drag changes and saves its angle, using actual map dimensions/effective scale. Left-click toggles the panel; right-click opens settings. The header uses the same simplified radar identity.

## Commands

/dropwatch is the main command. /dw and legacy /loottracker are aliases for every subcommand.

| Command | Action |
| --- | --- |
| /dropwatch | Toggle Loot/History panel |
| /dropwatch settings | Toggle settings |
| /dropwatch status | Version, client/interface, event status, mode and counters |
| /dropwatch diag | Toggle five-view diagnostics |
| /dropwatch debug | Toggle detailed diagnostics |
| /dropwatch clear | Clear session/recent/diagnostic/demo data |
| /dropwatch demo | Toggle isolated simulated data |
| /dropwatch demo burst | Add three simulated awards |
| /dropwatch demo off | Restore real session presentation |

Demo is clearly marked, uses fictional records and never enters the real detection feed, sends chat, touches inventory or persists. Genuine loot continues collecting in the background.

## Session lifecycle and limitations

History contains at most 1,000 lightweight snapshots for the current login session. LootTrackerSession is a bounded reload-recovery cache: restoration requires explicit reload flags and matching character identity. A genuine login starts fresh. Raw events, observations and live canonical diagnostics are each capped at 200. Crashes or uncertain lifecycle flags may lose recovery.

Event visibility, secret/restricted data, item cache availability and remote-instance trading rules limit classification. Unknown values stay unknown. Links cannot expose another player's individual trading timer or eligible-player list. Activity assignments remain conservative when run boundaries are unclear. Square/custom minimap skins are outside the circular-border positioning model.

The user reports successful Mythic+ detection, recipient identification, deduplication, expiration, History, Warbound exclusion, main rendering, minimap positioning and DropWatch branding. **Raid-specific testing and final validation of this exact hardened candidate remain incomplete.** Mock tests cannot certify client rendering, combat taint, native cursor capture or chat focus. No automatic trade/whisper, upgrade recommendation, permanent history, synchronization or publication is added.

## Development and artwork

Run python tests/run.py with lupa 2.8 (Lua 5.1 backend). Rebuild original SVG/PNG/TGA icons with python tools/build_icons.py and Pillow 12.3.0. Build the runtime-only ZIP with python tools/package.py <output-directory>. These are development dependencies only.

The [1024px project icon](Assets/DropWatch-Project.png) and [vector source](Assets/DropWatch-Project.svg) use charcoal, teal radar circles/sweep and a gold equipment shield. The [simplified minimap variant](Assets/DropWatch-Mini.png) has thick details for small sizes; only its uncompressed 32-bit TGA is loaded in game. See [asset build notes](Assets/README.md).

Read [validation](docs/TESTING.md), [architecture](docs/UI_ARCHITECTURE.md), [API review](docs/API_REVIEW.md), [rebrand report](docs/REPORT.md) and [optional GitHub rename instructions](docs/REPOSITORY_RENAME.md). The local repository and remote are unchanged; no release was published. Release preparation is complete; publication awaits owner approval.

## Release resources

See [CHANGELOG.md](CHANGELOG.md), [deterministic build instructions](docs/BUILD_RELEASE.md), [CurseForge description](docs/CURSEFORGE_DESCRIPTION.md), [release notes](docs/CURSEFORGE_RELEASE_NOTES.md), [release assets](docs/RELEASE_ASSETS.md), [license options](docs/LICENSE_REVIEW.md), [privacy review](docs/SECURITY_PRIVACY_REVIEW.md), [compatibility audit](docs/COMPATIBILITY_AUDIT.md) and [GitHub preparation](docs/GITHUB_RELEASE.md).

No LICENSE file is present and none was chosen automatically. MIT is the review recommendation, subject to owner approval; see the comparison before adopting terms.

For support, the configured repository issue URL is https://github.com/MathisVkg/loot-tracker/issues. Confirm public access and Issues before publishing it. Include addon/client versions, UI scale, reproduction steps and carefully reviewed/redacted diagnostics; logs never upload automatically.
