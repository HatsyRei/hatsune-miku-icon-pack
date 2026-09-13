#!/usr/bin/env bash
#
# Upscale the legacy miku-hyoromo theme PNGs into icon-pack drawables.
#
# The originals are 72x72 (a handful are odd sizes). Modern launchers ask for up
# to 192px on xxxhdpi, so everything is resampled to 192x192 with Lanczos and
# padded to square on transparency. Output lands in drawable-nodpi so Android
# never rescales them a second time.
#
# Usage: tools/upscale.sh
set -euo pipefail

cd "$(dirname "$0")/.."

SRC="art/miku-hyoromo"
OUT="app/src/main/res/drawable-nodpi"
SIZE=192

command -v convert >/dev/null || { echo "ImageMagick 'convert' not found" >&2; exit 1; }

mkdir -p "$OUT"
rm -f "$OUT"/*.png

count=0
for f in "$SRC"/*.png; do
  name="$(basename "$f" .png)"
  # Wallpapers are not icons and are deliberately not shipped.
  [[ "$name" == default_wallpaper_* ]] && continue

  # -alpha background zeroes the colour of fully transparent pixels first;
  # without it the resampler blends undefined RGB into the edges as a halo.
  convert "$f" \
    -alpha set \
    -alpha background \
    -filter Lanczos \
    -resize "${SIZE}x${SIZE}" \
    -background none \
    -gravity center \
    -extent "${SIZE}x${SIZE}" \
    -strip \
    PNG32:"$OUT/$name.png"

  count=$((count + 1))
done

echo "Wrote $count drawables to $OUT"
