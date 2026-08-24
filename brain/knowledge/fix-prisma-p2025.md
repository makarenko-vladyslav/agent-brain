# Fix: Prisma P2025 "No record found for delete"
> Гонка конкурентних воркерів на видаленні: delete кидає P2025, ідемпотентна заміна — deleteMany.
**Дата:** 2026-04-28
**Проєкт:** проєкт (але applies globally)
**Теги:** prisma, race-condition, delete, p2025

## Проблема
Concurrent workers намагаються видалити один і той самий запис. `prisma.model.delete()` кидає `PrismaClientKnownRequestError` з кодом P2025 коли запис вже видалений.

## Рішення
```typescript
// ❌ WRONG — кидає P2025 при race condition
await prisma.message.delete({ where: { id } });

// ✅ CORRECT — ідемпотентний, повертає { count: 0 }
await prisma.message.deleteMany({ where: { id } });
```

Якщо потрібен повернений об'єкт:
```typescript
try {
  return await prisma.message.delete({ where: { id } });
} catch (e) {
  if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2025') {
    return null; // вже видалений
  }
  throw e;
}
```

## Де застосовувати
- Workers що працюють паралельно (preview-pool, sweeper, deep-content)
- Server Actions з concurrent users
- Будь-який delete де запис може бути видалений іншим процесом
- Також додати `onDelete: Cascade` на FK щоб уникнути orphaned records
