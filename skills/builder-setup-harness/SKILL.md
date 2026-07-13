---
name: builder-setup-harness
description: Run once per project to install the builder harness. Human-invoke-only (type /builder-setup-harness); the model cannot trigger it. Detects the stack, interviews for what detection can't answer, scaffolds config + state, generates project-owned skills, and proves the gates work.
disable-model-invocation: true
---

# Setup Harness — the installer

Instrument the current project so work can flow through the `builder-feature` pipeline. Explicit invocation only. Target: ≤10 minutes, mostly detection.

## Host (Claude Code or Codex — identify first, it changes where things land)

The harness runs on either host. Detect which one is running this setup (Claude Code exposes `${CLAUDE_PLUGIN_ROOT}` / a `.claude/` home; Codex exposes `$CODEX_HOME` / `.agents/skills/` discovery / was installed via `codex plugin`). **Record the host in `.harness/STATE.md`'s baseline** (Step 3) so `builder-feature`/`builder-ship` don't re-detect. The `.harness/` layer itself is identical on both hosts; only these anchors differ, and each step below says which to use:

| What | Claude Code | Codex |
|---|---|---|
| Bundled files (`assets/…`, `references/…`) | `${CLAUDE_PLUGIN_ROOT}/skills/builder-setup-harness/<path>` | this installed skill's own folder + `/<path>` |
| Generated project skills go to | `.claude/skills/` | `.agents/skills/` (repo-shared scope) |
| Permissions / config artifact | merge `assets/settings-snippet.json` → `.claude/settings.json` | merge `assets/config-snippet.toml` → the project's Codex config (`.codex/config.toml`, or `$CODEX_HOME/config.toml` `[projects."<path>"]`) — sets `sandbox_mode`/`approval_policy` and trusts the gate commands |
| Instructions/pointer file | `CLAUDE.md` | `AGENTS.md` |
| Review reviewers (written into `review.md`) | `pr-review-toolkit` agents if present, else `general-purpose` subagents | `codex review` / `codex exec review`, or custom subagents (`.codex/agents/*.toml`) |
| Invocation surface (prose) | `/builder-feature` … | `$builder-feature` … |

Where a step names a Claude Code path (`.claude/…`, `CLAUDE.md`), substitute the Codex column when the host is Codex.

**Hard rule that governs everything below: run every command before you write it into a skill, mapping, or STATE.md. An unverified command is a liability, not an asset.** If a command you expected to exist doesn't work, stop and ask — never write a guessed command.

**Interactive commands hang autonomous runs.** Some CLIs prompt and block forever (e.g. `prisma migrate dev`, unscoped `git rebase -i`, first-run auth). Prefer the non-interactive variant (`prisma migrate deploy` / `migrate status`), and when you write such a command into a skill, record the non-interactive form + a Gotcha noting the interactive one hangs. If a setup command stalls, don't wait it out — kill it, find the non-interactive path, and move on.

## Step 1 — Detect (explore before asking)

Read the repo and infer as much as possible. Do NOT ask what you can detect:

- **Workspace shape** — decide first. Scan for nested git repos (`find . -maxdepth 2 -name .git`) and check remotes: **`single`** (one git repo — the default) · **`monorepo`** (one git, many packages) · **`workspace`** (a root dir/repo hosting nested git repos with their own remotes — e.g. a backend repo and a frontend repo side by side). Record the shape in gates.md for every shape. `workspace` → the root is the harness's home (Step 3's workspace rule) and detection runs once per nested repo. Two root checks, recorded in the registry: **(a)** is the root itself a git repo? A plain folder → recommend `git init` (harness state deserves history; ask, don't just run it) or record `no root repo` — ship then skips root commits/archiving and says so. **(b)** does the root have a remote, and is it **shared** (other contributors in `git log`)? Ship asks before pushing to a shared root's default branch. `monorepo` → behaves as `single` for git actions (one repo, one branch, one PR); if packages have genuinely separate gates, give gates.md one verb→command block per package the same way workspace does per repo.
- **Stack / language** — manifest files (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `*.csproj`, `Gemfile`), lockfiles, framework deps. Workspace/monorepo → per repo/package.
- **Test runner + how to run it** — scripts in the manifest, CI config, existing test dirs. Workspace → per nested repo; there is no single workspace-wide gate.
- **Repo type** — frontend (React/Vue/Svelte/etc.), API/backend, fullstack, CLI, library. This decides which project skills to generate — in a workspace, per nested repo.
- **Git remote + tracker** — `git remote -v`; GitHub → likely `gh`/Issues, GitLab → `glab`, Jira/Linear/etc. from remote or existing config.
- **Existing docs** — CLAUDE.md / AGENTS.md, `docs/`, ADRs, CI workflows.
- **Product context** — README intro, landing/marketing pages, an existing PRD or pitch doc: what the software is for and who uses it. Draft a purpose + candidate personas from what you find.
- **Design system (frontend/fullstack repos)** — component library (a `components/` or `ui/` dir, deps like shadcn/MUI/Chakra), design tokens (Tailwind config, CSS variables, theme files), Storybook. This grounds the "reuse, never reinvent components" rule.

Summarize what you found in chat before asking anything.

## Step 2 — Ask (only the gaps, batched, recommended answer first)

Batch the remaining gaps into **one `AskUserQuestion` call (up to 4 questions)**, each with a recommended default listed first — one interruption beats five (pilot 2: batching worked better than one-at-a-time). Overflow or follow-ups go in a second batch. Cover:

- Tracker + label vocabulary (which verbs mean "fetch the ticket", "post the spec back", "mark ready").
- Gate commands: **quick**, **full**, **build** — expected test count for quick/full; build just exit 0.
- Protected paths and forbidden actions (recorded in `.harness/map/paths.md`).
- Where docs live (specs, ADRs, glossary).
- **Product: who uses this, for what, and what does success look like?** Present the drafted purpose + personas from detection as the recommended answer; ask for corrections, missing personas, explicit non-goals, and 1–2 measurable success signals. **Do not finish setup without a confirmed purpose, at least one persona, and at least one success signal** — user stories draw their roles from this, and ALIGN challenges features against the signals.

Stop asking as soon as the gaps are closed.

## Step 3 — Scaffold (write config, state, pointers)

Everything the harness installs and maintains lives under **`.harness/`** (plus generated skills and the pointer block, which go in host-dictated locations — see the Host table). One directory answers "what did the harness put here?".

**Workspace shape — everything harness-owned stays at the workspace root.** Nested repos have their own remotes, owners, and reviewers; never write `.harness/`, skills, or pointer blocks into them. Runs, reports, STATE, outbox, generated skills — root only. Per-repo instructions files (`CLAUDE.md`/`AGENTS.md` — conventions local to one repo, loaded on demand when the agent reads there) are worth **recommending to the human** at the end of setup — but they're that repo's property; never auto-write one into a nested repo without an explicit yes.

Create in the target project:

- **`.harness/map/` mappings** — the config-indirection layer. Canonical verbs → real commands for THIS repo. At minimum:
  - `.harness/map/tracker.md` — "fetch the ticket", "post the spec back", "mark ready", label vocabulary → the real MCP tool / CLI. No tracker? Record that here — `builder-ship` then skips its tracker step.
  - `.harness/map/docs.md` — where docs live: specs write path (default: the run folder, `.harness/runs/<YYYY-MM-DD>-<feature>/spec.md` — each `/builder-feature` run colocates its spec, plan, and report in one dated folder; `/builder-ship` archives the folder whole), glossary/CONTEXT location, ADR dir. ALIGN and the doc-sync step resolve through this. Include a short **Doc-sync checklist** section — condense it from this skill's `references/doc-sync-checklist.md` (resolve per the Host table) so ad hoc sessions have something concrete to walk.
  - `.harness/map/gates.md` — "run the quick gate" / "run the full gate" / "run the build" → the real commands, each with its expected test count. **Workspace shape:** open the file with the workspace shape line and a **repo registry** (one row per nested repo: path · remote · default branch · kind), then one verb→command block **per repo** — gates are per-repo by definition; a run resolves "run the gate" through the repo(s) its sizing line names. Single shape: one block, unchanged.
  - `.harness/map/paths.md` — protected/append-only paths, forbidden actions.
  - `.harness/map/review.md` — how "run the code review" resolves. **Claude Code:** probe whether the `pr-review-toolkit` agents are available (is `pr-review-toolkit:code-reviewer` a listed agent type?). Not installed → ask the human once, recommended yes: "Install Anthropic's pr-review-toolkit (specialized review agents the pipeline uses before e2e and before the PR)? `/plugin marketplace add anthropics/claude-plugins-official` then `/plugin install pr-review-toolkit@claude-plugins-official` — takes effect after a restart." Preferred = the plugin's agents; fallback (not installed / declined) = one `general-purpose` subagent per axis. **Codex:** map the axes to `codex review` / `codex exec review` for the always-on pass, and to custom subagents (`.codex/agents/*.toml`) for the conditional axes; note that `codex review` is coarser than the per-axis agents. **Both:** the fallback subagent prompt is this skill's `references/reviewer-prompt.md` (resolve per the Host table). Record the default branch name here too — review scope diffs against its merge-base. (Workspace shape: default branches live per-repo in gates.md's registry; point at that instead of duplicating.)
  - `.harness/map/design.md` *(frontend/fullstack only)* — where components live, which library/tokens to reuse, Storybook URL if any. Pointers to the detected inventory, not a style guide — this is what "reuse the design system" resolves to.
- **`.harness/product.md`** — from the `product.md` template: purpose, personas, success signals, non-goals ("not doing, and why"), as confirmed in Step 2. One page max. If the project already has an equivalent doc, point to it from here instead of duplicating.
- **`.harness/STATE.md`** — from this skill's `assets/STATE.md` shape. Record the installed harness version (from this plugin's `plugin.json`) **and the detected host** (Claude Code / Codex) in the baseline section; leave the gate baselines for Step 5.
- **Permissions / config** — **Claude Code:** merge this skill's `assets/settings-snippet.json` into the project's `.claude/settings.json`. Tune the permissions allowlist to the detected stack (add the gate commands so they don't prompt), and the Read-deny list to what's actually generated/vendored here — drop a deny that would block real source (e.g. a repo whose `build/` is hand-written), add ones detection found (committed codegen dirs, vendored SDKs). Merge — never clobber an existing settings.json; show the diff. **Expect this write to be denied** in auto mode (the classifier blocks self-modification of permission rules — pilot 2). Fallback ladder: (1) ask the human to approve the write interactively; (2) still blocked → write the merged JSON to `.harness/settings-suggested.json` and tell the human in one line to move it. **Codex:** merge this skill's `assets/config-snippet.toml` instead — set `sandbox_mode = "workspace-write"` and an `approval_policy` the human accepts, and trust the project path so gate commands don't prompt; write it to the project's Codex config (or, if that write is blocked, to `.harness/config-suggested.toml` with the same one-line fallback). Never leave the snippet only as chat text.
- **`## Harness` pointer block** in the host's instructions file — `CLAUDE.md` on Claude Code, `AGENTS.md` on Codex. Pointers only, not content. A few lines: "this project uses the builder harness; run features via the `builder-feature` skill; gate commands live in `.harness/map/gates.md`; state in `.harness/STATE.md`." **Workspace shape:** the block goes in the **root** instructions file and includes a one-line repo map ("`<path>` — <kind, stack>; PR per repo" per nested repo) so any session is oriented before it reads anything else. Plus two session-hygiene rules that catch work done OUTSIDE the pipeline (the pipeline's REPORT step already enforces them; ad hoc sessions have nothing else):
  - "**After finishing any piece of work** — even outside `/builder-feature` — walk the doc-sync checklist in `.harness/map/docs.md`: update whatever the session invalidated, STATE.md always, and route gotchas (universal ones also go to `.harness/plugin-outbox.md`)."
  - "If this file itself became wrong during the session, fix it now — a wrong instructions file is worse than a missing one."

  Phrase the trigger as "after finishing any piece of work", never "at the end of the session" — session end is not a moment the model can observe.

## Step 4 — Generate project-owned skills

Based on the detected repo type, instantiate templates from this skill's `assets/project-skills/` (resolve per the Host table) into the host's project-skill location — `.claude/skills/` on Claude Code, `.agents/skills/` on Codex (names keep the `builder-` prefix so every harness skill groups together in the `/` or `$` typeahead):

| Detected             | Generate                                                      |
| -------------------- | ------------------------------------------------------------- |
| Frontend             | `builder-prototype` + `builder-verify-ui`                     |
| Fullstack / services | `builder-run-local` + `builder-prototype` (if it has a UI) + `builder-verify-ui` / `builder-verify-api` |
| API backend          | `builder-verify-api`                                          |
| CLI / library        | (none templated yet — note it and move on)                    |

Fill every `<!-- setup fills -->` marker and ALLCAPS placeholder with the real commands and URLs for this repo — **and run each one to confirm it works before writing it in.** These skills are project property; they live in the project and evolve there.

**Workspace shape:** generate per nested repo (a frontend repo gets `builder-verify-ui`, an API repo `builder-verify-api`, …) but install them all in the **root** project-skill location (`.claude/skills/` or `.agents/skills/` per host) — never inside a nested repo (Step 3's workspace rule). On Claude Code, scope each by uncommenting the template's `paths:` frontmatter line with its repo's glob (e.g. `paths: ["frontend-repo/**"]`) so it auto-loads when working with that repo's files; if the host doesn't support path-scoped auto-load (Codex today), leave them explicit-invoke and note it. Suffix colliding names with the repo (`builder-verify-ui-<repo>`) if two repos need the same skill.

The project may already have equivalent skills (its own verify/run/test skills). **Reuse, don't duplicate:** map the harness verb to the existing skill in the relevant `.harness/map/` mapping and skip generating that template — note the reuse in the setup report.

## Step 5 — Verify itself (prove it works, don't assert it)

**Baseline** — run the quick gate, the full gate, and the build. **Each baseline is the literal command run once as-is** — `bun verify` means one `bun verify` invocation, not its components run separately (pilot 2: the decomposed pieces all passed while the real command failed). Decomposed runs are fine *additionally*, e.g. to extract per-lane counts. Confirm exit 0 on all three; record each command, exit code, and passing test count (build: exit 0 only) into `.harness/STATE.md`'s baseline section, with the date. **Workspace shape: one baseline block per nested repo** (`### <repo-path>` sub-heads in STATE.md, matching gates.md's per-repo blocks) — record each repo's gates from inside that repo. This is what later sessions diff against ("no silent test deletions").

**Exercise the generated skills** — the gates prove the tests run; they don't prove the skills work. Follow each generated skill exactly as written, as if you were a fresh session: bring the stack up via `builder-run-local`, log in and drive one screen via `builder-verify-ui`, hit one endpoint/action via `builder-verify-api`, then tear down. Any step that fails or needs a workaround → fix the skill now and record the Gotcha (pilot 2: a destructive-command block shipped inside a generated skill because only the gate commands were exercised). Delete any screenshots/artifacts this leaves in the repo, or move them under `.harness/`.

## Step 6 — Commit the install

An unstaged improvement didn't happen. Stage everything the setup wrote (`.harness/`, the generated skills, the instructions file, the permissions/config artifact) and commit: `chore: install builder harness v<version>`. If anything (including this skill's own later edits in the same session) changes a harness file after this commit, re-stage and amend or add a follow-up commit — never leave harness files drifting between index and worktree.

## Done

Report: what was detected, what was asked, files scaffolded, skills generated, the recorded baseline, and the install commit hash. **Route any gotchas learned during setup** (see Gotcha routing below). Then point the human at `/builder-feature <description or ticket>`.

## Gotcha routing (applies to every gotcha this skill learns)

Before writing a gotcha, ask: **"would this bite in a different repo?"**

- **No (repo-specific)** → the relevant generated skill's Gotchas section, or `.harness/STATE.md`.
- **Yes (universal — about the process, Claude Code, or common tooling)** → *also* append a row to `.harness/plugin-outbox.md` (create from the `plugin-outbox.md` template if missing): date · symptom → cause → fix · target plugin file · status `queued`. The human runs `/builder-improve` against the plugin source to ingest it — the installed plugin is a frozen snapshot and cannot be edited from here.

## Rationalizations (all invalid)

| Excuse                                                     | Reality                                                                    |
| ---------------------------------------------------------- | -------------------------------------------------------------------------- |
| "The command probably works, I'll write it in"             | Run it first. An unverified gate command breaks every future run silently. |
| "CLAUDE.md needs all the detail so the model has context"  | Pointers only. Detail goes in `.harness/map/`. Keep it under 200 lines.     |
| "I'll ask everything up front to be safe"                  | Detect first. Only ask what you genuinely can't infer.                     |
| "The gates passed, the generated skills must work"         | Gates prove the tests run. Exercise each skill's actual flow (Step 5).     |
| "The full gate's parts all passed individually"            | The baseline is the literal command. Run it once as-is.                    |

## Red Flags

- Writing a command into a skill/mapping/STATE.md without having run it this session
- A gate command recorded without its expected test count
- Recording a full-gate baseline assembled from separately-run components
- Finishing without having exercised each generated skill end-to-end
- Clobbering an existing permissions/config file (`.claude/settings.json` or the Codex config) instead of merging
- Workspace shape: any harness-owned file (`.harness/`, skills, pointer block) written inside a nested repo
- Workspace shape: a gates.md without the repo registry, or a baseline not recorded per-repo
- CLAUDE.md `## Harness` block growing past a few pointer lines
- Ending the session with harness files unstaged or uncommitted

## Gotchas

Format: symptom → cause → what to do instead.

- **A gate "passed" but actually failed** → `cmd > log 2>&1; echo "EXIT=$?"` reports the `echo`'s exit code (always 0), masking the command's → never chain `; echo` after a gate; check `$?` directly or read the exit code from the harness's task result. Bit twice in pilot 2 (2026-07-08).
- **A freshly-added `.mcp.json` server "doesn't exist"** → newly-registered MCP servers only connect after a Claude Code restart, and http servers may need an OAuth sign-in on first connect → record the manual bridge in the tracker mapping, note the restart requirement, and don't keep re-searching for the tools (pilot 2, 2026-07-08).
- **A destructive CLI refuses to run for an AI agent** → some tools (e.g. `prisma migrate reset|dev`) detect agent invocation and block without explicit human consent → find the non-interactive/non-destructive variant (`migrate deploy` + a plain seed script), write THAT into the generated skill, and note the blocked form as its Gotcha (pilot 2, 2026-07-08).
