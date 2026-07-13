# Doc-sync checklist (condense this into the generated `.harness/map/docs.md`)

The `builder-feature` pipeline runs this at REPORT; setup condenses it into `docs.md` so **ad hoc sessions** (work done outside the pipeline) have something concrete to walk. Keep this file and `builder-feature`'s REPORT doc-sync table in sync when either changes.

After finishing any piece of work, update whatever the session invalidated (or mark n/a):

| Doc | Update when |
| --- | --- |
| CLAUDE.md / AGENTS.md | New convention/command/structure emerged, or something in it became wrong |
| CONTEXT.md / glossary | New domain terms coined, sharpened, or canonicalized (aliases to avoid recorded) |
| docs/adr/ | A decision passed the three-gate test (irreversible ∧ surprising ∧ tradeoff) |
| .harness/map/ mappings | A gate command, tracker verb, or expected test count changed |
| .harness/product.md | A new persona surfaced, or a non-goal was added/crossed (with the human's OK) |
| spec | Scope shifted during build (spec must match what was actually built) |
| .harness/STATE.md | **Always** — decisions (AD), lessons (L), gotcha if the workflow itself failed |
| .harness/plugin-outbox.md | A gotcha is **universal** (would bite in a different repo) — route per the gotcha rule |

**Gotcha routing:** before writing a gotcha, ask *"would this bite in a different repo?"* Repo-specific → the relevant project skill's Gotchas or STATE.md. Universal (about the process, the host, or common tooling) → *also* append a row to `.harness/plugin-outbox.md` (date · symptom → cause → fix · target plugin file · status `queued`). The installed plugin is a frozen snapshot — the human runs `builder-improve` against the plugin source to ingest the outbox.
