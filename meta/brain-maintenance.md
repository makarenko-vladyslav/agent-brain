# Brain Maintenance — Технічне обслуговування мозку

Протокол перевірки та оптимізації SuperBrain.

---

## 1. Коли запускати

- Юзер каже "перевір мозок", "оптимізуй brain", "що в тебе в голові?"
- Після великого рефактору або зміни стеку
- Коли помічаєш суперечність між правилами
- Рекомендовано: коли юзер просить, або коли помітив протиріччя/проблему

---

## 2. Чеклист обслуговування

### A. Правила (brain/rules/)
- [ ] Прочитати ВСЕ правила повністю
- [ ] Знайти суперечності → виправити (залишити актуальне)
- [ ] Знайти дублікати → merge в одне
- [ ] Перевірити Why — чи досі актуальна причина?
- [ ] Перевірити How to apply — чи працює в поточних реаліях?
- [ ] Видалити застарілі правила (не коментувати — ВИДАЛИТИ)

### B. Профіль (brain/profile.md)
- [ ] Стек актуальний? Нові технології додані?
- [ ] Активні проєкти — чи не з'явились нові / закрились старі?
- [ ] Стиль роботи — чи не змінились преференції?

### C. Скіли (skills/)
- [ ] README.md — чи всі скіли зареєстровані?
- [ ] Тригери — чи актуальні description полів?
- [ ] Мертві скіли — є скіли що ніколи не використовуються? → питати юзера чи видаляти
- [ ] Інструменти в скілах — чи не deprecated?
- [ ] Нові скіли — чи потрібні нові на основі останніх задач?

### D. Meta (meta/)
- [ ] Протоколи — чи працюють як описано?
- [ ] Чи не потрібні нові протоколи?

### E. CLAUDE.md (bootloader)
- [ ] Таблиця маршрутизації скілів — чи повна?
- [ ] Протокол ініціалізації — чи актуальний?
- [ ] Суперечності з brain/rules/ — бути не повинно

---

## 3. Операції обслуговування

### Merge правил
Коли два правила кажуть про одне:
1. Вибрати файл що більш загальний → він стає основним
2. Перенести унікальний контент з другого
3. Видалити другий файл
4. Commit: `brain: merge <old> into <main>`

### Видалення застарілого
Коли правило або скіл більше не актуальне:
1. Перевірити чи точно не використовується
2. Видалити файл повністю (не коментувати)
3. Оновити README / CLAUDE.md посилання
4. Commit: `brain: remove obsolete <name>`

### Upgrade скіла
Коли інструменти або best practices змінились:
1. Прочитати поточний SKILL.md
2. Оновити конкретні секції
3. НЕ переписувати все — тільки те що змінилось
4. Commit: `skills: update <name> — <що змінено>`

---

## 4. Звіт обслуговування

Після завершення maintenance — показати юзеру короткий звіт:

```
Brain Maintenance — <дата>
- Rules: X перевірено, Y оновлено, Z видалено
- Skills: X перевірено, Y оновлено, Z створено
- Profile: оновлено / без змін
- Суперечності: знайдено X, виправлено X
```

---

## 5. Audit Log

### 2026-04-28 — Full Audit (перший)
**Scope:** повний аудит всіх компонентів SuperBrain

**Rules (9/9 перевірено):**
- Виправлено 4 протиріччя (workflow↔ai-prompts, verify↔batch, close↔E2E, knowledge↔issues)
- Додано error recovery protocol
- Додано дедуплікацію з GitHub Issues
- Стандартизовано формат: tags, dates, cross-references

**Knowledge (13 → 12, +4 нових):**
- Видалено 5 obsolete/data-dumps, створено 1 consolidated (reference-personal-insights)
- Створено: knowledge index (README), global scaling strategy, ADR проєкт architecture
- Створено 3 fix-* файли (prisma-p2025, deploy-standalone, gmail-stale-tokens)

**Skills (19/19 перевірено):**
- content-pipeline-orchestrator: переписано з архітектурного документа в executable skill
- README.md: додано anti-triggers та skill combinations
- apple-scroll merged в frontend-ui-ux-mastery (без видалення)
- skill-engineering: виправлено стейл paths, додано canonical ref
- youtube-search-explorer: виправлено стейл script path

**Profile:** додано last verified date, оновлено scaling goal (global)

**CLAUDE.md:** усунено дублювання routing table та Skill Forge protocol

**Meta:** tool-inventory.md — виправлено YouTube Search path

**Baseline metrics:**
- 9 rules, 12 knowledge files, 19 skills, 5 meta docs
- 0 протиріч, 0 стейл paths, 0 дублювань
