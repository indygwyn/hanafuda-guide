#!/usr/bin/env bash
# Downloads all 48 hanafuda card SVGs in two sets:
#   cards/     — original red-border set (complete, all 48 exist)
#   cards-alt/ — black-border Alt set (42 true Alt + 6 fallbacks to originals)
# Run from the hanafuda-guide directory: bash download-cards.sh
# Requires: curl
# Card images are CC BY-SA 4.0, Spenĉjo et al.

set -euo pipefail

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
B="https://upload.wikimedia.org/wikipedia/commons"

mkdir -p cards cards-alt

# Format: "filename|original_url|alt_url"
# 6 files have no true Alt upload; alt_url falls back to the original for those.
declare -a CARDS=(
  "Hanafuda_January_Hikari_Alt.svg|$B/c/c7/Hanafuda_January_Hikari.svg|$B/1/15/Hanafuda_January_Hikari_Alt.svg"
  "Hanafuda_January_Tanzaku_Alt.svg|$B/8/83/Hanafuda_January_Tanzaku.svg|$B/4/44/Hanafuda_January_Tanzaku_Alt.svg"
  "Hanafuda_January_Kasu_1_Alt.svg|$B/6/67/Hanafuda_January_Kasu_1.svg|$B/6/62/Hanafuda_January_Kasu_1_Alt.svg"
  "Hanafuda_January_Kasu_2_Alt.svg|$B/1/12/Hanafuda_January_Kasu_2.svg|$B/0/0f/Hanafuda_January_Kasu_2_Alt.svg"
  "Hanafuda_February_Tane_Alt.svg|$B/d/d5/Hanafuda_February_Tane.svg|$B/e/e3/Hanafuda_February_Tane_Alt.svg"
  "Hanafuda_February_Tanzaku_Alt.svg|$B/e/ed/Hanafuda_February_Tanzaku.svg|$B/7/7f/Hanafuda_February_Tanzaku_Alt.svg"
  "Hanafuda_February_Kasu_1_Alt.svg|$B/b/ba/Hanafuda_February_Kasu_1.svg|$B/6/6c/Hanafuda_February_Kasu_1_Alt.svg"
  "Hanafuda_February_Kasu_2_Alt.svg|$B/6/6c/Hanafuda_February_Kasu_2.svg|$B/a/a1/Hanafuda_February_Kasu_2_Alt.svg"
  "Hanafuda_March_Hikari_Alt.svg|$B/3/35/Hanafuda_March_Hikari.svg|$B/2/2a/Hanafuda_March_Hikari_Alt.svg"
  "Hanafuda_March_Tanzaku_Alt.svg|$B/a/af/Hanafuda_March_Tanzaku.svg|$B/a/af/Hanafuda_March_Tanzaku.svg"
  "Hanafuda_March_Kasu_1_Alt.svg|$B/7/7f/Hanafuda_March_Kasu_1.svg|$B/0/0b/Hanafuda_March_Kasu_1_Alt.svg"
  "Hanafuda_March_Kasu_2_Alt.svg|$B/5/5b/Hanafuda_March_Kasu_2.svg|$B/5/5b/Hanafuda_March_Kasu_2.svg"
  "Hanafuda_April_Tane_Alt.svg|$B/a/a2/Hanafuda_April_Tane.svg|$B/6/66/Hanafuda_April_Tane_Alt.svg"
  "Hanafuda_April_Tanzaku_Alt.svg|$B/8/8e/Hanafuda_April_Tanzaku.svg|$B/f/f8/Hanafuda_April_Tanzaku_Alt.svg"
  "Hanafuda_April_Kasu_1_Alt.svg|$B/f/fe/Hanafuda_April_Kasu_1.svg|$B/f/f0/Hanafuda_April_Kasu_1_Alt.svg"
  "Hanafuda_April_Kasu_2_Alt.svg|$B/8/80/Hanafuda_April_Kasu_2.svg|$B/3/32/Hanafuda_April_Kasu_2_Alt.svg"
  "Hanafuda_May_Tane_Alt.svg|$B/e/e1/Hanafuda_May_Tane.svg|$B/e/e1/Hanafuda_May_Tane.svg"
  "Hanafuda_May_Tanzaku_Alt.svg|$B/6/6a/Hanafuda_May_Tanzaku.svg|$B/8/88/Hanafuda_May_Tanzaku_Alt.svg"
  "Hanafuda_May_Kasu_1_Alt.svg|$B/c/c9/Hanafuda_May_Kasu_1.svg|$B/c/c9/Hanafuda_May_Kasu_1.svg"
  "Hanafuda_May_Kasu_2_Alt.svg|$B/c/ce/Hanafuda_May_Kasu_2.svg|$B/2/2c/Hanafuda_May_Kasu_2_Alt.svg"
  "Hanafuda_June_Tane_Alt.svg|$B/0/04/Hanafuda_June_Tane.svg|$B/a/a2/Hanafuda_June_Tane_Alt.svg"
  "Hanafuda_June_Tanzaku_Alt.svg|$B/b/be/Hanafuda_June_Tanzaku.svg|$B/8/89/Hanafuda_June_Tanzaku_Alt.svg"
  "Hanafuda_June_Kasu_1_Alt.svg|$B/6/65/Hanafuda_June_Kasu_1.svg|$B/e/e3/Hanafuda_June_Kasu_1_Alt.svg"
  "Hanafuda_June_Kasu_2_Alt.svg|$B/a/a9/Hanafuda_June_Kasu_2.svg|$B/3/35/Hanafuda_June_Kasu_2_Alt.svg"
  "Hanafuda_July_Tane_Alt.svg|$B/a/ae/Hanafuda_July_Tane.svg|$B/d/d1/Hanafuda_July_Tane_Alt.svg"
  "Hanafuda_July_Tanzaku_Alt.svg|$B/e/e1/Hanafuda_July_Tanzaku.svg|$B/a/a6/Hanafuda_July_Tanzaku_Alt.svg"
  "Hanafuda_July_Kasu_1_Alt.svg|$B/c/cb/Hanafuda_July_Kasu_1.svg|$B/0/0e/Hanafuda_July_Kasu_1_Alt.svg"
  "Hanafuda_July_Kasu_2_Alt.svg|$B/9/9e/Hanafuda_July_Kasu_2.svg|$B/c/ce/Hanafuda_July_Kasu_2_Alt.svg"
  "Hanafuda_August_Hikari_Alt.svg|$B/0/0b/Hanafuda_August_Hikari.svg|$B/8/8c/Hanafuda_August_Hikari_Alt.svg"
  "Hanafuda_August_Tane_Alt.svg|$B/8/8d/Hanafuda_August_Tane.svg|$B/0/03/Hanafuda_August_Tane_Alt.svg"
  "Hanafuda_August_Kasu_1_Alt.svg|$B/3/3e/Hanafuda_August_Kasu_1.svg|$B/a/ae/Hanafuda_August_Kasu_1_Alt.svg"
  "Hanafuda_August_Kasu_2_Alt.svg|$B/1/1e/Hanafuda_August_Kasu_2.svg|$B/1/1e/Hanafuda_August_Kasu_2_Alt.svg"
  "Hanafuda_September_Tane_Alt.svg|$B/7/71/Hanafuda_September_Tane.svg|$B/7/77/Hanafuda_September_Tane_Alt.svg"
  "Hanafuda_September_Tanzaku_Alt.svg|$B/b/b1/Hanafuda_September_Tanzaku.svg|$B/1/1b/Hanafuda_September_Tanzaku_Alt.svg"
  "Hanafuda_September_Kasu_1_Alt.svg|$B/1/16/Hanafuda_September_Kasu_1.svg|$B/f/f5/Hanafuda_September_Kasu_1_Alt.svg"
  "Hanafuda_September_Kasu_2_Alt.svg|$B/2/2f/Hanafuda_September_Kasu_2.svg|$B/1/11/Hanafuda_September_Kasu_2_Alt.svg"
  "Hanafuda_October_Tane_Alt.svg|$B/a/a4/Hanafuda_October_Tane.svg|$B/0/02/Hanafuda_October_Tane_Alt.svg"
  "Hanafuda_October_Tanzaku_Alt.svg|$B/3/3f/Hanafuda_October_Tanzaku.svg|$B/3/3f/Hanafuda_October_Tanzaku.svg"
  "Hanafuda_October_Kasu_1_Alt.svg|$B/8/8f/Hanafuda_October_Kasu_1.svg|$B/4/49/Hanafuda_October_Kasu_1_Alt.svg"
  "Hanafuda_October_Kasu_2_Alt.svg|$B/3/36/Hanafuda_October_Kasu_2.svg|$B/6/6a/Hanafuda_October_Kasu_2_Alt.svg"
  "Hanafuda_November_Hikari_Alt.svg|$B/5/5b/Hanafuda_November_Hikari.svg|$B/6/61/Hanafuda_November_Hikari_Alt.svg"
  "Hanafuda_November_Tane_Alt.svg|$B/3/31/Hanafuda_November_Tane.svg|$B/e/e3/Hanafuda_November_Tane_Alt.svg"
  "Hanafuda_November_Tanzaku_Alt.svg|$B/1/1b/Hanafuda_November_Tanzaku.svg|$B/b/b5/Hanafuda_November_Tanzaku_Alt.svg"
  "Hanafuda_November_Kasu_Alt.svg|$B/1/1f/Hanafuda_November_Kasu.svg|$B/1/1f/Hanafuda_November_Kasu.svg"
  "Hanafuda_December_Hikari_Alt.svg|$B/9/91/Hanafuda_December_Hikari.svg|$B/0/08/Hanafuda_December_Hikari_Alt.svg"
  "Hanafuda_December_Kasu_1_Alt.svg|$B/d/de/Hanafuda_December_Kasu_1.svg|$B/d/db/Hanafuda_December_Kasu_1_Alt.svg"
  "Hanafuda_December_Kasu_2_Alt.svg|$B/e/e6/Hanafuda_December_Kasu_2.svg|$B/3/3c/Hanafuda_December_Kasu_2_Alt.svg"
  "Hanafuda_December_Kasu_3_Alt.svg|$B/5/58/Hanafuda_December_Kasu_3.svg|$B/4/49/Hanafuda_December_Kasu_3_Alt.svg"
)

is_valid_svg() {
  [[ -f "$1" && -s "$1" ]] && head -c 20 "$1" | grep -qi '<svg'
}

fetch() {
  local label="$1" dest="$2" url="$3"
  if is_valid_svg "$dest"; then
    echo "$label skip"
    return 0
  fi
  echo -n "$label fetch ... "
  if curl -sL --max-redirs 5 --retry 3 --retry-delay 2 -A "$UA" "$url" -o "$dest" \
      && is_valid_svg "$dest"; then
    echo "ok"
    return 0
  else
    echo "FAILED (url: $url)"
    rm -f "$dest"
    return 1
  fi
}

total=${#CARDS[@]}
errors=0

echo "=== Downloading original (red border) set → cards/ ==="
count=0
for entry in "${CARDS[@]}"; do
  count=$((count + 1))
  IFS='|' read -r f orig_url alt_url <<< "$entry"
  fetch "[$count/$total] $f" "cards/$f" "$orig_url" || errors=$((errors + 1))
  sleep 0.3
done

echo ""
echo "=== Downloading Alt (black border) set → cards-alt/ ==="
count=0
for entry in "${CARDS[@]}"; do
  count=$((count + 1))
  IFS='|' read -r f orig_url alt_url <<< "$entry"
  fetch "[$count/$total] $f" "cards-alt/$f" "$alt_url" || errors=$((errors + 1))
  sleep 0.3
done

echo ""
echo "Done: $errors errors total."
[[ $errors -eq 0 ]] && echo "Both sets ready — commit cards/ and cards-alt/."
