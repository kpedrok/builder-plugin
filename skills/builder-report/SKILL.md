---
name: builder-report
description: Write the builder HTML report — the ownership-transfer document — for any finished piece of work. Use as the REPORT step of the builder-feature pipeline, and standalone whenever asked to "write the report", "explain what you built/changed", "report on this diff/PR/branch/session", or "/builder-report" — including work that never went through the pipeline (no spec, plan, or run folder required).
---

# Report

One self-contained HTML file that transfers ownership of a change to a human: a reviewer should finish it able to retell how the feature works and answer "what does the system do when X?" without reading the code. Works from a full pipeline run's artifacts or from a bare diff — the difference is provenance, not structure.

## Host (Claude Code or Codex — resolve once, at entry)

- **Bundled files.** `assets/report.html` is inside *this skill's own directory*. **Claude Code** → `${CLAUDE_PLUGIN_ROOT}/skills/builder-report/assets/report.html`; **Codex** → this installed skill's own folder (the one holding this SKILL.md) + `/assets/report.html`.
- **Invocation surface**: `/builder-report` on Claude Code, `$builder-report` on Codex. The builder-feature pipeline invokes this skill by name at its REPORT step — never by reaching into this skill's files from outside.

## Step 1 — Find the input (first rung that matches wins)

1. **Run folder** — the invocation names one, or exactly one in-flight `.harness/runs/<date>-<slug>/` matches the session's work. Harvest sources: `spec.md`, `plan.md` (Progress ledger), PROVE evidence shown in the conversation. Output goes to `<run>/report.html`.
2. **Explicit target** — the human named a scope in any form: a diff range, branch, or PR, **or a prose description** ("the uncommitted changes", "what we did this morning", "the auth refactor"). Resolve prose to the concrete diff it describes (`gh pr diff` / `git diff <range>` / `git diff HEAD` for the working tree) and state the resolution in one line before proceeding. Harvest sources: the diff, commit messages, the ticket/PR description, tests you run now.
3. **This session's work** — nothing named at all: scope = `git diff $(git merge-base <default-branch> HEAD)...HEAD` plus this conversation. Empty diff → say so and stop; don't report on nothing.

On rungs 2–3 (no run folder): write to `.harness/runs/<YYYY-MM-DD>-<slug>/report.html` if the project is instrumented, else `./report-<slug>.html` at the repo root, and say where it went.

## Step 2 — Degradation contract (missing artifacts downgrade chips, never invent)

Everything in the report is **harvested from real artifacts** — spec, plan, tests, marked code, shown output. When an artifact doesn't exist, harvest the section from the best remaining source and let the evidence chip carry the truth:

| Missing | Do instead | Chip |
| --- | --- | --- |
| Spec | §2 "asked" column from the conversation/ticket/PR description | ◐ (inferred ask) |
| Plan / ledger | §3 cards from `git log` slice commits, or one card for the whole diff | — |
| PROVE evidence | Run the gate/tests NOW and paste real output; can't run → say so | ✓ if run, ○ if not |
| ALIGN data map | Derive §4 figures from the diff's actual entities/hops | ◐ |

Never award ✓ to something this run didn't observe. A standalone report is naturally ◐/○-heavier — that's the honest shape, not a defect. If the ask itself is unrecoverable (no ticket, no conversation), ask the human one batched question rather than inventing acceptance criteria.

## Step 3 — Write it

Build from this skill's `assets/report.html` — **read that file fresh with the Read tool; never reconstruct it from memory** (the template is versioned and evolves — a remembered copy drifts from the current CSS and section set). **The template is the single spec for the report's content and look**: its head comment and inline section comments carry every rule — always-present sections, evidence chips and ship-gates, "Needed:" lines on ○, the reviewer triage block, diagram and caption rules, §5's harvest-never-invent contract, §7's reproduce/inspect/explore steps, §12's quiz rules. Follow them from the file you just read, and **keep the CSS and the inline `<script>` untouched**.

## Step 4 — Verify before declaring done

- **Tag balance**: for each of `div`, `table`, `pre`, `details`, `button`, `script`, compare open vs close counts (`grep -o '<div' | wc -l` vs `grep -o '</div>' | wc -l`) — `file://` pages won't reliably surface a broken tree.
- Render it (browser/preview) in light **and** dark; click one quiz option to confirm the reveal works.
- Code blocks preserve newlines (`white-space: pre` intact — no flattened output).

## Step 5 — Hand off

- **Inside a pipeline run** (rung 1): `git add` the report (an untracked report gets orphaned at ship), show its path, and return to the pipeline (ledger tick and STOP are builder-feature's job).
- **Standalone** (rungs 2–3): show the path and stop. Doc sync is not this skill's job — but if writing the report exposed a stale doc (wrong CLAUDE.md line, spec that no longer matches reality), say so in one line so the human can act.

## Gotchas

- **Never reconstruct the template from memory** — v0.5.1 caught a drift caused exactly this way; read `assets/report.html` fresh every run.
- **Quiz distractors**: the template exempts them from harvest-never-invent (they're labeled wrong by construction). Don't refuse to write them, and don't mark them with chips.
- **Report the diff you scoped, not the session you remember** — on rungs 2–3 the diff is the source of truth; conversation memory only fills the "why".
