# Tool Inventory — Повний арсенал AI агента

Кожен агент ЗОБОВ'ЯЗАНИЙ знати про ці інструменти і використовувати їх проактивно.

---

## 1. MCP Конектори (Cloud Services)

### Chrome Browser Automation (`mcp__claude-in-chrome__*`)
Повне управління браузером Chrome.
- `tabs_context_mcp` — отримати контекст відкритих вкладок (ЗАВЖДИ першим)
- `tabs_create_mcp` — створити нову вкладку
- `navigate` — перейти на URL
- `read_page` / `get_page_text` — прочитати вміст сторінки
- `find` — знайти елемент на сторінці
- `computer` — клік, скрол, введення тексту
- `form_input` — заповнення форм
- `javascript_tool` — виконати JS на сторінці
- `read_console_messages` — читати console.log
- `read_network_requests` — моніторити мережеві запити
- `gif_creator` — записати GIF взаємодії
- `upload_image` — завантажити зображення
- `resize_window` — змінити розмір вікна
- `shortcuts_execute` / `shortcuts_list` — клавіатурні комбінації
**Коли:** веб-скрапінг, тестування UI, автоматизація браузерних задач, YouTube дослідження

### Gmail (`mcp__claude_ai_Gmail__*`)
- `search_threads` — пошук листів
- `get_thread` — прочитати тред
- `create_draft` — створити чернетку
- `label_message` / `label_thread` — маркування
- `list_labels` / `create_label` — управління лейблами
- `list_drafts` — список чернеток
**Коли:** email-комунікація, аналіз листування, автоматичні відповіді, клієнт-менеджмент

### Google Calendar (`mcp__claude_ai_Google_Calendar__*`)
- `list_calendars` — список календарів
- `list_events` — список подій
- `get_event` — деталі події
- `create_event` — створити подію
- `update_event` — оновити подію
- `delete_event` — видалити подію
- `suggest_time` — знайти вільний час
- `respond_to_event` — відповісти на запрошення
**Коли:** планування, дедлайни, нагадування, розклад зустрічей

### Google Drive (`mcp__claude_ai_Google_Drive__*`)
- `search_files` — пошук файлів
- `list_recent_files` — останні файли
- `read_file_content` — прочитати вміст
- `download_file_content` — завантажити файл
- `create_file` — створити файл (docs, sheets, presentations, folders)
- `get_file_metadata` — метадані файлу
- `get_file_permissions` — права доступу
**Коли:** документи, таблиці, презентації, спільне сховище, backup знань

### Figma (`mcp__claude_ai_Figma__*`)
- `get_design_context` — отримати дизайн + код
- `get_screenshot` — скріншот дизайну
- `get_metadata` — метадані файлу
- `generate_diagram` — створити діаграму в FigJam (Mermaid)
- `create_new_file` — створити новий файл
- `get_code_connect_map` / `add_code_connect_map` — зв'язок Figma↔код
- `get_libraries` — бібліотеки компонентів
- `search_design_system` — пошук по дизайн-системі
- `whoami` — інфо про акаунт
**Коли:** дизайн-імплементація, діаграми архітектури, UI компоненти, Code Connect

### Supabase (`mcp__claude_ai_Supabase__*`)
- `list_projects` / `get_project` — проєкти
- `execute_sql` — виконати SQL
- `apply_migration` — міграції
- `list_tables` — таблиці
- `deploy_edge_function` — Edge Functions
- `create_branch` / `merge_branch` — бранчі БД
- `get_logs` — логи
- `get_advisors` — рекомендації з оптимізації
- `generate_typescript_types` — генерація типів
- `search_docs` — пошук по документації
**Коли:** база даних, міграції, Edge Functions, типи, аналітика БД

### Vercel (`mcp__claude_ai_Vercel__*`)
- `list_projects` / `get_project` — проєкти
- `deploy_to_vercel` — деплой
- `list_deployments` / `get_deployment` — деплойменти
- `get_deployment_build_logs` — логи білду
- `get_runtime_logs` — runtime логи
- `search_vercel_documentation` — документація
- `check_domain_availability_and_price` — перевірка домену
**Коли:** деплой, діагностика, домени

### Context7 (`mcp__claude_ai_Context7__*`)
- `resolve-library-id` — знайти бібліотеку
- `query-docs` — запитати документацію
**Коли:** ЗАВЖДИ при роботі з будь-якою бібліотекою/фреймворком — навіть якщо "знаєш" відповідь

### Hugging Face (`mcp__claude_ai_Hugging_Face__*`)
- `authenticate` — автентифікація
**Коли:** ML моделі, datasets, Hugging Face integration

---

## 2. CLI Tools (через Bash)

| Інструмент | Команда | Для чого |
|---|---|---|
| **GitHub CLI** | `gh` | Issues, PRs, repos, actions, releases |
| **NotebookLM CLI** | `uvx --from notebooklm-mcp-cli nlm` | Запити до бази знань, додавання джерел |
| **YouTube Search** | `yt-dlp --flat-playlist "ytsearch10:query" --print title,url` | Пошук відео |
| **yt-dlp** | `yt-dlp` | Завантаження відео/метаданих |
| **Claude CLI** | `claude` | Запуск під-агентів як subprocess |
| ~~**Fly.io**~~ | ~~`fly`~~ | ❌ НЕ використовувати. Бінарник стоїть, але все живе на Hetzner |
| **Docker** | `docker` | Контейнери |
| **Node.js** | `node`, `npm`, `npx` | JS runtime, пакети |
| **Python** | `python3`, `uvx`, `python3 -m pip` | Скрипти, ML (окремого `pip` у PATH немає) |
| **FFmpeg** | `ffmpeg` | Відео обробка |
| **Git** | `git` | Версіонування |
| **SSH** | `ssh` | Доступ до серверів (read-only!) |
| **cURL** | `curl` | HTTP запити |

---

## 3. Built-in Tools (Claude Code native)

| Інструмент | Для чого |
|---|---|
| `Read` | Читати файли, зображення, PDF |
| `Write` | Створювати нові файли |
| `Edit` | Редагувати існуючі файли |
| `Glob` | Пошук файлів за патерном |
| `Grep` | Пошук в контенті файлів |
| `Bash` | Shell команди |
| `Agent` | Запуск під-агентів (Explore, Plan, general) |
| `WebFetch` | Отримати вміст URL |
| `WebSearch` | Пошук в інтернеті |
| `TaskCreate/Update/List` | Управління задачами |
| `NotebookEdit` | Jupyter notebooks |
| `CronCreate/Delete/List` | Задачі за розкладом |
| `RemoteTrigger` | Віддалені агенти |
| `Skill` | Виклик скіла / slash-команди |
| `Workflow` | Оркестрація десятків агентів по фазах |
| `Monitor` | Чекати на умову (звичайний `sleep` заблокований) |
| `SendUserFile` | Віддати файл власнику — він часто з телефону |
| `Artifact` | Опублікувати сторінку, яку видно з телефону |
| `ScheduleWakeup` | Самотемпові пробудження всередині `/loop` |
| `EnterWorktree` | Ізольована копія репо під паралельну роботу |

**Частина інструментів відкладена** (`Monitor`, `Cron*`, `Task*`, `WebSearch`, `RemoteTrigger`, `PushNotification`…): видно лише назву, схеми немає. Перед викликом підвантажити одним запитом: `ToolSearch "select:Monitor,CronCreate,TaskCreate"`. Кілька назв — один виклик, не по одному.

---

## 4. Знання (Knowledge Sources)

| Джерело | Як отримати | Для чого |
|---|---|---|
| **NotebookLM** | `nlm query <id> "питання"` | База знань (4 ноутбуки відео-пайплайн + потенційно нові) |
| **Context7** | MCP tool | Документація будь-якої бібліотеки |
| **Vercel Docs** | MCP tool | Vercel-специфічна документація |
| **Supabase Docs** | MCP tool | Supabase документація |
| **SuperBrain/skills/** | Read SKILL.md | Скіли за доменами; routing — `skills/README.md` (звірено 15.08: 21 тека = 21 запис) |
| **Google Drive** | MCP tool | Документи, таблиці |
| **Web** | WebSearch + WebFetch | Будь-що в інтернеті |
| **GitHub** | `gh` CLI | Issues, code, PRs, repos |

---

## 5. Правило використання

**Проактивність:** Не чекати поки юзер попросить — якщо інструмент може допомогти, використати його.

**Context7:** ЗАВЖДИ для бібліотек/фреймворків, навіть якщо "знаєш" — knowledge cutoff може не відповідати реальності.

**Browser:** Коли потрібно перевірити щось візуально, заповнити форму, або автоматизувати web-задачу.

**Gmail/Calendar/Drive:** Коли задача стосується комунікації, планування, або документації.

**NotebookLM:** Коли потрібна глибока база знань по YouTube, маркетингу, AI influencer стратегіях.

**Пам'ять ПЕРЕД задачею:** команди `mempalace` **не існує** — не кликати (перевірено 15.08.2026). Реальні джерела: `brain/knowledge/README.md` — індекс усіх знань з описами (генерується автоматично, не бреше); auto-memory проєкту — `MEMORY.md` у `~/.claude/projects/<проєкт>/memory/`; `rg` по SuperBrain — коли треба точне слово.

**OMC режими (використовуй проактивно):**
- Складна задача → `/ralph` (loop до done)
- Повна фіча → `/autopilot`
- Багато файлів → `/ultrawork` (паралельно)
- QA → `/ultraqa`
- Баг → `/trace` + `/deep-dive`
- Планування → `/omc-plan`

**Higgsfield (відео-пайплайн):** Style directors (`/01-cinematic`, `/11-social-hook`) + `/seedance-auto-generate` для автоматичної генерації відео.

---

## 6. Автономія — коли не робити руками

Закон: **робота, що триває довше за увагу власника або повторюється, не має чекати
на його присутність.** Він СЕО і працює з телефону. Все нижче перевірено 15.08.2026.

**Повторювати задачу з інтервалом → `/loop`.**
`/loop 10m /перевір деплой` — прогін кожні 10 хвилин. Без інтервалу темп обираю сам
(`ScheduleWakeup`): довге очікування — рідкі пробудження, зовнішній процес — за його
ритмом. Це для «стеж, поки не станеться», не для одноразової задачі.

**Робота за розкладом → розрізняй, що переживе сесію.**
- `CronCreate` — **тільки в межах поточної сесії**, в памʼяті, згасає разом з нею і
  сам вимирає через 7 днів. Годиться для «перевіряй кожні 20 хв, поки я тут»,
  не годиться для ритуалів. Живі — `CronList`, зняти — `CronDelete`.
- `/schedule` — хмарні routines за cron, працюють без відкритої сесії. Це для
  ранкового звіту, тижневого перегляду цілей, регулярного аудиту.
- `launchd` на Mac — коли задачі потрібен доступ до локального репо й підписки
  (так живе нічний агент проєкт: `com.yourname.проєкт-deslop`).

Ритуал, записаний у markdown без жодного з трьох механізмів, не виконується.
Перевірено на власному мозку: «Weekly Review Protocol» описаний у `brain/goals/ACTIVE.md`,
а цілі не переглядались 109 днів.

**Довга збірка, тест, скрипт → `Bash` з `run_in_background`.**
Не блокує діалог, сам озветься на завершенні. `npx vitest`, `next build`, деплой,
довгий `curl` — завжди у фон. Чекати на умову — `Monitor` (звичайний `sleep` заблокований).

**Обійти багато файлів: аудит, рефакторинг, пошук багів по всій базі → `Workflow`.**
JS-оркестратор у фоні: фази, десятки паралельних агентів, змагальна перевірка знахідок
скептиками, критик повноти. Прогрес — `/workflows`. Одна фіча = один агент, для неї це
надлишок. Не збирати саморобний конвеєр із bash і патчів — це вже було і коштувало ночі.

**Одна самостійна підзадача → `Agent`.**
Субагент із чистим контекстом на тій самій моделі. Дешевше, ніж тягнути ту саму роботу
всередині довгої сесії. Кілька незалежних — одним повідомленням, щоб бігли разом.

**Багатокрокова робота → `TaskCreate` / `TaskUpdate`.**
Щоб не загубити половину при перемиканні. Перед стартом — `in_progress`, після — `completed`.

**Результат власнику → `SendUserFile` (файл, скрін, звіт) або `Artifact` (сторінка з телефону).**
Він не має заходити на localhost і не має запускати команди сам.

**Довести, що працює → `/run`, потім окремий прохід рев'ю.**
`/run` піднімає застосунок і показує зміну в реальності. Рев'ю — `/review`,
`/security-review` або агент `code-reviewer`: **автор не затверджує сам себе**.
`/code-review ultra` вмикає лише власник, сам я його не запускаю.

**Ізоляція паралельних змін → worktree.**
`EnterWorktree` або `isolation: "worktree"` в агента, коли кілька рук пишуть одночасно
в ті самі файли. Нічний агент проєкт живе саме так.

**Цілі → `/goal`.**
Показати стан із доказами, поставити нову, посунути наявну. Файл — `brain/goals/ACTIVE.md`.
Ціль без механізму просування лишається текстом: поставив ціль — одразу підбери їй
режим із цього розділу.

**Стан сесії → `/remember`.** Незавершене має пережити сесію без переказу.

**Ліміти підписки.** `claude --print "/usage"` — точні відсотки. На ~85% сесії: зупинитись
охайно, зафіксувати стан, запланувати продовження на час скидання. Тижневий ліміт —
зупинка на дні й попередження власника.

Повний каталог можливостей: `brain/knowledge/tool-installed-capabilities-2026.md`

