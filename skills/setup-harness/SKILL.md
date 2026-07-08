---
name: setup-harness
description: Run once per project to install the builder harness. Human-invoke-only (type /setup-harness); the model cannot trigger it. Detects the stack, interviews for what detection can't answer, scaffolds config + state, generates project-owned skills, and proves the gates work.
disable-model-invocation: true
---

# Setup Harness — the installer

Instrument the current project so work can flow through the `feature` pipeline. Explicit invocation only. Target: ≤10 minutes, mostly detection.

**Hard rule that governs everything below: run every command before you write it into a skill, mapping, or STATE.md. An unverified command is a liability, not an asset.** If a command you expected to exist doesn't work, stop and ask — never write a guessed command.

**Interactive commands hang autonomous runs.** Some CLIs prompt and block forever (e.g. `prisma migrate dev`, unscoped `git rebase -i`, first-run auth). Prefer the non-interactive variant (`prisma migrate deploy` / `migrate status`), and when you write such a command into a skill, record the non-interactive form + a Gotcha noting the interactive one hangs. If a setup command stalls, don't wait it out — kill it, find the non-interactive path, and move on.

## Step 1 — Detect (explore before asking)

Read the repo and infer as much as possible. Do NOT ask what you can detect:

- **Stack / language** — manifest files (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `*.csproj`, `Gemfile`), lockfiles, framework deps.
- **Test runner + how to run it** — scripts in the manifest, CI config, existing test dirs.
- **Repo type** — frontend (React/Vue/Svelte/etc.), API/backend, fullstack, CLI, library, monorepo. This decides which project skills to generate.
- **Git remote + tracker** — `git remote -v`; GitHub → likely `gh`/Issues, GitLab → `glab`, Jira/Linear/etc. from remote or existing config.
- **Existing docs** — CLAUDE.md / AGENTS.md, `docs/`, ADRs, CI workflows.
- **Product context** — README intro, landing/marketing pages, an existing PRD or pitch doc: what the software is for and who uses it. Draft a purpose + candidate personas from what you find.

Summarize what you found in chat before asking anything.

## Step 2 — Ask (only the gaps, one at a time, recommended answer first)

For each thing detection couldn't settle, ask ONE question with a recommended default. Cover:

- Tracker + label vocabulary (which verbs mean "fetch the ticket", "post the spec back", "mark ready").
- Gate commands: **quick**, **full**, **build** — and the current expected test count for each.
- Protected paths and forbidden actions (recorded in `docs/agents/paths.md`; deterministic hook enforcement is Phase 4).
- Where docs live (specs, ADRs, glossary).
- **Product: who uses this and for what?** Present the drafted purpose + personas from detection as the recommended answer; ask for corrections, missing personas, and explicit non-goals. **Do not finish setup without a confirmed purpose and at least one persona** — every future spec's user stories draw their roles from this.

Stop asking as soon as the gaps are closed.

## Step 3 — Scaffold (write config, state, pointers)

Create in the target project:

- **`docs/agents/` mappings** — the config-indirection layer. Canonical verbs → real commands for THIS repo. At minimum:
  - `docs/agents/tracker.md` — "fetch the ticket", "post the spec back", "mark ready", label vocabulary → the real MCP tool / CLI.
  - `docs/agents/gates.md` — "run the quick gate" / "run the full gate" / "run the build" → the real commands, each with its expected test count.
  - `docs/agents/paths.md` — protected/append-only paths, forbidden actions.
- **`docs/product.md`** — from the `product.md` template: purpose, personas, non-goals ("not doing, and why"), as confirmed in Step 2. One page max. If the project already has an equivalent doc, point to it from here instead of duplicating.
- **`.harness/STATE.md`** — from the `STATE.md` template. Leave the baseline section for Step 5.
- **Permissions** — merge `templates/settings-snippet.json` into the project's `.claude/settings.json`. Tune the permissions allowlist to the detected stack (add the gate commands so they don't prompt). Merge — never clobber an existing settings.json; show the diff.
- **`## Harness` block in CLAUDE.md** — pointers only, not content. A few lines: "this project uses the builder harness; run features via the `feature` skill; gate commands live in `docs/agents/gates.md`; state in `.harness/STATE.md`." Keep CLAUDE.md under 200 lines — push detail into the pointed-to docs.

## Step 4 — Generate project-owned skills

Based on the detected repo type, instantiate templates from this plugin's `templates/project-skills/` into the project's `.claude/skills/`:

| Detected             | Generate                                                      |
| -------------------- | ------------------------------------------------------------- |
| Frontend             | `prototype` + `verify-ui`                                     |
| Fullstack / services | `run-local` (+ `verify-ui` and/or `verify-api` as applicable) |
| API backend          | `verify-api`                                                  |
| CLI / library        | (none templated in Phase 1 — note it and move on)             |

Fill every `SETUP_FILLS` / placeholder marker with the real commands and URLs for this repo — **and run each one to confirm it works before writing it in.** These skills are project property; they live in the project and evolve there.

## Step 5 — Verify itself (prove it works, don't assert it)

**Baseline** — run the quick gate and the full gate. Confirm exit 0. Record the command, exit code, and passing test count into `.harness/STATE.md`'s baseline section, with the date. This is what later sessions diff against ("no silent test deletions").

## Done

Report: what was detected, what was asked, files scaffolded, skills generated, and the recorded baseline. Then point the human at `/feature <description or ticket>`.

## Rationalizations (all invalid)

| Excuse                                                     | Reality                                                                    |
| ---------------------------------------------------------- | -------------------------------------------------------------------------- |
| "The command probably works, I'll write it in"             | Run it first. An unverified gate command breaks every future run silently. |
| "CLAUDE.md needs all the detail so the model has context"  | Pointers only. Detail goes in `docs/agents/`. Keep it under 200 lines.     |
| "I'll ask everything up front to be safe"                  | Detect first. Only ask what you genuinely can't infer.                     |

## Red Flags

- Writing a command into a skill/mapping/STATE.md without having run it this session
- A gate command recorded without its expected test count
- Clobbering an existing `.claude/settings.json` instead of merging
- CLAUDE.md `## Harness` block growing past a few pointer lines

## Gotchas

_(empty — populate from pilots)_
