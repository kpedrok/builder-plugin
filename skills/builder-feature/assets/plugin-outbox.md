# Plugin outbox

Universal gotchas learned in THIS project that belong in the **builder plugin** (they would bite in any repo). The installed plugin is a frozen snapshot, so they queue here; the human runs `/builder-improve` in the plugin source repo to ingest them.

One row per gotcha (routing rule lives in the skills that write here):

| Date | Symptom → cause → fix | Target plugin file | Status |
| --- | --- | --- | --- |
| <!-- YYYY-MM-DD --> | <!-- what broke → why → what to do instead --> | <!-- e.g. skills/builder-feature/SKILL.md, skills/builder-setup-harness/assets/project-skills/builder-run-local/SKILL.md --> | queued |

Status values: `queued` → `ingested: v<version> (date)` or `rejected: <reason>` (set by `/builder-improve`).
