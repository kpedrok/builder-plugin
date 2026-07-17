---
name: builder-prototype
description: Explore a UI feature as 5 variations in ONE self-contained HTML file before building it for real. Instead of one-shotting a single design, generate 5 genuinely distinct takes in a tabbed switcher, let the human pick the winner (or a blend), then build only that in the real stack. Use when asked to "mock this up", "show me options/variations", "what could this look like", "5 variations", "/builder-prototype" — or before committing to a build for any new UI feature, component, or page. Works with or without an installed harness.
---

# Prototype — 5 variations, pick one, build it

Default to exploration before implementation. For any new UI feature, do **not** one-shot a
single design. Produce **one self-contained HTML file presenting 5 distinct variations**, let
the human pick the winner, then build just that one for real.

Step 2's output is **disposable** — a picture to choose from, not production code.

## Host (Claude Code or Codex — resolve once, at entry)

- **Bundled files.** `assets/variations.html` is inside *this skill's own directory*. **Claude Code** → `${CLAUDE_PLUGIN_ROOT}/skills/builder-prototype/assets/variations.html`; **Codex** → this installed skill's own folder (the one holding this SKILL.md) + `/assets/variations.html`.
- **Invocation surface**: `/builder-prototype` on Claude Code, `$builder-prototype` on Codex. The builder-feature pipeline routes UI-facing features here by skill name before PLAN — never by reaching into this skill's files from outside.

## Project facts (first rung that matches wins)

The technique is universal; the *look* must match the target app. Resolve these once:

1. **Harness installed** (`.harness/map/design.md` exists) — take the accent color, design
   tokens, component vocabulary, and real entities from there. Variations output dir:
   `.harness/prototypes/`.
2. **No harness, known codebase** — skim the app's styles/theme for its accent and rough
   visual language; use its real entities and labels. Output dir: `prototypes/` (create it;
   don't commit it unless asked).
3. **No codebase context** (greenfield idea) — sensible defaults; keep the scaffold's accent
   and say so.

State the rung you resolved to in one line.

## The loop

1. **Frame it** in one line (+ stated assumptions). Ask ONE question only if it would change
   the *directions*; otherwise pick sensible defaults and note them.
2. **Build the variations file** — copy the bundled scaffold (per Host) to
   `<output-dir>/<feature>-variations.html`, fill in 5 genuinely-different takes, and open it
   (`open <file>` — it works from `file://`).
3. **Human picks** a winner — or a blend ("V2's layout + V4's header").
4. **Build the winner** for real in the project's actual stack — through the `builder-feature`
   pipeline when the harness is installed, directly otherwise — reusing existing components.

## Step 2 — the variations file (the heart of this skill)

- **Layout = tabbed switcher** (already wired in the scaffold). A header bar: the title on the
  **left**, a row of **numbered pill tabs on the right** (active = solid dark pill, inactive =
  light/muted with a gray number) — then **one variation shown full-width** below, swapped by
  clicking a tab (or pressing 1–5). Title reads `5 <plural-noun> for <feature>` (e.g. "5 zoom
  bars for the grid"). Each tab is named by the variation's **idea**, not "Version 1".
- **One file, self-contained.** All CSS in `<style>`, JS inline, opens straight from `file://`.
  Tailwind via CDN and Google Fonts `<link>`s are fine; no local images (use CSS / inline SVG /
  emoji). Set the scaffold's `--accent` to the app's accent (per Project facts).
- **Render each variation full-width and in situ** — show it inside a realistic frame (a faux
  panel/canvas), not floating, so the choice is meaningful. Give each a one-line *bet* in your
  message (the tab itself stays just the idea-name).
- **Make them genuinely distinct** — differ on a real axis, not a recolor. Pick 5 across:
  - **Structure** — single column / sidebar / dense grid / card feed / canvas
  - **Tone** — minimal-utilitarian / editorial-typographic / playful / bold-marketing
  - **Density** — airy & focused vs information-dense (Linear/terminal-like)
  - **Metaphor** — list / board / timeline / map-spatial / inline-inspector
- **Real-looking content.** Plausible copy and numbers from the app's domain — never
  "Lorem ipsum" or "Item 1". Considered spacing, type hierarchy, restrained palette: this
  previews *taste*, so cheap-looking output defeats the purpose.

## Step 4 — build the winner

- Build **only** the chosen direction (or the exact blend the human names). With a harness
  installed, hand off to `/builder-feature` (ALIGN → PLAN → …) like any other build; the spec
  names the chosen variation. Without one, build directly in the app's conventions.
- The HTML was a sketch. The real build reuses the app's existing components and tokens,
  **never** the sketch's inline CSS.
- Delete the variations file once a direction is chosen.

## When NOT to use this

- Implementing an already-chosen design (mockup in the ticket, an existing pattern to copy) → just build it.
- Wiring real data / back-end logic → this skill makes pictures, not systems.
- A trivial copy/spacing tweak or a field in an existing form → don't ceremony it with 5 mockups.

## Non-negotiable

- The variations file is disposable exploration; never ship its inline CSS as the real
  implementation.
- Don't touch shared branches / production without an explicit ask; push only when asked.
