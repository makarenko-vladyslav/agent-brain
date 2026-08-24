# Cross-Project Sync — Синхронізація між агентами та проєктами

Протокол для забезпечення повної обізнаності усіх агентів.

---

## 1. Принцип: Один мозок — багато рук

Усі агенти (проєкт, відео-пайплайн, будь-який новий проєкт) — це ОДИН і той самий AI з ОДНИМ SuperBrain. Не "агент для проєкт" і "агент для відео-пайплайн" — а один AI що працює на різних проєктах.

---

## 2. Boot Sequence (при кожному старті)

```
1. Read ~/Projects/SuperBrain/CLAUDE.md (bootloader)
2. Read ~/Projects/SuperBrain/brain/profile.md (хто юзер)
3. Read ~/Projects/SuperBrain/brain/rules/ (як працювати)
4. Read проєктний CLAUDE.md (специфіка проєкту)
5. Classify task → Load relevant skills/
6. Check brain/knowledge/ для релевантних записів
```

---

## 3. Knowledge Flow між проєктами

### При вирішенні проблеми
```
проєкт агент знайшов рішення
  → Записав в SuperBrain/brain/knowledge/
  → Commit + push
  → відео-пайплайн агент при наступному старті бачить це рішення
```

### При отриманні feedback
```
Юзер дав корекцію в відео-пайплайн
  → Визначити: це глобальне чи проєктне?
  → Глобальне → SuperBrain/brain/rules/ + commit + push
  → Проєктне → відео-пайплайн/CLAUDE.md
```

### При створенні скіла
```
Новий скіл створений в контексті проєкт
  → SuperBrain/skills/<name>/SKILL.md
  → Доступний для ВСІХ проєктів одразу
```

---

## 4. Що зберігати глобально vs локально

| Тип інформації | Де |
|---|---|
| Стиль роботи юзера | `SuperBrain/brain/profile.md` |
| Правила роботи | `SuperBrain/brain/rules/` |
| Best practices & рішення | `SuperBrain/brain/knowledge/` |
| Скіли | `SuperBrain/skills/` |
| Протоколи | `SuperBrain/meta/` |
| Серверні адреси/ключі | Проєктний `CLAUDE.md` |
| Специфічні API/tools | Проєктний `CLAUDE.md` |
| GitHub Issues категорії | Проєктний `CLAUDE.md` |
| Бізнес-логіка проєкту | Проєктний `CLAUDE.md` |

---

## 5. Awareness Protocol

### Що агент МАЄ знати
- Всі активні проєкти юзера та їх стан
- Персональні преференції та стиль роботи
- Всі доступні інструменти (MCP, CLI, Built-in)
- Всі скіли та коли їх використовувати
- Всі правила та протоколи
- Нещодавні відкриття та рішення (brain/knowledge/)

### Як бути завжди в курсі
1. **Boot Sequence** — завантажує базовий контекст
2. **brain/knowledge/** — contains cross-project learnings
3. **git log** SuperBrain — показує що змінилось нещодавно
4. **GitHub Issues** — стан задач по проєктах
5. **Google Calendar** — що заплановано
6. **Gmail** — що відбувається в комунікаціях

---

## 6. Проактивний Sync

Агент не чекає запиту — сам слідкує:
- Якщо рішення в одному проєкті може допомогти іншому → згадати про це
- Якщо знання застарілі → оновити
- Якщо юзер питає щось про інший проєкт → знати контекст, не перепитувати
- Якщо є вільні інструменти що можуть допомогти → запропонувати

---

## 7. NotebookLM як глибока пам'ять

Для знань що потребують queryable storage (дослідження, стратегії, довгі документи):

```bash
# Створити ноутбук для SuperBrain
nlm notebook create "SuperBrain Knowledge Base"

# Додати джерело (research document, article, etc.)
nlm source add <notebook-id> --type text --content "..."

# Запитати знання
nlm query <notebook-id> "питання"

# Cross-notebook query (всі ноутбуки)
nlm cross query "питання"
```

Ідеально для: research findings, strategy documents, market analysis, competitive intelligence.
