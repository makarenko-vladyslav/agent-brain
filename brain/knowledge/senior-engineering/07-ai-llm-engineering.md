# 07 — AI / LLM Engineering

> Senior playbook for building WITH LLMs. This is the discipline that defines an
> AI-first product — treat it as core engineering, not prompt tinkering.
> Stack: multi-model (Claude/Gemini), AI SDK, structured output, RAG, agents.

## Mandates

**LLM output is untrusted input**
- **[SELF] MUST** parse-don't-validate every AI response at the boundary with a Zod schema. Never `JSON.parse(aiText)` and trust it.
- **[SELF] MUST** repair/retry on parse failure (bounded retries), then fail loud — never ship a half-parsed object downstream.
- **[SELF] NEVER** interpolate raw LLM output into SQL, shell, HTML, or file paths (prompt-injection → injection).

**Prompts are owner-controlled (проєкт law)**
- **[SELF] NEVER** auto-edit prompts / model instructions. Escalate to the owner. Prompts live under owner control (`shared/config/ai-prompts-templates/**` excluded from automated changes, incl. nightly deslop).
- **[SELF] MUST** honor prompt versioning: when a live prompt has parallel versions (e.g. V3 live + V4 staged), mirror an approved change to BOTH — a single-version edit creates drift.

**Structured over free-text**
- **[SELF] MUST** use tool/function calling or JSON-schema/structured-output for anything a machine consumes. Free-text parsing is a slop signal.
- **[SELF] MUST** make illegal AI outputs unrepresentable in the schema (enums, discriminated unions) so the model can't return an unhandled shape.

**Determinism in tests**
- **[SELF] MUST** mock the model in tests; assert on output **shape + resulting DB state**, never call a live model.
- **[SELF] NEVER** let AI non-determinism into CI — no live calls, no unseeded sampling, gate outbound behind `E2E_SAFE_MODE`.

**Cost & efficiency (a real incident class — $110/cycle: uncounted thinking-tokens + stale pricing + 24% double critic calls)**
- **[SELF] MUST** count ALL tokens including thinking/reasoning tokens; keep the pricing table current per model.
- **[SELF] MUST** treat token cost as a guardrail metric per pipeline; emit a cost-alert (Telegram) when a run exceeds threshold.
- **[SELF] MUST** cache reusable context (prompt/context caching) and dedupe calls — a JSON-flake retry must not silently double every call.
- **[SELF] MUST** route by complexity: cheap model for simple/mechanical calls, top model (Opus) for quality-critical (generation, critic, code investigation). Don't default max everywhere, don't downgrade quality-critical to save cents.

**Resilience**
- **[SELF] MUST** make AI calls idempotent (CAS-claim / dedup key) so a retry doesn't double-charge or double-generate.
- **[SELF] MUST** set timeouts + bounded retries with backoff; a hung stream must not block a worker forever.

## Eval / Quality Harness

- **Golden-master before generator changes**: capture current AI output for fixed inputs; diff after a change. No generator/prompt-adjacent change ships without an eval pass.
- **LLM-as-judge with a stable threshold**: critic/QA scores must clear a fixed bar (проєкт: 96+/100) and be reproducible — flaky judge JSON = fix the judge, not the bar.
- **Regression evals per bug**: an AI-output bug gets a fixed-input case added to the eval set.
- **Trace the output, fix at the source node**: when an AI-output bug repeats, dump the RAW output of each node and fix where it's born (strategy/concept), not with a downstream scrub.

## Prompt Engineering Rigor (when owner authorizes a change)

- Structure prompts (XML tags / clear sections); put hard mandates first (primacy) and repeat critical bans.
- Few-shot with concrete positive+negative examples beats abstract instruction.
- Keep volatile bits (model names, pricing, feature copy) out of code — inject from config/env.
- Draft prompt changes in the owner's language for review, then land the approved English in code.

## Anti-Patterns

- Trusting LLM JSON without schema-parse · free-text where structured output fits · live model calls in tests · auto-editing prompts · max-model everywhere (or downgrading critic to save cost) · thinking-tokens uncounted · no eval before touching the generator · retry-on-flake silently doubling calls · raw model output into SQL/HTML (injection) · prompt edited in one version while a parallel version drifts.

## Sources
Anthropic & OpenAI prompt-engineering guides; Alexis King "Parse, Don't Validate" (applied to LLM I/O); "LLM-as-a-judge" eval literature; structured-output/function-calling docs (AI SDK, Anthropic tool use); проєкт cost-incident post-mortem (thinking-tokens, pricing drift, double critic calls).
