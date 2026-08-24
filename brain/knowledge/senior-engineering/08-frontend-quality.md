# 08 — Frontend Quality: Performance · Accessibility · i18n

> Senior playbook. Stack: Next.js App Router / React / Tailwind, heavy scroll animations, PWA, multi-locale (uk/en/de/es/fr/no via next-intl).

## Mandates

### Performance
- **[SELF] MUST** animate **only `transform` and `opacity`** (composited, GPU). Scroll: `translateY/scale`, never `top/left/width/height`.
- **[SELF] MUST** `next/image` with `sizes` + `priority` on the LCP hero; lazy-load below-fold (`dynamic(() => import(), { ssr:false })`).
- **[SELF] MUST** ship RSC by default; add `'use client'` only for interactivity/hooks/browser API.
- **[SELF] MUST** service worker = stale-while-revalidate + **versioned cache** (`cache-v{BUILD_ID}`); purge non-current caches on activate.
- **[SELF] MUST** honor `prefers-reduced-motion` in every animation (CSS media + `matchMedia` in JS).
- **[SELF] MUST** `next/font` with `display:swap`; audit new deps >20kB with bundle-analyzer.
- **[SELF] NEVER** animate layout props; never barrel-import (`from '@/components'` kills tree-shaking); never block main thread >50ms; never `setInterval` poll (SSE only).

### Accessibility
- **[SELF] MUST** semantic HTML first: `<button>`/`<a href>` not `<div onClick>`; `<nav>/<main>/<header>`.
- **[SELF] MUST** full keyboard operability; tab order = visual order; **focus trap** in modals (focus in on open, restore to trigger on close); `focus-visible` rings.
- **[SELF] MUST** ARIA only when native can't express it — use WAI-ARIA APG patterns verbatim; live regions (`role="status"`/`alert`, kept mounted) for async.
- **[SELF] MUST** forms: `<label>`/`aria-label` + `aria-describedby` for errors + `aria-invalid`; touch targets ≥44×44px; meaningful `alt` / `alt=""` decorative.
- **[SELF] NEVER** `tabIndex>0`; never color-only meaning; never suppress focus outline without a visible replacement.

### i18n
- **[SELF] MUST** every user-facing string via next-intl `t()` — incl. placeholders, `aria-label`, errors, email subjects, PDF content.
- **[SELF] MUST** `Intl` for dates/numbers/currency with explicit locale; ICU plurals (`t('items',{count})`), never manual ternary.
- **[SELF] MUST** landing, emails, client-facing content translated to **all active locales** (admin-only UI may stay uk/en); no locale file with missing keys; `hreflang` on public pages; prefer logical props (`ms-/me-`) for RTL-readiness.
- **[SELF] NEVER** concatenate strings in JSX (`"Welcome " + name`); never `toLocaleDateString()` without locale; never hardcode currency symbols.

## Visual Quality — why AI-built UI looks the same, and the fix

The generic look is not a prompting failure, it is a **material** failure: asking a model to "make it beautiful" makes it emit its own average. Three habits change the output:

- **Supply a visual language instead of an adjective.** Give a concrete reference — a component from a library (ThreeUI, React Bits, Magic UI…), a Dribbble shot, a screenshot of the real thing. Phrase it as: *"use this as a visual reference — keep the mechanics and the character of the motion, adapt colors, size and content to the current design, do not touch the page structure."* Pasting a component without that framing gets it embedded as a foreign body.
- **One library as the base, others only for a specific effect.** Mixing several visual systems produces mush. Within one page, **one or two strong accents beat ten effects** — restraint is what reads as premium.
- **Know the model's drift and correct against it.** Left alone it goes cheerful (bright, blue, friendly) when the reference is near-monochrome; procedural when the job needs real textures; toward the most *probable* explanation of an effect rather than the actual one. Each of these reads as "fine" and costs the "expensive" look. See rule `argue-with-my-own-first-answer`.

**Working phrases that pay for themselves:**
- *"List fixes from simple-and-effective down to complex-and-ineffective."* Without it the model returns 20 items of equal weight and nothing is actionable.
- **Show, don't describe.** Annotate a screenshot (draw the lines, mark the regions) and hand over the image — for vision-capable models this beats paragraphs of prose about layout.
- **Debug by absurdity.** When it's unclear what a setting controls, crank it to an extreme and watch what breaks. That is how a focus target silently pinned to the wrong object gets found.
- **Delete instead of repairing** a bad idea of your own. Polishing it burns time and tokens on something that gets cut anyway.

**Do not trust self-reported performance.** An agent measures FPS and reports comfortable numbers while ignoring that a retina display renders 4× the pixels — the report is convincing and wrong. Ask specifically which effects cost frames, and verify on the real device class.

### Brand and structure are two separate references

Never take both from the same source. Stripe's palette on a service business is fine; Stripe's *page structure* on a service business is wrong — a SaaS page and a plumber's page answer different questions in a different order.

- **Brand** (color, type, buttons, radii, elevation) — from a brand kit. Ready-made: [getdesign.md](https://getdesign.md) ships ~60 brands (Stripe, Vercel, Figma, Linear, Anthropic…) as a single `DESIGN.md` you drop into the workspace; also `designkit.sh`, `shadcn.io/design`. Or extract one from screenshots.
- **Structure** (section order, what the hero promises, where proof sits) — from a reference **in the target industry**, e.g. a Dribbble shot of an agency page when building an agency page.

Then state it explicitly: *"use the brand kit for branding, use the attached screenshot for page structure."*

### The six layout decisions — the vocabulary that lets you direct instead of hope

You don't need to know how to implement these. You need to know they exist, because naming them is what turns "make it nicer" into a directive:

1. **Direction** — content flowing vertically, horizontally, or nested both ways.
2. **Column ratio** — 50/50 reads static; 60/40 and 70/30 read designed.
3. **Container width** — constrained vs full-bleed. A full-bleed dark band breaks page monotony; the same band cut off at the container edge looks like a mistake.
4. **Section rhythm** — spacing *between* sections, consistent down the page.
5. **Padding vs margin** — inside the border vs outside it. Cramped padding under a navbar is the single most common reason a page reads cheap.
6. **Alignment** — of text and of elements within their box.

**Consistency rule:** when spacing changes in one section, it propagates to all of them. A hero with generous padding above a cramped next section looks worse than if neither had been touched.

## Budgets & Targets
| Metric | Good | Poor (block) |
|---|---|---|
| LCP | ≤2.5s | >4.0s |
| CLS | ≤0.1 | >0.25 |
| INP | ≤200ms | >500ms |
| JS/route (gz) | ≤150kB | >300kB |
| Contrast text | 4.5:1 (AA) | <3:1 |
| Contrast UI | 3:1 (AA) | <3:1 |
| Touch target | ≥44×44px | <24×24px |
| Frame budget | 16ms (60fps) | dropped frames |

## Anti-Patterns
`style={{width: pct+'%'}}` animated bar (non-composited → jank/CLS) · `<div onClick>` button (no keyboard/role) · `t('Submit')` display-string key (use `form.submit`) · barrel import (no tree-shake) · SW `force-cache` without version (stale JS after deploy) · `<img>` without `width/height` (CLS) · redundant `aria-label` on labeled button · mount/unmount live region · dynamic `import()` in render.

## Pre-merge Frontend Checklist
Perf: transform/opacity only · LCP `priority`+`sizes` · heavy = lazy · bundle diff reviewed · SW cache versioned · reduced-motion honored.
A11y: keyboard end-to-end · focus trap + restore · labels + `aria-describedby` · contrast checked (axe) · targets ≥44px · async announced · axe-core 0 violations.
i18n: zero hardcoded strings · keys in ALL locales · Intl for dates/numbers · ICU plurals · hreflang · client copy translated.

## Sources
web.dev Core Web Vitals (Google); Addy Osmani "Animations Guide"; WCAG 2.1/2.2 (W3C); WAI-ARIA APG; next-intl docs; Next.js image/bundle docs; web.dev stale-while-revalidate; MDN focus management & prefers-reduced-motion.
