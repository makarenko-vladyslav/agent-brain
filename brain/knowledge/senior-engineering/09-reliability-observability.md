# 09 — Reliability, Resilience & Observability

> Senior backend/SRE playbook. Stack: Next.js/Prisma/Postgres/Redis, background workers (CAS-claim, leader-lock via pg advisory), SSE (Redis pub/sub), expensive AI calls, blue-green, Telegram alerting.

## Mandates

### Resilience
- **[SELF] MUST** timeout every I/O — HTTP, DB, Redis, AI, Puppeteer. No call without a deadline (AI 10min `AI_STREAM_TIMEOUT_MS`, DB 30s, Redis 5s, webhooks 15s).
- **[SELF] MUST** retry only idempotent ops with exponential backoff + full jitter. Email/payment/Telegram retry ONLY after checking an idempotency key.
- **[SELF] MUST** write an idempotency key before any side-effect: `INSERT ... ON CONFLICT (idem_key) DO NOTHING RETURNING id` — null → skip.
- **[SELF] MUST** CAS-claim every worker job: `UPDATE jobs SET status='processing' WHERE id=$id AND status='pending'` — 0 rows = someone else has it.
- **[SELF] MUST** leader-lock singleton jobs (`pg_try_advisory_lock`), release in `finally`.
- **[SELF] MUST** dead-letter after N retries + Telegram alert; never silently discard.
- **[SELF] MUST** circuit-breaker every flaky external (Serper, Higgsfield, Gmail, AI): open after 5 fails/60s, half-open probe after 30s, state in Redis (cross-instance).
- **[SELF] MUST** emit workflow events AFTER the transaction commits (emit-after-settle); dispatchEvent idempotency-guarded to survive blue-green race.

### Error Handling
- **[SELF] NEVER** swallow: no `catch(e){}` or `catch(e){ console.log(e) }`. Every catch = structured log + rethrow OR explicit handle + metric.
- **[SELF] MUST** fail loud — unexpected worker state throws, never silent `return null`.
- **[SELF] MUST** typed errors (`AppError { code; retryable }`); check `retryable` before scheduling a retry.
- **[SELF] MUST** user-facing generic + `ref: correlationId`; full detail server-side only. React error boundary per route.

### Observability
- **[SELF] MUST** structured JSON logs: `{ ts, level, service, correlationId, projectId?, jobId?, userId?, msg, ...ctx }`. No bare interpolated strings.
- **[SELF] MUST** correlation ID at the edge (middleware), threaded via `AsyncLocalStorage`.
- **[SELF] NEVER** log PII (emails/phones/names) — log entity IDs.
- **[SELF] MUST** symptom-based alerts (job stuck, error-rate) not cause-based (CPU); every alert links a runbook.

## Resilience Patterns → When to Apply
| Pattern | When | проєкт touchpoint |
|---|---|---|
| Timeout | every I/O | AI stream, DB `statement_timeout`, Redis |
| Retry+jitter | idempotent transient (429/503) | AI gen, Serper, Higgsfield poll |
| Circuit breaker | flaky external | Serper, Gmail, AI, Higgsfield |
| Bulkhead | isolate slow from fast | separate queues (ai-gen/email/analysis), pools web 10 / worker 15 |
| Idempotency key | side-effect must not duplicate | email, payment, Telegram, event dispatch |
| CAS-claim | worker claims shared row | every pending→processing |
| Leader-lock | exactly-one global job | nightly agents, cron |
| Dead-letter + alert | N failures, no recovery | retry budget exhausted → SYSTEM alert |
| Graceful degradation | optional feature, external down | monitoring down → skip+alert; gen continues without AI images |
| Fallback | critical path, external down | AI fails → cached prior result + retry CTA |

## What to Instrument (concrete)
- **State transitions:** `workflow.event.dispatched/skipped_duplicate`, `job.claimed/completed/failed/dead_lettered`, `leader_lock.acquired/skipped`.
- **AI (cost = observability):** `ai.call.start/complete/error/timeout` with `inputTokens, outputTokens, thinkingTokens, costUsd` — track thinking-tokens separately (they're billed and easy to miss).
- **Payment/Auth:** `payment.initiated/completed/failed`, `auth.login`, `auth.secret_missing` (P0).
- **RED metrics per job type:** rate, error-rate (alert >5%/5min), duration p50/p95/p99.
- **SSE:** `sse.publish/subscribe/stale_detected`.
- **Alert severity:** CRITICAL (dead-letter, payment fail, secret missing, pool exhausted) · ERROR (breaker open, worker crash, migration fail) · WARN (AI cost > $X, p95 breach, DLQ>0). Body: `{ severity, category, projectId?, jobId?, msg, runbookUrl }`.

## Host-Level Triage (single box: Hetzner, 3.7GB RAM / 38GB disk)

App-level instrumentation above tells you *that* something broke; this tells you *where* on the machine. USE method (Brendan Gregg) per resource — Utilization, Saturation, Errors — in this order:

1. **CPU — read Load Average, not `%CPU`.** The three numbers are 1/5/15-min averages; the trend between them says whether it's growing or draining. On Linux LA counts **uninterruptible (D-state) tasks too**, not just runnable — which is why "LA 200 but the box feels fine" is possible: those tasks are blocked on I/O, not burning CPU. Never alert on `%CPU` alone (cause-based, see Mandates).
2. **`wa` (iowait) in `top`** — CPU fine, RAM fine, everything crawls → the CPU is *waiting on disk*. Usual suspect: the database. This is the failure mode that looks like "the server is slow" and has nothing to do with the server being busy.
3. **Memory & the OOM killer.** When RAM runs out the kernel picks a victim by `oom_score` (roughly: biggest RSS wins) and kills it — the process just vanishes, no stack trace, no app-level log. Symptom: a worker "disappeared". Check `dmesg`/journal for the kill line before hunting a phantom bug. A critical process can be protected via `oom_score_adj`. **On a 3.7GB box this is a live risk, not trivia** — a build and a Chromium render at the same time is enough.
4. **Disk: `df` then `du`.** `df` for the whole picture (which partition), `du` inside it to walk down to the offender — usually one log file that nobody rotated. Space always runs out, always at the worst time.
5. **Inodes — the trap.** `df` says space is free, the system says disk full → **inodes exhausted**, not bytes. Happens with millions of tiny files (caches, session files, unrotated per-request logs). Different counter, different fix; `df -i` is the only thing that shows it.
6. **Ports.** "Address already in use" after a failed deploy → find the holder with `ss -ltnp` before killing anything. In blue-green this usually means the old slot never died.
7. **Config reload ≠ restart.** `restart` kills the process and drops every open connection; `reload` re-reads config in place and keeps them. For a proxy in front of prod (Caddy/nginx) always reload — restarting to apply a one-line change is a self-inflicted outage.

**Process states worth recognizing:** *zombie* — process is gone but its entry remains in the table (parent never reaped it; harmless in ones, a leak in thousands). *Orphan* — parent died first, `init`/systemd adopts it. Both are read from `/proc`, the pseudo-filesystem that `ps`/`top` themselves read — when a tool lies, `/proc` is the ground truth.

**Scope boundary — deliberate.** This stack is one box: systemd units + Caddy + GitHub Actions building artifacts. Kubernetes, Ansible, Terraform and service meshes solve fleet problems this project does not have; adding them buys operational cost and no reliability. Revisit only when there is more than one machine to keep in sync.

## Anti-Patterns
silent `catch → return null` · retry non-idempotent without key · cause-based alert ("CPU>80%") · emit inside transaction · `setInterval` poll (use SSE) · single pool for all workloads · log PII · no correlation ID · no timeout on AI stream · double-fire workflow event (emit before write).

## Sources
Nygard *Release It!* (timeout, circuit breaker, bulkhead, idempotency, dead-letter); Google *SRE Book/Workbook* (SLO, symptom alerts); Kleppmann *DDIA* (CAS, idempotency, exactly-once); AWS Builders' Library (backoff+jitter, leader election); Brendan Gregg (USE method); OpenTelemetry (structured logs, correlation propagation).
