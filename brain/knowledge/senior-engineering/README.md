# Senior Engineering Canon
> Стандарт senior-рівня, що діє завжди: конституція (ролі, інваріанти, DoD), 10 playbooks і активний enforcement у lint/CI.

The standard that makes every agent operate like a 15-year senior, and the agent
fleet operate like a full IT company (product · design · architecture · dev ·
security · QA · DevOps/SRE). Owner = CEO; agents = the company.

## Read order
1. **[CONSTITUTION.md](CONSTITUTION.md)** — master standard: roles, lifecycle, unbreakable invariants, Definition of Done, agent protocol. **Start here.**
2. Canon playbooks (detail, load on demand):
   - [01 — Code Craft & AI-Slop Prevention](01-code-craft.md)
   - [02 — Architecture & Decomposition](02-architecture-decomposition.md)
   - [03 — OOP & Design Principles](03-design-principles.md)
   - [04 — Secure-by-Design](04-security.md)
   - [05 — Test Strategy & Quality](05-testing-quality.md)
   - [06 — Full Lifecycle](06-lifecycle.md)
   - [07 — AI/LLM Engineering](07-ai-llm-engineering.md)
   - [08 — Frontend Quality (perf · a11y · i18n)](08-frontend-quality.md)
   - [09 — Reliability & Observability](09-reliability-observability.md)
   - [10 — Code Review Discipline](10-code-review.md)
3. **[ENFORCEMENT.md](ENFORCEMENT.md)** — how `[SELF]` rules become `[CI]` blocks (ratchet strategy, measured baseline). Owner-gated.

## How agents use it
Every task: **frame roles/phase → design (name seams, ADR) → build to craft+security standards → self-review for slop → run the full gate → separate reviewer pass → ship safely + record.** See CONSTITUTION §5.

## Relationship to existing skills
This canon is the *principles* layer. The domain OMC skills (backend-db-security-architect, frontend-ui-ux-mastery, tech-lead-reviewer, devops-qa-compliance, react-performance-core, github-agile-manager, …) are the *tooling* layer — they execute; the canon sets the bar they execute to.

Grounded in: Martin, Ousterhout, Parnas, Evans, Fowler, Richards/Ford, Metz, GoF, OWASP, NIST, Google SRE/Eng-Practices, Beck, Dodds, Cagan, Nielsen, WCAG, DORA/Accelerate, 12-Factor, Diátaxis.
