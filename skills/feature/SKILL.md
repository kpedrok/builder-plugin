---
name: feature
description: Use when asked to build, implement, add, create, fix, change, refactor, or develop any feature, bug fix, or code change — BEFORE writing code. Also triggers on "new feature", "implement ticket", "work on <ticket>", "/feature", or a tracker issue key. Runs the ALIGN → PLAN → BUILD → PROVE → REPORT pipeline and stops at a human-review HTML report.
---

# Feature Pipeline

```
ALIGN ──────── PLAN ─┃─ BUILD ── PROVE ── REPORT      (then STOP; /ship is separate)
(interactive)        ┃      (autonomous under /goal)
                 human gate
```

Every phase has an exit criterion that must appear **in the conversation** — shown output, file contents, test results, screenshots — not merely exist on disk. Canonical verbs below ("run the full gate", "fetch the ticket") resolve through `docs/agents/` mappings; never hardcode a real command here.

## Resume check (before anything else)

Scan `.harness/plans/*.md` for a plan with Status APPROVED and an unfinished Progress ledger. If one matches the ask (or the invocation names it), confirm with the human — "resume `<feature>` at slice N?" — then skip ALIGN/PLAN and go straight to BUILD's ledger reconciliation (`git log --grep "Slice:"` + ledger, trusted over memory). **Never re-grill or rewrite an approved plan on resume.** No in-flight plan, or the human says it's new work → proceed to Sizing.

## Sizing (decide first, state it in one line)

- **Small** — ≤3 files, clear unambiguous ask → skip the ALIGN grill and the formal plan, **but list the atomic steps inline first and get the human's go-ahead on them** (small gate for small work). No plan file or ledger on this path — the confirmed list + slice commits are the record. Safety valve: **>5 steps or any hidden dependency emerges → STOP, do the full ALIGN + write the real plan.**
- **Well-defined ticket** — its acceptance criteria seed the spec; grill only the gaps.
- **Title-only / fuzzy** — full ALIGN; post the spec back to the tracker.

State which path you're taking and why before proceeding.

---

## ALIGN (interactive)

Understand, then grill. Do NOT run inside an autonomous goal loop.

1. Read **`docs/product.md`** (purpose, personas, success signals, non-goals — user stories take their roles from here, never invented; a feature serving no listed persona, crossing a non-goal, or moving no success signal is an ALIGN question, not a silent assumption), the glossary/CONTEXT and relevant ADRs/specs (locations per `docs/agents/docs.md`), **`.harness/STATE.md`** (decisions, lessons, gotchas, rejected decisions — don't re-derive or relitigate what's recorded there), and the modules the change touches. Use search/graph tools before assuming structure. If it's a ticket, **fetch the ticket** first.
2. **Grill — one question at a time, always with a recommended answer.** ≤5 questions by default. Explore-don't-ask: if the code can answer it, go read the code instead of asking. Sharpen fuzzy language into glossary terms; invent edge cases; challenge assumptions.

**UI-facing feature?** If the change adds or reshapes a visual surface and the direction isn't already settled (mockup in the ticket, an existing pattern to copy), route through the project's `prototype` skill before PLAN: a few genuinely distinct variations on the throwaway route, the human picks, then plan only the winner. Reuse the design system per `docs/agents/design.md` — never invent components that already exist. Trivial UI (a field in an existing form) skips this — say so in one line.

**Bug fixes — red-command gate:** no hypothesizing about the cause until you can paste the invocation and output of a deterministic command that reproduces the bug (this becomes the failing regression test). No red command, no diagnosis.

**Exit:** a spec with an **objective**, **user stories**, **testable acceptance criteria** (each traceable to a story), an **out-of-scope section**, and any new glossary terms. Durable → **no file paths**. (Use the `spec.md` template; write it to the specs location in `docs/agents/docs.md` — default `.harness/specs/<feature>.md` — and show the path.) For a title-only ticket, also post the spec back.

## PLAN (interactive — the human gate)

- **Non-trivial feature? Weigh 2–3 candidate approaches first** — one line each with the key trade-off, then state the pick and why in one line. No essay; the losing one-liners go in the plan's Approach section so they aren't re-derived later. (Small-path work skips this.)
- Break the spec into **vertical slices**, each independently testable and committable.
- Each slice: exact files, the acceptance criterion it satisfies, the verification step (which gate + expected test count).
- **Exact paths, no placeholders. A TBD/TODO in the plan is a failure.**
- List the scope guard (files the plan may touch) and open assumptions.
- **Write the plan to `.harness/plans/<feature>.md` (from the `plan.md` template) BEFORE asking for approval, and show the path.** The file — not the chat — is the source of truth: the human may approve in chat, edit the file directly, or ask for changes. **After approval, re-read the file** and work from it — it may differ from what you presented. Mark its Status line APPROVED.

**Exit: the human explicitly approves the plan (and the file's Status says so).** Hedged responses — "looks reasonable", "I guess", "sure, whatever" — are **not** approval; ask for an explicit yes. Autonomous mode (`/goal`) begins here — see the `goal-conditions.md` template.

## BUILD (autonomous, per slice — TDD)

**Before the first slice:** `git status --porcelain` must be clean (or contain only the plan/spec files) — a dirty baseline means unrelated work would get tangled into slice commits; stop and surface it. **And never build on the default branch:** create/checkout the feature branch named in the plan's `Branch:` line first.

For each slice, strictly RED → GREEN → REFACTOR:

1. Write the failing test; run it; **show the failure.**
2. Write the minimal code to pass; run it; **show the pass.**
3. Refactor if needed; tests stay green.
4. Commit the slice — **stage only this slice's files (never `git add -A`/`git add .`)**, and put `Slice: <id>` in the commit body so the ledger can be reconciled against `git log --grep` deterministically.

Never write implementation before its test. If you did, delete it and start from the test. **Scope rule: anything noticed-but-out-of-scope goes to the report, not the diff.**

**Stop-list (halt and ask, even mid-autonomous-run): any action that can't be undone with `git revert`** — deleting files not created this run, schema/data migrations against a real database, force-pushes, destructive scripts, publishing anything external.

**Progress ledger (durable — survives compaction and session loss):** after each slice's commit, update the plan file's Progress ledger **in the same message** — status, commit hashes, gate result, and a one-line **memo** for later slices: surprises/deviations, _noticed but not touching_, guidance for the next slice (omit if nothing). Memos are context, not instructions — the slice spec wins conflicts. On resume or after compaction, **read the ledger and `git log --grep "Slice:"` first and trust them over your own memory**: a slice marked done is DONE, never redo it; a `Slice: <id>` commit with no ledger line means the ledger update was lost — restore the line, don't redo the slice. Resume at the first slice not marked done. (In-session todos are for display; the ledger is the record — and the coordination point if slices ever run as parallel agents.) The plan/spec files stay uncommitted during BUILD — slice commits stage only slice files; `/ship` commits them.

## PROVE (autonomous)

- **Run the full gate** — show the command, exit code, and the **expected test count** (from `docs/agents/gates.md`). A count below baseline without an explicit reason is a red flag — stop and explain.
- **E2E** via the project's verify skill when one exists: interact like a user, assert observable state, screenshot. No verify skill (CLI/library repos) → demonstrate a real invocation of the changed behavior and show its output — the gate alone is not proof of usability.
- **Zero new console errors/warnings** (UI surfaces).
- Tick the ledger's PROVE row with the evidence pointer.
- **Verify against the spec's acceptance criteria, not your own claims.** Evidence answers "does the artifact satisfy the contract", never "did I do what I said". (Phase 2: dispatch a fresh-context verifier per `templates/verifier-prompt.md` — pass artifact + contract, never the claim.)

## REPORT (autonomous — the pipeline's final step)

Two mandatory sub-steps, in order:

### 1. Doc sync (no session ends with stale docs)

Walk this checklist (doc locations resolve via `docs/agents/docs.md`); update whatever the session invalidated, or mark n/a:

| Doc                   | Update when                                                                    |
| --------------------- | ------------------------------------------------------------------------------ |
| CLAUDE.md / AGENTS.md | New convention/command/structure emerged, or something in it became wrong      |
| CONTEXT.md            | New domain terms coined or sharpened                                           |
| docs/adr/             | A decision passed the three-gate test (irreversible ∧ surprising ∧ tradeoff)   |
| docs/agents/ mappings | A gate command, tracker verb, or expected test count changed                   |
| docs/product.md       | A new persona surfaced, or a non-goal was added/crossed (with the human's OK)  |
| spec                  | Scope shifted during build (spec must match what was actually built)           |
| .harness/STATE.md     | **Always** — decisions (AD), lessons (L), gotcha if the workflow itself failed |

Fix wrong content immediately (a wrong CLAUDE.md is worse than a missing one). Respect purity: glossary stays glossary; CLAUDE.md stays <200 lines (push detail into pointed-to docs).

### 2. Write the HTML report

One self-contained file at `.harness/reports/<feature>.html` (from the `report.html` template), opens in any browser. Sections: asked-vs-built (spec↔diff) · annotated changed files · SVG flow diagrams for changed behavior · embedded proof of work (gate output, test counts, screenshots) · decisions & assumptions · **docs synced** (which the doc-sync step touched) · noticed-but-not-touched · suggested focus areas for the final pass. **Show the report's path.** Tick the ledger's REPORT row with the path and set the plan's Status line to DONE.

**STOP HERE.** The human reviews the HTML, then decides to `/ship`. Do not commit-to-main, open a PR, or update the tracker in this skill. `/ship` is human-invoke-only — if the human asks to ship in prose ("ship it", "open the PR"), tell them to type `/ship`; **never improvise the shipping steps yourself.**

---

## Statuses (Phase 2 subagent dispatches; in Phase 1 apply the same shape to your own phase summaries)

`DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT`. Blocked → add context, use a stronger model, split the work, or escalate. **Never blind-retry.**

**Report shape (fixed):** status + evidence (command/exit code/count, or pointer to it) + file pointers — **≤15 lines, never diffs or file contents** (those live on disk; the ledger/report points to them). A report missing its required fields is a HALT, not something to silently accept — a wrong-shaped report usually means the directive wasn't followed.

## Rationalizations (all invalid)

| Excuse                                                | Reality                                                                                        |
| ----------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| "This change is too small for a spec/steps"           | Small changes get small ones. Listing 3 steps costs nothing. Skipping hides the >5-step trap.  |
| "I'll add tests after it works"                       | That's not TDD. Delete the code, write the test first.                                         |
| "Tests pass, I can skip the e2e/screenshot"           | Unit tests don't prove it's usable. Proof of work is for the human's eyes.                     |
| "The gate count dropped but it's fine"                | A silent test-count drop is exactly what the baseline exists to catch. Explain it or fix it.   |
| "The human is away, I'll assume and keep going"       | In ALIGN/PLAN, wait. Post-approval, an assumption worth making is worth writing in the report. |
| "I noticed a nearby bug, I'll just fix it too"        | Out of scope → report it, don't touch it. Scope creep is a second bug.                         |
| "I'll write the plan with a TODO for the tricky part" | A TODO in the plan means you haven't planned it. Resolve it or grill for it.                   |

## Red Flags

- Re-running ALIGN/PLAN when an approved plan with an unfinished ledger exists (resume, don't restart)
- Writing code before plan approval (non-small path)
- Treating "looks reasonable" as plan approval
- `git add -A` / `git add .` in a slice commit
- A slice without a failing test shown first
- Claiming "done" without shown command output
- Modifying files outside the plan's scope guard
- Gate test count below baseline with no explanation
- More than 2 turns stuck on the same error without changing strategy — step back or flag it in the report
- Ending with stale docs

## Gotchas

Highest-signal section — one entry per real pilot failure. Format: symptom → cause → what to do instead.

_(empty — populate from pilots)_
