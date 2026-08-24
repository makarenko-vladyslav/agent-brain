# 04 — Secure-by-Design Engineering

> Senior AppSec playbook. Security built in on EVERY feature, not bolted on.
> Stack: Next.js (server actions/API routes), Prisma/Postgres, NextAuth, multi-tenant USER/ADMIN, Stripe, storage, email.

## Mandates

**AuthN / AuthZ**
- **MUST** gate every server action & API route with a session check before touching data.
- **MUST** treat server actions as public RPC — no client-only `if (isAdmin)`; always re-check role server-side.
- **MUST** verify resource ownership on EVERY mutation: `where: { id, ownerId: session.user.id }`. Never trust `projectId` from body/params alone (IDOR).
- **NEVER** return full DB records to the client; shape output, strip internal fields.

**Input validation**
- **MUST** parse-don't-validate with Zod at the boundary; `.strict()` to reject unknown keys.
- **MUST** validate uploads: MIME via magic bytes (not client `file.type`), size limit, path-traversal check.
- **NEVER** `JSON.parse(userInput)` without a schema; never `eval`; never template-string SQL.

**Secrets**
- **MUST** keep secrets in env only; assert presence at build (`if(!process.env.X) throw`).
- **NEVER** import secrets in `"use client"` files or the `app/` client tree — Next.js bundles them.
- **NEVER** log secrets, tokens, or PII.

**Multi-tenancy (IDOR)**
- **MUST** scope every query by owner/tenant; `findFirst({ where:{ id, ownerId } })`, never `findUnique({ where:{ id } })` alone.
- **MUST** log ADMIN cross-tenant access explicitly.
- **NEVER** accept `userId`/`ownerId` from the request body — derive from server session.

**Sensitive data**
- **MUST** encrypt tokens at rest (OAuth/Gmail refresh) with a server secret (AES-256-GCM).
- **MUST** HMAC-sign storage URLs with expiry; never expose raw paths.

## Per-Feature 5-Minute Threat Model (STRIDE-lite)

| Ask | STRIDE |
|---|---|
| Can an unauth/wrong-tenant user reach this? | Spoofing |
| Are all inputs validated? Ownership verified? | Tampering |
| Does an error leak internal IDs/stack/user existence? | Info Disclosure |
| What happens at 1000×? Rate limit? Unbounded query? | DoS |
| Does it assume a role from client input? | Elevation |
| What would a bot/competitor do with this endpoint? | Abuse case |

**Per-feature checklist:** AuthN ✓ · AuthZ on the specific resource ✓ · Zod at entry ✓ · IDOR (`AND ownerId=` in WHERE) ✓ · no internal fields leaked, generic client errors ✓ · rate limit (auth, AI, uploads, email) ✓ · audit log (admin/payment/export/auth) ✓

## Framework Traps

```ts
// Next.js server action — "use server" does NOT authorize. Any client can POST the action URL.
export async function deleteProject(id: string) {
  const session = await getServerSession(authOptions)
  if (!session) throw new Error('Unauthorized')
  const project = await prisma.project.findFirst({ where: { id, ownerId: session.user.id } }) // IDOR guard
  if (!project) throw new Error('Not found')
  await prisma.project.delete({ where: { id } })
}

// Prisma — findUnique by id alone = IDOR → findFirst scoped to owner.
// Raw query: prisma.$queryRaw`... WHERE email = ${email}` (parameterized), never string interpolation.

// NextAuth — don't trust a JWT role claim forever for sensitive ops; re-fetch role from DB or use short expiry + rotation.
// Validate OAuth redirect is same-origin: const safe = url?.startsWith('/') ? url : '/dashboard'

// Stripe webhook — stripe.webhooks.constructEvent(rawBody, sig, secret); rawBody must be the Buffer, not parsed JSON.

// Uploads — validate MIME by magic bytes; serve user files from a different origin (SVG/HTML XSS); HMAC-signed expiring URLs.
```

## Anti-Patterns

- Client role check only · trusting client-supplied owner · secret in a client-imported util · stack traces to client · unbounded `findMany` (DoS) · SSRF via user URL in `fetch` · logging request body (PII/tokens) · path traversal (`./uploads/${name}` → `path.basename`) · mass assignment (`data: req.body` → pick fields) · ownership check AFTER mutation.

## Supply Chain
Commit lockfile · `npm audit --audit-level=high` in CI, block on critical · pin security-critical packages (NextAuth, Stripe) · `npm ci` in CI · review any new transitive dep touching network/fs/env.

## Sources
OWASP Top 10 (2021) A01/A03/A07; OWASP ASVS v4 L2; OWASP Proactive Controls; OWASP SSRF cheat sheet; NIST SSDF SP 800-218; Next.js Security docs; STRIDE; SLSA.
