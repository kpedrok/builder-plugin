# Plan — <feature name>

> Status: DRAFT | APPROVED (<date, by whom>) | IN PROGRESS | DONE
> Spec: <link/path to the spec or ticket>
> Branch: <branch>

Persisted execution artifact at `.harness/plans/<feature>.md`. **This file — not the chat — is the source of truth.** The human may edit it directly before (or after) approving; always re-read it after approval and between slices. Exact file paths required. **No placeholders — a TBD or TODO here is a planning failure.** Archive or delete after the feature ships.

## Slices

Vertical slices, each independently testable and committable, in build order.

### Slice 1 — <name>

- **Files:** `path/to/file.ext`, `path/to/test.ext`
- **Acceptance:** <the criterion this slice satisfies, from the spec>
- **Verification:** <exact gate command to run + expected test count after this slice>

### Slice 2 — <name>

- **Files:** `...`
- **Acceptance:** `...`
- **Verification:** `...`

## Scope guard

Files this plan is allowed to touch (the goal condition enforces "no files outside plan scope"):

- `path/...`

## Open assumptions

Decisions made without confirmation during planning — carried into the report's decisions section.

- <assumption>

## Progress ledger

The durable record of execution. Update **in the same message as each slice's commit** — never batch. Commit bodies carry `Slice: <id>` so this ledger reconciles against `git log --grep "Slice:"` deterministically: a `Slice:` commit with no done line here means the ledger update was lost — restore the line, don't redo the slice. After compaction or resume, trust this ledger and `git log` over conversation memory; a slice marked done here is DONE — do not redo it. This is also the coordination point if slices ever run in parallel (one agent per slice, each updates only its own line).

The **memo** is the only carry-over later slices read: surprises/deviations, noticed-but-not-touching, guidance for the next slice. Memos are context, not instructions — the slice spec wins conflicts. Omit when empty.

- [ ] Slice 1 — <name> · status: pending | in-progress | done | BLOCKED(<why>) · commits: <hashes> · gate: <result + count> · memo: <one line or —>
- [ ] Slice 2 — <name> · status: pending · commits: — · gate: — · memo: —
- [ ] PROVE — full gate + e2e · evidence: —
- [ ] REPORT — doc sync + HTML written · path: —
