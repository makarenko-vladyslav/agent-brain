# 10 — Code Review Discipline

> Senior playbook. The reviewer pass is a SEPARATE agent (code-reviewer/critic). Writer never self-approves. This keeps review rigorous, not rubber-stamp.

## Mandates

### Author
- **[SELF] MUST** self-review the raw diff first (not the editor) — catch the obvious in 30s.
- **[SELF] MUST** write a description: what changed, why, what was explicitly NOT changed.
- **[SELF] MUST** keep CLs small (<~400 LOC, one logical purpose). Split refactor from behavior change.
- **[SELF] MUST** include tests for every new branch/condition. No test = incomplete.
- **[SELF] NEVER** self-approve in the same pass that wrote the code; never bundle unrelated changes (reformat + rename + feature = 3 PRs); never bundle a security change with cosmetics.

### Reviewer
- **[SELF] MUST** read the description, then review behavior against **intent**.
- **[SELF] MUST** look for **what's NOT there**: missing error path, missing auth check, missing test, silent failure.
- **[SELF] MUST** verify claims by reading the actual code/types — **trust the compiler, not prose** (grep/read to confirm; verifiers hallucinate).
- **[SELF] MUST** label every comment with a severity tag; approve only when it genuinely meets the bar (partial LGTM → Request Changes with the blocker list).
- **[SELF] NEVER** approve without reading the diff; never approve on test-passage alone; never nitpick style while blockers are unresolved; never skip security because the PR is small.

## Review Priority Order (high → low)
1. **Correctness / logic** — does it do what the description says? off-by-one, inverted boolean, race, swallowed error, wrong state mutation. *(primary job)*
2. **Security** — authZ bypass, injection (SQL/XSS/path), secrets in code/logs, unvalidated input. Adversarial: "how would I exploit this?"
3. **Design / boundaries** — respects abstractions? new cross-layer coupling, schema change w/o migration, breaking change to a shared interface.
4. **Completeness** — all new branches tested? error handling for every failure path?
5. **Tests** — exercise behavior or just the mock? would a regression be caught?
6. **Readability / naming** — understandable in 6 months? names that lie are latent bugs.
7. **Style** (lowest) — only if no linter enforces it; never block on style.

## Severity Rubric
**BLOCKS MERGE** (`blocking`): correctness bug in a prod path · security hole · missing test for a new branch · boundary/design violation · unintended behavior change · schema change without migration.

**NON-BLOCKING**: `issue` (real but non-critical, fix before next release) · `suggestion` (optional improvement) · `nitpick` (style/naming, trivially ignorable) · `praise` (reinforce good patterns).

Rule: unsure severity → default to `suggestion`, not `blocking`. Reserve `blocking` for clear risk.

## Architectural Archaeology (entering unfamiliar code)

No docs, no architect, 10 years of history — read the system by the traces it left. Each trace is a hypothesis about where to look first, not a verdict.

- Long `if/else` chains that get edited on every feature → **OCP** broken; the variant belongs in a discriminated union.
- `instanceof` / type-sniffing scattered around → **LSP** broken; substitution doesn't hold, so callers check by hand.
- Files in the thousands of lines → **SRP** broken; count the distinct actors requesting changes, that's the split.
- Directory names about the framework, not the domain → structure isn't screaming; expect business rules smeared across layers.
- Persistence types visible in the UI → no data boundary; a DTO seam is missing.
- Import cycle between modules → **ADP** broken; they are one module already.
- 7+ mocks needed to test one unit → I/O never got pushed to the edge.

## Anti-Patterns
Rubber-stamp LGTM (600-LOC in 2min, no comments) · hallucinated verification ("type is string" — it's `string|undefined`) · praise-only review (not adversarial) · style-first (3 nitpicks, 0 on missing error handling) · missing-negative-path blindness · trust-the-author on security · vague blocking ("this seems wrong", no line/risk/fix) · self-approval (writer=reviewer) · test-coverage theater (tests the mock).

## Sources
Google *Engineering Practices* ("CL Author's Guide", "How to Do a Code Review"); Conventional Comments (severity tags); SmartBear best-practices (n=2700: <400 LOC → 70%+ defect detection); Czerwonka et al. 2015 (review value is design > defect); Sadowski et al. Google 2018 (attention drops >200–400 LOC; "what's missing" = highest value).
