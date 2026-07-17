---
name: builder-feature
description: Use when asked to build, implement, add, create, fix, change, refactor, or develop any feature, bug fix, or code change — BEFORE writing code. Also triggers on "new feature", "implement ticket", "work on <ticket>", "/builder-feature", or a tracker issue key. Runs the ALIGN → PLAN → BUILD → PROVE → REPORT pipeline and stops at a human-review HTML report.
---

# Feature Pipeline

```
ALIGN ──────── PLAN ─┃─ BUILD ── PROVE ── REPORT      (then STOP; /builder-ship is separate)
(interactive)        ┃      (autonomous under /goal)
                 human gate
```

## Host (Claude Code or Codex — resolve once, at entry)

This skill runs on either host; `.harness/STATE.md`'s baseline records which one this project was set up for (setup detects it). Everything below is host-neutral except these anchors — resolve them for the active host and don't mix them up:

- **Bundled files.** Paths written `assets/…` or `references/…` are inside *this skill's own directory*. Resolve to an absolute path before reading: **Claude Code** → `${CLAUDE_PLUGIN_ROOT}/skills/builder-feature/<path>`; **Codex** → this installed skill's own folder (the one holding this SKILL.md) + `/<path>`.
- **Autonomous loop** (starts at plan approval). **Claude Code** → `/goal` with the conditions in `references/goal-conditions.md`. **Codex** → no native `/goal`; the conditions in `references/goal-conditions.md` are still the end-state contract — run the post-approval phases in-session (or headless via `codex exec --output-schema`) and self-check against them before REPORT. Either way the artifacts, not a loop primitive, are the proof.
- **Asking the human.** **Claude Code** → batch via `AskUserQuestion`. **Codex** → ask in chat, one batched message.
- **Review dispatch** resolves through `.harness/map/review.md` (setup wrote the host's real reviewers there) — see PROVE.
- **Invocation surface** in prose (`/builder-ship`, `/builder-feature`) is Claude Code's; on Codex the same skills are `$builder-ship`, `$builder-feature`.

**Not instrumented?** No `.harness/` directory here → say so in one line, offer `/builder-setup-harness`, and handle the request as a normal coding task — don't improvise the pipeline without the harness.

Every phase has an exit criterion that must appear **in the conversation** — shown output, file contents, test results, screenshots — not merely exist on disk. Canonical verbs below ("run the full gate", "fetch the ticket") resolve through `.harness/map/` mappings; never hardcode a real command here.

**Context hygiene at entry:** if a long scoping conversation precedes this invocation (ticket triage, screenshots, exploration), suggest the human compact or start a fresh session with just the ticket key/description — the pipeline needs the context window more than the scoping chat does (pilot 4: scoping exhausted the window before the pipeline started).

**Workspace shape** (gates.md opens with a repo registry — a root hosting nested git repos with their own remotes): every git action, gate, and baseline below is **per-repo**: the sizing line names the target repo(s); slices name theirs; the clean-tree/branch checks and the same-named feature branch happen in each touched repo; "run the gate" resolves to the named repo's block in gates.md and **its own** baseline in STATE.md; review scope is the merge-base diff per touched repo (default branches from the registry), reviewers get the combined file list. Harness artifacts (run folder, report, STATE, outbox) always live in the **workspace root** — never inside a nested repo. Single-repo installs: ignore this paragraph, nothing changes.

## Run folder (one folder per run holds all its artifacts)

Each run owns `.harness/runs/<YYYY-MM-DD>-<feature-slug>/` — created when the spec is written (small path: at step go-ahead), date = the day ALIGN starts, fixed inner filenames `spec.md` / `plan.md` / `report.html` (the folder name carries identity; `<run>` below means this folder). A re-run of the same feature gets a new dated folder — never overwrite an old run's files. `/builder-ship` moves the whole folder to `.harness/archive/`, so everything under `runs/` is by definition in flight. Cross-run singletons (`STATE.md`, `plugin-outbox.md`) stay at the `.harness/` root.

## Resume check (before anything else)

Scan `.harness/runs/*/plan.md` for a plan with Status APPROVED and an unfinished Progress ledger. If one matches the ask (or the invocation names it), confirm with the human — "resume `<feature>` at slice N?" — then skip ALIGN/PLAN and go straight to BUILD's ledger reconciliation (`git log --grep "Slice:"` + ledger, trusted over memory). **Never re-grill or rewrite an approved plan on resume.** No in-flight plan, or the human says it's new work → proceed to Sizing.

## Sizing (decide first, state it in one line)

- **Small** — ≤3 files, clear unambiguous ask → skip the ALIGN grill and the formal plan, **but list the atomic steps inline first and get the human's go-ahead on them** (small gate for small work). No spec, plan file, or ledger on this path — the confirmed list + slice commits are the record. **The run folder and REPORT still happen:** create `<run>/` at go-ahead (it will hold only `report.html`) — `/builder-ship` requires the report (pilot 4 ran exactly this way). Safety valve: **>5 steps or any hidden dependency emerges → STOP, do the full ALIGN + write the real plan.**
- **Well-defined ticket** — its acceptance criteria seed the spec; grill only the gaps.
- **Title-only / fuzzy** — full ALIGN; post the spec back to the tracker.

State which path you're taking and why before proceeding. **Workspace shape: the sizing line also names the target repo(s)** — everything downstream (branch, gates, baseline, PR) keys off that declaration. A change spanning repos is never Small.

---

## ALIGN (interactive)

Understand, then grill. Do NOT run inside an autonomous goal loop.

1. Read **`.harness/product.md`** (purpose, personas, success signals, non-goals — user stories take their roles from here, never invented; a feature serving no listed persona, crossing a non-goal, or moving no success signal is an ALIGN question, not a silent assumption), the glossary/CONTEXT and relevant ADRs/specs (locations per `.harness/map/docs.md`), **`.harness/STATE.md`** (decisions, lessons, gotchas, rejected decisions — don't re-derive or relitigate what's recorded there), and the modules the change touches. Use search/graph tools before assuming structure. If it's a ticket, **fetch the ticket** first.
2. **Map the data & interfaces the change touches — before grilling, and show it.** You cannot choose a sound approach against data you haven't verified — an approach picked on assumed shapes is the classic plan that collapses in BUILD. Produce a short map, read from the code/schema, never assumed: the **entities/types** involved and their real shapes; the **existing interfaces/APIs/contracts** the feature will consume or extend; the **data flow** traced from entry point to storage/output; and what's **not available** (the missing field/capability that rules an approach out). Use the search/graph tools — read the schema and the types; explore-don't-ask applies here too. This map feeds the grill (gaps become questions) and PLAN's slice ordering (schema → types → endpoints → UI, contract-first). Small path skips this — say so in one line.
3. **Read back the intent and confirm it — before grilling details.** Restate what you believe is being asked in one compact block: **outcome** (what's true when this is done) · **who** it's for · **done-when** (the observable signal) · **out of scope** (what this deliberately does *not* touch — non-negotiable, since half of misalignment is silent disagreement about what isn't being built). Then treat the request as possibly a **solution in disguise**: is the stated ask the goal, or a means to it? ("You asked for X — is X the goal, or a way to get Y?" A request describes a solution; dig for the need behind it.) Get an **explicit yes** on the readback — a hedge ("looks right", "whatever you think") is not confirmation, same bar as plan approval. Wrong readback → correct and re-confirm before spending questions on detail.
4. **Grill — one question at a time, always with a recommended answer.** ≤5 questions by default. Explore-don't-ask: if the code can answer it, go read the code instead of asking. **Canonicalize terms** — when a concept goes by several names across frontend, backend, and users (step 2's data map surfaces these), pick one canonical name and record the losers as aliases to avoid; when one word means two things, flag and split it ("'account' is used for both the Customer and the User — which do you mean?"). Invent edge cases; challenge assumptions.

**UI-facing feature?** If the change adds or reshapes a visual surface and the direction isn't already settled (mockup in the ticket, an existing pattern to copy), route through the project's `builder-prototype` skill before PLAN: a few genuinely distinct variations on the throwaway route, the human picks, then plan only the winner. Reuse the design system per `.harness/map/design.md` — never invent components that already exist. Trivial UI (a field in an existing form) skips this — say so in one line.

**Bug fixes — red-command gate:** no hypothesizing about the cause until you can paste the invocation and output of a deterministic command that reproduces the bug (this becomes the failing regression test). No red command, no diagnosis.

**Exit:** a spec with an **objective**, **user stories**, a **data & interfaces** summary (entities/shapes, contracts consumed/produced, what's unavailable — from step 2), **testable acceptance criteria** (each traceable to a story), an **out-of-scope section**, and any new glossary terms. Durable → **no file paths**. (Use this skill's `assets/spec.md` as the shape; write it to the specs location in `.harness/map/docs.md` — default `<run>/spec.md` — and show the path.) For a title-only ticket, also post the spec back.

## PLAN (interactive — the human gate)

- **Non-trivial feature? Weigh 2–3 candidate approaches first** — one line each with the key trade-off, then state the pick and why in one line. No essay; the losing one-liners go in the plan's Approach section so they aren't re-derived later. (Small-path work skips this.)
- Break the spec into **vertical slices**, each independently testable and committable.
- Each slice: exact files, the acceptance criterion it satisfies, the verification step (which gate + expected test count). **Workspace shape: each slice names its repo, and cross-repo work is ordered contract-first** — the slice that defines the shared shape (backend type, endpoint, schema) lands before the slices that consume it, all in this one run: splitting a cross-repo change across sessions re-derives the contract decisions per repo.
- **Exact paths, no placeholders. A TBD/TODO in the plan is a failure.**
- List the scope guard (files the plan may touch) and open assumptions.
- **Write the plan to `<run>/plan.md` (from this skill's `assets/plan.md` shape) BEFORE asking for approval, and show the path.** The file — not the chat — is the source of truth: the human may approve in chat, edit the file directly, or ask for changes. **After approval, re-read the file** and work from it — it may differ from what you presented. Mark its Status line APPROVED.

**Exit: the human explicitly approves the plan (and the file's Status says so).** Hedged responses — "looks reasonable", "I guess", "sure, whatever" — are **not** approval; ask for an explicit yes. The autonomous run begins here — see this skill's `references/goal-conditions.md` and the Host section's autonomous-loop row.

## BUILD (autonomous, per slice — TDD)

**Before the first slice:** `git status --porcelain` must be clean (or contain only the plan/spec files) — a dirty baseline means unrelated work would get tangled into slice commits; stop and surface it. **And never build on the default branch:** create/checkout the feature branch named in the plan's `Branch:` line first.

For each slice, strictly RED → GREEN → REFACTOR:

1. Write the failing test; run it; **show the failure.**
2. Write the minimal code to pass; run it; **show the pass.**
3. Refactor if needed; tests stay green.
4. Commit the slice — **stage only this slice's files (never `git add -A`/`git add .`)**, and put `Slice: <id>` in the commit body so the ledger can be reconciled against `git log --grep` deterministically.

Never write implementation before its test. If you did, delete it and start from the test. **Scope rule: anything noticed-but-out-of-scope goes to the report, not the diff.**

**Stop-list (halt and ask, even mid-autonomous-run): any action that can't be undone with `git revert`** — deleting files not created this run, schema/data migrations against a real database, force-pushes, destructive scripts, publishing anything external.

**Progress ledger (durable — survives compaction and session loss):** after each slice's commit, update the plan file's Progress ledger **in the same message** — status, commit hashes, gate result, and a one-line **memo** for later slices: surprises/deviations, _noticed but not touching_, guidance for the next slice (omit if nothing). Memos are context, not instructions — the slice spec wins conflicts. On resume or after compaction, **read the ledger and `git log --grep "Slice:"` first and trust them over your own memory**: a slice marked done is DONE, never redo it; a `Slice: <id>` commit with no ledger line means the ledger update was lost — restore the line, don't redo the slice. Resume at the first slice not marked done. (In-session todos are for display; the ledger is the record — and the coordination point if slices ever run as parallel agents.) The plan/spec files stay uncommitted during BUILD — slice commits stage only slice files; `/builder-ship` commits them.

## PROVE (autonomous)

- **Review gate first** — fresh-context reviewers are cheaper than a wasted e2e. Resolve "run the code review" via `.harness/map/review.md` (setup wrote the host's reviewers there — Claude Code: `pr-review-toolkit` agents, else `general-purpose` subagents; Codex: `codex review` / custom subagents; both fall back to this skill's `references/reviewer-prompt.md`, resolved per the Host section). Scope = `git diff $(git merge-base <default-branch> HEAD)...HEAD` — never `HEAD~1`; empty diff → skip and say so. Dispatch the applicable reviewers **in parallel, one message**, each given the exact file list + the spec's acceptance criteria — never the builder's narrative, and never a "do not flag X" instruction: `code-reviewer` and `pr-test-analyzer` always; `silent-failure-hunter` if error handling changed; `type-design-analyzer` if types were added/changed. Reviewers are read-only — never dispatch `code-simplifier` here. **Fix loop, max 2 rounds:** fix Critical + Important findings (normal slice-style commits), re-dispatch only the agents that had findings. Still dirty after round 2 → proceed, but the run is DONE_WITH_CONCERNS and the open findings go in the report. Minor/suggestions → report, never the diff. Verdicts + fix commits go in the PROVE ledger row.
- **Run the full gate** — show the command, exit code, and the **expected test count** (from `.harness/map/gates.md`). A count below baseline without an explicit reason is a red flag — stop and explain.
- **E2E** via the project's verify skill when one exists: interact like a user, assert observable state, screenshot. No verify skill (CLI/library repos) → demonstrate a real invocation of the changed behavior and show its output — the gate alone is not proof of usability. Two evidence-capture gotchas (pilot 4): a Node helper script that imports a project dep must live **inside that repo's directory** (copy in, run, `rm`) — ESM resolves bare specifiers from the script's location, not cwd, so a scratchpad-located helper fails with `ERR_MODULE_NOT_FOUND`; and transient UI (hover cards, toasts) vanishes before a separate screenshot call — pin the state via eval or capture within the same eval, don't hover-then-screenshot.
- **Zero new console errors/warnings** (UI surfaces).
- Tick the ledger's PROVE row with the evidence pointer.
- **Verify against the spec's acceptance criteria, not your own claims.** Evidence answers "does the artifact satisfy the contract", never "did I do what I said".

## REPORT (autonomous — the pipeline's final step)

Two mandatory sub-steps, in order:

### 1. Doc sync (no session ends with stale docs)

Walk this checklist (doc locations resolve via `.harness/map/docs.md`); update whatever the session invalidated, or mark n/a:

| Doc                   | Update when                                                                    |
| --------------------- | ------------------------------------------------------------------------------ |
| CLAUDE.md / AGENTS.md | New convention/command/structure emerged, or something in it became wrong      |
| CONTEXT.md            | New domain terms coined, sharpened, or canonicalized (aliases to avoid recorded) |
| docs/adr/             | A decision passed the three-gate test (irreversible ∧ surprising ∧ tradeoff)   |
| .harness/map/ mappings | A gate command, tracker verb, or expected test count changed                   |
| .harness/product.md       | A new persona surfaced, or a non-goal was added/crossed (with the human's OK)  |
| spec                  | Scope shifted during build (spec must match what was actually built)           |
| .harness/STATE.md     | **Always** — decisions (AD), lessons (L), gotcha if the workflow itself failed |
| .harness/plugin-outbox.md | A gotcha is **universal** (would bite in a different repo) — see routing below |

Fix wrong content immediately (a wrong CLAUDE.md is worse than a missing one). Respect purity: glossary stays glossary; CLAUDE.md stays <200 lines (push detail into pointed-to docs).

**Gotcha routing:** before writing any gotcha, ask *"would this bite in a different repo?"* Repo-specific → the relevant project skill's Gotchas or STATE.md. Universal (about the process, Claude Code, or common tooling) → *also* append a row to `.harness/plugin-outbox.md` (date · symptom → cause → fix · target plugin file · status `queued`; create from this skill's `assets/plugin-outbox.md` if missing). The installed plugin is a frozen snapshot — the human runs `/builder-improve` against the plugin source to ingest the outbox.

**Mapping self-heal:** if this run successfully used a tool that a `.harness/map/` mapping says is "not wired" or "manual" (e.g. a tracker MCP that has since connected), update that mapping now with the verb → real command you actually ran.

### 2. Write the HTML report — delegate to the `builder-report` skill

Invoke the **`builder-report` skill by name** (`/builder-report` on Claude Code, `$builder-report` on Codex — never by reaching into that skill's files from here), pointing it at this run's `<run>/` folder. It owns the template (`assets/report.html` in *its* directory), the writing rules, and the tag-balance/render verification; on this rung it harvests from the run's real artifacts — spec, plan, ledger, PROVE evidence — and `git add`s the finished `<run>/report.html` (staged so `/builder-ship` step 2 commits it — an untracked report gets orphaned; pilot 3).

When it returns: **show the report's path**, tick the ledger's REPORT row with the path, and set the plan's Status line to DONE (small path: no ledger/plan — skip, the report is the record).

**STOP HERE.** The human reviews the HTML, then decides to `/builder-ship`. Do not commit-to-main, open a PR, or update the tracker in this skill. `/builder-ship` is human-invoke-only — if the human asks to ship in prose ("ship it", "open the PR"), tell them to type `/builder-ship`; **never improvise the shipping steps yourself.**

---

## Statuses (phase summaries and subagent reports)

`DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT`. Blocked → add context, use a stronger model, split the work, or escalate. **Never blind-retry.**

**Report shape (fixed):** status + evidence (command/exit code/count, or pointer to it) + file pointers — **≤15 lines, never diffs or file contents** (those live on disk; the ledger/report points to them). A subagent report missing its required fields is a HALT, not something to silently accept — a wrong-shaped report usually means the directive wasn't followed.

## Rationalizations (all invalid)

| Excuse                                                | Reality                                                                                        |
| ----------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| "This change is too small for a spec/steps"           | Small changes get small ones. Listing 3 steps costs nothing. Skipping hides the >5-step trap.  |
| "The data model is obvious, I'll figure it out in BUILD" | An approach chosen against unverified shapes is the plan that collapses at slice 2. Read the schema in ALIGN. |
| "The request is clear, I don't need to read it back"  | Clear requests carry implicit assumptions and are often a solution in disguise. The readback costs one message.  |
| "I'll add tests after it works"                       | That's not TDD. Delete the code, write the test first.                                         |
| "Tests pass, I can skip the e2e/screenshot"           | Unit tests don't prove it's usable. Proof of work is for the human's eyes.                     |
| "The human is away, I'll assume and keep going"       | In ALIGN/PLAN, wait. Post-approval, an assumption worth making is worth writing in the report. |

## Red Flags

- Re-running ALIGN/PLAN when an approved plan with an unfinished ledger exists (resume, don't restart)
- Speccing before the intent readback got an explicit yes (a hedge isn't a yes)
- Choosing an approach with no data & interface map shown (non-small path) — the shapes were assumed, not read
- Writing code before plan approval (non-small path)
- Treating "looks reasonable" as plan approval
- `git add -A` / `git add .` in a slice commit
- A slice without a failing test shown first
- Claiming "done" without shown command output
- Modifying files outside the plan's scope guard
- Gate test count below baseline with no explanation
- Workspace shape: a slice without a named repo, a gate run against another repo's baseline, or a harness artifact written inside a nested repo
- More than 2 turns stuck on the same error without changing strategy — step back or flag it in the report
- Ending with stale docs

## Gotchas

Highest-signal section — one entry per real pilot failure. Format: symptom → cause → what to do instead.

- **A gate "passed" but actually failed** → `cmd > log 2>&1; echo "EXIT=$?"` reports the `echo`'s exit code (always 0), masking the command's → never chain `; echo` after a gate command; check `$?` directly or read the exit code from the harness's task result. Nearly recorded two false green baselines in pilot 2 (2026-07-08).
