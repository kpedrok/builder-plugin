# Harness State

Typed, durable memory for this project. Survives compaction and sessions. Keep entries terse; archive anything older than ~60 days into a `## Archive` section at the bottom.

## Baseline

Recorded by `/builder-setup-harness`. Later sessions diff against this — a drop in the test count without an explicit reason is a red flag.

- **Installed harness:** `builder v<version>` (from the plugin's `plugin.json`; makes drift vs the plugin source visible)
- **Quick gate:** `<command>` → exit 0, `<N>` tests passing (recorded <date>)
- **Full gate:** `<command>` → exit 0, `<N>` tests passing (recorded <date>) — the literal command run once as-is, not assembled from its components
- **Build:** `<command>` → exit 0 (recorded <date>)

<!-- Workspace shape (gates.md has a repo registry): keep the "Installed harness" line, then replace the
     flat gate lines with one block per nested repo — same three lines each, recorded from inside that repo.
     A run diffs only against the blocks of the repos it touched.

### <repo-path>

- **Quick gate:** `<command>` → exit 0, `<N>` tests passing (recorded <date>)
- **Full gate:** `<command>` → exit 0, `<N>` tests passing (recorded <date>)
- **Build:** `<command>` → exit 0 (recorded <date>)
-->

## Decisions (AD)

Architecture/approach decisions made during runs. `AD-NNN — <decision> (why, date)`.

_(none yet)_

## Lessons (L)

Non-obvious things learned the hard way. `L-NNN — <lesson> (date)`.

_(none yet)_

## Rejected (don't relitigate)

Approaches considered and deliberately rejected. `R-NNN — <rejected approach>: <why> (date)`. Checked during ALIGN — re-proposing one of these without new evidence is a red flag.

_(none yet)_

## Gotchas

Where the harness/workflow itself failed. Symptom → cause → what to do instead. Every stall becomes a row here. **Routing:** a gotcha that would bite in a different repo also gets a row in `.harness/plugin-outbox.md` (ingested into the plugin via `/builder-improve`).

_(none yet)_
