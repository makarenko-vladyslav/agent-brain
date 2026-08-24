# Higgsfield Claude Skills — video automation
> Дев'ятнадцять скілів автоматизації відео через Higgsfield Seedance і Playwright.
**Дата:** 2026-04-28
**Проєкт:** відео-пайплайн
**Теги:** higgsfield, video, seedance, playwright, automation

## Джерело
`/tmp/higgsfield-claude-skills/` (AKCodez/higgsfield-claude-skills)

## Що це
19 Claude Code skills для автоматизації відео через Higgsfield Seedance 2.0 + Playwright browser automation.

## Workflow
1. Обрати style sub-skill → генерує production-grade prompt (15-25 рядків)
2. `/seedance-auto-generate` → Playwright автоматично: upload image + fill prompt + click Generate

## 15 Style Directors

### Creative
| Skill | Стиль |
|---|---|
| `/01-cinematic` | Film quality — dramatic lighting, anamorphic |
| `/02-3d-cgi` | 3D rendered — Pixar, Unreal Engine |
| `/03-cartoon` | 2D animation — cel-shaded, hand-drawn |
| `/04-comic-to-video` | Animate comics/manga/webtoons |
| `/05-fight-scenes` | Action choreography |
| `/08-anime-action` | Japanese animation |
| `/10-music-video` | Beat-synced, performance |

### Commercial (для проєкт ad creative)
| Skill | Стиль |
|---|---|
| `/06-motion-design-ad` | SaaS/software product launches |
| `/07-ecommerce-ad` | Product ads (fashion, electronics) |
| `/09-product-360` | Turntable product showcase |
| `/11-social-hook` | TikTok/Reels/Shorts scroll-stoppers |
| `/12-brand-story` | Brand narrative, mission videos |

### Industry
| Skill | Стиль |
|---|---|
| `/13-fashion-lookbook` | Fashion/beauty |
| `/14-food-beverage` | Food photography/video |
| `/15-real-estate` | Property showcase |

## Де застосовувати
- **відео-пайплайн:** `/01-cinematic` + `/11-social-hook` для thumbnail/intro generation
- **проєкт:** `/07-ecommerce-ad` + `/12-brand-story` для клієнтського ad creative
- **сайт-портфоліо:** `/06-motion-design-ad` для portfolio showcase videos

## Встановлення
```bash
# Скопіювати skills в проєкт відео-пайплайн
cp -r /tmp/higgsfield-claude-skills/* ~/Projects/відео-пайплайн/.claude/skills/
```
Або використовувати напряму через Claude Code slash commands.
