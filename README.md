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

## Where it can live

Three shapes, detected at setup: a **single repo** (the default), a **monorepo** (one git, many packages), or a **multi-repo workspace** — a root folder hosting nested git repos with their own remotes (say, a backend repo and a frontend repo side by side). In a workspace, gates and baselines are tracked per repo, a cross-repo feature ships one cross-linked PR per touched repo, and everything the harness itself writes stays at the workspace root — no harness files land in your work repos (your feature branches, commits, and PRs do, as intended).

## Requirements

- Claude Code (desktop, CLI, or IDE extension).
- Optional, recommended: the [`pr-review-toolkit`](https://github.com/anthropics/claude-plugins-official)
  plugin. builder uses its review agents automatically if present, and falls back to a built-in reviewer if not.

## Install

```
/plugin marketplace add kpedrok/builder-plugin
/plugin install builder@builder
```

Turn on auto-update once so you stay current: `/plugin` → **Marketplaces** → **builder** → **Enable auto-update**.

### Force an update

Auto-update only re-fetches **at startup**, so mid-session (or if the **Update** button is greyed out) the app is still comparing against a stale local copy of the marketplace. To pull the latest now, run these in the chat input, in order:

```
/plugin marketplace update builder
/plugin install builder@builder
/reload-plugins
```

The first re-fetches the marketplace and refreshes the catalog; the second installs the new version; `/reload-plugins` activates it in the current session without a restart. Or just **quit and reopen** Claude Code — with auto-update on, it pulls the latest at launch. (A greyed-out **Update** button means only that the marketplace copy hasn't been refreshed yet — `/plugin marketplace update builder` fixes it.)

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

## How it works

Each `/builder-feature` run moves through five phases. The first two are interactive; the rest run on their own:

```
ALIGN → PLAN → [ you approve ] → BUILD → PROVE → REPORT → [ you review ] → /builder-ship
```

- **ALIGN** — understand the request, ask sharp questions, write a testable spec.
- **PLAN** — break it into small independent slices; you approve before any code is written.
- **BUILD** — test-first, one commit per slice.
- **PROVE** — run the full test suite, review the diff, drive the feature end-to-end.
- **REPORT** — a teaching HTML report of what changed and how, for your review.

## Skills

| Skill | What it does |
|---|---|
| `/builder-setup-harness` | Instruments a project (run once). |
| `/builder-feature` | Runs the pipeline above. |
| `/builder-ship` | Commits, opens the PR, updates the tracker — you invoke it after reviewing. |
| `/builder-improve` | Run in this repo to fold lessons from real runs back into the plugin. |

## Design notes (for contributors)

- **Plugin = process, project = facts.** The four skills are identical in every repo. Anything repo-specific — test commands, doc locations, the product itself — lives in the project under `.harness/`, reached through a thin indirection layer. Universal lessons go into `templates/` so future installs inherit them.
- **Prompts + files, not code.** The workflow lives in skill instructions and state lives in markdown on disk; scripts may do mechanical work but never decide what happens next.
- **Phase 1 (Crawl).** Completion verifiers, ticket routing, safety hooks, and worktrees are later phases — nothing speculative ships before its phase wires it up.
- **Pre-1.0, single user: no back-compat.** Never add migration paths, "upgrading from ≤vX" steps, or breaking-change scaffolding — break freely; existing installs are fixed by rerunning setup or by hand. Version bumps exist only to propagate auto-update. Revisit if the plugin ever gets a second user.
