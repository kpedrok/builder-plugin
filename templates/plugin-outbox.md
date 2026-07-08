# Plugin outbox

Universal gotchas learned in THIS project that belong in the **builder plugin** (they would bite in any repo). The installed plugin is a frozen snapshot, so they queue here; the human runs `/builder:improve` in the plugin source repo to ingest them.

Routing test (applied by `feature`/`setup-harness` before writing here): *"would this bite in a different repo?"* — No → project skill Gotchas / STATE.md only. Yes → a row here **in addition to** the local gotcha.

One row per gotcha:

| Date | Symptom → cause → fix | Target plugin file | Status |
| --- | --- | --- | --- |
| <!-- YYYY-MM-DD --> | <!-- what broke → why → what to do instead --> | <!-- e.g. skills/feature/SKILL.md, templates/project-skills/builder-run-local/SKILL.md --> | queued |

Status values: `queued` → `ingested: v<version> (date)` or `rejected: <reason>` (set by `/builder:improve`).
