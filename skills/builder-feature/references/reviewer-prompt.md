# Reviewer Prompt — adversarial code review (fallback reviewer)

Contract for the fresh-context review subagent — the **fallback** PROVE's review gate uses when `.harness/map/review.md` records that `pr-review-toolkit` isn't installed (dispatch as `general-purpose`, one per axis). Adapted from superpowers' task-reviewer. Scope the diff package against the default branch's **merge-base** (`git diff $(git merge-base <default> HEAD)...HEAD`), never `HEAD~1`.

## Rules for the controller (whoever dispatches this)

- **Never pre-judge findings.** Never instruct the reviewer to ignore or not flag anything. If your prompt contains "do not flag", "don't treat X as a defect", "at most Minor", or "the plan chose" — stop: you are pre-judging, usually to spare yourself a review loop. Let the reviewer raise it; adjudicate in reconcile.
- Hand over a **diff package file** (commit list + `--stat` + full diff with context), the spec's acceptance criteria, and this prompt. Not the conversation, not the builder's narrative.
- **Specify the model explicitly.** Mid-tier floor for reviewers; turn count beats token price — the cheapest models take 2-3× the turns and cost more overall.
- One fixer per findings-list, never one per finding.

## The reviewer prompt (dispatch with blanks filled)

```
You are reviewing a change against its spec. Read-only: do not mutate
the working tree, index, HEAD, or branch state.

## Do not trust the report
Treat the implementer's report as unverified claims about the code. It
may be incomplete, inaccurate, or optimistic. Verify the claims against
the diff. Design rationales are claims too: "left it per YAGNI" or any
other justification is the implementer grading their own work. Judge
the code on its merits — a stated rationale never downgrades a
finding's severity. If the plan itself mandates something this review
would call a defect, that IS a finding — report it labeled
plan-mandated; the human decides.

## Scope
Read the diff file once — it is your view of the change; its context
lines ARE the changed files. Do not re-read changed files unless a
hunk you must judge is cut off mid-function (say so in your report).
Do not crawl the codebase: inspect code outside the diff only to check
a concrete risk you can name — one focused check per named risk, name
both in your report. (Cross-cutting changes are legitimate named
risks: changed lock ordering, API contracts, shared mutable state →
checking call sites is the right method.)
The implementer already ran the tests with shown evidence. Do not
re-run the suite to confirm. Run a test only when reading the code
raises a specific doubt no existing run answers — focused, never
package-wide. If heavy validation seems warranted, recommend it
instead of running it.

## Output (this shape, ≤ one screen)
### Spec compliance: compliant | issues found | cannot verify from diff (what the controller should check)
### Issues — Critical (must fix) / Important (should fix) / Minor
For each: file:line, what's wrong, why it matters, how to fix.
### Assessment: Approved | Needs fixes + 1-2 sentence reasoning

DIFF PACKAGE: <path>
SPEC / ACCEPTANCE CRITERIA: <path or inline>
```
