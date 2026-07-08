---
name: improve
description: Ingest plugin-level gotchas from instrumented projects' .harness/plugin-outbox.md files into the plugin source, bump the version, and remind to re-upload. Human-invoke-only (type /builder:improve, optionally with project paths); the model cannot trigger it — plugin changes are a human decision, same trust boundary as plan approval.
disable-model-invocation: true
---

# Improve — the plugin's self-improvement intake

Projects can't edit the installed plugin (it's a frozen snapshot), so universal gotchas they learn queue in each project's `.harness/plugin-outbox.md`. This skill, run against the **plugin source repo**, ingests them. This is the channel that makes the harness improve from its own runs instead of relearning the same lessons per project.

**Preconditions:** the working directory is the plugin source (has `.claude-plugin/plugin.json` with `"name": "builder"`), and its git tree is clean. Not the source repo → stop and say where to run it.

## Steps

1. **Collect outboxes.** From project paths given as arguments; none given → ask for them. Read each `.harness/plugin-outbox.md`; process only rows marked `queued`.
2. **Triage each row.** For every gotcha: does it belong in a plugin skill's Gotchas, a template (so future installs inherit it), or a process change to a skill's steps? A row that is actually repo-specific → mark it `rejected: repo-specific` in the outbox and move it to the project's STATE.md instead. When unsure, ask — one question, recommended answer first.
3. **Apply.** Edit the target plugin files. Rules: Gotcha entries follow symptom → cause → what to do instead, with source project + date; a process change must not add repo-specific lines to a plugin skill (that's what `.harness/agents/` mappings and project skills are for — if the fix needs a repo fact, the fix is a template or mapping change).
4. **Mark ingested.** Rewrite each consumed outbox row with `ingested: v<new version> (<date>)` so the next run skips it, and commit that outbox edit in its project.
5. **Version + changelog.** Bump `plugin.json` (patch for gotcha-only batches, minor for process changes), append a line per change to `CHANGELOG.md` (create if missing), and commit the plugin repo: `improve: ingest <N> gotchas from <projects> → v<version>`.
6. **Remind.** Installed copies are snapshots — tell the human to re-upload/reinstall the plugin, and that already-instrumented projects keep their generated skills as-is (project property; only templates changed).

## Rules

- Never ingest without applying — an outbox row marked ingested whose fix isn't in the diff is a lie.
- Never edit a project's generated skills from here (project property). Templates only.
- One commit in the plugin repo per improve run, version bumped exactly once (the per-project outbox-marking commits in Step 4 are separate).

## Red Flags

- Editing the installed plugin copy under `~/.claude/plugins/` instead of the source repo
- A plugin skill gaining a repo-specific command/path/URL during ingestion
- Version unchanged after applying changes

## Gotchas

_(empty — populate from runs)_
