# Security and privacy review — 0.3.0 candidate

Reviewed every runtime module in DropWatch.toc, the two texture dependencies and the whitelist packager.

| Area | Finding |
| --- | --- |
| External transmission | No HTTP client, upload endpoint, telemetry, external account integration or download path in runtime Lua |
| Credentials | No credential collection/storage or extra account requirement |
| Chat | Quick Whisper is an explicit button action opening an empty native input; no automatic SendChatMessage call |
| Addon communication | No addon-message send/prefix registration or synchronization |
| Gameplay | Informational event-driven display; no automatic trade, inventory, spell, movement or protected gameplay action |
| Execution | No external process, executable download, Lua loadstring/RunScript or filesystem API in runtime modules |
| Debug | Bounded local diagnostics, default debug off; no automatic sharing/upload |
| Persistence | Whitelisted preferences and bounded reload snapshots are written by WoW, not by an external service |

Data can include character/realm names, GUIDs, classes, item links, timestamps and instance/event context. Raw events and canonical/observation views are capped at 200; session snapshots at 1,000; demo at 60; each canonical has at most two source observations. Notification ID tracking now follows retained session capacity even during uninterrupted new-award traffic. Visible frame pools are bounded by the viewport and recycled.

Recent expiry does not delete session History. PLAYER_LOGOUT can write lightweight History for reload recovery; a genuine login does not admit the previous cache, but disk contents can remain until WoW writes again. Do not describe this as secure erasure or encrypted storage. /dropwatch clear clears the in-memory stores/cache; logs are not uploaded.

User-triggered native modified item clicks and opening a whisper can expose an item/recipient in the user's own game UI; actual chat sending remains the user's action. If the user manually copies diagnostics or screenshots to an issue, review/redact identifiers first.

Development Python tools use local files, temporary folders, Pillow/lupa and ZIP operations. They are excluded from installation and never executed by the addon. Test safety scans are supporting evidence, not a formal exploit proof. No runtime exception requiring external transmission or credentials was found. Native taint/combat behavior still requires final client validation.
