# Enforcement Plan — turning `[SELF]` rules into `[CI]` blocks

> The critic's MAJOR-1: many craft rules are self-checked, not machine-blocked —
> so a green CI does not mean playbook-clean. This is the plan to close that gap
> **without breaking the build** (the naive "flip everything to error" would fail
> CI on thousands of legacy lines).

## Strategy: the ratchet (baseline + block-new)

You can't enforce a rule the codebase already violates 500× by making it `error` —
CI goes red instantly. The senior move is a **one-way ratchet**:

1. **Measure baseline** — how many violations exist today, per rule (below).
2. **Turn rules on at `warn`** — full visibility, CI stays green.
3. **Block NEW violations only** — CI lints the *changed files* in a PR/push at
   `error`; existing debt is grandfathered, but no new violation gets in.
4. **Burn down the baseline** — the nightly deslop pass + code-review pass chip at
   existing violations over time (they're already running).
5. **Flip rule → global `error`** once its baseline hits 0. The ratchet only tightens.

This is how large codebases adopt strict lint without a big-bang freeze.

## Candidate rules & baseline (measured on `origin/staging`)

Rules proposed (from the critic's MAJOR-1 + playbook 01/03):

| Rule | Threshold | Baseline | Action |
|---|---|---|---|
| `no-else-return` | — | **3** | flip to `error` NOW — almost clean |
| `max-params` | 4 | **74** | block-new ratchet |
| `no-nested-ternary` | — | **220** | block-new ratchet |
| `complexity` | 15 | **261** | block-new ratchet |
| `@typescript-eslint/no-explicit-any` | error | **447** | currently `warn`; block-new (highest value — types are the truth) |
| `max-lines-per-function` | 80 | **559** | block-new; long burn-down (`ai-service.ts` 1122 LOC etc.) |

Measured on `origin/staging` (`a94de27`): **2102 total lint messages across 634 files** with candidate rules at `warn`. The existing baseline already carries 216 `no-unused-vars` + 178 FSD-boundary (`import/no-restricted-paths`) as `warn`.

**Verdict:** flipping everything to `error` reds CI on 2102 violations — **the ratchet is mandatory**. `no-else-return` (3) can go straight to `error` today; everything else is block-new until its baseline burns down.

> **This extends an existing policy, not a new one.** проєкт's `eslint.config.mjs`
> already runs FSD-boundary rules at `warn` with the exact ratchet note: *"рівень
> warn, НЕ error… коли борг розчищено до 0 — підняти до error."* `no-explicit-any`
> is already `warn` under the same logic. We're applying the team's own proven
> approach to craft rules.

## Status: DEPLOYED ✅

Enforcement is live on проєкт staging: craft-block in `eslint.config.mjs` (PR #220
merged) + a CI job that keeps NEW files craft-clean. First rule fully ratcheted to
`error`: `no-else-return` (baseline 3 → fixed → error, PR #221).

**Lesson from our own CI (PR #221):** `--diff-filter=ACM` with `--max-warnings 0`
blocked *any* touch to a legacy file that still carried debt — i.e. it blocked the
burn-down itself. Fixed to `--diff-filter=A`: only NEWLY-CREATED files must be
craft-clean; edits to legacy files are caught by the main lint on **errors** (an
`error`-level rule blocks everywhere via the "0 errors" gate). The system caught a
flaw in itself and self-corrected — that is the standard working.

## Implementation (deployed config)

**1. `eslint.config.mjs`** — add one block before the closing `]);` (safe, `warn` = non-blocking):
```js
  // ── Craft rules (Senior Constitution 01/03) — WARN baseline, ratchet ──────
  // Same policy as FSD boundaries above: visible now, block NEW via lint-changed
  // CI, flip a rule to `error` once its baseline hits 0.
  // Baselines on staging: max-lines 559, complexity 261, no-nested-ternary 220,
  // max-params 74, no-else-return 3.
  {
    files: ["{app,views,widgets,features,entities,shared}/**/*.{ts,tsx}"],
    rules: {
      "max-lines-per-function": ["warn", { max: 80, skipBlankLines: true, skipComments: true }],
      "max-params": ["warn", 4],
      "no-nested-ternary": "warn",
      "complexity": ["warn", 15],
      "no-else-return": "warn", // baseline=3; fix those 3, then bump to "error"
    },
  },
```

**2. CI `.github/workflows/test.yml`** — add a `lint-changed` job that blocks NEW violations only:
```yaml
  lint-changed:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci
      - name: Block new craft violations
        run: |
          BASE="${{ github.event.pull_request.base.sha || 'origin/staging' }}"
          FILES=$(git diff --name-only --diff-filter=ACM "$BASE"...HEAD -- '*.ts' '*.tsx' \
            | grep -vE '\.(test|spec)\.' || true)
          [ -z "$FILES" ] && echo "no changed TS files" && exit 0
          npx eslint --max-warnings 0 $FILES
```

**3. `lefthook.yml` pre-push** — already runs `npx eslint`; add a changed-files mirror so violations are caught locally before push (optional but recommended).

**4. Burn-down** — the nightly deslop + code-review passes already reduce the baseline; no new mechanism needed. When a rule's baseline hits 0, flip it to `error` (start with `no-else-return`).

## Risks & guardrails
- **NEVER** flip a rule to global `error` while its baseline > 0 — that reds CI for everyone.
- Roll out one rule at a time; watch the changed-files job for false-positive friction.
- `no-explicit-any` → `error` is the highest-value flip (types are the truth); do it first once new-code baseline is clean.
- This touches CI config → **owner decision** per Constitution §5 (outward-facing / affects all agents).

## Owner decision
This plan is ready to apply. It does **not** go live until you say so, because it
changes the shared CI gate. Recommended first step: enable the rules at `warn` +
the `lint-changed` block-new job — zero risk to existing green, immediate stop on
new violations.
