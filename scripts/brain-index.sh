#!/bin/bash
# Генерує brain/knowledge/README.md з самих файлів знань.
# Опис береться з першого рядка-цитати (`> ...`) у файлі — не з назви.
# Мовчки випасти з індексу не може ніщо: файл без опису або з назвою
# поза конвенцією зупиняє скрипт і називається поіменно.
#
#   brain-index.sh          — перегенерувати README.md
#   brain-index.sh --check  — нічого не писати, впасти якщо індекс застарів
set -euo pipefail

cd "$(dirname "$0")/.."
KB=brain/knowledge
OUT=$KB/README.md

no_desc=()      # є файл, немає рядка "> опис"
off_convention=()  # назва не під жоден префікс
handled=""
body=""

section() {
  local title=$1 prefix=$2 found=""
  for f in "$KB/$prefix"*.md; do
    [ -e "$f" ] || continue
    local name d
    name=$(basename "$f" .md)
    handled+="|$name|"
    d=$(head -8 "$f" | grep -m1 '^> ' | sed 's/^> //' || true)
    if [ -z "$d" ]; then no_desc+=("$name"); continue; fi
    found+="- **$name** — $d"$'\n'
  done
  [ -n "$found" ] && body+="## $title"$'\n'"$found"$'\n'
  return 0
}

section "Архітектурні рішення (adr-)" "adr-"
section "Best practices (bp-)" "bp-"
section "Фікси (fix-)" "fix-"
section "Довідка (reference-)" "reference-"
section "Інструменти (tool-)" "tool-"

# усе, чого не торкнулась жодна секція
for f in "$KB"/*.md; do
  name=$(basename "$f" .md)
  [ "$name" = "README" ] && continue
  case "$handled" in *"|$name|"*) ;; *) off_convention+=("$name") ;; esac
done

# підтеки — цілісні набори, показуємо як один пункт із описом їхнього README
sets=""
for d in "$KB"/*/; do
  [ -d "$d" ] || continue
  dname=$(basename "$d")
  if [ ! -f "$d/README.md" ]; then no_desc+=("$dname/ (немає README.md)"); continue; fi
  sd=$(head -8 "$d/README.md" | grep -m1 '^> ' | sed 's/^> //' || true)
  if [ -z "$sd" ]; then no_desc+=("$dname/README"); continue; fi
  sets+="- **$dname/** ($(ls "$d"*.md | wc -l | tr -d ' ') файлів) — $sd"$'\n'
done
[ -n "$sets" ] && body+="## Набори"$'\n'"$sets"$'\n'

fail=0
if [ ${#no_desc[@]} -gt 0 ]; then
  echo "✗ Немає опису (другим рядком файлу потрібен '> один рядок про суть'):" >&2
  printf '   %s\n' "${no_desc[@]}" >&2
  fail=1
fi
if [ ${#off_convention[@]} -gt 0 ]; then
  echo "✗ Назва поза конвенцією — файл випав би з індексу (треба adr-/bp-/fix-/reference-/tool-):" >&2
  printf '   %s\n' "${off_convention[@]}" >&2
  fail=1
fi
[ $fail -eq 1 ] && exit 1

new=$(cat <<EOF
# Knowledge Base — індекс

> Згенеровано \`scripts/brain-index.sh\` з описів усередині самих файлів. Руками не правити.
> Кожен файл знань несе другим рядком \`> один рядок про суть\` — звідти й береться опис.

$body---

## Конвенція іменування

| Префікс | Що | Приклад |
|---|---|---|
| \`fix-\` | Рішення нетривіальних проблем | \`fix-prisma-p2025.md\` |
| \`bp-\` | Best practices | \`bp-quality-gate-lefthook.md\` |
| \`tool-\` | Інструменти/бібліотеки | \`tool-github-stars-map.md\` |
| \`adr-\` | Архітектурні рішення | \`adr-payment-provider.md\` |
| \`reference-\` | Контекстні дані | \`reference-personal-insights.md\` |
EOF
)

# ── Індекс правил ──────────────────────────────────────────────────
# Правила описує їхній власний заголовок `# ...` — окремого рядка-опису
# не заводимо, бо заголовок правила і є його формулюванням.
RULES=brain/rules
ROUT=$RULES/README.md
rules_body=""
rules_no_title=()
for f in "$RULES"/*.md; do
  [ -e "$f" ] || continue
  name=$(basename "$f" .md)
  [ "$name" = "README" ] && continue
  title=$(grep -m1 '^# ' "$f" | sed 's/^# //' || true)
  if [ -z "$title" ]; then rules_no_title+=("$name"); continue; fi
  rules_body+="- [$title]($name.md)"$'\n'
done
if [ ${#rules_no_title[@]} -gt 0 ]; then
  echo "✗ Правило без заголовка '# ...' — випало б з індексу:" >&2
  printf '   %s\n' "${rules_no_title[@]}" >&2
  exit 1
fi
rules_new=$(cat <<EOF
# Правила роботи — індекс

> Згенеровано \`scripts/brain-index.sh\` із заголовків самих правил. Руками не правити.
> Це постійні правила власника. Читати перед роботою; відкривати файл, коли правило
> стосується того, що робиш прямо зараз.

$rules_body
EOF
)

if [ "${1:-}" = "--check" ]; then
  if [ "$new" != "$(cat "$OUT" 2>/dev/null)" ]; then
    echo "✗ $OUT застарів — запусти scripts/brain-index.sh" >&2
    exit 1
  fi
  if [ "$rules_new" != "$(cat "$ROUT" 2>/dev/null)" ]; then
    echo "✗ $ROUT застарів — запусти scripts/brain-index.sh" >&2
    exit 1
  fi
  echo "✓ індекс актуальний ($(grep -c '^- \*\*' "$OUT") файлів знань, $(grep -c '^- \[' "$ROUT") правил)"
else
  printf '%s\n' "$new" > "$OUT"
  printf '%s\n' "$rules_new" > "$ROUT"
  echo "✓ $ROUT — $(grep -c '^- \[' "$ROUT") правил"
  echo "✓ $OUT — $(grep -c '^- \*\*' "$OUT") файлів"
fi
