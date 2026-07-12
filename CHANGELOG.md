# Changelog

## 0.11.0 — 2026-07-12

**Evidence-review round** (outside-in audit of the report against published evidence — learning science, NN/g document UX, visual-design practice, engineering-handoff prior art; `Research/Report Evidence Review` in the vault. The audit confirmed the template on most strong-evidence practice and found seven gaps, all shipped here):

- **Reviewer triage block in the hero (always present):** the agent's one-sentence *assessment* (its own judgment — allowed here and nowhere else; SBAR's fence between facts and analysis), *"spend your review here"* — 2–3 anchor links harvested from the riskiest §8 decision + the ○ items, each saying why human judgment matters there (OpenAI verification-at-scale: budget the reviewer's attention), and *"not touched"* — the scary things the diff provably doesn't do, from the spec's out-of-scope + the diff (incident-comms rule-out; never invented reassurance).
- **Ship-gates on every ○ chip** (§5 edges + §10): `decide before ship` / `ship, then watch` / `fine as-is` — ○ says *who* must act, the gate says *when* (Rust RFC's unresolved-questions split); every "decide before ship" item must appear in the triage links.
- **Captions state the CLAIM, not the topic** — every figcaption is a standalone sentence asserting what the figure is evidence for (assertion-evidence method; Mayer redundancy: caption and picture must carry different information).
- **Section verdict lines** — §4/§5/§6 open with a one-line `.sectionlede` takeaway so a heading-only scanner still gets the verdict (NN/g layer-cake scanning).
- **Worked example in the flow figure** — step text carries the run's real values ("types 12.50" → "upserts 1250 cents"), tracing one concrete value end-to-end (Sweller's worked-example effect).
- **12px floor on informational micro-text** — `.tag`, `.src`, `.kind`, `.lane`, `.eyebrow`, `th` bumped from 9.9–11.2px to the template's .72rem micro-tier (NN/g: nothing informational below ~12px; uppercase+bold compensates the remaining fraction).
- Rendered-verification with pilot-6 content in light + dark before shipping (v0.7.1 rule). Deliberate rejection recorded: NLM labeled abstract for the lede — pills+tiles already carry Result/Verification/Risk; a labeled block would be Mayer-redundant.

## 0.10.0 — 2026-07-12

**Report §4 diagram kit** (pilot 6, kondak manual-external-price: Pedro's ding — "the report doesn't have diagrams or data flows that are easy to visualize and understand." Root cause: v0.7.0 rightly demoted fragile hand-drawn SVGs to the CSS pipe strip, but the pendulum overshot — the template's only visual was one *linear* strip, so a write-then-read-back feature got flattened into five boxes with the loop hidden in the caption, and the new schema entity whose compound key *is* the mechanism had no visual at all — even though ALIGN's spec "Data & interfaces" section had captured every entity, key, and seam. The map died in the spec.)

- **Flow figure now shapes itself to the real flow** (template rule + skeleton): linear request→response → one `.pipe` strip; **write-then-read-back (most features) → two strips with `.lane` labels (write path / read path) joined by a `.pipe-link` line naming the shared artifact** (the row/queue/file) that carries data between them; genuine branch/merge/fan-out → the SVG escape hatch, unchanged. Stated as a correctness rule: one linear strip that hides the loop misrepresents the feature.
- **Data-model figure, required when the run touched schema:** `.model` cards — one `.ent` per entity (load-bearing fields only, `.f.key` on identity/join fields, `.src.new` tag on entities this run created) with a `.join` arrow stating the join condition in plain words. The mechanism a reader must see, not the whole schema; omitted entirely when no schema changed.
- **Harvest rule:** both figures pull actors, entities, and keys from the spec's "Data & interfaces" section (the ALIGN v0.6.2 map) — never invented. Closes the chain: ALIGN maps the data → spec records it → REPORT renders it.
- New plugin-owned CSS (`.lane`, `.pipe-link`, `.model`/`.ent`/`.join`), verified rendered with pilot-6's real content in light + dark + mobile before shipping (per the v0.7.1 meta-lesson) — deterministic components over freehand SVG, so diagram quality doesn't vary per generation.
- `builder-feature` REPORT §4 section description updated to match.

## 0.9.0 — 2026-07-10

**New report §5 "Rules & edge cases" — the behavioral contract** (Pedro's framing: as agents write more of the code, the report is the document through which a human comes to *own* what the agent spec'd, planned, and built; owning a solution means being able to answer "what does the system do when X?" without reading the code). Report is now 12 sections (5–11 renumbered to 6–12).

- **Two tables, harvested never invented:** *the rules* — every business rule the run implemented or newly relies on, in plain English, with where it lives and the test that pins it; *at the edges* — boundary/degenerate inputs and the system's **observed** behavior (what a test or run actually showed — never intended behavior; the evidence chip says which). An edge nobody pinned gets ○ *and* a row in §10 Noticed — an unpinned edge is a decision the human hasn't made yet, and surfacing it is the section's job.
- **`templates/spec.md`: new "Edge cases & behavior" section** — the ALIGN grill's invented edge cases now have a durable home ("when X → the system does Y"; "undefined is not a behavior"), so BUILD turns them into tests and REPORT harvests instead of reconstructing. Closes the chain: ALIGN invents → spec records → BUILD pins → REPORT proves ownership-ready.
- **§7 explore step now picks its variation from §5's tables** (the rule with the most surprising edge row) — the reader watches a documented rule bite, connecting the contract to their own hands. §12 tie-back updated to match.
- Readpath line updated: "… §5 is the contract · §6 proves it · §7 lets you reproduce it · §12 checks you understood."

## 0.8.2 — 2026-07-10

§6 "Try it yourself" upgraded from reproduce-a-recipe to **learn-by-doing** (Pedro's ask: the report must help the reader learn by exploring what was implemented — verifying the data, workflows, and business logic; the v0.7 section only replayed the proof). Steps now come in **three labeled kinds, all three required**:

- **reproduce** — re-run the proof; at least one step exercises the feature as a *user* would (unchanged from v0.7).
- **inspect** — verify the *data* first-hand: query the persisted rows / read the raw payload directly (psql/duckdb/curl), not through the app. Seeing the row beats being shown it (§5's persistence table is second-hand; this step is the reader's own eyes).
- **explore** — make a *business rule* visible by varying one input: a "Before running — what do you expect?" **predict box** (`.expect.predict`, new CSS) before the command, then what actually happens, why, and where the rule lives. Prefer the variation where the rule bites (the cap, the filter, the fallback) — discovering a rule beats reading it. (Pedagogy carried over from the field-guide's step-8 "discover the gap with your own hands", which v0.7 stole only mechanically.)

Plus: `.kind` step labels (reproduce/inspect/explore tags on each step card), and §11 ties back to §6 — at least one question targets the explore step's rule, and answers the reader saw first-hand cite their step ("you saw this in §6 step 4").

## 0.8.1 — 2026-07-10

Report-template reference fixed (source-review finding; checked against how the studied frameworks reference bundled assets — `Design/Report v3` note). The REPORT step named the template as "the `report.html` template" with **no path**, so Claude had to guess where to read it — inviting reconstruction from memory (drift from the versioned CSS/section set the "keep the CSS untouched" rule is meant to prevent).

- `builder-feature` REPORT step now reads the template from `${CLAUDE_PLUGIN_ROOT}/templates/report.html` with the Read tool, explicitly "never reconstruct from memory" — matching the sibling `reviewer-prompt.md` reference and Anthropic's own plugin-dev guidance (*"always use `${CLAUDE_PLUGIN_ROOT}` for intra-plugin references"*; its example is literally `${CLAUDE_PLUGIN_ROOT}/templates/report.md`). Convention confirmed across frameworks: co-located skill assets use a relative path (`references/x.md`); plugin-root/shared assets use `${CLAUDE_PLUGIN_ROOT}` — `templates/` is plugin-root and shared, so the latter applies.
- README `templates/` bullet corrected — it claimed setup "stamps" all nine templates into the project. Only `product.md`, `STATE.md`, the settings snippet, and `project-skills/` are stamped at setup; `report.html`, `reviewer-prompt.md`, `goal-conditions.md`, the `spec.md`/`plan.md` shapes, and `plugin-outbox.md` are read live from the plugin (or created on demand) and never copied in.

## 0.8.0 — 2026-07-10

Prune + rename pass from a full-source review (no new behavior). Existing installs: rerun `/builder-setup-harness` or `mv .harness/agents .harness/map` by hand — pre-1.0, no migration shipped.

- **`.harness/agents/` → `.harness/map/`** — the biggest naming smell: none of those files are agents, they're verb→command mappings, and the old name collided conceptually with Claude Code's own agents. 30 references renamed across skills, templates, README; the README no longer needs a "these are not sub-agents" disclaimer.
- **`goal-conditions.md` shrunk 65→45 lines** — the three example goals restated the workflow, violating the template's own anti-pattern ("the skill carries the process; the goal only names the artifacts"). Now one artifact-naming template + one-line bug-fix/refactor/workspace variants.
- **Speculative phase framing trimmed from live skills** — "Phase 2 subagent dispatches", "Phase 4 hook enforcement", "Stop-hook version is Phase 2+", "Ship (Phase 1)" forward-refs removed; the roadmap lives in one place (README design notes + the ai vault's Harness Sketch), not sprinkled through instructions the model executes.
- **Empty `.gitignore` deleted** — dead file.

## 0.7.1 — 2026-07-10

Report polish pass — reviewed the v0.7.0 template filled with pilot-5's real content (not placeholders), rendered desktop + mobile. Fixes from that review:

- **Section hierarchy** — h2 1.15→1.35rem with the section number in accent color; the 11 sections were disappearing under the new hero scale.
- **Reading-path line** (fixed text, under the evidence legend): *"In a hurry? Pills & tiles are the verdict · §1 and §4 explain it · §5 proves it · §6 lets you reproduce it · §11 checks you understood."* — routes juniors and tech leads to their layer without either reading linearly.
- **Pipeline-step overflow** — long code tokens (routes, class names) now wrap inside `.pstep` cards (`overflow-wrap: anywhere`); the strip + caption is now a proper `<figure class="flow">`.
- **Tag noise rule** — tag only the steps this run added (`.tag.new`); tagging every step "existing" read as noise in the filled sample.
- **Mobile** — the section nav goes static under 700px (3 sticky rows ate a quarter of the viewport).
- **Chip tooltips** — `title` attributes on the bare ✓/◐/○ table chips, so hover explains them away from the legend.

## 0.7.0 — 2026-07-10

Report v3 — evidence discipline + reproduce-it-yourself (design: `Design/Report v3 - Field Guide Steal-List.md` in the ai vault; source: pilot-5 run review + Pedro's hand-grown momentus `field-guide.html`, which beat the v0.6 report on presence and per-claim verification). Template restructured (now 11 sections), skill's report step rewritten to match.

- **Evidence chips** — every claim wears how it was verified: ✓ *live this run* / ◐ *fixture or inference* / ○ *needs a human*. Used in the Asked-vs-built Met column (kills the "✓ with an asterisk" hack for partially-met ACs), a new §5 **validation log** (claim · how verified · chip), and §9 items. Legend under the pills. Rule: never award ✓ to something the run didn't observe.
- **New §6 "Try it yourself" (always present, Pedro's ask)** — teaches the reviewer to reproduce the proof *without the session*: prereq cards (services/env/seeds), 3–6 numbered copy-paste steps each with a "what you'll see" expectation box (success signal + likeliest failure and fix), last step exercises the feature as a *user* would. Steps that need session-only state say so with ○, never pretend.
- **CSS pipeline strip replaces the SVG sequence diagram** as the default flow visual — numbered step cards with real actor/route names and existing/this-run tags; responsive by construction, far more robust to generate. Hand-drawn SVG only for genuinely non-linear flows.
- **Presence** — sticky section nav, hero-scale headline (`clamp`), **stat-tile row** (tests+delta / files / ±lines / slices), terminal blocks get window chrome (traffic lights + context-labeled title bar, `$` via CSS) and a "what it means" line after each (`.expect`, `.aha` for the payoff), callouts get a 3px left border.
- **Handoff & staleness** — §10 gains an optional **paste-ready block** (PR description / ask-to-a-teammate, verbatim); §9 items each carry a **proof anchor** (the command/file/ticket that shows the issue exists); footer records the HEAD commit the report reflects + a re-verify warning. Template footer version now tracks the plugin version.

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
