# 02 — Software Architecture & Work Decomposition

> Senior playbook. Judgment for feature design and breaking down work.
> Stack: TypeScript/Next.js/Prisma, Feature-Sliced Design (FSD).

## Mandates

**MUST**
- Depend only on stable abstractions, never volatile implementations (Stable Dependencies Principle). FSD order: `shared/config, shared/lib ← shared/services ← entities ← features ← widgets ← app`. Never reverse.
- Keep the dependency graph acyclic (ADP). A cycle between modules means they are one module wearing two names — merge them or invert one edge behind an interface. This is lint-checkable; enforce it there, not in review.
- Separate I/O from logic at every layer. Pure functions in `/lib`; side effects only at service boundaries.
- Express intent via ports (interfaces/types); hide impl behind adapters. Every external system (DB, AI, email, storage) gets an interface + one concrete impl (Parnas: information hiding).
- Record architectural decisions in an ADR the moment a non-obvious trade-off is made.
- Name seams before writing code: "Where will this change independently?" → that seam is a module boundary.
- Design every task to be independently deployable + testable. If B needs A merged first, A is a blocking dependency — make it explicit.
- Gate volatility on one side of the boundary. Config, prompt text, pricing, model names → isolate in `/config` or env. Code must not change when these change.

**NEVER**
- Never let a feature import from another feature (FSD). Cross-feature coupling is the #1 source of multi-agent merge hell.
- Never skip the abstraction layer because "there's only one implementation" — the interface is the contract the test owns.
- Never merge a layer-violating import "temporarily" (complexity is incremental — it never gets fixed).
- Never model the implementation in the domain type. `ProjectStatus = 'prisma_enum'` is a leak — use a domain type, map at the persistence adapter.
- Never build an abstraction before two concrete uses (YAGNI). One use = inline. Two = extract. Three = design it.
- Never decompose by technology layer (frontend/backend/DB). Decompose by capability slice (vertical, end-to-end, user-observable value).

## Decomposition Method: Epic → Shippable Tasks

1. **Domain-event spine** — list every domain event in order: `LeadCreated → SiteGenerated → ReviewRequested → SiteDelivered`. Each event is a candidate task boundary.
2. **Read/write spine** — for each event: what it reads, what it writes. Tasks sharing no writes ship in parallel.
3. **Strangler-fig ordering** — always ship in this order:
   1. Schema + types (Prisma migration + TS interfaces). No UI/logic. Merged alone.
   2. Service layer (pure functions + adapters). Unit-tested. No routes/components.
   3. API surface (route handlers / server actions). Integration-tested. No UI.
   4. UI (React using the already-tested API). E2E at the seam, not internals.
   5. Observability (SSE, alerts, logging). Ships last — reads, never writes domain state.
4. **Size each task to "one PR, one logical change."** If the description needs "and also…", split.
5. **Make dependencies explicit before assigning.** Draw a DAG; in-degree>0 = blocker. Parallelize the rest. Two agents never own the same file — use worktree isolation.
6. **Define Done per task**: input contract (types), output contract (API/event), a test red-before green-after.

## Boundary & Coupling Heuristics

- **Cohesion (Parnas):** "If I change this, what else must change?" Spanning many modules → cohesion too low → pull co-changing code together.
- **Coupling (Evans):** "Can I replace this with a fake and the system still makes sense?" No → boundary wrong / abstraction leaks.
- **Stable vs volatile:** stable = domain types, business rules, contracts. Volatile = model names, prompt text, pricing, SDKs, env config. Stable must never import volatile — inject volatile as a parameter.
- **Port/adapter placement:** interface lives in the layer owning the domain concept; adapter lives in `shared/services/[provider]/`.

**Seam checklist before coding:** what changes independently? → boundary · stable contract? → interface · volatile impl? → adapter · owns the mapping? → adapter, not domain.

## Component Principles (module-level SOLID)

SOLID governs classes; these govern packages — and they decide whether a monolith stays navigable.

**Cohesion — what belongs in one component:**
- **CCP** (Common Closure) — group what changes for the same reason, by the same actor. SRP one level up.
- **CRP** (Common Reuse) — never force a dependency on something the consumer doesn't use. Always used together → together. Never together → split.
- **REP** (Reuse/Release Equivalence) — the unit of reuse is the unit of release; a component you can't version independently isn't a component.

**Coupling — how components may depend:**
- **ADP** — no cycles. The one mechanically verifiable rule in this whole playbook.
- **SDP** — depend toward the more stable. Newly added code must never carry the foundation.
- **SAP** — the most stable component must be the most abstract, else "stable" degrades into "unchangeable."

**Screaming structure** — the directory tree must announce the *business*, not the framework. `orders/ payments/ catalog/ shipping/` tells you the domain in 3 seconds; `controllers/ services/ repositories/` only tells you which framework was fashionable. FSD's `entities/` + `features/` is this principle with the import direction already fixed. Pragmatic caveat: pure business-slicing produces awkward seams too — combine, don't dogmatize.

**Deferral as a design goal** — good architecture maximizes how long expensive decisions can stay unmade. "How does a user place an order" must be answerable before "which ORM." If a choice can't be deferred, that's the one to write the ADR for.

## Anti-Patterns

| Anti-pattern | Example | Fix |
|---|---|---|
| Leaky abstraction | `prisma.ProjectStatus` in UI | map to domain enum at repo adapter |
| Feature coupling | `features/site-editor` imports `features/payment` | extract to `entities/` |
| God service | `aiService` does gen+pricing+routing+cache | split by capability |
| Abstraction by analogy | `IEmailService` before a 2nd provider exists | inline until second use |
| Business logic in route/action | server action does auth+validation+logic+prisma inline | route/action → service → prisma; action stays thin (a repository layer only for complex domains) |
| Shotgun surgery | renaming a model touches 40 sites | centralize in `shared/config` |
| Boolean trap | `generateSite(id, true, false, true)` | named options object |
| Missing ADR | "we switched to Vite, here's the PR" | ADR: why, rejected alternatives, reversal cost |

## ADR Practice
Write an ADR when: a non-obvious tech choice is made; a constraint eliminates alternatives (SSE-only); a known trade-off is accepted. One-page template:
```markdown
# ADR-NNN: [Title]
Date: YYYY-MM-DD  Status: [Proposed|Accepted|Superseded]
## Context   [1-3 sentences: what forced the decision]
## Decision  [1-3 sentences: what was chosen]
## Consequences  [easier / harder / now forbidden]
```

## Sources
Parnas "On the Criteria To Be Used in Decomposing Systems into Modules" (1972); Evans *Domain-Driven Design*; Fowler *PoEAA* + bliki (Stable Dependencies, Strangler Fig); Ousterhout *A Philosophy of Software Design*; Richards & Ford *Fundamentals of Software Architecture*; Feature-Sliced Design.
