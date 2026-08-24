# Fix: Preview анімації не працюють — HMR WebSocket origin rejection
> Анімації в preview не грали: Next.js 16 читає allowedDevOrigins '*' буквально, HMR-WebSocket відхиляється, React не гідрується, елементи лишаються прозорими.
**Дата:** 2026-04-29
**Проєкт:** проєкт
**Теги:** preview, docker, next.js, framer-motion, HMR, WebSocket

## Проблема
Згенеровані сайти у preview контейнерах показували фоновий малюнок та хедер, але весь контент з Framer Motion анімаціями (`initial={{ opacity: 0 }}`, `whileInView`) залишався невидимим.

## Причина
Next.js 16 трактує `allowedDevOrigins: ['*']` як literal string `'*'`, а не wildcard. HMR WebSocket з'єднання з `p-PORT.проєкт.46.225.105.129.sslip.io` субдоменів відхилялись → CSS/JS оновлення не доходили → React не гідрувався → елементи з `opacity: 0` не анімувались.

Додатково: `PREVIEW_HOST_DOMAIN` env var ніколи не передавалась в Docker контейнер через `docker-manager.ts`.

## Рішення
1. `next.config.mjs`: побудова `allowedDevOrigins` з `PREVIEW_HOST_DOMAIN` env var (`[*.HOST, https://*.HOST]`)
2. `docker-manager.ts`: передача `PREVIEW_HOST_DOMAIN` в контейнер Env
3. Перебілд Docker image обов'язковий бо `next.config.mjs` baked in at build time

## Супутні фікси
- Pool worker: промоушн `warm` тільки коли HTTP сервер відповідає (не лише Docker running)
- `checkAlive`: `return false` на Docker API error (замість `true`)
- `NODE_OPTIONS`: 768MB → 256MB (контейнер = 384MB, 768MB = OOM kill)
- `writeFile`: буфер pending writes замість fire-and-forget 2s retry
- Cleanup timeout: 15min → 60min (уніфікація з pool-worker)
- Session route: destroy Docker контейнер при видаленні DB запису

## Де застосовувати
- Будь-яка проблема з "порожнім" preview — перевіряти HMR WebSocket в browser devtools
- Коли міняєш template файли в `templates/site-nextjs/` — завжди перебілдовувати Docker image
- Next.js 16 `allowedDevOrigins` НІКОЛИ не підтримує `['*']` як wildcard
