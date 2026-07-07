# Plan — <feature name>

Short-lived execution artifact. Exact file paths required. **No placeholders — a TBD or TODO here is a planning failure, not a note-to-self.** Delete after the feature ships.

## Slices

Vertical slices, each independently testable and committable, in build order.

### Slice 1 — <name>

- **Files:** `path/to/file.ext`, `path/to/test.ext`
- **Acceptance:** <the criterion this slice satisfies, from the spec>
- **Verification:** <exact gate command to run + expected test count after this slice>

### Slice 2 — <name>

- **Files:** `...`
- **Acceptance:** `...`
- **Verification:** `...`

## Scope guard

Files this plan is allowed to touch (the goal condition enforces "no files outside plan scope"):

- `path/...`

## Open assumptions

Decisions made without confirmation during planning — carried into the report's decisions section.

- <assumption>
