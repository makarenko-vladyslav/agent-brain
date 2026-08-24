#!/bin/bash
# Механічна перевірка мозку. Тільки те, де хибних спрацювань не буває:
# биті [[wikilinks]], самопосилання, факт без опису, знання поза індексом.
#
# Прози не перевіряє свідомо: спроба ловити «мертві шляхи» в тексті дала
# 174 хибні знахідки (CSS-властивості, хеші комітів, назви чужих репо).
# Те, що потребує судження, робить brain-reflect.sh моделлю, не regexp'ом.
set -uo pipefail

cd "$(dirname "$0")/.."
MEM="${BRAIN_MEMORY_DIR:-}"
fail=0

echo "── знання (brain/knowledge)"
if ./scripts/brain-index.sh --check; then :; else fail=1; fi

if [ -z "$MEM" ] || [ ! -d "$MEM" ]; then
  echo "── пам'ять проєкту: пропущено (задай BRAIN_MEMORY_DIR, якщо ведеш окрему памʼять)"
else
echo "── пам'ять проєкту ($(ls "$MEM"/*.md 2>/dev/null | wc -l | tr -d ' ') файлів)"
python3 - "$MEM" <<'PY' || fail=1
import re, sys, pathlib
mem = pathlib.Path(sys.argv[1])
if not mem.is_dir():
    print(f"  ⚠ теки немає: {mem} — пропускаю"); raise SystemExit(0)
files = {p.stem: p for p in mem.glob("*.md") if p.name != "MEMORY.md"}
dead, selfl, nodesc, unindexed = [], [], [], []
index = (mem/"MEMORY.md").read_text(errors="ignore") if (mem/"MEMORY.md").exists() else ""
for stem, p in files.items():
    t = p.read_text(errors="ignore")
    if not re.search(r'^description:', t, re.M): nodesc.append(stem)
    if f"{stem}.md" not in index: unindexed.append(stem)
    for link in re.findall(r"\[\[([^\]]+)\]\]", t):
        if link == stem: selfl.append(stem)
        elif link not in files: dead.append((stem, link))
bad = 0
for title, items in (("биті [[wikilinks]]", dead), ("самопосилання", selfl),
                     ("без description", nodesc), ("не в MEMORY.md", unindexed)):
    if items:
        bad = 1
        print(f"  ✗ {title}: {len(items)}")
        for it in items[:10]:
            print(f"      {it if isinstance(it, str) else it[0] + '  →  [[' + it[1] + ']]'}")
    else:
        print(f"  ✓ {title}: 0")
raise SystemExit(bad)
PY
fi

[ $fail -eq 0 ] && echo "── мозок чистий" || echo "── є що полагодити (див. вище)"
exit $fail
