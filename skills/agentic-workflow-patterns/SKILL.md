---
name: agentic-workflow-patterns
description: Патерни ефективних промптів і воркфлоу Claude Code (офіційна prompt library) — формулювання задач, verification loops, розпізнавання розмитих запитів, автоматизація повторів через skills/hooks/CLAUDE.md
metadata: {"tags": ["prompts", "workflow", "claude-code", "automation", "verification", "sdlc"], "source": "https://code.claude.com/docs/en/prompt-library", "learned": "2026-07-03"}
---
### ROLE: Майстер agentic-воркфлоу
**Focus**: розпізнавати за короткою командою юзера повний патерн роботи, будувати собі verification loops, і перетворювати повтори на автоматизацію.

### 6 МЕТА-ПАТЕРНІВ (ядро — чому промпти працюють)

1. **Outcome, не кроки.** Юзер каже ЩО, агент сам знаходить файли. «add rate limiting to the public API and make sure existing tests still pass» — без жодного шляху.
2. **Verification loop у тому ж запиті.** write + run + fix / implement + screenshot + compare + iterate. Агент ітерує сам, а не зупиняється після першої спроби. ЦЕ ГОЛОВНИЙ ПАТЕРН.
3. **Референс замість опису.** «зроби X так само як Y» — без референсу агент дефолтить до general best practices; з референсом — матчить конвенції кодбази.
4. **Вимірювана ціль = definition of done.** «p95 з 2s до <500ms», «coverage >80%», «bundle <200KB» — завершення однозначне; ідеально для /goal-циклів.
5. **Артефакт замість переказу.** Помилка/лог/скріншот/plan-вивід вставляється напряму (@-mention) — агент читає джерело, не інтерпретацію юзера.
6. **Формат відповіді назвати одразу.** «як HTML-сторінку з діаграмою і відкрий у браузері», «списком», «для PM-рівня».

### КАТАЛОГ ПАТЕРНІВ ПО SDLC (52 промпти → формули)

**DISCOVER (розібратися)**
- Огляд репо: `overview of this codebase: architecture, key directories, how pieces connect` → далі /init → CLAUDE.md
- Пояснити код: `explain what {path} does and how data flows` + формат відповіді
- Пошук за поведінкою (не за іменем файлу): `where do we {behavior}?`
- Blast radius перед видаленням: `what would break if I deleted {target}?`
- Еволюція через git history: `look through the commit history of {path}, summarize how it evolved and why` — коли питання ЧОМУ, не ЩО
- Оцінка обсягу до старту: `which files would I need to touch to {change}?` — 1 компонент чи cross-cutting
- Продуктове питання до коду: `I am a {role}. walk me through what happens when user {action}, from UI down to result`

**DESIGN (спланувати)**
- План без редагування: `plan how to refactor {target} to {goal}. list files, don't edit yet` (= plan mode Shift+Tab)
- Спека через інтерв'ю: `I want to build {feature}. interview me about implementation, UX, edge cases, tradeoffs until we covered everything, then write SPEC.md` — агент ставить питання, юзер не пише спеку сам
- Мітинг → тікети: `read {notes}, write action items, create a ticket for each with acceptance criteria`
- Мапа edge cases ДО дизайну: `list the error states, empty states, and edge cases for {feature}` — питати чого БРАКУЄ, не що є
- Мокап → клікабельний прототип: працюючий код відповідає на питання, які статичний мокап не може
- Скріншот → імплементація з self-check: `implement this design, screenshot the result, compare to original, fix differences` — verification loop без юзера

**BUILD (зробити)**
- За існуючим патерном: `look at how {example} is implemented, then build {new} the same way`
- Issue end-to-end: `read issue #{n}, implement the fix, run the tests` — давати НОМЕР, не переказ (вимоги не губляться)
- Копірайт по всій базі: `find every place we say "{copy}" or a close variant, show each in context, update all to "{new}". leave tests and changelog alone` — варіанти + що пропустити
- Драфт зі своїх прикладів: `read the {examples} in {folder} to learn structure and voice, then draft a new one for {topic}`
- Тести: `write tests for {path}, run them, fix failures` (одним запитом!) · TDD: `write tests first, then implement until they pass` · Coverage-driven: `read {coverage report}, add tests for lowest-covered files until each >{n}%`
- Міграція патерну: `migrate everything from {old} to {new}: identify every place first, then change` — список call sites у відповіді = можна перевірити повноту
- Портування: `port {source} to {lang}, keeping the same {public API / test behavior}` — назвати ЩО зберегти = контракт для перевірки
- Оптимізація: `optimize {target} to bring {metric} from {current} to under {goal}`
- Точковий візуальний баг: елемент + вимір + контейнер + вьюпорт («login button extends 20px beyond card border on mobile»)

**REVIEW / STEER (контроль)**
- Перед комітом: `review my uncommitted changes, flag anything risky` — агент читає файли повністю, не тільки diff
- PR: `review PR #{n}, summarize what changed, list concerns` — рев'ю з контекстом усієї кодбази
- Security через субагента: `use a subagent to review {path} for security issues` — довгий аудит не з'їдає основний контекст
- Terraform/infra plan: вставити вивід → «what is this going to do, will anything cause problems?»
- Корекція курсу: `that is not right: {named constraint}. try a different approach` — НАЗВАТИ пропущене обмеження, не просто «неправильно»
- Звузити обсяг: `too much. keep only changes to {scope}, undo the rest` — межа рятує від рефактора-лавини
- **Повторювана помилка → правило: `you keep {mistake}. add a rule to CLAUDE.md so this stops happening`** — корекція в чаті не шариться, правило в CLAUDE.md читається кожну сесію

**SHIP (відвантажити)**
- Merge conflicts: `resolve the conflicts and explain what you kept from each side` — reasoning робить merge рев'юваним
- Commit: повідомлення з diff, у стилі репо
- Тікет → PR: `find the ticket about {topic} and open a PR that implements it` — без перемикання контекстів
- Release notes: `compare {v1} to {v2}, draft release notes grouped by feature/fix/breaking`
- CI: описати КОЛИ і ЩО — YAML генерується під команди проєкту

**OPERATE (експлуатація)**
- Падаючий тест: `the {name} test is failing, find out why and fix it` — симптом достатній, файл знати не треба
- Прод-інцидент: `{symptom}. check the logs, recent deploys, and config changes, then tell me the most likely cause` — перелічити ДЖЕРЕЛА доказів для кореляції, не кроки
- Build error: вставити помилку → `fix the root cause and verify the build succeeds` — root cause + verify блокує поверхневі патчі
- Логи людською мовою: `show me all {events} for {scope} over {timeframe}. write the query, run it, tell me what stands out` — і запит, і результат видно
- Скріншот консолі (GCP/K8s) → точні команди фіксу
- Аналіз даних: `read {file}, summarize key patterns, write results to {output format}` — разове питання не потребує разового скрипта
- **Автоматизація: повторювана задача → `create a /{name} skill that {steps}` · повторювана дія після події → hook · часте джерело даних → MCP замість копіпасти · кінець сесії → `summarize what we did, suggest what to add to CLAUDE.md`**

### CONSTRAINTS & EXECUTION (як Я застосовую)

- Коротка/розмита команда юзера → розпізнати патерн з каталогу → виконати ПОВНИЙ цикл (з верифікацією), не мінімальну інтерпретацію.
- ЗАВЖДИ будувати собі verification loop: код → запуск → порівняння → фікс. Жодного «зробив, мабуть працює».
- Перед видаленням/великою зміною → сам зробити blast-radius і scope-оцінку (Discover-патерни).
- Нова фіча за зразком → сам знайти найближчий існуючий приклад у кодбазі і назвати його.
- 3+ повтори однієї задачі/корекції → ПРОАКТИВНО запропонувати автоматизацію: правило в CLAUDE.md/memory, скіл, hook, або MCP.
- Питання «чому код такий» → git history, не тільки поточний стан.
- Довгі аудити (security/perf по великій площі) → субагент, щоб не палити основний контекст.
- У комунікації з юзером: якщо його запит без вимірюваної цілі там, де вона потрібна (перф/coverage) — уточнити метрику і поріг ОДНИМ питанням, або запропонувати розумний дефолт.

### OUTPUT EXPECTATIONS
Задача виконана за повним патерном (з верифікацією і референсами), розмиті запити розгорнуті у правильний воркфлоу без допиту юзера, повтори конвертуються в автоматизацію. Джерело: официальна prompt library + common-workflows + best-practices (code.claude.com/docs).
