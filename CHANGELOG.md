# Changelog

## 0.6.3 — 2026-07-09

Two ALIGN reliability gaps closed — intent alignment and terminology alignment (design: `Design/ALIGN Intent Readback and Terminology Canonicalization.md` in the ai vault). Both are cheap additions to the existing grill/glossary machinery, no new phase.

- **Intent gap (the XY problem)** — a request often describes a solution, not the real goal, or means something other than its literal wording. New **ALIGN step 3 (intent readback)**, before the detail grill: restate the ask as **outcome · who · done-when · out of scope**, treat it as a possible solution-in-disguise ("is X the goal or a means to Y?"), and require an **explicit yes** — a hedge isn't confirmation (same bar as plan approval). Language borrowed from agent-skills `interview-me` (structured restate + non-negotiable out-of-scope line) and claude-code-context-agents ("clients describe solutions, not problems").
- **Terminology drift** — one concept, many names across frontend/backend/users (e.g. opportunity / inquiry / quote request). The grill's "sharpen fuzzy language" is upgraded to **canonicalize** (now step 4): pick one canonical name, record the losers as **aliases to avoid**, and split a word that means two things ("'account' is both Customer and User — which?"). `templates/spec.md` glossary section now carries an `_Avoid:_` aliases field; CONTEXT.md doc-sync row updated. Language borrowed from mattpocock-skills `domain-modeling` / `ubiquitous-language` (canonical term + `_Avoid_` list; the synonym/ambiguity taxonomy). Composes with v0.6.2's data & interface map — reading the real entity/type names is where cross-layer naming drift surfaces.
- One Red Flag ("speccing before the intent readback got an explicit yes") and one Rationalization row ("the request is clear, I don't need to read it back") added.

## 0.6.2 — 2026-07-09

Data-model / interface discovery made a first-class ALIGN step (design: `Design/ALIGN Data and Interface Map - discovery before design.md` in the ai vault). It was only implicit before — ALIGN said "read the modules the change touches, use search/graph tools" but forced no checked artifact, so an approach could be chosen against assumed data shapes (the plan that collapses at slice 2). Two studied frameworks make it first-class; the language is borrowed from the two sharpest: claude-code-context-agents (*"data flow traced from entry point to storage/output"*) and agent-skills (dependency graph rooted at `DB schema → API models/types → endpoints → client → UI`).

- `builder-feature`: **new ALIGN step 2** (before the grill) — map the entities/types and their real shapes, the interfaces/APIs consumed or extended, the data flow entry→storage/output, and **what's not available**, read from code/schema and never assumed. Feeds the grill (gaps → questions) and PLAN's contract-first slice ordering. Small path skips it. ALIGN exit now names the data & interfaces summary; one Red Flag ("approach chosen with no map shown") and one Rationalization row ("data model is obvious, I'll figure it out in BUILD") added.
- `templates/spec.md`: new **Data & interfaces** section (Entities/shapes · Consumes · Produces · Not available) — durable contracts, no file paths; deleted on the small path.
- Deliberately **not** done (Crawl-phase YAGNI, don't relitigate without pilot evidence): no separate gated read-only `research.md` artifact (the map lives inline in the spec — one artifact, lighter ALIGN); no schema-specialist auto-dispatch (Zod/Neo4j experts).

## 0.6.1 — 2026-07-08

Deploy-readiness + prune pass (two fresh-context reviewers over the whole repo). Four gap fixes, then cuts — net smaller than v0.5.1:

- `builder-feature`: **not-instrumented guard** (no `.harness/` → offer setup, handle as a normal task); **small path now explicitly gets a run folder + report** (was contradictory — Small said "no plan file" while REPORT/ship required run artifacts; codified pilot 4's working behavior); report-staging rationale corrected.
- `builder-setup-harness` + `builder-ship`: **workspace-root git semantics defined** — setup records whether the root is a git repo (plain folder → recommend `git init` or record `no root repo`) and whether its remote is shared; ship pushes a private root, **asks before pushing a shared root's default branch**, skips root commits when there's no root repo.
- **Pruned (shipped-but-never-executed cargo, ~1,100 words):** `templates/verifier-prompt.md` deleted (only referenced by a Phase-2 parenthetical; `reviewer-prompt.md` is the wired one) · `hooks/guardrails.sh` deleted (unwired since Phase 1; returns when Phase 4 wires it) · both legacy-migration paragraphs (≤0.3 layouts; no such installs remain, and the described paths were wrong) · triple-stated rules in builder-feature deduped (Rationalizations rows that restated bolded inline rules) · per-step workspace reminders folded into the one header invariant · goal-conditions' Stop-hook roadmap note · plugin-outbox's third copy of the routing rule · setup's doc-sync enumeration replaced with a pointer to the feature skill's table.
- Plugin-internal paths now use `${CLAUDE_PLUGIN_ROOT}`; README workspace claim tightened ("no harness files land in your work repos").
- **Deferred, deliberately (don't relitigate without new evidence):** `templates/agents/` files for the gates/tracker/review/docs mappings — the prose specs in setup have produced compatible files across both live installs, and the feature skill depends only on loose anchors (repo registry, verb blocks); revisit if a third install drifts. Also deferred: narrowing the `git add:*` allow rule (the `git add -A` ban stays prose-only until Phase 4 hooks — commits are revertible).

## 0.6.0 — 2026-07-08

Multi-repo workspace support (design: `Design/Multi-Repo Workspace Support - large-codebases doc applied.md` in the ai vault; evidence: pilot 4 on momentus + the Claude Code large-codebases guide). Builder now handles three deployment shapes — `single` (unchanged), `monorepo`, and `workspace` (a root hosting nested git repos with their own remotes, e.g. backend + frontend side by side):

- `builder-setup-harness`: Step 1 detects the workspace shape and runs detection per nested repo; gates.md opens with a **repo registry** (path · remote · default branch · kind) and one verb→command block per repo; the `## Harness` CLAUDE.md block goes in the root with a one-line repo map; **everything harness-owned stays at the workspace root** — never written into nested repos, per-repo CLAUDE.md files only recommended; project skills install at root scoped by `paths:` frontmatter globs (and reuse the project's existing equivalents instead of duplicating); baselines recorded **per repo** (`### <repo-path>` blocks in STATE.md).
- `builder-feature`: the sizing line names the target repo(s) — branches, gates, baselines, and review merge-base scope all key off that; slices name their repo; cross-repo work is ordered **contract-first** in one run; a change spanning repos is never Small. Entry hint: long scoping conversation → compact or fresh session before invoking (pilot 4 burned the window before the pipeline started). PROVE evidence-capture gotchas: Node helpers importing a project dep must live inside that repo's dir (ESM bare-specifier resolution), transient UI must be pinned or captured in the same eval.
- `builder-ship`: steps 2–4 iterate per touched repo — one PR per repo, cross-linked, merge order stated; harness artifacts commit to the workspace root (no PR — direct to default); new step offers local-stack teardown.
- `builder-improve`: new **truth-check step** — verify each outbox claim against the current source before ingesting; not reproducible → `rejected: not reproducible against v<X>` (pilot 4 queued a false claim about `templates/project-skills/` missing; the proposed fix would have been wrong).
- `templates/settings-snippet.json`: Read-deny rules for generated/vendored paths (`dist`, `build`, `*.generated.*`, `vendor`), tuned per repo at setup.
- `templates/STATE.md`: per-repo baseline block variant documented inline; `templates/project-skills/*`: commented `paths:` frontmatter placeholder setup uncomments in workspace shape.
- Fresh-context review pass on this diff (7 findings, all fixed): monorepo shape behavior defined (as `single` for git actions, per-package gate blocks optional), report section 9 now owns the touched-repo list ship reads, vendor deny glob nest-safe, `paths:` semantics worded correctly.

## 0.5.1 — 2026-07-08

Internal-alignment review pass before first post-v0.5.0 use. All findings were v0.4.0's review lane not fully propagated into templates:

- `templates/goal-conditions.md`: all three goal templates now name the review gate ("review gate run with verdicts shown") — before, an autonomous run could skip PROVE's first step and still satisfy `/goal`.
- `templates/plan.md`: PROVE ledger row gains the review gate + a `review:` field — the feature skill says verdicts and fix commits go there, but the template had no slot.
- `templates/report.html`: docs-synced table gains the CONTEXT.md/glossary and docs/adr/ rows from the skill's doc-sync checklist; footer template stamp updated (it had lagged at v0.3.2 through the v0.4.0 pill change — exactly the drift it exists to catch).
- `builder-setup-harness` Step 6: pruned redundant path listing (`.harness/` subsumes its children).

## 0.5.0 — 2026-07-08

Plugin skills renamed with the `builder-` prefix: `setup-harness` → `builder-setup-harness`, `feature` → `builder-feature`, `ship` → `builder-ship`, `improve` → `builder-improve`. Rationale: builder installs two kinds of skills — these plugin skills (namespaced `builder:` by Claude Code) and the `builder-*` project skills that setup generates into `.claude/skills/`. Before, the harness surface was split in the `/` typeahead — `/builder-` found the project skills, `/builder:` found the plugin skills, and the plugin origin of a bare row (`feature`, `ship`) was only visible on hover. Now a single `/builder-` filter surfaces the entire harness and every row shows its origin. Trade-off accepted: the fully-qualified form is now `/builder:builder-feature` (redundant, but rarely typed — the menu shows `builder-feature`). Directories, frontmatter `name:` fields, all in-doc invocation/skill references, and the README updated; CHANGELOG history left as-is (those versions really used the old names). **Breaking:** anyone who scripted `/builder:feature` etc. must update to `/builder-feature`.

## 0.4.0 — 2026-07-08

Review lane lands (first Phase-2 slice), via Anthropic's `pr-review-toolkit` plugin instead of authored agents (see `Design/Review Integration - pr-review-toolkit in the Pipeline.md` in the ai vault). Survey of all six studied frameworks converged on the shape: two review moments, parallel conditional subagents, severity gating, auto-fix only where autonomous, merge-base scope.

- New `.harness/agents/review.md` mapping (written by `setup-harness`): "run the code review" → `pr-review-toolkit` agents when installed (setup probes and prompts the install once — `anthropics/claude-plugins-official` marketplace), else fallback `general-purpose` + `templates/reviewer-prompt.md`. Records the default branch for merge-base scoping.
- `feature` PROVE gains a **review gate as its first step** (before e2e — reviewers are cheaper than a wasted e2e): scope `git diff $(git merge-base <default> HEAD)...HEAD`, parallel conditional dispatch (`code-reviewer` + `pr-test-analyzer` always; `silent-failure-hunter` / `type-design-analyzer` when applicable; never `code-simplifier` — reviewers are read-only), bounded fix loop (Critical+Important, max 2 rounds, re-dispatch only agents that had findings), else DONE_WITH_CONCERNS. Minor → report, never the diff.
- `ship` gains a **delta re-check** before opening the PR: post-review commits touching code → `code-reviewer` on that delta only; no fix loop — the human decides (fix / ship anyway / hand back). Shipped-with findings go in the PR body. "No review subagents in Phase 1" line retired.
- `templates/report.html`: review status pill (clean / N fixed / N open) with fact-ownership note.
- `templates/reviewer-prompt.md` reframed as the documented fallback; merge-base scope rule added.

## 0.3.2 — 2026-07-08

Fresh-context review of the v0.3.0 report template + its pilot-3 instance (12 findings). Template fixes:

- **`<mark>` contrast fixed** (HIGH): dedicated `--mark` token light/dark — the highlighted "load-bearing lines" in How-it-works were invisible in dark mode.
- Sequence diagram scrolls on mobile (`.diagram { overflow-x: auto }` + `min-width: 640px`) instead of shrinking labels to ~5px; `.dim` lifeline class + dashed-lifeline placeholder added (every real diagram needed it); self-call guidance (no zero-length lines); `rx` inline (CSS `rx` misses older Safari).
- **Fact-ownership rules** in the instruction comments (the same fact was echoing across 4 sections): pills own gate/baseline (3–6 pills max); asked-vs-built holds product criteria only with pointer-style evidence; lede never previews the mechanism (section 1's job); section 9 is shipping mechanics only.
- **Next-steps sharpened**: every noticed-but-not-touched item ends with <em>Suggested: ticket / ignore / monitor</em>; descoped behavior from Decisions gets listed there too.
- Template version stamp in the footer meta (drift between installs now traceable).

Kept deliberately: Google Fonts links (internet assumed per Pedro; system fallbacks cover offline).

## 0.3.1 — 2026-07-08

- **Everything the harness installs now lives under `.harness/`**: `docs/agents/` → `.harness/agents/`, `docs/product.md` → `.harness/product.md` (Kiro precedent — its steering docs live inside `.kiro/steering/`). One root = simple navigation, obvious ownership, one-directory uninstall; the "point to an existing PRD instead of duplicating" rule stays. `setup-harness` carries a one-line upgrade migration for ≤0.3.0 installs. Only `.claude/skills/` and the CLAUDE.md pointer block remain outside — Claude Code dictates those locations.

## 0.3.0 — 2026-07-08

Driven by pilot 3 (first real `/feature` on kondak-orcamento) + Pedro's reference report ("SAA-733"). Theme: Report v2 — design + pedagogy (see `Design/Report v2 - Design and Pedagogy.md` in the ai vault).

- `templates/report.html` rewritten: design-token CSS with light/dark, Inter + JetBrains Mono webfonts (system fallbacks), status pills, per-slice change cards with diffstats and ± rows, dark terminal evidence blocks, tinted callouts (ship risk / deviation / fixed-in-passing), framed captioned screenshots. CSS is plugin-owned — agents fill content, never restyle.
- New pedagogy sections: "The story" (prose narrative), "How it works" (real code excerpts + sequence diagram of the actual user action), "How to ship it", "To internalize" (reviewer questions with `<details>` answers).
- `feature` REPORT step rewritten to match: teaching-document intent, section list, hard rules (real terminal output only; screenshots ≤1200px JPEG ~70, <150 KB each), and **`git add` the report** (pilot 3 left it untracked — it didn't travel with the branch).
- **Run-folder layout** (convergent pattern across spec-kit / Kiro / OpenSpec; replaces type-grouped `.harness/specs|plans|reports/`): each run colocates its artifacts in `.harness/runs/<YYYY-MM-DD>-<feature>/{spec.md, plan.md, report.html}` — date prefix makes recency visible and re-runs collision-free; `/ship` archives the **whole folder** to `.harness/archive/` (structurally fixes pilot 3's orphaned report). Singletons (`STATE.md`, `plugin-outbox.md`) stay at the `.harness/` root. `feature` carries a one-paragraph legacy-layout migration (`git mv` per feature, DONE runs straight to archive).

## 0.2.1 — 2026-07-08

- CLAUDE.md `## Harness` block gains two session-hygiene rules so ad hoc sessions (work outside `/feature`) also doc-sync: "after finishing any piece of work, walk the doc-sync checklist in `docs/agents/docs.md`" + "fix this file if it became wrong". Trigger deliberately phrased per-piece-of-work, not per-session (session end is unobservable to the model); the deterministic Stop-hook version stays Phase 2+.
- `docs/agents/docs.md` spec now includes a condensed doc-sync checklist for those ad hoc sessions to walk.

## 0.2.0 — 2026-07-08

Driven by pilot 2 (`/setup-harness` on kondak-orcamento). Theme: skill-ownership contract + proactive self-improvement loop.

- Ownership contract documented (README): plugin = process (byte-identical everywhere), project = facts; templates are the genome.
- New `improve` skill: ingests projects' `.harness/plugin-outbox.md` into the plugin source, bumps version.
- Gotcha routing mandated in `feature` (REPORT doc-sync) and `setup-harness` (Done): universal gotchas also queue in the project's `plugin-outbox.md` (new template).
- `setup-harness` Step 5 now exercises the generated skills end-to-end (boot / drive / tear down), not just the gates.
- Baselines must be the literal gate command run once as-is.
- Permissions merge gains a denial fallback ladder (interactive ask → `.harness/settings-suggested.json`).
- New Step 6: commit the install; persistence rule everywhere ("an unstaged improvement didn't happen"); `ship` commits harness-file edits and surfaces queued outbox rows.
- Step 2 interview batched into one `AskUserQuestion` (up to 4 questions).
- Mapping self-heal rule in `feature`: first successful use of a "not wired" tool updates the mapping.
- Fullstack repos with a UI now also get `builder-prototype`.
- Plugin Gotchas seeded from pilot 2: `; echo` exit-code masking, MCP-restart-after-`.mcp.json`, destructive CLIs blocking AI agents (also seeded into the `builder-run-local` template).
- STATE.md template records the installed harness version.

## 0.1.0 — 2026-07-07

Phase 1 (Crawl) initial build: `setup-harness`, `feature`, `ship` skills + templates.
