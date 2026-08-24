# Конвенції — рішення які вже прийняті

Це НЕ принципи (ті в DNA.md). Це конкретні рішення які агент не може вивести сам.

## Код
- **Stack:** Next.js, React, TailwindCSS, Zustand (state), Prisma (ORM)
- **Architecture:** FSD strict (features/, entities/, shared/)
- **TypeScript:** strict, no `any`, max 200 рядків/файл
- **Design:** Dark Mode only, Emerald Neon accent (#10B981)
- **Abstraction first:** interface навіть для 1 імплементації

## Git
- Тільки `main`, без гілок (якщо юзер не просить)
- Batch push, не кожну дрібницю
- "На гіт" = verify → commit → push → update issues → close completed
- Commit messages: конкретні, lowercase, `feat:`, `fix:`, `refactor:`, `knowledge:`

## GitHub Issues
- Єдине джерело правди (не TODO.md)
- Naming: `[Категорія] Назва` українською, max 80 символів
- Labels (UA): `новий-функціонал`, `покращення`, `штучний-інтелект`, `баг`, `документація`

## AI промпти
- НІКОЛИ не змінювати назви/версії моделей
- Промпти не редагувати без дозволу
- Структурний код навколо промптів (Zod, parsing, retry) — можна

## Верифікація
- Завжди: `tsc --noEmit` + `vitest run` + `npm run build`
- Для змін логіки: + E2E + cleanup test data
- Не потрібно для: docs, configs, refactors без зміни поведінки

## Sessions / Sync (формати)

### LATEST.md (оновлювати при push або "готово")
```
**Date/Project/Agent**
## What was done (3-7 points)
## Key decisions
## What's next
```

### STATE.md (оновлювати при старті/завершенні)
```
## Active Sessions (таблиця: проєкт, що робить, файли, started)
## Recent Discoveries (last 5, FIFO)
## Cross-Project Insights Queue
```
