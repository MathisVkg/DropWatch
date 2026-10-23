# Changelog

Version 0.3.0 remains a local release candidate; no public release/tag is created here.

## 0.3.0

- Selected MIT, documented original artwork coverage, updated canonical GitHub links and rebuilt the licensed archive without changing addon functionality.

- Rebranded Loot Tracker to DropWatch with original radar project/minimap icons.
- Added /dropwatch and /dw; kept /loottracker as a compatibility alias.
- Preserved legacy preference globals with a documented settings-file migration.
- Release-candidate hardening: bound outstanding notification tracking to retained History and retract notifications for records removed after item loading.
- Hide stale tooltip content when a native item hyperlink query fails.
- Added deterministic runtime-only packaging, integrity/checksum manifests, clean-ZIP boot tests, release documentation and a portal-ready PNG.

## 0.2.2

- Anchored the minimap icon to the circular rim with size/scale-aware dragging and saved angular position.

## 0.2.1

- Polished the scrollbar, resize grip, header controls, settings positioning and background opacity.
- Added adaptive panel height and conservative account/Warband presentation filtering, retaining diagnostic evidence.

## 0.2.0

- Added main Loot/History interface, grouped session snapshots, independent 15-minute Recent expiration, notifications, native tooltips and empty quick-whisper actions.
- Added settings, minimap access and isolated demo mode.

## 0.1.1

- Improved normalized canonical awards, recipient resolution, original-link preservation, delayed enrichment and conservative cross-event reconciliation.

## 0.1.0

- Initial addon foundation, bounded event capture, equipment detection and diagnostics prototype.

### History verification

The local Git history contains 8e71b59 (initial import already at 0.2.2) and 7c369ce (0.3.0 rename). No version tags exist at review time. Earlier entries describe development milestones verified against retained 0.1.1/0.2.0/0.2.1 manifests, implementation reports and current code; they are not invented Git tags or claimed public releases. The 0.1.0 prototype is the documented foundation underlying that implementation. Final public version/date/type require owner approval.
