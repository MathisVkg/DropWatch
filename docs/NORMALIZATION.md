# Canonical records and reconciliation

## Data flow and bounds

`Core/Events` snapshots readable event arguments into `ns.raw`. `Modules/Loot` parses/enriches observations in `ns.records`. `Modules/Normalize` feeds `ns.normalized`, the future UI's internal data source. Each store is capped independently at 200. Canonical IDs and observation IDs increase monotonically during the session, including across clear; they are not persisted or reused.

Only equipment and enabled mounts enter canonical loot. When classification is entirely unavailable, a readable item ID may create a **provisional** canonical record (`loaded=false`, `selected=false`) pending item data. A later filtered classification removes that provisional record and keeps its observation for diagnostics. Known irrelevant items and recognized creation messages do not create awards. Unknown acquisition formats remain visibly incomplete candidates, with unknown quantities.

Each canonical record retains at most one observation per primary source (two total), and source references retain every contributing original link. Raw events can be evicted independently; references identify their original IDs but do not promise indefinite raw-history availability. Pending work scans both observation rows and retained canonical observations, so row eviction does not strand an otherwise retained award. Late callbacks cannot recreate cleared/evicted awards.

## Matching rule

1. A repeated positive chat line ID plus identical original link within five seconds is an explicit repeat notification. Keep the raw event; do not parse or normalize it again. A new line ID is never treated as a repeat just because the item matches.
2. For opposite-source pairing, compare only unmatched single-source canonical records in the same observed activity scope, known instance ID and difficulty.
3. Require matching recipient identity (qualified realms, or readable matched roster GUIDs), the same item ID and complete `item:` payload, and known equal quantities. Color wrappers and displayed item names may differ; bonus/context fields may not. Preserve both complete original hyperlinks, with the earliest original as the primary link.
4. Require at most ten seconds between observations and a recognized non-creation acquisition. Reject conflicts between event/link IDs or recipient fields. Do not consolidate unknown messages using a guessed quantity.
5. Reconcile only when exactly one strong counterpart exists and there are no competing uncertain counterparts. Add the second observation to the existing canonical ID. This works in either arrival order.
6. Otherwise keep the incoming award/candidate. Potential counterparts within 60 seconds are marked with ambiguity reasons and up to eight candidate IDs. Ambiguous records are not greedily paired later. Outside the comparison horizon, observations remain independent.

The timing window only limits evidence for pairing; it never suppresses an incoming award. Once both sources occupy a canonical record, another same-source event must start another award. Interleaved `chat, encounter, chat, encounter` duplicates yield two awards. Batched indistinguishable `chat, chat, encounter, encounter` observations cannot be confidently assigned; all four candidates remain visible. This deliberately favors retaining evidence over guessing.

## Recipients and provenance

`Recipients` refreshes on initialization, world entry and GROUP_ROSTER_UPDATE, checking `player`, party units or up to forty raid units. Readable qualified names are direct values. A bare name can acquire a realm/GUID only from one unique current roster identity; this expansion is **inferred**. Different supplied realms/GUIDs do not merge. No roster match means no realm invention. Realm comparison removes ordinary spaces, hyphens and apostrophes and applies Lua's ASCII lowercasing; displayed text and non-Latin bytes are preserved. Character names are compared as supplied.

Localized message text determines acquisition. Matching event-argument recipient information may supply a missing realm; conflicting supplied names/realms are marked rather than silently trusted. CHAT_MSG_LOOT arg12 is not assumed to identify the award recipient. ENCOUNTER_LOOT_RECEIVED arg5 is used as recipient based on the user's successful Task 01 Heroic/Mythic+ observations, with the generated-documentation naming discrepancy retained in API_REVIEW.

## Canonical shape

| Field(s) | Meaning |
| --- | --- |
| `id`, `revision`, `timestamp`, `clock` | Stable session award ID, revision, earliest epoch and monotonic observation time |
| `player`, `realm`, `guid` | Recipient identity; absent values remain nil |
| `itemID`, `link`, `itemName`, `icon`, `rarity`, `itemLevel` | Original link and item metadata; effective level only queried with the original link |
| `category`, `equipLoc`, `classID`, `subclassID`, `mountID`, `quantity` | Classification, native equipment slot and quantity |
| `loaded`, `selected`, `equipment`, `status`, `acquisition` | Processing/selection state and observed acquisition type |
| `context` | Immutable-by-convention instance/difficulty/activity snapshot; active encounter, last successful encounter, active/completed challenge identifiers |
| `explicitEncounterID`, `encounterID`, `encounterName`, `association` | Direct encounter association versus retained contextual hint |
| `observations`, `sourceEvents`, `sources` | Contributing observations, their event/raw/observation IDs, timestamps and original links, plus source-name set |
| `confidence` | Per-field `confirmed`, `inferred`, or `unavailable` |
| `ambiguous`, `matchAmbiguous`, `ambiguityReasons`, `candidateIDs`, `uncertainties` | Matching ambiguity and missing identity/quantity evidence |

`confirmed` means directly observed readable data or a supported deterministic localized-format interpretation; it does not certify the server's award uniqueness. Matched roster expansion and contextual boss/run attribution are inferred. Even a successfully reconciled award has `confidence.uniqueness="inferred"` because no shared unique award GUID exists. Missing fields are nil with unavailable confidence. The first equally trusted field value wins; a later confirmed realm can replace an inferred realm. API retries do not replace a complete original link or erase already loaded item metadata merely because a subsequent query returns nothing.

## Context retention

Active encounters and last **successful** encounters are separate. Failed encounters do not become successful-boss hints. A direct encounter-loot ID confirms an encounter association; plain chat uses only an inferred active/last-successful hint. Completion retains both the completed run and successful encounter without a short timeout. A completed-run item is a reward **candidate**, without requiring a boss ID. A newly contributed completed-run snapshot can enrich an earlier active snapshot.

Changing known instance/difficulty/type, starting/resetting a challenge, or beginning a new encounter after a completed run starts a new activity and clears old hints. Same-activity world transitions preserve context. Login/reload resets prior history; an available active challenge map may recover active state. A temporarily missing instance query does not erase the last known identity used to detect the next actual activity transition. Past record snapshots are not mutated by these resets. These rules cannot distinguish every same-instance reset when the client emits no identifying transition; all non-explicit associations remain inferred.

## Internal change API

Future addon modules receive the existing private `ns` table from `...`:

```lua
local unsubscribe = ns:Subscribe(function(kind, record, detail)
    -- Treat ns.normalized and record tables as read-only.
end)
-- Later: unsubscribe()
```

Events are `created`, `enriched`, `reconciled`, `classification`, `removed`, and `reset`. Creation delivers a populated record (possibly provisional). Reconciliation delivers the same ID and the added observation ID in detail. Enrichment advances revision when visible fields/confidence/status change. Classification additionally supplies previous category/selection when those change after creation. Removal reports capacity eviction or a newly filtered provisional record. Reset means rebuild the consumer's state from the now-empty stores. Callback failures are isolated and counted in `ns.listenerErrors`; callbacks must not mutate model tables or re-enter loot processing. These internal callbacks do not send player-facing notifications.

## Counters

`rawLoot`: primary loot events including explicit repeats; `parsed`: unique parsed item/recipient/quantity observations with a known format; `failures`: observations missing those parsing prerequisites; `equipment`: canonical records first classified as equipment; `reconciled`: opposite-source observations paired; `ambiguous`: incoming observations with plausible but unresolved counterpart matches. Missing fields also flag an individual record for the Ambiguous view without necessarily incrementing the match counter. Counts accumulate until clear/reload; live store sizes can be lower due to reconciliation/filtering/eviction. Context/roster/item-load events appear in Raw but do not increment rawLoot.


## Task 02 consumer

The player interface now consumes this model through Modules/Session.lua. Class tokens are additive matched-roster metadata; canonical recipientNote and apiError summarize the underlying diagnostic provenance. Matching, variant comparison, observation bounds and confidence rules remain unchanged. See UI_ARCHITECTURE.md for the independent bounded history, expiry, reload cache and row pooling. Raw diagnostic caps do not cap the new session History at 200.

## v0.2.1 additive metadata

Observations retain sanitized GetItemInfo bindType. Canonical rebuild derives optional bindingCategory (warbound/soulbound/bind-on-equip/unknown), rewardSource (ordinary-loot/bonus-roll/unknown), tradeability (confirmed-ineligible/unknown), exclusionReason, classificationConfidence and classificationEvidence. None participates in recipient/variant/quantity/source matching. A bonus format is source evidence, never proof of trading eligibility. Presentation filtering operates after canonical reconciliation; no confirmed-tradeable state exists.
