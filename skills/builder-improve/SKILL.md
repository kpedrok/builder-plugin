---
name: builder-improve
description: Ingest plugin-level gotchas from instrumented projects' .harness/plugin-outbox.md files into the plugin source, bump the version, and push. Human-invoke-only (type /builder-improve, optionally with project paths); the model cannot trigger it — plugin changes are a human decision, same trust boundary as plan approval.
disable-model-invocation: true
---

# Improve — the plugin's self-improvement intake

Projects can't edit the installed plugin (it's a frozen snapshot), so universal gotchas they learn queue in each project's `.harness/plugin-outbox.md`. This skill, run against the **plugin source repo**, ingests them. This is the channel that makes the harness improve from its own runs instead of relearning the same lessons per project.

**Preconditions:** the working directory is the plugin source (has `.claude-plugin/plugin.json` with `"name": "builder"`), and its git tree is clean. Not the source repo → stop and say where to run it.

## Steps

1. **Collect outboxes.** From project paths given as arguments; none given → ask for them. Read each `.harness/plugin-outbox.md`; process only rows marked `queued`.
2. **Truth-check each row against the current source.** Outbox rows are written mid-run, sometimes against a stale installed snapshot — verify the claim before acting on it: does the referenced file/dir/step actually look like the row says, in **this** repo at **this** version? Claim doesn't reproduce → mark it `rejected: not reproducible against v<current>` and move on — but first ask *why* the project saw it (stale cache? wrong path probed?); if the real defect is different (e.g. the file ships but the skill fails to find it), ingest **that** instead. Never apply a "fix" for a state the source isn't in. (Pilot 4 queued a row claiming `templates/project-skills/` doesn't ship in v0.5.1 — it does; the fix it proposed would have been wrong.)
3. **Triage each surviving row.** For every gotcha: does it belong in a plugin skill's Gotchas, a template (so future installs inherit it), or a process change to a skill's steps? A row that is actually repo-specific → mark it `rejected: repo-specific` in the outbox and move it to the project's STATE.md instead. When unsure, ask — one question, recommended answer first.
4. **Apply.** Edit the target plugin files. Rules: Gotcha entries follow symptom → cause → what to do instead, with source project + date; a process change must not add repo-specific lines to a plugin skill (that's what `.harness/agents/` mappings and project skills are for — if the fix needs a repo fact, the fix is a template or mapping change).
5. **Mark ingested.** Rewrite each consumed outbox row with `ingested: v<new version> (<date>)` so the next run skips it, and commit that outbox edit in its project.
6. **Version + changelog.** Bump `plugin.json` (patch for gotcha-only batches, minor for process changes), append a line per change to `CHANGELOG.md` (create if missing), and commit the plugin repo: `improve: ingest <N> gotchas from <projects> → v<version>`.
7. **Push.** `git push` the plugin repo (marketplace `kpedrok/builder-plugin`). Projects with auto-update on pick up the new version on their next Claude Code startup; others pull it with `/plugin marketplace update builder`. Already-instrumented projects keep their generated skills as-is (project property; only templates changed).

## Rules

- Never ingest without applying — an outbox row marked ingested whose fix isn't in the diff is a lie.
- Never edit a project's generated skills from here (project property). Templates only.
- One commit in the plugin repo per improve run, version bumped exactly once (the per-project outbox-marking commits in Step 5 are separate).

## Red Flags

- Editing the installed plugin copy under `~/.claude/plugins/` instead of the source repo
- A plugin skill gaining a repo-specific command/path/URL during ingestion
- Version unchanged after applying changes

## Gotchas

_(empty — populate from runs)_
