---
name: builder-improve
description: Ingest plugin-level gotchas from instrumented projects' .harness/plugin-outbox.md files into the plugin source, bump the version, and push. Human-invoke-only (type /builder-improve, optionally with project paths); the model cannot trigger it — plugin changes are a human decision, same trust boundary as plan approval.
disable-model-invocation: true
---

# Improve — the plugin's self-improvement intake

Projects can't edit the installed plugin (it's a frozen snapshot), so universal gotchas they learn queue in each project's `.harness/plugin-outbox.md`. This skill, run against the **plugin source repo**, ingests them. This is the channel that makes the harness improve from its own runs instead of relearning the same lessons per project.

**Preconditions:** the working directory is the plugin source (has `.claude-plugin/plugin.json` **and** `.codex-plugin/plugin.json`, both with `"name": "builder"`), and its git tree is clean. Not the source repo → stop and say where to run it.

## Steps

1. **Collect outboxes.** From project paths given as arguments; none given → ask for them. Read each `.harness/plugin-outbox.md`; process only rows marked `queued`.
2. **Truth-check each row against the current source.** Outbox rows are written mid-run, sometimes against a stale installed snapshot — verify the claim before acting on it: does the referenced file/dir/step actually look like the row says, in **this** repo at **this** version? Claim doesn't reproduce → mark it `rejected: not reproducible against v<current>` and move on — but first ask *why* the project saw it (stale cache? wrong path probed?); if the real defect is different (e.g. the file ships but the skill fails to find it), ingest **that** instead. Never apply a "fix" for a state the source isn't in. (Pilot 4 queued a row claiming `templates/project-skills/` doesn't ship in v0.5.1 — it does; the fix it proposed would have been wrong.)
3. **Triage each surviving row.** For every gotcha: does it belong in a plugin skill's Gotchas, a template (so future installs inherit it), or a process change to a skill's steps? A row that is actually repo-specific → mark it `rejected: repo-specific` in the outbox and move it to the project's STATE.md instead. When unsure, ask — one question, recommended answer first.
4. **Apply.** Edit the target plugin files. Rules: Gotcha entries follow symptom → cause → what to do instead, with source project + date; a process change must not add repo-specific lines to a plugin skill (that's what `.harness/map/` mappings and project skills are for — if the fix needs a repo fact, the fix is a template or mapping change).
5. **Mark ingested.** Rewrite each consumed outbox row with `ingested: v<new version> (<date>)` so the next run skips it, and commit that outbox edit in its project.
6. **Version + changelog.** Bump **both** manifests in lockstep — `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` to the same version (patch for gotcha-only batches, minor for process changes) — append a line per change to `CHANGELOG.md` (create if missing), and commit the plugin repo: `improve: ingest <N> gotchas from <projects> → v<version>`. A version that differs between the two manifests is a bug.
7. **Push.** `git push` the plugin repo (marketplace `kpedrok/builder-plugin`). Claude Code projects with auto-update on pick up the new version on their next startup (others: `/plugin marketplace update builder`); Codex projects pull it with `codex plugin marketplace upgrade` then `codex plugin add builder@<marketplace>`. Already-instrumented projects keep their generated skills as-is (project property; only templates changed).

## Rules

- Never ingest without applying — an outbox row marked ingested whose fix isn't in the diff is a lie.
- Never edit a project's generated skills from here (project property). Templates only.
- One commit in the plugin repo per improve run, version bumped exactly once (the per-project outbox-marking commits in Step 5 are separate).

## Red Flags

- Editing the installed plugin copy (under `~/.claude/plugins/` or Codex's plugin cache) instead of the source repo
- A plugin skill gaining a repo-specific command/path/URL during ingestion
- A plugin skill gaining a host-specific mechanic outside its `## Host` section (host anchors belong there, not scattered through the steps)
- Version unchanged, or the two manifests' versions diverging, after applying changes

## Gotchas

- **Codex's plugin validator rejects `disable-model-invocation: true`** → running `validate_plugin.py` (or `codex plugin add`) flags the three invoke-only skills' frontmatter "must be false". This is an irreducible cross-host conflict, **not a bug to fix by removing the key**: Claude Code *requires* `disable-model-invocation: true` for the setup/ship/improve invoke-only boundary; Codex enforces the same boundary via `agents/openai.yaml` `policy.allow_implicit_invocation: false`. Keep both. Codex distribution is the `.agents/skills/` copy path (loader honors `openai.yaml`; no manifest validation) until Codex tolerates the key. Never strip the Claude boundary to make the Codex packager pass (v0.12.0, 2026-07-13).
