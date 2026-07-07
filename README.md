# dev-harness

A setup-first development harness, packaged as a Claude Code plugin. Instrument any project once, then run work through a pipeline that fixes the recurring failure modes of agentic coding — misalignment, premature "done", unverified claims, context rot, scope creep, and dangerous actions.

The harness is **prompts + files, never orchestration code.** The workflow graph lives in skills; state lives in markdown on disk; safety lives in deterministic hooks.

## What's in Phase 1 (Crawl)

- **`setup-harness`** skill — the installer. Detects the stack, interviews for the gaps, scaffolds config/state/guardrails, generates project-owned skills, and proves the gates and hooks actually work.
- **`feature`** skill — the pipeline: ALIGN → PLAN → BUILD → PROVE → REPORT, sized to the work, stopping at a self-contained HTML report for your review.
- **`ship`** skill — reads the report, commits, opens a PR linking the evidence, updates the tracker.
- **`hooks/guardrails.sh`** — PreToolUse guardrail that blocks force-push, `reset --hard`, `clean -f`, `branch -D`, `checkout .`/`restore .`, `rm -rf` on absolute/home paths, and destructive SQL, with exit 2.
- **`templates/`** — spec, plan, STATE, HTML report skeleton, goal conditions, and the project-skill templates setup instantiates.

## Install

### Via marketplace

```
/plugin marketplace add <owner>/dev-harness
/plugin install dev-harness
```

### Local dev flow

Point Claude Code at this directory:

```
claude --plugin-dir /path/to/dev-harness
```

The `setup-harness`, `feature`, and `ship` skills then appear in `/help` and via the Skill tool.

## Usage — three steps

1. **`/setup-harness`** — once per project. Instruments the repo (config, state, guardrails, generated skills) and records the test baseline. ~10 minutes, mostly detection.
2. **`/feature <description or ticket>`** — runs the pipeline. You approve the plan; it builds, proves, and writes an HTML report to `.harness/reports/`.
3. **Review the HTML**, then **`/ship`** — commits, opens the PR with the report's evidence linked, updates the tracker.

## Not in Phase 1

Review subagents, dedicated verify-skill drivers beyond the generated templates, `/ticket` tracker routing, Stop hooks, worktrees, and nightly routines are Phase 2+.
