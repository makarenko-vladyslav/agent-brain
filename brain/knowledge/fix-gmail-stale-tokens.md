# Fix: Gmail OAuth Stale Tokens (invalid_grant)
> Gmail invalid_grant: за яких умов Google відкликає refresh-токен і чому треба чистити токен, а не ретраїти вічно.
**Дата:** 2026-04-28
**Проєкт:** проєкт
**Теги:** gmail, oauth, tokens, auth

## Проблема
Gmail refresh token стає невалідним (invalid_grant), але код продовжує retry нескінченно замість очистки.

## Причина
Google revokes refresh tokens при: зміні паролю, 6+ місяців неактивності, ручному відкликанні, перевищенні ліміту (50 refresh tokens per user per client).

## Рішення
```typescript
// При отриманні invalid_grant — очистити stale tokens
try {
  const tokens = await oauth2Client.refreshAccessToken();
} catch (e) {
  if (e.message?.includes('invalid_grant')) {
    // Видалити збережені tokens з БД
    await prisma.userSettings.update({
      where: { userId },
      data: { gmailRefreshToken: null, gmailAccessToken: null }
    });
    // Юзеру потрібна повторна авторизація
    throw new Error('Gmail re-authorization required');
  }
  throw e;
}
```

## Де застосовувати
- Будь-яка OAuth інтеграція (Gmail, Google Calendar, Drive)
- Особливо для long-running workers що використовують refresh tokens
- Загальний патерн: detect invalid token → clear → request re-auth
