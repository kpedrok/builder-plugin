---
name: ship
description: Use after the human has reviewed the feature's HTML report and wants to ship it — "ship it", "/ship", "open the PR", "commit and PR this", "raise the pull request". Reads the report, commits the work, opens a PR linking the report's evidence, and updates the tracker. Runs only after the human's review pass.
---

# Ship (Phase 1)

The pipeline stopped at the HTML report for the human's review. This skill takes it from there. **Only run after the human has reviewed and said to ship.** No review subagents in Phase 1 — that's Phase 2.

Canonical verbs ("update the tracker") resolve through `docs/agents/` mappings; never hardcode a real command here.

## Steps

1. **Read the report.** Open `.harness/reports/<feature>.html` — it is the source of truth for what was built, the acceptance criteria met, the proof of work, and the decisions. If there's no report, the feature pipeline didn't finish — stop and say so.
2. **Confirm the tree is shippable.** `git status` — everything intended is committed, nothing stray is staged. If uncommitted work from the run remains, commit it with a descriptive message. Never force-push, reset, or delete branches here.
3. **Open the PR.** Push the branch and open a pull request. The PR body links/embeds the report's evidence: acceptance criteria (asked-vs-built), gate output + test counts, screenshots, and the decisions/assumptions section. Link the report file. Show the PR URL.
4. **Update the tracker.** Move the ticket to its post-merge/ready state and comment with the PR link (per `docs/agents/tracker.md`).
5. **Offer to babysit.** Suggest `/loop 10m` to watch CI and review comments while the next ticket starts.

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
