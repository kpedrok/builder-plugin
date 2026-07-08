---
name: ship
description: Ship a reviewed feature — reads the HTML report, commits remaining work, opens a PR linking the report's evidence, and updates the tracker. Human-invoke-only by design (type /ship after reviewing the report); the model cannot trigger it, so nothing ships without your review.
disable-model-invocation: true
---

# Ship (Phase 1)

The pipeline stopped at the HTML report for the human's review. This skill takes it from there. **Only run after the human has reviewed and said to ship.** No review subagents in Phase 1 — that's Phase 2.

Canonical verbs ("update the tracker") resolve through `docs/agents/` mappings; never hardcode a real command here.

## Steps

1. **Read the report.** Open `.harness/reports/<feature>.html` — it is the source of truth for what was built, the acceptance criteria met, the proof of work, and the decisions. If there's no report, the feature pipeline didn't finish — stop and say so.
2. **Confirm the tree is shippable.** `git status` — everything intended is committed, nothing stray is staged. If uncommitted work from the run remains, commit it with a descriptive message. Never force-push, reset, or delete branches here.
3. **Open the PR.** Push the branch and open a pull request. The PR body links/embeds the report's evidence: acceptance criteria (asked-vs-built), gate output + test counts, screenshots, and the decisions/assumptions section. Link the report file. Show the PR URL.
4. **Update the tracker.** Move the ticket to its post-merge/ready state and comment with the PR link (per `docs/agents/tracker.md`). Skip if that mapping records no tracker.
5. **Close the plan.** Move `.harness/plans/<feature>.md` to `.harness/plans/archive/` (its Status is DONE from REPORT) so resume scans stay clean.
6. **Offer to babysit.** Suggest a recurring CI/review-comment check (e.g. `/loop 10m` where available) while the next ticket starts.

## Rules

- Never open a PR without a report to back it — the report is the evidence the PR references.
- Don't re-run the whole pipeline here; if something's missing, hand back to `feature`.
- One PR per feature. If scope split mid-run, ship the completed slice and note the rest in the tracker.

## Rationalizations (all invalid)

| Excuse                                              | Reality                                                                     |
| --------------------------------------------------- | ---------------------------------------------------------------------------- |
| "The report is basically fine, I'll PR without it"  | No report = the pipeline didn't finish. Hand back to `feature`.              |
| "The human said 'looks good' about something else"  | Ship only on an explicit ship instruction about THIS feature's report.       |
| "I'll clean up these stray files while I'm here"    | Shipping commits the run's work, nothing else. Stray changes → ask.          |

## Red Flags

- Opening a PR with no report file to reference
- Committing files the feature run didn't create or touch
- Any force-push, reset, or branch deletion
- Updating the tracker before the PR exists

## Gotchas

_(empty — populate from pilots)_
