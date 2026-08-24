# Claude CLI Pipeline Issues & Fixes (April 2026)
> Чому Claude CLI віддає порожньо: CLAUDE.md перебиває формат відповіді, ліміт ARG_MAX, гонка stdin, обрізаний JSON. З обхідними шляхами.

## Problem: Claude CLI subprocess gives empty output intermittently

### Root causes found:
1. **CLAUDE.md interference** — project CLAUDE.md says "respond in Ukrainian", Claude returns Ukrainian text instead of JSON
2. **ARG_MAX limit** — `-p` argument hits OS limit (~262KB) for large prompts
3. **stdin timing** — Node.js spawn stdin.write() + stdin.end() race condition
4. **Token output limit** — Large JSON (3000-word script in JSON field) gets truncated

### Working solution:
```typescript
// Write prompt to temp file, pipe via shell redirect
const tmpFile = join(tmpdir(), `відео-пайплайн-prompt-${Date.now()}.txt`);
await writeFile(tmpFile, fullPrompt);
const result = await runShell(
  `claude --print --model sonnet --system-prompt '...' < '${tmpFile}'`,
  timeout,
);
```

- `--system-prompt` REPLACES default prompt (overrides CLAUDE.md)
- File redirect `< file` is more reliable than `cat | pipe`
- Add JSON instruction at END of prompt (not just system prompt) — Claude "forgets" system prompt for large outputs
- `repairTruncatedJSON()` for handling truncated responses
- Accept stdout even with non-zero exit code if content > 50 chars

### Pollinations.ai rate limits:
- Free tier: ~1 request per 15-90 seconds
- 429 Too Many Requests on concurrent requests
- Fix: concurrency=1 + retry with 30/60/90s backoff
