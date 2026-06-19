#!/usr/bin/env bash
# Downloads all 48 hanafuda card SVGs from Wikimedia Commons into ./cards/
# Run from the hanafuda-guide directory: bash download-cards.sh
# Requires: curl, python3
# Card images are CC BY-SA 4.0, Spenĉjo et al.

set -euo pipefail

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
BASE="https://upload.wikimedia.org/wikipedia/commons"
DIR="$(cd "$(dirname "$0")" && pwd)/cards"
mkdir -p "$DIR"

# Wikimedia upload URL = BASE/{a}/{ab}/{filename}
# where a/ab are the first 1 and 2 chars of md5(filename)
wikimedia_url() {
  local filename="$1"
  local hash
  hash=$(python3 -c "import hashlib; print(hashlib.md5('$filename'.encode()).hexdigest())")
  echo "$BASE/${hash:0:1}/${hash:0:2}/${filename}"
}

# 6 Alt files that don't exist on upload.wikimedia.org — use the non-Alt original instead.
# The artwork is identical; only the border color differs (black vs red).
declare -A OVERRIDE
OVERRIDE["Hanafuda_March_Tanzaku_Alt.svg"]="$BASE/a/af/Hanafuda_March_Tanzaku.svg"
OVERRIDE["Hanafuda_March_Kasu_2_Alt.svg"]="$BASE/5/5b/Hanafuda_March_Kasu_2.svg"
OVERRIDE["Hanafuda_May_Tane_Alt.svg"]="$BASE/e/e1/Hanafuda_May_Tane.svg"
OVERRIDE["Hanafuda_May_Kasu_1_Alt.svg"]="$BASE/c/c9/Hanafuda_May_Kasu_1.svg"
OVERRIDE["Hanafuda_October_Tanzaku_Alt.svg"]="$BASE/3/3f/Hanafuda_October_Tanzaku.svg"
OVERRIDE["Hanafuda_November_Kasu_Alt.svg"]="$BASE/1/1f/Hanafuda_November_Kasu.svg"

files=(
  "Hanafuda_January_Hikari_Alt.svg"
  "Hanafuda_January_Tanzaku_Alt.svg"
  "Hanafuda_January_Kasu_1_Alt.svg"
  "Hanafuda_January_Kasu_2_Alt.svg"
  "Hanafuda_February_Tane_Alt.svg"
  "Hanafuda_February_Tanzaku_Alt.svg"
  "Hanafuda_February_Kasu_1_Alt.svg"
  "Hanafuda_February_Kasu_2_Alt.svg"
  "Hanafuda_March_Hikari_Alt.svg"
  "Hanafuda_March_Tanzaku_Alt.svg"
  "Hanafuda_March_Kasu_1_Alt.svg"
  "Hanafuda_March_Kasu_2_Alt.svg"
  "Hanafuda_April_Tane_Alt.svg"
  "Hanafuda_April_Tanzaku_Alt.svg"
  "Hanafuda_April_Kasu_1_Alt.svg"
  "Hanafuda_April_Kasu_2_Alt.svg"
  "Hanafuda_May_Tane_Alt.svg"
  "Hanafuda_May_Tanzaku_Alt.svg"
  "Hanafuda_May_Kasu_1_Alt.svg"
  "Hanafuda_May_Kasu_2_Alt.svg"
  "Hanafuda_June_Tane_Alt.svg"
  "Hanafuda_June_Tanzaku_Alt.svg"
  "Hanafuda_June_Kasu_1_Alt.svg"
  "Hanafuda_June_Kasu_2_Alt.svg"
  "Hanafuda_July_Tane_Alt.svg"
  "Hanafuda_July_Tanzaku_Alt.svg"
  "Hanafuda_July_Kasu_1_Alt.svg"
  "Hanafuda_July_Kasu_2_Alt.svg"
  "Hanafuda_August_Hikari_Alt.svg"
  "Hanafuda_August_Tane_Alt.svg"
  "Hanafuda_August_Kasu_1_Alt.svg"
  "Hanafuda_August_Kasu_2_Alt.svg"
  "Hanafuda_September_Tane_Alt.svg"
  "Hanafuda_September_Tanzaku_Alt.svg"
  "Hanafuda_September_Kasu_1_Alt.svg"
  "Hanafuda_September_Kasu_2_Alt.svg"
  "Hanafuda_October_Tane_Alt.svg"
  "Hanafuda_October_Tanzaku_Alt.svg"
  "Hanafuda_October_Kasu_1_Alt.svg"
  "Hanafuda_October_Kasu_2_Alt.svg"
  "Hanafuda_November_Hikari_Alt.svg"
  "Hanafuda_November_Tane_Alt.svg"
  "Hanafuda_November_Tanzaku_Alt.svg"
  "Hanafuda_November_Kasu_Alt.svg"
  "Hanafuda_December_Hikari_Alt.svg"
  "Hanafuda_December_Kasu_1_Alt.svg"
  "Hanafuda_December_Kasu_2_Alt.svg"
  "Hanafuda_December_Kasu_3_Alt.svg"
)

is_valid_svg() {
  [[ -f "$1" && -s "$1" ]] && head -c 20 "$1" | grep -qi '<svg'
}

echo "Checking existing files..."
for f in "${files[@]}"; do
  dest="$DIR/$f"
  if [[ -f "$dest" ]] && ! is_valid_svg "$dest"; then
    echo "  removing bad file: $f"
    rm "$dest"
  fi
done

echo "Fetching cards..."
total=${#files[@]}
count=0
errors=0

for f in "${files[@]}"; do
  count=$((count + 1))
  dest="$DIR/$f"

  if is_valid_svg "$dest"; then
    echo "[$count/$total] skip  $f"
    continue
  fi

  if [[ -n "${OVERRIDE[$f]:-}" ]]; then
    url="${OVERRIDE[$f]}"
  else
    url=$(wikimedia_url "$f")
  fi

  echo -n "[$count/$total] fetch $f ... "
  if curl -sL --max-redirs 5 --retry 3 --retry-delay 2 \
      -A "$UA" "$url" -o "$dest" \
      && is_valid_svg "$dest"; then
    echo "ok"
  else
    echo "FAILED (url: $url)"
    rm -f "$dest"
    errors=$((errors + 1))
  fi
  sleep 0.3
done

echo ""
echo "Done: $((total - errors))/$total downloaded, $errors errors."
if [[ $errors -eq 0 ]]; then
  echo "All cards present in cards/ — ready to commit."
else
  echo "Re-run to retry failed files."
fi
