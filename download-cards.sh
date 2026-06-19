#!/usr/bin/env bash
# Downloads all 48 hanafuda card SVGs from Wikimedia Commons into ./cards/
# Run from the hanafuda-guide directory: bash download-cards.sh
# Requires: curl
# License: card images are CC BY-SA 4.0, Spenĉjo et al.

set -euo pipefail
UA="Mozilla/5.0 (compatible; hanafuda-guide/1.0; +https://github.com/indygwyn)"
BASE="https://commons.wikimedia.org/wiki/Special:FilePath"
DIR="$(dirname "$0")/cards"
mkdir -p "$DIR"

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

total=${#files[@]}
count=0
errors=0

for f in "${files[@]}"; do
  count=$((count + 1))
  dest="$DIR/$f"
  if [[ -f "$dest" && -s "$dest" ]]; then
    echo "[$count/$total] skip  $f"
    continue
  fi
  echo -n "[$count/$total] fetch $f ... "
  if curl -sL -A "$UA" "$BASE/$f" -o "$dest" && [[ -s "$dest" ]]; then
    echo "ok"
  else
    echo "FAILED"
    rm -f "$dest"
    errors=$((errors + 1))
  fi
  sleep 0.3  # be polite to Wikimedia
done

echo ""
echo "Done: $((total - errors))/$total downloaded, $errors errors."
[[ $errors -eq 0 ]] && echo "All cards present — commit the cards/ directory."
