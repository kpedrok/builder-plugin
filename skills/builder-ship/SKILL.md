---
name: builder-ship
description: Ship a reviewed feature — reads the HTML report, commits remaining work, opens a PR linking the report's evidence, and updates the tracker. Human-invoke-only by design (type /builder-ship after reviewing the report); the model cannot trigger it, so nothing ships without your review.
disable-model-invocation: true
---

# Ship

The pipeline stopped at the HTML report for the human's review. This skill takes it from there. **Only run after the human has reviewed and said to ship.** The full review gate already ran in PROVE — here only a delta re-check (step 3).

Canonical verbs ("update the tracker") resolve through `.harness/map/` mappings; never hardcode a real command here.

**Host.** Runs on Claude Code or Codex (`.harness/STATE.md`'s baseline records which). Invocation surfaces in prose (`/builder-ship`, `/builder-feature`) are Claude Code's; on Codex read them as `$builder-ship`, `$builder-feature`. Everything else here is host-neutral (git, `.harness/map/` verbs, the report).

**Workspace shape** (gates.md opens with a repo registry): steps 2–4 run **per touched repo** (the repos the run's sizing line/slices named — the report's "How to ship it" section lists them). Code PRs come from the nested repos; harness artifacts (report, STATE, outbox, run archive) commit to the **workspace root**, which gets no PR — direct to its default branch. Whether that root commit is **pushed** follows gates.md's registry: private root remote → push; **shared** root (other contributors) → ask the human first; no remote → local commit only; `no root repo` recorded → skip root commits and the archive move, and say so. Single-repo installs: ignore this paragraph.

## Steps

1. **Read the report.** Open `.harness/runs/<date>-<feature>/report.html` — it is the source of truth for what was built, the acceptance criteria met, the proof of work, and the decisions. If there's no report, the feature pipeline didn't finish — stop and say so.
2. **Confirm the tree is shippable** — every touched repo, plus the workspace root in workspace shape. `git status` — everything intended is committed, nothing stray is staged. If uncommitted work from the run remains, commit it with a descriptive message. **Harness files the run edited — plan, spec, STATE.md, `.harness/map/` mappings, project-skill Gotchas, `plugin-outbox.md` — ship in this commit too** (workspace shape: in the root repo); an unstaged improvement didn't happen. Never force-push, reset, or delete branches here.
3. **Delta re-check** — per touched repo. Commits made after PROVE's review gate (report, doc sync) are normal. If any of them touch **code**, re-run `code-reviewer` (per `.harness/map/review.md`) on that delta only; no code delta → skip, say so in one line. **No fix loop here — the human is present:** a Critical or Important finding → ask (fix now / ship anyway / hand back to `builder-feature`). Findings shipped-with go in the PR body.
4. **Open the PR(s).** Push the branch and open a pull request in each touched code repo. The PR body links/embeds the report's evidence: acceptance criteria (asked-vs-built), gate output + test counts, screenshots, the decisions/assumptions section, and any review findings the human chose to ship with. Link the report file. Multiple PRs → **cross-link them in each body** and state the merge order (contract repo first). Show every PR URL.
5. **Update the tracker.** Move the ticket to its post-merge/ready state and comment with the PR link(s) — one comment covering all PRs (per `.harness/map/tracker.md`). Skip if that mapping records no tracker.
6. **Archive the run.** `git mv` the **whole run folder** `.harness/runs/<date>-<feature>/` to `.harness/archive/` (the plan's Status is DONE from REPORT) so resume scans stay clean and spec/plan/report travel together — and commit the move; the ship must end with a clean tree. Moving only part of the folder is a bug (pilot 3 orphaned an untracked report this way). While here: **if `.harness/STATE.md` is over ~150 lines, sweep its oldest Lessons and Gotchas rows into `.harness/archive/state-<year>.md`** (Decisions and Rejected never age out) and include the sweep in this commit.
7. **Surface the outbox.** If `.harness/plugin-outbox.md` has rows still marked `queued`, tell the human in one line: "N plugin-level gotchas queued — run `/builder-improve` in the plugin source when convenient."
8. **Offer teardown.** If the run left a local stack running for the e2e (services, DB, preview server), list what's up and offer to stop it — never assume.
9. **Offer to babysit.** Suggest a recurring CI/review-comment check while the next ticket starts — `/loop 10m` on Claude Code where available; on Codex, a scheduled `codex exec` check or an automation. Skip if neither is available.

## Rules

- Never open a PR without a report to back it — the report is the evidence the PR references.
- Don't re-run the whole pipeline here; if something's missing, hand back to `builder-feature`.
- One PR per feature **per repo** (workspace shape: one per touched repo, cross-linked). If scope split mid-run, ship the completed slice and note the rest in the tracker.
- Workspace shape: the root repo carries harness artifacts only — a code change in the root repo's PR-less commit is a red flag.

## Rationalizations (all invalid)

| Excuse                                              | Reality                                                                     |
| --------------------------------------------------- | ---------------------------------------------------------------------------- |
| "The report is basically fine, I'll PR without it"  | No report = the pipeline didn't finish. Hand back to `builder-feature`.              |
| "The human said 'looks good' about something else"  | Ship only on an explicit ship instruction about THIS feature's report.       |
| "I'll clean up these stray files while I'm here"    | Shipping commits the run's work, nothing else. Stray changes → ask.          |

## Red Flags

- Opening a PR with no report file to reference
- Committing files the feature run didn't create or touch
- Any force-push, reset, or branch deletion
- Updating the tracker before the PR exists

## Gotchas

_(empty — populate from pilots)_
