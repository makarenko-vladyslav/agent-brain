# Global Skills — Super Brain

Об'єднаний набір скілів з проєктів проєкт та відео-пайплайн. Кожна папка — `SKILL.md`. Читай **лише** релевантний скіл.

## Core — Web Development

| Скіл | Тригер | НЕ тригер |
|---|---|---|
| **github-agile-manager** | Issues, PR, чеклісти, GitHub Projects | Загальні git-команди |
| **react-performance-core** | Оптимізація React, мемоізація, рендери | Нові компоненти (→ frontend) |
| **frontend-ui-ux-mastery** | UI/UX, Tailwind, доступність, конверсія, scroll-анімації | Бекенд API, БД |
| **backend-db-security-architect** | Server Actions, Prisma, SSE, черги, безпека | Client-side код |
| **tech-lead-reviewer** | Код-рев'ю, архітектурний пас | Написання нового коду |
| **devops-qa-compliance** | CI/CD, Docker, тести, Playwright, GDPR | Бізнес-логіка |
| **growth-marketing-billing** | SEO, аналітика, Stripe, маркетинг, email | Технічний код |
| **applied-ai-automation** | AI-агенти, RAG, Vercel AI SDK, промпт-інженерія | Конфігурація моделей (→ ai-prompts rule) |

## Additional (за задачею)

| Скіл | Тригер | НЕ тригер |
|---|---|---|
| **google-genai-sdk** | Gemini / `@google/genai`, structured output | Claude/OpenAI API |
| **github-readme-architect** | README, SVG анімації для GitHub profile | Звичайна документація |
| **find-skills** | Пошук/встановлення зовнішніх скілів | Створення нових (→ skill-engineering) |
| **skill-engineering** | Створення нових `SKILL.md`, evals | Пошук існуючих (→ find-skills) |
| **sales-outreach-strategist** | Продажі, outreach, холодні ланцюжки | SEO/маркетинг (→ growth) |
| **headless-cms-architect** | Headless CMS (Strapi, Sanity, Contentful) | Звичайні API |
| **apple-scroll-animation-architect** | Складні Canvas scroll-анімації (Apple-style) | Прості CSS анімації (→ frontend) |
| **awwwards-web-architect** | Преміум сайти, лендінги, портфоліо рівня Awwwards | Бекенд API, бази даних |
| **agentic-workflow-patterns** | Розмиті/короткі команди → повний воркфлоу, verification loops, blast-radius, повтори → skill/hook/CLAUDE.md | Доменні знання (React/AI/DB → відповідні скіли) |

## Skill Combinations (часті пари)

| Задача | Скіли |
|---|---|
| Лендінг з конверсією | frontend-ui-ux-mastery + growth-marketing-billing |
| Преміум сайт з анімаціями | awwwards-web-architect + apple-scroll-animation-architect |
| YouTube відео від ідеї до публікації | content-pipeline-orchestrator + video-production-agent |
| Код-рев'ю з рефактором | tech-lead-reviewer + backend-db-security-architect |
| Новий AI feature | applied-ai-automation + backend-db-security-architect |

## Як додати новий скіл

1. Прочитай `meta/skill-forge.md` — canonical протокол
2. Anti-duplicate check — перевір чи немає серед існуючих
3. Створи `skills/<name>/SKILL.md` з YAML frontmatter
4. Додай рядок в цю таблицю (з anti-trigger!)
5. Commit + push
