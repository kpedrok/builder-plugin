# Changelog

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
