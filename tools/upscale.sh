#!/usr/bin/env bash
#
# Upscale the legacy miku-hyoromo theme PNGs into icon-pack drawables.
#
# The originals are 72x72 (a handful are odd sizes). 144 is an exact 2x of that
# and is also what an xxhdpi/1080p launcher asks for, so the common case needs
# no runtime scaling and the offline resample stays on an integer factor.
# Output lands in drawable-nodpi so Android never rescales it a second time.
#
# Usage: tools/upscale.sh
set -euo pipefail

cd "$(dirname "$0")/.."

SRC="art/miku-hyoromo"
OUT="app/src/main/res/drawable-nodpi"
SIZE=144

command -v convert >/dev/null || { echo "ImageMagick 'convert' not found" >&2; exit 1; }

mkdir -p "$OUT"
rm -f "$OUT"/*.png

count=0
for f in "$SRC"/*.png; do
  name="$(basename "$f" .png)"
  # Wallpapers are not icons and are deliberately not shipped.
  [[ "$name" == default_wallpaper_* ]] && continue
  # d_home is the same drawing as allapp at 72px; shipping both puts two
  # identical-looking entries in every launcher's picker.
  [[ "$name" == d_home ]] && continue

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
