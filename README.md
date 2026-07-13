# Builder Claude Code Plugin

A Claude Code plugin that takes a feature or bug fix from request to a reviewed,
tested pull request. It asks the right questions first, builds in small test-first
steps, proves the result actually runs, and hands you a report to review — nothing
ships until you say so.

## What it does for you

- **Aligns before coding** — writes a short spec and plan you approve first.
- **Builds in small, tested steps** — a failing test, then the code to pass it, one commit at a time.
- **Proves it works** — runs your tests, reviews the diff, and exercises the feature like a real user.
- **Reports, then waits** — you get a self-contained HTML report; nothing is committed to main or opened as a PR until you run `/builder-ship`.

## Requirements

- **Claude Code** (desktop, CLI, or IDE extension) — or **OpenAI Codex** (the same skills run on both host; builder is dual-host as of v0.12.0).
- Optional, recommended (Claude Code): the [`pr-review-toolkit`](https://github.com/anthropics/claude-plugins-official)
  plugin. builder uses its review agents automatically if present, and falls back to a built-in reviewer if not. On Codex the review gate uses `codex review` / custom subagents instead.

## Install

**Claude Code:**

```
/plugin marketplace add kpedrok/builder-plugin
/plugin install builder@builder
```

Turn on auto-update once so you stay current: `/plugin` → **Marketplaces** → **builder** → **Enable auto-update**.

**Codex:** copy the skills into the project (or `~/.agents/skills/` for all projects):

```
git clone https://github.com/kpedrok/builder-plugin /tmp/builder && \
  mkdir -p .agents/skills && cp -R /tmp/builder/skills/builder-* .agents/skills/
```

Codex discovers `.agents/skills/` automatically; the invoke-only boundary on `setup-harness`/`ship`/`improve` comes from each skill's `agents/openai.yaml` (`policy.allow_implicit_invocation: false`). Invoke skills as `$builder-feature`, `$builder-setup-harness`, etc. — read every `/builder-…` below as `$builder-…`.

> The one-command `codex plugin add builder@builder` (marketplace) path is not enabled yet: Codex's plugin-manifest validator currently rejects the `disable-model-invocation: true` frontmatter that Claude Code needs for its invoke-only skills. Until Codex tolerates that key, use the copy path above (it enforces the same boundary via `openai.yaml`).

<details>
<summary>Force an update mid-session</summary>

Auto-update only re-fetches **at startup**, so mid-session (or if the **Update** button is greyed out) the app is still comparing against a stale local copy of the marketplace. To pull the latest now, run these in order:

```
/plugin marketplace update builder
/plugin install builder@builder
/reload-plugins
```

The first re-fetches the marketplace and refreshes the catalog; the second installs the new version; `/reload-plugins` activates it without a restart. Or just **quit and reopen** Claude Code — with auto-update on, it pulls the latest at launch.
</details>

## Use it — 3 steps

**1. Set up the project (once).**
```
/builder-setup-harness
```
Detects your stack, asks the few things it can't infer (how to run your tests, where docs live, what the product is), and installs itself. ~10 minutes.

**2. Build something.**
```
/builder-feature add CSV export to the reports page
```
Or pass a ticket: `/builder-feature PROJ-123`. It writes a spec and plan for you to approve, then builds, tests, and reviews on its own, ending with an HTML report.

**3. Review, then ship.**
Open the report, check it, then:
```
/builder-ship
```
Commits the work, opens a PR with the report's evidence linked, and updates your tracker.

---

# How it works

## The one idea behind everything: process vs. facts

The plugin is **process** — the four skills are byte-for-byte identical in every repo you install it into. They never contain a real test command, a real branch name, or a real tracker call. Instead they speak in **canonical verbs** ("run the full gate", "fetch the ticket", "run the code review").

Each project holds the **facts** — everything specific to *this* repo — in a `.harness/` directory. Setup writes a thin indirection layer there that maps each canonical verb to the real command for this repo. So the same skill drives a Bun monorepo, a Django API, and a Rust CLI without a line of difference: only the facts under `.harness/` change.

That split is why the folder structure below exists. Read `.harness/` as "the answers to the questions the universal skills ask."

## The pipeline

Each `/builder-feature` run moves through five phases. The first two are interactive; the rest run on their own once you approve the plan:

```
ALIGN → PLAN → [ you approve ] → BUILD → PROVE → REPORT → [ you review ] → /builder-ship
```

| Phase | What happens | Where it's proved |
|---|---|---|
| **ALIGN** | Read product + state + code, map the data/interfaces the change touches, read the intent back to you, then grill — one question at a time. | A **spec**: objective, user stories, data & interfaces, testable acceptance criteria, out-of-scope. |
| **PLAN** | Weigh 2–3 approaches, break the spec into small vertical slices, name exact files per slice. **You approve before any code is written** — this is the human gate. | A **plan** file with a scope guard and a progress ledger; its Status line reads `APPROVED`. |
| **BUILD** | Per slice, strictly test-first: failing test shown → minimal code to pass → commit. One commit per slice, staging only that slice's files. | Each slice's failing-then-passing test, shown in the transcript; the ledger updated per commit. |
| **PROVE** | Fresh-context review agents on the diff (a bounded fix loop), the full test suite, then the feature driven end-to-end like a user. | Review verdicts, gate output with test count, screenshots / real invocation output. |
| **REPORT** | Sync docs, then write a teaching HTML report of what changed and how. **Then it stops.** | A self-contained `report.html`; nothing committed to main. |

Two boundaries are deliberate: **you approve the plan** before autonomous work starts, and **you review the report** before anything ships. `/builder-ship` is the only thing that commits to main, opens PRs, and touches your tracker — and it can only be run by you, never by the model.

---

# What setup generates

Running `/builder-setup-harness` writes everything below. Harness-owned files live under **`.harness/`**; the two exceptions are host-dictated locations — shown here for Claude Code (`.claude/settings.json`, `.claude/skills/`, the `CLAUDE.md` block). On Codex the equivalents are the Codex config (`sandbox_mode`/`approval_policy`/project trust), `.agents/skills/`, and the `AGENTS.md` block; `.harness/` itself is identical on both.

```
your-project/
├── CLAUDE.md                       ← gains a short "## Harness" pointer block
├── .claude/
│   ├── settings.json               ← permissions merged in (gate commands pre-allowed)
│   └── skills/                     ← project-owned skills, generated to fit this repo
│       ├── builder-run-local/          (fullstack / services)
│       ├── builder-prototype/          (frontend)
│       ├── builder-verify-ui/          (frontend / fullstack)
│       └── builder-verify-api/         (API / backend)
└── .harness/                       ← everything else the harness owns and maintains
    ├── product.md                  ← what the product is, who uses it, what success means
    ├── STATE.md                    ← durable memory: baselines, decisions, lessons, gotchas
    ├── plugin-outbox.md            ← universal gotchas queued for the plugin itself
    ├── map/                        ← the indirection layer: canonical verbs → real commands
    │   ├── tracker.md
    │   ├── docs.md
    │   ├── gates.md
    │   ├── paths.md
    │   ├── review.md
    │   └── design.md                   (frontend / fullstack only)
    ├── runs/                       ← one folder per in-flight feature
    │   └── <YYYY-MM-DD>-<feature>/
    │       ├── spec.md                 (from ALIGN)
    │       ├── plan.md                 (from PLAN)
    │       └── report.html             (from REPORT)
    └── archive/                    ← runs moved here whole by /builder-ship
```

## `.harness/map/` — the indirection layer (the heart of the design)

Config-mapping files, one per concern. Each answers "when a skill says *do X*, what's the real command in this repo?" This is what lets one universal skill run anywhere. The skills never hardcode a command; they always resolve it here.

| File | What it maps | Why it exists |
|---|---|---|
| `gates.md` | "run the quick / full gate", "run the build" → the real commands, each with its expected test count. | The single most-used mapping. A run resolves every test invocation through here, and the expected counts let it catch silent test deletions. |
| `tracker.md` | "fetch the ticket", "post the spec back", "mark ready" → the real MCP tool / CLI, plus your label vocabulary. | Ports the pipeline to whatever tracker you use — or records "no tracker" so `/builder-ship` skips that step cleanly. |
| `docs.md` | Where specs, the glossary/CONTEXT, and ADRs live; plus a doc-sync checklist. | ALIGN reads context from here and REPORT writes updates back here, so docs never drift. |
| `paths.md` | Protected / append-only paths and forbidden actions. | The scope fence. (Deterministic hook enforcement is a later phase; today it's read by the skills.) |
| `review.md` | How "run the code review" resolves — the `pr-review-toolkit` agents if installed, else a `general-purpose` fallback reviewer. Also records your default branch. | Makes the review gate portable and records the branch that review scope diffs against. |
| `design.md` | Where components live, which library/tokens to reuse, Storybook URL. *(frontend/fullstack only)* | What "reuse the design system, don't reinvent components" actually points at. |

## `.harness/` top-level files

| File | What it holds | Why it exists / how it helps |
|---|---|---|
| `product.md` | Purpose, personas, success signals, non-goals — one page. | The backbone of alignment. User-story roles come from its personas (never invented); a feature that serves no persona, crosses a non-goal, or moves no success signal gets challenged at ALIGN. |
| `STATE.md` | Typed durable memory: the recorded gate **baseline**, architecture decisions (AD), lessons (L), rejected approaches (R), and workflow gotchas. Survives compaction and new sessions. | The project's long-term memory. Later runs diff against the baseline (a dropped test count is a red flag), don't re-derive recorded decisions, and don't relitigate rejected ones. |
| `plugin-outbox.md` | A queue of **universal** gotchas — ones that would bite in *any* repo, not just this one. | The installed plugin is a frozen snapshot and can't edit itself, so lessons that belong in the plugin queue here until `/builder-improve` folds them into the source. This is how the harness gets better from real runs instead of relearning the same lesson per project. |
| `settings-suggested.json` | *(only if present)* The permissions merge, written here when the direct `.claude/settings.json` write was blocked. | A fallback so the permissions snippet is never lost as chat text — you move it into place by hand. |

## `.harness/runs/` and `archive/` — one folder per feature

Every `/builder-feature` run owns a dated folder that colocates all three of its artifacts, so a run's spec, plan, and report always travel together and never overwrite a previous run's:

| File | Written by | Purpose |
|---|---|---|
| `spec.md` | ALIGN | The behavior contract: objective, user stories, data & interfaces, acceptance criteria, out-of-scope. Durable, no file paths. |
| `plan.md` | PLAN | **The source of truth for execution** (not the chat). Vertical slices with exact files, a scope guard, and a progress ledger that survives compaction — on resume, the ledger and `git log` are trusted over conversation memory. |
| `report.html` | REPORT | The self-contained teaching report you review. Explains what changed and how well enough to retell the feature; every claim wears an evidence chip showing how it was verified. |

Anything under `runs/` is by definition in flight. `/builder-ship` moves the whole folder to `archive/` once shipped, keeping resume scans clean.

## The generated project skills (`.claude/skills/`)

These are **project property**, not plugin property — generated once to fit this repo's real commands, then they live and evolve here (each grows a Gotchas section over time). Which ones you get depends on the detected repo type:

| Skill | Generated for | What it does |
|---|---|---|
| `builder-run-local` | fullstack / services | The exact order, env, seeds, and health checks to bring the whole stack up for end-to-end verification. |
| `builder-verify-ui` | frontend / fullstack | Drives the running app like a user, screenshots it, and asserts zero new console errors — proof beyond unit tests. |
| `builder-verify-api` | API / backend | Makes real calls to the running API and asserts status and shape. |
| `builder-prototype` | frontend | Explores a UI idea as a few throwaway variations before real code is written, so a direction is chosen first. |

Setup also adds a **`## Harness` pointer block to your `CLAUDE.md`** (a few lines pointing at `.harness/`, never content) and merges gate commands into **`.claude/settings.json`** permissions so routine commands don't prompt.

## Where it can live

Three shapes, detected at setup: a **single repo** (the default), a **monorepo** (one git, many packages), or a **multi-repo workspace** — a root folder hosting nested git repos with their own remotes (say, a backend repo and a frontend repo side by side). In a workspace, gates and baselines are tracked per repo, a cross-repo feature ships one cross-linked PR per touched repo, and everything the harness itself writes stays at the workspace root — no harness files land in your work repos (your feature branches, commits, and PRs do, as intended).

## The self-improvement loop

The harness learns from its own runs without you re-teaching it per project:

```
run hits a universal gotcha → queued in .harness/plugin-outbox.md
     → you run /builder-improve in the plugin source
     → it truth-checks, folds the lesson into a skill or template, bumps the version, pushes
     → auto-update carries the fix to every installed project
```

Repo-specific lessons stay local (in `STATE.md` or a project skill's Gotchas); only universal ones travel to the plugin.

## Skills reference

| Skill | Invoked by | What it does |
|---|---|---|
| `/builder-setup-harness` | you (once per project) | Instruments a project — detects the stack, generates the `.harness/` layer and project skills, proves the gates work. |
| `/builder-feature` | you or the model | Runs the ALIGN → PLAN → BUILD → PROVE → REPORT pipeline. |
| `/builder-ship` | **you only** | Commits, opens the PR with the report's evidence, updates the tracker — after you've reviewed. |
| `/builder-improve` | you (in the plugin source) | Folds queued universal gotchas from real runs back into the plugin. |

`setup-harness`, `ship`, and `improve` are human-invoke-only by design — instrumenting, shipping, and changing the plugin are decisions the model can't make on its own.

---

## Design notes (for contributors)

The plugin source is organized to mirror the process/facts split:

- **`skills/`** — the four universal skills. Identical in every install; contain no repo-specific facts. Each carries its own bundled seeds under `assets/` (stamped/instantiated into a project — `product.md`, `STATE.md`, `settings-snippet.json`, `config-snippet.toml`, `project-skills/`, the `spec.md`/`plan.md`/`plugin-outbox.md` shapes, `report.html`) and `references/` (read live from the skill — `reviewer-prompt.md`, `goal-conditions.md`, `doc-sync-checklist.md`), plus `agents/openai.yaml` (Codex UI metadata). **Bundled files live inside their one consuming skill** so both hosts resolve them the same way — Codex skills can only read their own directory, and this also drops `${CLAUDE_PLUGIN_ROOT}` from the Claude side. Universal lessons land in these seeds so **future installs inherit them**.
- **Host neutrality** — each skill has a `## Host` section resolving the ~5 anchors that differ between Claude Code and Codex (bundled-file paths, autonomous loop, asking the human, review dispatch, invocation surface). Kept inline per skill (not a shared file — a shared plugin-root reference is unreachable from a Codex skill).
- **`.claude-plugin/`** and **`.codex-plugin/`** — the two `plugin.json` manifests (same `name`/`version`, bumped in lockstep by `improve`). Distribution: `.claude-plugin/marketplace.json` for Claude Code, `.agents/plugins/marketplace.json` for Codex.
- **`docs/`** — the GitHub Pages landing page (`index.html`, self-contained). Explains the framework to newcomers; not part of the installed process — skills never read it.

Principles that govern changes:

- **Plugin = process, project = facts, host = an axis.** Anything repo-specific belongs under a project's `.harness/`, reached through the `map/` indirection layer — never hardcoded in a skill. Anything host-specific belongs in a skill's `## Host` section — never scattered through the steps. If a fix needs a repo fact, the fix is a seed or mapping change, not a skill edit.
- **Prompts + files, not code.** The workflow lives in skill instructions; state lives in markdown on disk. Scripts may do mechanical work but never decide what happens next.
- **Encode failures into the system**, not into longer prompts — a real pilot failure becomes a Gotcha entry or a template change, so it's fixed once for every install.
- **Phase 1 (Crawl).** Completion verifiers, ticket routing, safety hooks, and worktrees are later phases — nothing speculative ships before its phase wires it up.
- **Pre-1.0, single user: no back-compat.** Never add migration paths or breaking-change scaffolding — break freely; existing installs are fixed by rerunning setup or by hand. Version bumps exist to propagate auto-update.
