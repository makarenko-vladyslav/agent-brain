# BP: Автоматичний quality-gate перед пушем (lefthook + CI)
> Два рубежі якості: локальний lefthook (Go, паралельний, без Node) плюс CI. Чому верифікація за дисципліною не масштабується.

**Проблема:** «верифікація за дисципліною» (памʼятати запустити tsc/lint/test) не масштабується — помилки прослизають у git. Особливо коли пушать і люди, і AI-агенти.

**Рішення: два рубежі (defense-in-depth).**

## 1. Локальний — lefthook
Чому lefthook, не husky (best-practice 2026): Go-бінарник без Node-залежності, **паралельний запуск (~10x швидше)**, один YAML замість husky+lint-staged, self-install.

`lefthook.yml`:
```yaml
pre-commit:        # ШВИДКЕ на staged (секунди)
  parallel: true
  commands:
    lint-fix:
      glob: "*.{ts,tsx,js,jsx,mjs,cjs,mts}"
      run: npx eslint --fix --no-warn-ignored {staged_files}
      stage_fixed: true
pre-push:          # ПОВНЕ на проєкті (~25с), паралельно
  parallel: true
  commands:
    typecheck: { run: npx tsc --noEmit }
    lint:      { run: npx eslint }
    test:      { run: npx vitest run }
```
Self-install: `"prepare": "lefthook install"` у package.json → активний після `npm install` у кожному клоні. Нічого памʼятати.

## 2. CI — невідходний рубіж
Локальний хук обходиться `git push --no-verify` → CI ОБОВʼЯЗКОВИЙ. GitHub Actions job `tsc → lint → test` (fail-fast) на всіх робочих гілках + PR. Важке (build/E2E) → CI, бо локально повільне/крихке.

## Розподіл навантаження (best-practice)
pre-commit = lint/format (staged) · pre-push = typecheck+lint+test (повне) · CI = усе + build + E2E.

## Філософія порогів (важливо для legacy кодбаз)
- **ERRORS=0 блокують** — реальні баги (type-errors, падіння тестів, rules-of-hooks, syntax).
- **WARNINGS видимі, не блокують** — code smells, що НЕ ламають runtime (tsc=0, тести зелені). Чистяться поступово (ratchet), не блокують масовим рефактором.

Типове вилизування при першому вмиканні lint у CI:
- тести/скрипти: `no-explicit-any` off (any у моках — норма; часто 80%+ усіх «errors»)
- boundary any (XML/JSON/postMessage/ORM Json) + lazy require → warn
- React Compiler діагностики (eslint-plugin-react-hooks v6) → warn (оптимізаційні хінти, не баги; масовий рефактор UI без E2E = ризик регресій)
- виправити РЕАЛЬНІ: rules-of-hooks, prefer-const, no-unescaped-entities

## Універсальний інсталятор
`setup-quality-gate.mjs` (у одному проєкті `scripts/`): детектить package manager (lock-файл) + наявні скрипти (typecheck|tsc/lint/test), ставить lefthook, генерує `lefthook.yml`, додає self-install `prepare`+`typecheck`+`verify`. Ідемпотентний. Копіювати в будь-який Node-проєкт і запускати в корені.

## Граблі
- **Зворотний бік self-install (проєкт, 14.08.2026):** `npm ci` у CI виконує той самий `prepare: lefthook install`, тож хуки діють **усередині раннера GitHub**. Крок, що робить `git commit`/`git push` (bump версії у `deploy-production.yml`), запускає повний pre-push із vitest — 11 хв, job упирається в `timeout-minutes` і завершується cancelled, при цьому виглядає як успішний деплой. Фікс: `env: LEFTHOOK: "0"` + `--no-verify` на такому кроці (стало 1 с). Повний розбір інциденту — памʼять проєкту `bug_ci_lefthook_hangs_deploy`.
- lefthook ставить hook у СПІЛЬНИЙ `.git/hooks` (worktree ділить з головним репо). БЕЗ lefthook.yml hook gracefully skip (exit 0) — паралельні worktree не ламаються. Global `core.hooksPath` НЕ чіпати.
- Локальний `next build` НЕ в pre-push (конфліктує з dev `.next`) — лише CI.
- Перевір gate обома способами: навмисна помилка → exit≠0 (блокує); чисто → exit 0.

**Першоджерело:** проєкт, гілка feat/quality-gate, `docs/QUALITY-GATE.md` (2026-06).
