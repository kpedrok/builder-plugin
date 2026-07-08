# Goal Condition Templates

Copy for use with `/goal` to cover BUILD → PROVE → REPORT autonomously after the human approves the plan. `/ship` is separate and human-triggered.

The evaluator only sees the transcript. Every clause must be provable by output Claude *shows* — never by "the file exists" alone.

## How to use

1. Run ALIGN and PLAN interactively — normal conversation.
2. When you approve the plan, set the goal to cover BUILD → PROVE → REPORT.
3. Use auto mode alongside so tool calls don't prompt (`/goal` removes per-turn prompts, auto mode removes per-tool prompts).

## Standard feature goal (BUILD → REPORT)

```text
/goal Feature <NAME> is complete per the feature skill: every slice in the
approved plan at .harness/runs/<DATE>-<NAME>/plan.md is implemented with TDD (failing test
shown before each implementation), the plan's progress ledger updated after each
slice (shown), the full gate command and exit 0 with the expected test count
are shown, e2e verified with the interaction described and screenshots taken,
docs synced (CLAUDE.md/CONTEXT.md/ADRs/spec/.harness/product.md updated or explicitly n/a — listed, plus a .harness/STATE.md entry shown),
and the HTML report written to the run folder (.harness/runs/<DATE>-<NAME>/report.html) with its path shown. No files
outside the plan's scope are modified. Stop after 40 turns.
```

## Bug fix goal

```text
/goal The bug in <AREA> is fixed per the feature skill: a regression test
reproducing the bug is shown failing, then passing after the fix; root cause
explained in one paragraph; full gate exits 0 with expected test count (output
shown); no other test file modified; docs synced or explicitly n/a (STATE.md entry shown); HTML report
written with its path shown. Stop after 20 turns.
```

## Refactor goal

```text
/goal The refactor of <MODULE> is complete: behavior unchanged (full gate exits
0 before and after with test counts, both outputs shown), <MEASURABLE TARGET —
e.g. each file under 300 lines / duplication X removed>, no public API changes,
docs synced or explicitly n/a (STATE.md entry shown), and the HTML report written with its path shown.
Stop after 30 turns.
```

## Anatomy of a good condition

| Part | Example |
|---|---|
| One measurable end state | "full gate exits 0 with expected test count", "HTML report written" |
| A stated check (how to prove it) | "command and output shown", "path shown" |
| Constraints | "no files outside the plan's scope modified" |
| Bound | "stop after 40 turns" |

## Anti-patterns

- ❌ "the code is correct / clean / well-designed" — not transcript-provable
- ❌ "the spec is written" as a goal clause for autonomous mode — spec is an interactive phase; approve it before setting the goal
- ❌ Restating the whole workflow in the condition — the skill carries the process; the goal only names the artifacts
- ❌ No turn bound — always cap it

## Graduating to a Stop hook (Phase 2 — not built yet)

Once the condition stabilizes, move the check into `.claude/settings.json` as a Stop hook so every session enforces it without typing `/goal`. Agent Stop hooks can actually run the gates (unlike the `/goal` evaluator). Deferred to Phase 2.
