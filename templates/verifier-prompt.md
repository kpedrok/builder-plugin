# Verifier Prompt — fresh-context doubt protocol

For any claim worth verifying (Phase 2: a fresh subagent; Phase 1: the same discipline applied to your own PROVE evidence). Adapted from agent-skills' doubt-driven-development. The point: **the author never judges its own completion.**

## The cycle

```
- [ ] 1. CLAIM     — write the claim + why it matters (2-3 lines; can't? you have a vibe, not a decision)
- [ ] 2. EXTRACT   — isolate ARTIFACT + CONTRACT, strip your reasoning
- [ ] 3. DOUBT     — dispatch the verifier with the prompt below
- [ ] 4. RECONCILE — classify every finding (precedence order below)
- [ ] 5. STOP      — trivial findings only, 3 cycles done, or human override
```

**Pass ARTIFACT + CONTRACT only. Never pass the CLAIM or your reasoning** — handing the verifier your conclusion gets back validation of your conclusion. The verifier must independently determine whether the artifact satisfies the contract.

- ARTIFACT — the diff or function (not the whole file); a decision in 3–5 sentences; the assertion plus its evidence. Small enough to hold in one read — a 500-line PR gets decomposed first.
- CONTRACT — the spec's acceptance criteria / the constraints the artifact must satisfy.

## The verifier prompt (dispatch verbatim, fill the blanks)

```
Adversarial review. Find what is wrong with this artifact.
Assume the author is overconfident. Look for:
- Unstated assumptions
- Edge cases not handled
- Hidden coupling or shared state
- Ways the contract could be violated
- Existing conventions this might break
- Failure modes under unexpected input

Do NOT validate. Do NOT summarize. Find issues, or state
explicitly that you cannot find any after thorough examination.

Report format: status (DONE / DONE_WITH_CONCERNS / BLOCKED) + findings
(file:line, what, why it matters) — ≤15 lines, pointers not diffs.

ARTIFACT: <artifact or path to it>
CONTRACT: <acceptance criteria / constraints>
```

## Reconcile (first matching class wins)

The verifier's output is data, not verdict — re-read the artifact against each finding; rubber-stamping the verifier is the same failure as ignoring it.

1. **Contract misread** — flagged because your CONTRACT was unclear/incomplete → fix the contract, re-classify next cycle.
2. **Valid + actionable** — real issue → change the artifact, re-loop.
3. **Valid trade-off** — real but fixing costs more than accepting → document it explicitly for the human.
4. **Noise** — correct under context the verifier lacked → note it; would adding that context to the contract have prevented the false flag?

A fresh verifier can be wrong because it lacks context. Don't defer just because it's "fresh."

## Stop rules

- Next cycle returns only trivial/already-considered findings, **or** 3 cycles done (escalate — three unresolved cycles is information about the artifact, not a reason for a fourth), **or** the human says ship it.
- 3 cycles "obviously insufficient" because the artifact is big → the artifact is too big; decompose, don't lift the bound.
- **Doubt theater (checkable):** 2+ cycles with substantive findings, zero classified actionable → you are validating, not doubting. Stop and escalate.
