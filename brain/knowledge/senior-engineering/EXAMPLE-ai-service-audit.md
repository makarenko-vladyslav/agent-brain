# Worked Example — Canon applied to real code (`ai-service.ts`)

> Proof the Constitution is actionable on production code, and a template for how
> an agent runs the review/architect lane. Target: проєкт `shared/services/ai/
> ai-service.ts` (1122 LOC — the critic's "God service"). Reviewer: code-reviewer
> (Opus), applying playbooks 02/03/04/07. Read-only diagnosis.

## What the canon caught (grounded in code, not guessed)

- **[HIGH] SRP / God-service** (02, 03) — one class, 5 reasons to change: provider
  construction (`:111-156`), cost (7 inline `estimateCostUsd` sites), routing
  (`:191-219`), Gemini cache block copy-pasted 3× (`:277,:399,:516`), a 235-LOC
  `streamWithFallback` (`:632-867`, 12× the ≤20 guideline).
- **[HIGH] Untrusted-AI-output inconsistency** (07) — `generateObject`/`generateStructured`
  schema-parse, but `generateText` (65 call sites) returns raw text; two structured
  paths with divergent shapes (`{object,usage}` vs `{data,usage}`).
- **[MED→HIGH] Secret leaked into a public type** (04) — `resolveLanguageModel` is
  public and returns `apiKey`; the ONE consumer (`chat-stream.ts`) never reads it →
  needless secret blast-radius. Verified by grep.
- **[MED] Silent cost drift** (07, the $110 class) — unlisted model → `FALLBACK_PRICING`
  guess with no alert; spend tracker fires on the guess.
- **Positives the canon confirmed as already-right:** thinking-tokens now counted
  at output rate (half the $110 incident closed), circuit breakers per provider,
  SDK retries off so the chain owns fallback, conservative `maybeRouteCheaper`.

## Remediation — 5 PRs, strangler-fig, backward-compatible (02 method)
Public method names/signatures/shapes stay byte-for-byte (100+ call sites don't move).
1. **Types & seams** — ports (`ModelResolver/CostReporter/PromptCache/ModelRouter`), internal `ResolvedModel` (with key) vs public `ResolvedModelHandle` (without). No behavior.
2. **Private runner** — extract the 6-step ceremony (resolve→cache→log→breaker→usage→spend) copy-pasted 5×; existing 1070 test-LOC is the regression net, must pass unedited.
3. **Cache + Router adapters** — dedupe the 3× Gemini cache; relocate routing to existing `ai-tiers.ts`.
4. **Contain the secret + collapse redundant structured path** — narrow the public return (drop `apiKey`); alias `generateStructured`→`generateObject`. Full gate (outward type).
5. **Streaming seam + cost-fallback alert** — fix dead public stream methods vs inline route duplication (escalate: owner call); add `ai_pricing_missing` alert. Ships last (reads only).

Net: 1122 LOC of repeated procedure → ~250-LOC facade over 4 named collaborators.

## Why this matters as a template
This is the **agent protocol** (Constitution §5) executed on real code: read canon →
read target → diagnose against invariants with file:line → decompose safely →
name risks + mitigations → escalate the owner-gated call (streaming seam) instead of
deciding it. Any agent picking up an epic should produce this shape of output.
