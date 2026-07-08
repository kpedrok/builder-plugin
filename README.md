# builder

The builder harness, packaged as a Claude Code plugin: an agent that builds products must understand the product (personas, non-goals), the design (spec, plan, human gates), and the software (TDD slices, gates, proof) — not just emit code. Instrument any project once, then run work through a pipeline that fixes the recurring failure modes of agentic coding — misalignment, premature "done", unverified claims, context rot, scope creep, and dangerous actions.

The harness is **prompts + files — scripts may transform, never decide.** The workflow graph lives in skills and state lives in markdown on disk, never in a code-driven state machine. Deterministic mechanical steps (extracting a task brief, packaging a diff for review, reconciling the ledger against `git log`) may be small scripts a skill calls; a script never decides control flow — which slice is next, whether to proceed, what to dispatch.

## What's in Phase 1 (Crawl)

- **`setup-harness`** skill — the installer. Detects the stack, interviews for the gaps, scaffolds config/state, generates project-owned skills, and proves the gates actually work.
- **`feature`** skill — the pipeline: ALIGN → PLAN → BUILD → PROVE → REPORT, sized to the work, stopping at a self-contained HTML report for your review.
- **`ship`** skill — reads the report, commits, opens a PR linking the evidence, updates the tracker.
- **`templates/`** — spec, plan, STATE, product one-pager (purpose/personas/non-goals — the durable source of user-story roles), HTML report skeleton, goal conditions, verifier/reviewer subagent prompts (written for Phase 2, doubt-protocol discipline applies from Phase 1), and the project-skill templates setup instantiates.

## Install

### Via marketplace

```
/plugin marketplace add <owner>/builder-plugin
/plugin install builder
```

### Local dev flow

Point Claude Code at this directory:

```
claude --plugin-dir /path/to/builder-plugin
```

The `setup-harness`, `feature`, and `ship` skills then appear in `/help` and via the Skill tool.

## Usage — three steps

1. **`/setup-harness`** — once per project. Instruments the repo (config, state, generated skills) and records the test baseline. ~10 minutes, mostly detection.
2. **`/feature <description or ticket>`** — runs the pipeline. You approve the plan; it builds, proves, and writes an HTML report to `.harness/reports/`.
3. **Review the HTML**, then **`/ship`** — commits, opens the PR with the report's evidence linked, updates the tracker.

## Not in Phase 1

Review subagents, dedicated verify-skill drivers beyond the generated templates, `/ticket` tracker routing, Stop hooks, worktrees, and nightly routines are Phase 2+. Security guardrails, skill evals, and other hardening are last phase (Phase 4) — `hooks/guardrails.sh` remains in the repo as the ready implementation but is not wired by setup.
