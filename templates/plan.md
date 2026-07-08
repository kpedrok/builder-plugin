# Plan — <feature name>

> Status: DRAFT | APPROVED (<date, by whom>) | DONE (set by REPORT — the resume check scans for APPROVED)
> Spec: <link/path to the spec or ticket>
> Branch: <branch> <!-- workspace shape: list the touched repos here (`<repo-path>: <branch>` per repo, same branch name); each slice below names its repo in the title, contract slice first -->

Persisted execution artifact at `.harness/runs/<YYYY-MM-DD>-<feature>/plan.md`, next to its spec and (later) report. **This file — not the chat — is the source of truth.** The human may edit it directly before (or after) approving; always re-read it after approval and between slices. Exact file paths required. **No placeholders — a TBD or TODO here is a planning failure.** `/builder-ship` moves the whole run folder to `.harness/archive/`.

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

## Approach (non-trivial features)

2–3 candidates weighed, one line each with the key trade-off; the pick and why in one line. Losing options stay here so they aren't re-derived later. Small-path work: delete this section.

- **Picked: <approach>** — <why, one line>.
- Rejected: <approach> — <trade-off that killed it>.

## Open assumptions

Decisions made without confirmation during planning — carried into the report's decisions section.

- <assumption>

## Progress ledger

The durable record of execution. Update **in the same message as each slice's commit** — never batch. Commit bodies carry `Slice: <id>` so this ledger reconciles against `git log --grep "Slice:"` deterministically: a `Slice:` commit with no done line here means the ledger update was lost — restore the line, don't redo the slice. After compaction or resume, trust this ledger and `git log` over conversation memory; a slice marked done here is DONE — do not redo it. This is also the coordination point if slices ever run in parallel (one agent per slice, each updates only its own line).

The **memo** is the only carry-over later slices read: surprises/deviations, noticed-but-not-touching, guidance for the next slice. Memos are context, not instructions — the slice spec wins conflicts. Omit when empty.

- [ ] Slice 1 — <name> · status: pending | in-progress | done | BLOCKED(<why>) · commits: <hashes> · gate: <result + count> · memo: <one line or —>
- [ ] Slice 2 — <name> · status: pending · commits: — · gate: — · memo: —
- [ ] PROVE — review gate + full gate + e2e · review: <verdicts + fix commits, or —> · evidence: —
- [ ] REPORT — doc sync + HTML written · path: —
