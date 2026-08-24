# Quality Gates — testable assertions для кожного правила

Кожне правило в `brain/rules/` має автоматичну перевірку. AI агент запускає gates після завершення задачі.

---

## Gate Matrix

| Rule | Assertion | Command | Pass Criteria |
|---|---|---|---|
| **communication** | Відповідь українською | — | Мова відповіді = UA |
| **communication** | Не довше 5 речень на блок | — | Max 5 sentences per paragraph |
| **workflow** | Код не перед планом | — | Code phase only after explicit approval |
| **code-quality** | No `any` types | `grep -rn ': any' --include='*.ts'` | 0 results in new code |
| **code-quality** | Max 200 lines | `wc -l <changed-files>` | All files ≤200 lines |
| **code-quality** | FSD structure | `ls features/ entities/ shared/` | Directories exist |
| **verification** | TypeScript clean | `npx tsc --noEmit` | Exit code 0 |
| **verification** | Tests pass | `npx vitest run` | Exit code 0 |
| **verification** | Build succeeds | `npm run build` | Exit code 0 |
| **git-deploy** | Main branch | `git branch --show-current` | = "main" |
| **git-deploy** | Issues updated | `gh issue list --state open` | Relevant issues closed |
| **ai-prompts** | Models untouched | `git diff --name-only \| grep -i model` | 0 model config changes |
| **github-issues** | UA naming | — | Issue titles in Ukrainian |
| **multi-agent** | No overwrite | `git diff --name-only` | Only task-relevant files |
| **knowledge-capture** | Knowledge saved | `git log --oneline -1` | Contains "knowledge:" if significant |
| **token-budget** | MCP count | — | ≤10 active MCP servers |
| **cross-agent-sync** | STATE updated | `cat brain/sync/STATE.md` | Current session listed |
| **session-continuity** | LATEST updated | `cat brain/sessions/LATEST.md` | Today's date |
| **goal-tracking** | Goals referenced | `cat brain/goals/ACTIVE.md` | Progress updated |

---

## When to Run

### Auto (after every task completion)
Quick gates (no commands needed):
- Communication language = UA ✓
- Code phase follows plan ✓
- Response length reasonable ✓

### Before Push (pre-push checklist)
```bash
npx tsc --noEmit && npx vitest run && npm run build
```

### After Session (session-end checklist)
- [ ] STATE.md updated
- [ ] LATEST.md updated  
- [ ] ACTIVE.md goals checked
- [ ] USAGE_LOG.md updated (if skill used)
- [ ] Knowledge captured (if significant discovery)

---

## Failure Protocol

Gate failed → DO NOT ask user. Fix it yourself:
1. Identify which gate failed
2. Read the corresponding rule file
3. Fix the violation
4. Re-run gate
5. Only if 3 attempts fail → escalate to user

---

## Gate Severity

| Level | What happens on failure |
|---|---|
| **BLOCK** | Cannot push/complete until fixed (tsc, tests, build) |
| **WARN** | Log warning, continue (MCP count, file length) |
| **INFO** | Note for improvement (communication style) |
