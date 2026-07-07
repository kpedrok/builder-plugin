# Harness State

Typed, durable memory for this project. Survives compaction and sessions. Keep entries terse; archive anything older than ~60 days into a `## Archive` section at the bottom.

## Baseline

Recorded by `/setup-harness`. Later sessions diff against this — a drop in the test count without an explicit reason is a red flag.

- **Quick gate:** `<command>` → exit 0, `<N>` tests passing (recorded <date>)
- **Full gate:** `<command>` → exit 0, `<N>` tests passing (recorded <date>)
- **Build:** `<command>` → exit 0 (recorded <date>)

## Decisions (AD)

Architecture/approach decisions made during runs. `AD-NNN — <decision> (why, date)`.

_(none yet)_

## Lessons (L)

Non-obvious things learned the hard way. `L-NNN — <lesson> (date)`.

_(none yet)_

## Gotchas

Where the harness/workflow itself failed. Symptom → cause → what to do instead. Every stall becomes a row here.

_(none yet)_
