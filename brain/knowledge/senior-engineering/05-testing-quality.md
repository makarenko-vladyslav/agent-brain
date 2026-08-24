# 05 — Test Strategy & Quality Engineering

> Senior SDET playbook. Tests that catch regressions and don't rot.
> Stack: TS/Next.js/React/Prisma, Vitest (unit/integration), Playwright (E2E).

## Mandates

**MUST**
- Test **behavior**, not implementation. Tests survive refactors.
- One regression test per bug, written **before** the fix (red → green).
- Run `tsc --noEmit` + lint + vitest + `next build` + E2E as a **merge-blocking** gate.
- Isolate tests: each sets up & cleans its own state. Never depend on execution order.
- Make tests deterministic: pin time (`vi.setSystemTime`), seed randomness, freeze external IDs.
- E2E mirrors **real user journeys**, not UI fragments.
- Characterization (golden-master) tests before any large refactor — lock current behavior first.
- Keep it fast: unit <100ms, integration <1s, full E2E <5min.
- Gate all outbound side-effects behind `E2E_SAFE_MODE` — no real emails/charges/SMS in automated runs.

**NEVER**
- Mock what you don't own at unit level — stub at the boundary (HTTP/queue/event).
- Assert on internal state, private methods, module internals.
- Ignore a flaky test — quarantine immediately, fix in 24h or delete.
- Use `Date.now()`/`Math.random()`/uncontrolled DB sequences without seeding.
- Treat coverage % as a quality signal alone.
- Test framework code (Next routing, Prisma mechanics) — trust it, test your logic.
- Let an agent push without the full gate passing locally.

## What to Test at Each Level (Testing Trophy — Static > Integration > Unit > E2E)

- **Static (tsc + ESLint)** — free, always. 0 errors = hard gate. No `@ts-nocheck`/`eslint-disable` in prod code.
- **Unit** — pure logic only: transformers, formatters, calculators (ROI, price derivation, date windows), state machines, complex branching rules. NOT components/routes/DB. If you need 5+ mocks → it's integration.
- **Integration (majority)** — API handlers against a real test DB; service flows (`copywriter → builder → assembly`); worker claim→process→emit with DB assertions; auth authorized vs unauthorized; SSE payload shapes. If it touches Prisma/Redis/HTTP → integration.
- **E2E (critical paths only)** — lead→qualify→generate→deliver→approval→upsell; login + role access; generation happy path (mock AI, assert DB + output); email/payment guard asserts `E2E_SAFE_MODE`; marketplace with Stripe test mode; mobile 390px per scenario. NOT error messages/validation/UI states — those are integration.

## Anti-Patterns & Flaky Signals

| Anti-pattern | Signal |
|---|---|
| Clock dependency | `expect(x).toBe('2 days ago')` — fails next week |
| Shared DB state | Test B reads Test A's records — order-sensitive |
| Testing the mock | `expect(mockSend).toHaveBeenCalled()` with no behavior assertion |
| Snapshot thrash | fails on className change, not behavior |
| Over-mocked unit | 7 `vi.mock()` = integration in disguise |
| Async timing | `setTimeout(()=>expect())` → use `waitFor`/explicit signals |
| Real external calls | hits live Stripe/Gmail — flaky, costly, side-effects |
| Brittle selectors | `.btn-primary:nth-child(3)` → `data-testid`/role |
| Coverage theater | 100% covered, only the happy path |
| SSE `sleep(2000)` | → `waitForResponse`/event listeners |

**Flaky triage:** run 3× isolated. Pass 3/3 → upstream ordering bug. Intermittent isolated → timing/async bug. Fix at root; never add `sleep()`.

**Tests are just another client of the system** (Martin) — not a separate project layer. Consequence: a suite that shatters when an implementation detail moves is diagnosing a *boundary* problem, not a testing problem. One detail change breaking 100 tests = those tests attached below the seam. Fix the seam (Humble Object, DTO at the border), then the tests.

## Definition of Done — Verification Gate (in order)
```
1. tsc --noEmit          → 0 errors (hard block)
2. eslint                → 0 errors (warnings must not grow)
3. vitest run            → all green, no unexplained skips
4. next build            → prod build OK (catches "use server" sync exports)
5. Regression test       → red before fix, green after (bugs)
6. E2E (if flow changed) → real browser + viewport, E2E_SAFE_MODE=1
7. Manual browser scan   → screenshot, not "should work"
```
Never run E2E if tsc fails — it masks the real error. CI enforces the same gate on `staging`/`main`. Coverage is a risk map (payments/auth/generation must be covered), not a target.

## Sources
Freeman & Pryce *GOOS*; Kent Beck *TDD by Example*; *Software Engineering at Google* chs.11–14; Fowler "Practical Test Pyramid" & "Eradicating Non-Determinism in Tests"; Kent C. Dodds "Testing Trophy".
