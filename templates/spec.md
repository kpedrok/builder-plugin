# Spec — <feature name>

Durable. Describes behavior and contracts, never file paths or line numbers (those go stale). This must match what was actually built by the end of the run — if scope shifts during BUILD, update this file.

## Objective

One or two sentences: what this feature is for, in the user's terms.

## User stories

Roles come from `.harness/product.md` personas — never invented per-feature. A story whose role isn't listed there means the persona list needs updating (an ALIGN question), not a made-up role.

- As a <role>, I want <capability> so that <outcome>.

## Acceptance criteria

Each must be verifiable — a test, a command, or a visible behavior. No "works well".

- [ ] <criterion>
- [ ] <criterion>

## Out of scope

The gold-plating fence. Anything noticed but deliberately not built goes here.

- <thing not being done>

## Glossary terms coined / sharpened

- **<term>** — <definition>. _(mirror into CONTEXT.md)_
