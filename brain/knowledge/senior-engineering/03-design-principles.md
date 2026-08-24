# 03 — OOP & Design Principles (pragmatic TS/React)

> Senior playbook. SOLID/DRY/KISS/YAGNI translated to a functional-first TS/React codebase — not dogmatic Java OOP.

## Mandates

**MUST**
- Make illegal states unrepresentable in types before writing logic.
- Parse at the boundary; downstream trusts parsed types (parse-don't-validate).
- One reason to change per module/hook/component (SRP).
- Prefer discriminated unions over boolean flags or `status: string`.
- Exhaust union branches with `switch` + `assertNever` (compile-error on new variant).
- Colocate what changes together; separate what changes for different reasons.
- Keep functions/components under ~40 LOC before questioning the abstraction.

**NEVER**
- Introduce an abstraction to remove duplication before the 3rd occurrence (Rule of Three).
- Extend base classes in React/TS — compose hooks/slots instead.
- Reach for a pattern by name; reach for it only when the problem it solves exists.
- Store derived state; derive at render/call time.
- Prop-drill beyond 2 levels (Law of Demeter).
- Use `any`/`as X` to silence the compiler — fix the type.

## Principles → Concrete TS/React

- **SRP** — a hook that fetches+transforms+formats is three jobs: `useRawLeads()` → `transformLeads()` → `formatForTable()`. Each changes independently.
- **OCP** — discriminated union + exhaustive switch instead of if-chains you keep editing. New variant → compiler forces handling everywhere.
- **LSP** — an impl must not narrow the contract. If `EmailSender.send()` resolves on success, a mock must resolve too, not silently swallow.
- **ISP** — depend only on what you need: `Pick<Project, 'id'|'name'>` not the whole `Project`. Smaller surface = easier mocks, fewer re-renders.
- **DIP** — inject service interfaces; bind concrete impls at the composition root. Swap Gmail→Resend without touching business logic.
- **DRY vs WET (Sandi Metz)** — "duplication is far cheaper than the wrong abstraction." Wait for the 3rd instance AND shared *intent* (not just shared shape).
- **KISS / YAGNI** — ship `<LeadsTable/>` before the generic `<DataTable sortable virtualized/>`. Premature generality pays interest forever.
- **Law of Demeter** — `order.customer.address.city` → expose `order.shippingCity`. In React: pass `clientName`, not the whole `project`.
- **Tell-Don't-Ask** — `lead.tryAssign(queue)` not `if (lead.status==='new') lead.assign(...)`. Move decisions into the owner.
- **Humble Object** — anything hard to test (component, route handler, worker) splits in two: a *humble* half that only renders/dispatches and holds no decisions, and a testable half holding all of them. A component that fetches + transforms + formats + renders is not "one component" — extract the formatting and the branching, leave the JSX humble. Side effect: the test stops needing a renderer.

## When a Pattern/Class Helps vs Over-Engineering

| Situation | Use | Skip |
|---|---|---|
| Multiple impls of one interface (email, payment) | Strategy / injected fn | one impl now → YAGNI |
| Complex construction with optional parts | object + spread | ≤3 fields → literal |
| Shared state across unrelated tree | Context + reducer | 2 levels → props |
| Singleton resource (DB pool, Redis) | module-level export (TS modules ARE singletons) | `class XSingleton` |
| Wrapping 3rd-party (Prisma, Stripe) | thin adapter interface | leaking raw SDK types |
| Domain object with invariants (`Money`, `Email`) | class with methods enforcing rules | everywhere else — functions compose better |

## Anti-Patterns

- Prop drilling 4+ levels → context or colocate
- Boolean flag sprawl (`isLoading,isError,isEmpty`) → `type State = 'idle'|'loading'|'error'|'success'`
- God hook returning 40 values → split by responsibility
- Premature abstraction (`createGenericFormHandler` after 1 form)
- Anemic domain (data bag + logic in 20 service files) → put invariant-enforcing methods on the domain
- Mock the world (test needs 7 mocks) → push I/O to the edge, integration-test the boundary
- `as any` escape hatch → parse with a type guard/Zod at the boundary
- Inheritance for reuse (`class AdminPage extends BasePage`) → extract hooks/utilities

## Sources
Robert C. Martin (SOLID); Fowler *Refactoring*; GoF *Design Patterns* (sparingly); Sandi Metz "The Wrong Abstraction" + *POODR*; Dan Abramov "Writing Resilient Components"; Matt Pocock *Effective TypeScript*; Alexis King "Parse, Don't Validate".
