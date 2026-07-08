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
- **Design system (frontend/fullstack repos)** — component library (a `components/` or `ui/` dir, deps like shadcn/MUI/Chakra), design tokens (Tailwind config, CSS variables, theme files), Storybook. This grounds the "reuse, never reinvent components" rule.

Summarize what you found in chat before asking anything.

## Step 2 — Ask (only the gaps, batched, recommended answer first)

Batch the remaining gaps into **one `AskUserQuestion` call (up to 4 questions)**, each with a recommended default listed first — one interruption beats five (pilot 2: batching worked better than one-at-a-time). Overflow or follow-ups go in a second batch. Cover:

- Tracker + label vocabulary (which verbs mean "fetch the ticket", "post the spec back", "mark ready").
- Gate commands: **quick**, **full**, **build** — expected test count for quick/full; build just exit 0.
- Protected paths and forbidden actions (recorded in `.harness/agents/paths.md`; deterministic hook enforcement is Phase 4).
- Where docs live (specs, ADRs, glossary).
- **Product: who uses this, for what, and what does success look like?** Present the drafted purpose + personas from detection as the recommended answer; ask for corrections, missing personas, explicit non-goals, and 1–2 measurable success signals. **Do not finish setup without a confirmed purpose, at least one persona, and at least one success signal** — user stories draw their roles from this, and ALIGN challenges features against the signals.

Stop asking as soon as the gaps are closed.

## Step 3 — Scaffold (write config, state, pointers)

Everything the harness installs and maintains lives under **`.harness/`** (plus generated skills in `.claude/skills/` and the pointer block in CLAUDE.md — locations Claude Code dictates). One directory answers "what did the harness put here?". **Upgrading an install from harness ≤0.3.0** (which scaffolded `docs/agents/` and `docs/product.md`)? `git mv` them to `.harness/agents/` and `.harness/product.md`, update the CLAUDE.md pointers, and fold that into the install commit.

Create in the target project:

- **`.harness/agents/` mappings** — the config-indirection layer. Canonical verbs → real commands for THIS repo. At minimum:
  - `.harness/agents/tracker.md` — "fetch the ticket", "post the spec back", "mark ready", label vocabulary → the real MCP tool / CLI. No tracker? Record that here — `ship` then skips its tracker step.
  - `.harness/agents/docs.md` — where docs live: specs write path (default: the run folder, `.harness/runs/<YYYY-MM-DD>-<feature>/spec.md` — each `/feature` run colocates its spec, plan, and report in one dated folder; `/ship` archives the folder whole), glossary/CONTEXT location, ADR dir. ALIGN and the doc-sync step resolve through this. Include a short **Doc-sync checklist** section (condensed from the `feature` skill's REPORT table: CLAUDE.md/AGENTS.md if a convention changed or became wrong · glossary for new terms · mappings if a command/verb changed · STATE.md always · gotcha routing to `plugin-outbox.md`) so ad hoc sessions have something concrete to walk.
  - `.harness/agents/gates.md` — "run the quick gate" / "run the full gate" / "run the build" → the real commands, each with its expected test count.
  - `.harness/agents/paths.md` — protected/append-only paths, forbidden actions.
  - `.harness/agents/review.md` — how "run the code review" resolves. Probe whether the `pr-review-toolkit` agents are available (is `pr-review-toolkit:code-reviewer` a listed agent type?). Not installed → ask the human once, recommended yes: "Install Anthropic's pr-review-toolkit (specialized review agents the pipeline uses before e2e and before the PR)? `/plugin marketplace add anthropics/claude-plugins-official` then `/plugin install pr-review-toolkit@claude-plugins-official` — takes effect after a restart." Write the mapping either way: **preferred** = the plugin's agents; **fallback** (not installed / declined) = one `general-purpose` subagent per axis using this plugin's `templates/reviewer-prompt.md`. Record the default branch name here too — review scope diffs against its merge-base.
  - `.harness/agents/design.md` *(frontend/fullstack only)* — where components live, which library/tokens to reuse, Storybook URL if any. Pointers to the detected inventory, not a style guide — this is what "reuse the design system" resolves to.
- **`.harness/product.md`** — from the `product.md` template: purpose, personas, success signals, non-goals ("not doing, and why"), as confirmed in Step 2. One page max. If the project already has an equivalent doc, point to it from here instead of duplicating.
- **`.harness/STATE.md`** — from the `STATE.md` template. Record the installed harness version (from this plugin's `plugin.json`) in the baseline section; leave the gate baselines for Step 5.
- **Permissions** — merge `templates/settings-snippet.json` into the project's `.claude/settings.json`. Tune the permissions allowlist to the detected stack (add the gate commands so they don't prompt). Merge — never clobber an existing settings.json; show the diff. **Expect this write to be denied** in auto mode (the classifier blocks self-modification of permission rules — pilot 2). Fallback ladder: (1) ask the human via `AskUserQuestion` to approve the write interactively; (2) still blocked → write the merged JSON to `.harness/settings-suggested.json` and tell the human in one line to move it. Never leave the snippet only as chat text.
- **`## Harness` block in CLAUDE.md** — pointers only, not content. A few lines: "this project uses the builder harness; run features via the `feature` skill; gate commands live in `.harness/agents/gates.md`; state in `.harness/STATE.md`." Plus two session-hygiene rules that catch work done OUTSIDE the pipeline (the pipeline's REPORT step already enforces them; ad hoc sessions have nothing else):
  - "**After finishing any piece of work** — even outside `/feature` — walk the doc-sync checklist in `.harness/agents/docs.md`: update whatever the session invalidated, STATE.md always, and route gotchas (universal ones also go to `.harness/plugin-outbox.md`)."
  - "If this file itself became wrong during the session, fix it now — a wrong CLAUDE.md is worse than a missing one."

  Phrase the trigger as "after finishing any piece of work", never "at the end of the session" — session end is not a moment the model can observe. (Prose is best-effort; the deterministic Stop-hook version is Phase 2+.)

## Step 4 — Generate project-owned skills

Based on the detected repo type, instantiate templates from this plugin's `templates/project-skills/` into the project's `.claude/skills/` (names keep the `builder-` prefix so every harness skill groups together in the `/` typeahead):

| Detected             | Generate                                                      |
| -------------------- | ------------------------------------------------------------- |
| Frontend             | `builder-prototype` + `builder-verify-ui`                     |
| Fullstack / services | `builder-run-local` + `builder-prototype` (if it has a UI) + `builder-verify-ui` / `builder-verify-api` |
| API backend          | `builder-verify-api`                                          |
| CLI / library        | (none templated in Phase 1 — note it and move on)             |

Fill every `<!-- setup fills -->` marker and ALLCAPS placeholder with the real commands and URLs for this repo — **and run each one to confirm it works before writing it in.** These skills are project property; they live in the project and evolve there.

## Step 5 — Verify itself (prove it works, don't assert it)

**Baseline** — run the quick gate, the full gate, and the build. **Each baseline is the literal command run once as-is** — `bun verify` means one `bun verify` invocation, not its components run separately (pilot 2: the decomposed pieces all passed while the real command failed). Decomposed runs are fine *additionally*, e.g. to extract per-lane counts. Confirm exit 0 on all three; record each command, exit code, and passing test count (build: exit 0 only) into `.harness/STATE.md`'s baseline section, with the date. This is what later sessions diff against ("no silent test deletions").

**Exercise the generated skills** — the gates prove the tests run; they don't prove the skills work. Follow each generated skill exactly as written, as if you were a fresh session: bring the stack up via `builder-run-local`, log in and drive one screen via `builder-verify-ui`, hit one endpoint/action via `builder-verify-api`, then tear down. Any step that fails or needs a workaround → fix the skill now and record the Gotcha (pilot 2: a destructive-command block shipped inside a generated skill because only the gate commands were exercised). Delete any screenshots/artifacts this leaves in the repo, or move them under `.harness/`.

## Step 6 — Commit the install

An unstaged improvement didn't happen. Stage everything the setup wrote (`.harness/agents/`, `.harness/product.md`, `.harness/`, `.claude/skills/`, CLAUDE.md, settings) and commit: `chore: install builder harness v<version>`. If anything (including this skill's own later edits in the same session) changes a harness file after this commit, re-stage and amend or add a follow-up commit — never leave harness files drifting between index and worktree.

## Done

Report: what was detected, what was asked, files scaffolded, skills generated, the recorded baseline, and the install commit hash. **Route any gotchas learned during setup** (see Gotcha routing below). Then point the human at `/feature <description or ticket>`.

## Gotcha routing (applies to every gotcha this skill learns)

Before writing a gotcha, ask: **"would this bite in a different repo?"**

- **No (repo-specific)** → the relevant generated skill's Gotchas section, or `.harness/STATE.md`.
- **Yes (universal — about the process, Claude Code, or common tooling)** → *also* append a row to `.harness/plugin-outbox.md` (create from the `plugin-outbox.md` template if missing): date · symptom → cause → fix · target plugin file · status `queued`. The human runs `/builder:improve` against the plugin source to ingest it — the installed plugin is a frozen snapshot and cannot be edited from here.

## Rationalizations (all invalid)

| Excuse                                                     | Reality                                                                    |
| ---------------------------------------------------------- | -------------------------------------------------------------------------- |
| "The command probably works, I'll write it in"             | Run it first. An unverified gate command breaks every future run silently. |
| "CLAUDE.md needs all the detail so the model has context"  | Pointers only. Detail goes in `.harness/agents/`. Keep it under 200 lines.     |
| "I'll ask everything up front to be safe"                  | Detect first. Only ask what you genuinely can't infer.                     |
| "The gates passed, the generated skills must work"         | Gates prove the tests run. Exercise each skill's actual flow (Step 5).     |
| "The full gate's parts all passed individually"            | The baseline is the literal command. Run it once as-is.                    |

## Red Flags

- Writing a command into a skill/mapping/STATE.md without having run it this session
- A gate command recorded without its expected test count
- Recording a full-gate baseline assembled from separately-run components
- Finishing without having exercised each generated skill end-to-end
- Clobbering an existing `.claude/settings.json` instead of merging
- CLAUDE.md `## Harness` block growing past a few pointer lines
- Ending the session with harness files unstaged or uncommitted

## Gotchas

Format: symptom → cause → what to do instead.

- **A gate "passed" but actually failed** → `cmd > log 2>&1; echo "EXIT=$?"` reports the `echo`'s exit code (always 0), masking the command's → never chain `; echo` after a gate; check `$?` directly or read the exit code from the harness's task result. Bit twice in pilot 2 (2026-07-08).
- **A freshly-added `.mcp.json` server "doesn't exist"** → newly-registered MCP servers only connect after a Claude Code restart, and http servers may need an OAuth sign-in on first connect → record the manual bridge in the tracker mapping, note the restart requirement, and don't keep re-searching for the tools (pilot 2, 2026-07-08).
- **A destructive CLI refuses to run for an AI agent** → some tools (e.g. `prisma migrate reset|dev`) detect agent invocation and block without explicit human consent → find the non-interactive/non-destructive variant (`migrate deploy` + a plain seed script), write THAT into the generated skill, and note the blocked form as its Gotcha (pilot 2, 2026-07-08).
