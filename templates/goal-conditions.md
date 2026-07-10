# Goal Condition Templates

Copy for use with `/goal` to cover BUILD → PROVE → REPORT autonomously after the human approves the plan. `/builder-ship` is separate and human-triggered.

The evaluator only sees the transcript. Every clause must be provable by output Claude *shows* — never by "the file exists" alone. **The skill carries the process; the goal only names the artifacts** — don't restate workflow steps in the condition.

## How to use

1. Run ALIGN and PLAN interactively — normal conversation.
2. When you approve the plan, set the goal to cover BUILD → PROVE → REPORT.
3. Use auto mode alongside so tool calls don't prompt (`/goal` removes per-turn prompts, auto mode removes per-tool prompts).

## The template

```text
/goal Feature <NAME> is complete per the builder-feature skill: every slice in
the approved plan at .harness/runs/<DATE>-<NAME>/plan.md is done in its progress
ledger (shown), review gate verdicts shown, the full gate exits 0 with the
expected test count (output shown), e2e evidence shown, docs synced or
explicitly n/a (STATE.md entry shown), and the HTML report written to the run
folder with its path shown. No files outside the plan's scope are modified.
Stop after 40 turns.
```

Variants — swap in the clause that fits, keep the rest:

- **Bug fix:** add "a regression test reproducing the bug is shown failing, then passing after the fix; root cause explained in one paragraph; no other test file modified." Bound: ~20 turns.
- **Refactor:** add "behavior unchanged — full gate exits 0 before and after with test counts, both outputs shown; <MEASURABLE TARGET>; no public API changes." Bound: ~30 turns.
- **Workspace shape:** write the gate clause as "**each touched repo's** full gate exits 0 against its own baseline (outputs shown per repo)" — a workspace has no single gate, and a condition naming one lets an autonomous run skip the other repo.

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
