---
name: setup-harness
description: Run once per project to install the dev-harness. Triggers only on explicit invocation ("/setup-harness", "set up the harness", "instrument this project", "install the harness here"). Detects the stack, interviews for what detection can't answer, scaffolds config + state + guardrails, generates project-owned skills, and proves the gates and hooks work.
disable-model-invocation: true
---

# Setup Harness — the installer

Instrument the current project so work can flow through the `feature` pipeline. Explicit invocation only. Target: ≤10 minutes, mostly detection.

**Hard rule that governs everything below: run every command before you write it into a skill, mapping, or STATE.md. An unverified command is a liability, not an asset.** If a command you expected to exist doesn't work, stop and ask — never write a guessed command.

## Step 1 — Detect (explore before asking)

Read the repo and infer as much as possible. Do NOT ask what you can detect:

- **Stack / language** — manifest files (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `*.csproj`, `Gemfile`), lockfiles, framework deps.
- **Test runner + how to run it** — scripts in the manifest, CI config, existing test dirs.
- **Repo type** — frontend (React/Vue/Svelte/etc.), API/backend, fullstack, CLI, library, monorepo. This decides which project skills to generate.
- **Git remote + tracker** — `git remote -v`; GitHub → likely `gh`/Issues, GitLab → `glab`, Jira/Linear/etc. from remote or existing config.
- **Existing docs** — CLAUDE.md / AGENTS.md, `docs/`, ADRs, CI workflows.

Summarize what you found in chat before asking anything.

## Step 2 — Ask (only the gaps, one at a time, recommended answer first)

For each thing detection couldn't settle, ask ONE question with a recommended default. Cover:

- Tracker + label vocabulary (which verbs mean "fetch the ticket", "post the spec back", "mark ready").
- Gate commands: **quick**, **full**, **build** — and the current expected test count for each.
- Protected paths and forbidden actions (beyond the built-in guardrails).
- Where docs live (specs, ADRs, glossary).

Stop asking as soon as the gaps are closed.

## Step 3 — Scaffold (write config, state, guardrails, pointers)

Create in the target project:

- **`docs/agents/` mappings** — the config-indirection layer. Canonical verbs → real commands for THIS repo. At minimum:
  - `docs/agents/tracker.md` — "fetch the ticket", "post the spec back", "mark ready", label vocabulary → the real MCP tool / CLI.
  - `docs/agents/gates.md` — "run the quick gate" / "run the full gate" / "run the build" → the real commands, each with its expected test count.
  - `docs/agents/paths.md` — protected/append-only paths, forbidden actions.
- **`.harness/STATE.md`** — from the `STATE.md` template. Leave the baseline section for Step 5.
- **Guardrails + permissions** — merge `templates/settings-snippet.json` into the project's `.claude/settings.json`. Replace `ABSOLUTE_PATH_TO/guardrails.sh` with the real absolute path to this plugin's `hooks/guardrails.sh`. Tune the permissions allowlist to the detected stack (add the gate commands so they don't prompt). Merge — never clobber an existing settings.json; show the diff.
- **`## Harness` block in CLAUDE.md** — pointers only, not content. A few lines: "this project uses dev-harness; run features via the `feature` skill; gate commands live in `docs/agents/gates.md`; state in `.harness/STATE.md`." Keep CLAUDE.md under 200 lines — push detail into the pointed-to docs.

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

1. **Baseline** — run the quick gate and the full gate. Confirm exit 0. Record the command, exit code, and passing test count into `.harness/STATE.md`'s baseline section, with the date. This is what later sessions diff against ("no silent test deletions").
2. **Trip a guardrail on purpose** — issue a forged/dry dangerous command (e.g. attempt a `git push --force` on a throwaway, or pipe a forged tool-call JSON to `hooks/guardrails.sh`) and confirm it is BLOCKED (exit 2, `BLOCKED:` message). Show the output. If the hook doesn't fire, setup is not done — fix the settings path and retry.

## Done

Report: what was detected, what was asked, files scaffolded, skills generated, the recorded baseline, and the proof the guardrail fired. Then point the human at `/feature <description or ticket>`.

## Rationalizations (all invalid)

| Excuse                                                     | Reality                                                                    |
| ---------------------------------------------------------- | -------------------------------------------------------------------------- |
| "The command probably works, I'll write it in"             | Run it first. An unverified gate command breaks every future run silently. |
| "I'll skip tripping the guardrail, the config looks right" | A hook that isn't proven to fire is a hook that doesn't exist. Trip it.    |
| "CLAUDE.md needs all the detail so the model has context"  | Pointers only. Detail goes in `docs/agents/`. Keep it under 200 lines.     |
| "I'll ask everything up front to be safe"                  | Detect first. Only ask what you genuinely can't infer.                     |

## Gotchas

_(empty — populate from pilots)_
