# 06 — Full Lifecycle: Idea → Ship → Operate → Maintain

> Senior cross-functional playbook. Think like PM + designer + SRE, not only a coder.

## Mandates by Lane

### PRODUCT
- **Problem-first**: write the problem statement before any spec. Can't say it in one sentence → you don't understand it.
- **Job-to-be-done**: frame every feature `When [situation], I want [motivation], so I can [outcome]`. No job → kill it.
- **Appetite over estimates** (Shape Up): fix the time budget; scope flexes, deadline doesn't. Won't fit → cut scope or kill.
- **Success metrics before coding**: 1 leading + 1 guardrail metric. No metric → no ship.
- **Cut scope, not quality**: remove whole features, never half-implement one.
- **MVP is a hypothesis test**, not a junior version — validate the riskiest assumption first.

### DESIGN / UX
- **Nielsen's 10 heuristics** as a checklist (system status, real-world match, user control, consistency, error prevention, recognition>recall, flexibility, minimalism, error recovery, help).
- **Design system or nothing**: new tokens (color/spacing/component) go into the shared system. No one-off hardcodes.
- **States are part of the spec**: empty, loading, error, success defined before build. Unspecced states become prod bugs.
- **Mobile-first**: design at 375px, scale up; test on real touch (coarse pointer), not emulation.
- **WCAG 2.1 AA min**: 4.5:1 contrast, keyboard nav, aria-labels on icon buttons, visible focus. Run axe/Lighthouse a11y pre-merge.
- **Error messages recoverable**: what went wrong + why + what to do. "Something went wrong" is a design failure.

### DELIVERY / DevOps
- **Trunk-based**: short-lived branches; feature flags gate incomplete work, not branches. *(In проєкт the trunk is `staging`: push only to `staging`, `main`=prod merged on owner command, never push `main` directly.)*
- **CI is the gatekeeper**: type-check + lint + tests + build before merge. Broken main = P0.
- **Staging = production minus data**: identical config/migrations/env. Never test only in prod.
- **Blue-green always**: keep old slot live until new passes health check. Rollback = traffic switch, not rebuild.
- **Migration safety**: never drop a column in the same deploy that removes its code (two-phase). Always `ADD COLUMN IF NOT EXISTS`. Test on a staging DB copy first.
- **Feature flags decouple deploy from release**: ship dark → 5%→20%→100%. Every flag has a kill switch.
- **Rollback is a documented procedure**, written before deploy.

### OPERATE / SRE
- **Three pillars**: logs (what), metrics (how much), traces (where time went). Missing one = blind spot.
- **Log levels**: DEBUG dev-only, INFO normal, WARN degraded, ERROR action-required. Never log PII.
- **SLO thinking**: define SLO (e.g. 99.5% <400ms), compute error budget; budget gone → freeze features, fix reliability.
- **Alerting actionable**: every alert has a runbook; alert on symptoms (latency, error rate), not causes (CPU%).
- **Incident protocol**: detect → ack (<5min) → **mitigate** (rollback/flag off) → investigate → blameless postmortem (<48h). Mitigate first, investigate after.

### MAINTAIN
- **Tech debt is a ledger**: each item a GitHub issue with blast radius + remediation cost; reviewed each cycle.
- **Dependency updates are routine**: audit weekly; critical CVE <24h, minor next sprint, major scheduled.
- **Docs that stay true** (Diátaxis: tutorial/how-to/reference/explanation); docs next to code get updated, wikis rot.
- **Deprecation protocol**: announce → in-code warning → support both 1 cycle → remove. Never remove without notice.
- **Type safety is maintenance insurance**: `tsc` pre-push gate; `@ts-nocheck` banned in prod, flagged in CI.

## Lifecycle Gate Checklist

| Gate | Before |
|---|---|
| Problem validated (JTBD + metric) | starting design |
| Appetite set (budget, MVP locked) | starting build |
| States specced (empty/loading/error/success) | starting build |
| Migrations staged (tested on staging copy) | deploying prod |
| Feature flag + kill switch | merging to main |
| Rollback documented | going live |
| SLO defined | first real traffic |
| Runbook written | alerting enabled |
| Postmortem filed (<48h) | closing incident |
| Debt item logged | shipping known debt |
| Deprecation notice | removing any public API |

## Anti-Patterns
"Add metrics later" (can't prove it worked) · "works on my machine" (staging parity) · drop column in one deploy · long-lived branches · alert without runbook · `@ts-nocheck` to unblock · one-shot hardcoded strings (no i18n) · polling instead of SSE · full E2E with real external services · commit before local build passes · big-bang debt sprint (interleave instead) · parallel agents on the same file without worktrees.

## Sources
Cagan *Inspired*; Basecamp *Shape Up*; Nielsen Norman heuristics; W3C WCAG 2.1; Forsgren/Humble/Kim *Accelerate* (DORA); Google *SRE Book*; *12-Factor App*; Diátaxis.
