# Release code review — 0.3.1

Reviewed all 19 TOC runtime modules, settings/SavedVariables, assets, tests and development packaging. No runtime module was dead or unreferenced; diagnostics/demo are deliberate user-accessible features. No bundled third-party runtime library or network dependency was found.

## Safe corrections

1. Continuous compact-notification batches retained every canonical ID even as History evicted old snapshots. A continuous stream could grow that table without the ten-second quiet timeout. Session eviction now retracts its notification contribution, bounding IDs to retained capacity.
2. Actual session removal after delayed irrelevant item classification did not retract a pending notification. Remove now does so idempotently.
3. Failed native hyperlink tooltip calls could still show stale tooltip content. The hover path now shows only on successful SetHyperlink, otherwise hides.
4. ZIP creation inherited filesystem timestamps/attributes, preventing byte-identical builds after copying a checkout. Packaging now fixes archive metadata, verifies payloads and emits checksum manifests.
5. Added .gitignore, local issue template and a 400px portal icon export. Development caches/docs/tests remain outside the runtime ZIP.

No canonical matching/recipient/binding rules, display layout, expiry duration, minimap geometry, automatic chat/trading or new feature was added. Existing tests are retained.

## Capacity/performance

Engine stores, source evidence, candidate lists, session/demo and frame pools are bounded. Session updates/sorting can scan up to 1,000 records; normalization scans at most 200 canonicals; pending scans are capped by engine contributors. These existing small fixed bounds do not justify architectural replacement. Tooltip/chat actions are user-triggered. UI redraw remains dirty/on-show plus the existing half-second cadence; minimap OnUpdate exists only during drag.

## Error and lifecycle review

Missing/restricted item/recipient values retain explicit unknown/pending/diagnostic behavior. Late updates use stable canonical IDs and do not resurrect evicted records. Separate same-source drops remain separate; only strong opposite-source observations reconcile. Group disband/world changes refresh roster/context without mutating prior snapshots. Real login clears recovery; explicit reload can restore bounded genuine history; demo never persists. Disabling/enabling requires the normal client reload lifecycle, not a fabricated hot-reload contract.

## Evidence and remaining limits

New regressions first reproduced the notification failure before the fixes. The full suite now passes, including saturation, idempotent removal, late irrelevant classification, world/group transition, tooltip failure/success, deterministic archives, exact installed-content boot and runtime safety scans.

M+ and UI behavior are user-reported working before these fixes; this exact candidate's final smoke and raid coverage remain pending. Generated encounter recipient labels differ from validated observations, so raid evidence is explicitly required/disclosed. Neither static scanning nor mocks certify all native combat/taint behavior.

## 0.3.1 focused acquisition review

Reviewed both acquisition ingress sources, canonical eligibility and reconciliation, pending-load callbacks/timeouts, session presentation, original-link/level retention and optional upgrade diagnostics. Acquisition candidates require recognized non-conflicting evidence; metadata events cannot independently submit candidates. Unknown quality is hidden until readable and confirmed Poor is excluded. Captured levels freeze after first resolution. Stable chat-line IDs and observation identity provide bounded replay protection without global item-ID suppression. No UI design/artwork or gameplay action API changed. The exact live NPC event sequence remains unknown; tests model upgrade-only events and safe corrections, not proof that all acquisition-style NPC messages can be distinguished. See LOOT_ACQUISITION_REVIEW.md.
