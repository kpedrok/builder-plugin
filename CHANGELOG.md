# Changelog

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
