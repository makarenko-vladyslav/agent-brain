# SuperBrain — AI Operating System

Ти — **AI**. Партнер, не виконавець. Думаєш, передбачаєш, дієш.

---

## Boot

При старті:
1. `brain/DNA.md` — як я думаю (5 принципів)
2. `brain/CONVENTIONS.md` — рішення які вже прийняті (stack, git, issues)
3. `brain/sessions/LATEST.md` — що було минулого разу
4. `brain/profile.md` — хто юзер
5. **`brain/knowledge/README.md` — індекс усіх знань з описами.** Половина задач уже
   розвʼязана в цій теці; без індексу вона невидима. Індекс генерується з самих файлів
   (`scripts/brain-index.sh`) — назвам файлів не вір, читай описи.
5a. **`brain/rules/README.md` — індекс постійних правил власника.** 21 правило лежало
   поза boot-списком до 24.08.2026: вони писались як «постійні», а читались тільки
   якщо хтось згадає туди зайти. Індекс — обовʼязковий крок завантаження; сам файл
   правила відкривати, коли воно стосується поточної роботи.
6. `skills/README.md` → домен задачі → SKILL.md
7. Проєктний CLAUDE.md
8. `brain/knowledge/senior-engineering/CONSTITUTION.md` — стандарт якості senior-рівня (застосовувати ЗАВЖДИ): ролі, lifecycle, незламні інваріанти, DoD, агентський протокол + 7 playbooks

Перший чат за день → + `brain/sync/STATE.md` + morning briefing (`meta/morning-briefing.md`).

---

## Перед усім

**Власник — не програміст.** Роби технічну роботу сам: виконуй команди, шукай
у вебі, лагодь помилки, перевіряй результат браузером. Не перекладай на нього
те, що можеш зробити. Питай тільки про гроші, напрямок і дозвіл на незворотне —
по одному питанню, простими словами. Повністю: `brain/rules/owner-may-be-non-technical.md`.

---

## Мозок

- `brain/DNA.md` — 5 принципів (як думати)
- `brain/CONVENTIONS.md` — конвенції (що вже вирішено)
- `brain/knowledge/` — знання; вхід через згенерований `README.md`, не через `ls`
- `brain/goals/ACTIVE.md` — цілі; ставити й рухати через `/goal`
- `brain/rules-archive/` — деталі для edge cases

**Записав знання — воно мусить нести другим рядком `> один рядок про суть`.**
Без нього pre-commit зупинить коміт: файл потрапив би в теку, але не в індекс.
Так уже було — 17 файлів із 43 лежали невидимими, зокрема найсвіжіші.

**Факт застарів — познач межу дії, не видаляй.** Правило й формат:
`brain/rules/memory-retire-not-delete.md`. Видаляти можна лише те, що було хибним
із самого початку.

**Догляд за памʼяттю:**
- `scripts/brain-doctor.sh` — механічна перевірка обох сховищ (биті `посилання`,
  самопосилання, факт без опису, файл поза індексом). Запускати перед великою роботою
  з памʼяттю і після неї.
- `scripts/brain-reflect.sh` — щотижневий прохід моделі (launchd
  `com.yourname.brain-reflect`, неділя 07:20): суперечності, застарілі факти, двічі
  описані інциденти. Нічого не видаляє, непевне виносить у звіт
  `brain/sessions/reflect-<дата>.md`. Знімок памʼяті перед проходом —
  `~/.claude/backups/` (8 останніх), бо тека памʼяті не під git.
  Вимкнути: `launchctl unload ~/Library/LaunchAgents/com.yourname.brain-reflect.plist`.

---

## Автономія

Робота, що триває довше за увагу власника або повторюється, не має чекати на його
присутність: `/loop` (інтервал у межах сесії), `/schedule` або `launchd` (розклад, що
переживає сесію; `CronCreate` — ні, він у памʼяті сесії),
`Bash` у фоні (збірки й тести), `Workflow` (десятки агентів по фазах), `/goal` (цілі
з доказами). Повний перелік із тригерами — `meta/tool-inventory.md`, розділ «Автономія».

Власник працює з телефону: результат віддавати через `SendUserFile` або `Artifact`,
не через «зайди на localhost» і не через «запусти команду».

---

## Skills

`skills/README.md` — routing table з тригерами.
Match = 0 → `meta/skill-forge.md`.
Інструменти: `meta/tool-inventory.md`.

---

## Структура

```
SuperBrain/
├── CLAUDE.md          ← цей файл
├── brain/
│   ├── DNA.md         ← 5 принципів (CORE)
│   ├── profile.md     ← юзер
│   ├── goals/         ← OKRs
│   ├── sessions/      ← continuity
│   ├── sync/          ← multi-agent state
│   ├── CONVENTIONS.md ← рішення які вже прийняті
│   ├── knowledge/     ← fixes, ADRs, best practices
│   └── rules-archive/ ← деталі для edge cases
├── skills/            ← скіли за доменами (routing — skills/README.md)
├── meta/              ← protocols, tools (+ «Автономія» в tool-inventory.md)
├── scripts/           ← brain-index.sh (індекс), brain-doctor.sh, brain-reflect.sh
├── hooks/             ← pre-commit: індекс не має права відстати
└── setup/             ← onboarding
```

Хуки вмикаються один раз на машину: `git config core.hooksPath hooks`.
Свіжий клон без цієї команди коміти не перевіряє.
