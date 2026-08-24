# 01 — Code Craft & AI-Slop Prevention

> Senior playbook. Prevention, not cleanup — never produce slop in the first place.
> Stack context: TypeScript/React/Next.js/Prisma. Every rule is agent-enforceable.

## Mandates

### NAMING
- **MUST** name by meaning, not type: `filteredActiveUsers` not `arr2`, `calculateMonthlyRevenue` not `doCalc`.
- **MUST** name booleans as predicates: `isLoading`, `hasPermission`, `canEdit`. Never `loading`, `flag`, `check`.
- **MUST** match the domain vocabulary of the surrounding codebase. Read 3 adjacent files before naming.
- **NEVER** abbreviate unless universal (`id`, `url`, `ctx`). `usr`, `proj`, `cfg` → banned.
- **NEVER** add type noise: `userArray`, `dataObject`, `stringValue` — TypeScript already says so.

### FUNCTIONS
- **MUST** do one thing. If describing it needs "and", split it.
- **MUST** keep functions under ~20 lines. Longer → extract, don't comment.
- **MUST** limit arguments to ≤3. Beyond → options object with named fields.
- **NEVER** return different shapes based on a flag. Two functions, two names.
- **NEVER** add a `type: 'success' | 'error'` return field when you can throw or use a discriminated union.

### CONTROL FLOW
- **MUST** use early returns to kill nesting. Guard at top, happy path at bottom.
- **MUST** prefer positive conditions (`if (isValid)`) over negated (`if (!isNotInvalid)`).
- **NEVER** nest ternaries >1 level. Extract to a named variable/function.
- **NEVER** use `else` after a `return` — dead structure.

### COMMENTS
- **MUST** comment only *why*, never *what*. A "what" comment means: rename or refactor.
- **MUST** delete comments restating the type signature, param name, or return value.
- **NEVER** write `// increment counter` above `count++`.
- Legitimate: a non-obvious business rule, a workaround with a ticket ref, a performance constraint.

### MODULES & ABSTRACTION
- **MUST** follow Ousterhout's deep-module principle: small interface, large implementation. A one-line wrapper adding no semantics is noise.
- **MUST** read the file top-to-bottom before editing. Match its style, naming, import order.
- **NEVER** abstract for a single use-case. Three concrete callsites → then abstract (Rule of Three).
- **NEVER** introduce an interface/type just to name what TS already infers correctly.
- **MUST** hide information: don't leak Prisma types out of the data layer; don't export internals.

### REACT / NEXT.JS
- **MUST** colocate state with its owner. Don't lift higher than needed.
- **NEVER** add `useEffect` for derived state — compute inline or in `useMemo`.
- **MUST** gate SSR-only globals (`window`, `document`) with a mount check.
- **NEVER** pass raw Prisma model types as React props — define a view-model type at the boundary.

### PRISMA / BACKEND
- **MUST** `select` only the fields you use. `findMany` with no `select` on a wide table is a slop signal.
- **NEVER** `findUnique` then immediately `update` — use `update` with a `where` (one roundtrip).
- **MUST** validate before the DB call, not after.

## Anti-patterns & AI-Slop Signals

| Signal | Example |
|---|---|
| Redundant wrapper | `function getUser(id){ return fetchUser(id); }` — zero value |
| Restating the type | `// returns a string` above `→ string` |
| Defensive noise | `if (arr && arr.length > 0)` when TS + `?.` already handle it |
| "Just in case" param | `doThing(data, force=false)` — `force` never `true` anywhere |
| Copy-paste variant | `buildUserEmail`/`buildAdminEmail` differ by one string → parametrize |
| Hallucinated API | `.toISOString()` on a value that isn't a `Date` — verify the real shape |
| Boolean trap | `render(true)` → named options `render({ animate: true })` |
| God comment | 10-line JSDoc on a 3-line function |
| Abstraction tax | `createErrorResponse(msg)` returning `{error: msg}` — write the literal |
| Generic name | `handleData`, `processItem`, `doStuff` |
| Shotgun try/catch | `try { all } catch { return null }` — swallows bugs |
| Stale comment | describes pre-refactor behavior — now a lie |
| Enum-in-comment | `// 'pending' | 'done'` when a TS union exists |
| Over-exported internal | `export const _buildQuery` used in one file |

## Self-Review Checklist (hard gate before "done")

**Correctness**
- [ ] Empty/null/undefined handled explicitly or provably unreachable?
- [ ] Verified the actual shape of every external value (Prisma, API, env)?
- [ ] All async errors thrown or handled — no silent swallow?

**Naming & structure**
- [ ] Every function name readable without reading its body?
- [ ] Every function ≤20 lines, one thing?
- [ ] File style (imports, naming, spacing) matches what it was before I touched it?

**Slop detection**
- [ ] Any wrapper adding no logic? Any comment restating code/type? Any param never varied?
- [ ] Any placeholder/TODO I won't implement now?
- [ ] Copy-pasted block with one value changed → parametrize.

**TypeScript**
- [ ] Zero `any` (else disable-comment + reason). No `!` without a why-comment. `tsc --noEmit` clean.

**Final**
- [ ] I read the full diff as a reviewer. Would I approve it?
- [ ] Tests cover the new branch/edge, not just happy path. `next build` passes locally.

## Sources
Robert C. Martin *Clean Code*; John Ousterhout *A Philosophy of Software Design*; Kernighan & Pike *The Practice of Programming*; Google *Code Review Developer Guide*; Martin Fowler *Refactoring*; TypeScript Handbook; Next.js & Prisma docs.
