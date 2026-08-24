# Fix: Next.js Standalone Build Issues
> HTTP 500 після standalone-білду Next.js: биті артефакти .next і порядок залежностей, лікується чистою збіркою.
**Дата:** 2026-04-28
**Проєкт:** проєкт
**Теги:** nextjs, deploy, standalone, build

## Проблема
Next.js standalone build не працює на сервері — HTTP 500 "Invariant Error about missing client reference manifest".

## Причина
Corrupted `.next` артефакти від попереднього білду. Standalone mode вимагає чисту збірку.

## Рішення
```bash
# В deploy.sh — ЗАВЖДИ чистити перед build
rm -rf .next
npm run build
ls -la .next/standalone/server.js  # verify exists
```

## Пов'язані фікси
- `output: 'standalone'` в next.config — обов'язково
- Tailwind deps мають бути в `dependencies` (не devDependencies) для standalone
- Prisma client має бути згенерований ДО build: `prisma generate`
- Deploy order: `npm ci → prisma migrate deploy → prisma generate → next build`

## Де застосовувати
- Будь-який Next.js проєкт зі standalone deploy на VPS
- Якщо HTTP 500 на production після deploy — перше що перевірити
