#!/bin/bash

SVG="$1"
OUT="$2"
outdir="$OUT.iconset"

function to_png() {
  size="$1"
  name="$2"
  rsvg-convert -a -w $size -f png "$SVG" -o "$outdir/icon_"$name"x"$name"@2x.png"
}

mkdir -p "$outdir"
to_png 1024 512
to_png 512 256
to_png 256 128
to_png 64 32
to_png 32 16

iconutil -c icns "$outdir" -o "$OUT.icns"

