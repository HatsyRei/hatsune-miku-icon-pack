#!/usr/bin/env bash
#
# Generate the pack's own launcher icon from the theme's own icon art.
#
# Produces legacy square PNGs per density plus an adaptive-icon foreground for
# API 26+. Run after tools/upscale.sh.
#
# Usage: tools/gen_launcher_icon.sh
set -euo pipefail

cd "$(dirname "$0")/.."

SRC="art/miku-hyoromo/icon.png"
RES="app/src/main/res"

command -v convert >/dev/null || { echo "ImageMagick 'convert' not found" >&2; exit 1; }

# Legacy icon: full-bleed square at the five standard densities.
for entry in mdpi:48 hdpi:72 xhdpi:96 xxhdpi:144 xxxhdpi:192; do
  dpi="${entry%%:*}"
  px="${entry##*:}"
  mkdir -p "$RES/mipmap-$dpi"
  convert "$SRC" \
    -alpha set -alpha background \
    -filter Lanczos -resize "${px}x${px}" \
    -background none -gravity center -extent "${px}x${px}" \
    -strip PNG32:"$RES/mipmap-$dpi/ic_launcher.png"
done

# Adaptive foreground: 108dp canvas. The background layer is transparent, so the
# mask clips visible artwork rather than a filled shape -- keep the art inside
# the circle inscribed in the 72dp mask, not just the 72dp square.
mkdir -p "$RES/drawable-nodpi"
convert "$SRC" \
  -alpha set -alpha background \
  -filter Lanczos -resize 240x240 \
  -background none -gravity center -extent 432x432 \
  -strip PNG32:"$RES/drawable-nodpi/ic_launcher_foreground.png"

echo "Wrote launcher icons"
