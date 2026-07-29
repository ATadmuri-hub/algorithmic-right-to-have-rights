#!/bin/bash
# LaTeX build for paper.tex using latexmk.
# Toolchain: TeX Live / TinyTeX with natbib + apalike.bst.
# latexmk handles the multi-pass bibliography logic automatically.

set -u
cd "$(dirname "$0")"

LATEXMK="$(command -v latexmk || true)"
if [ -z "$LATEXMK" ] && [ -x "$HOME/Library/TinyTeX/bin/universal-darwin/latexmk" ]; then
  LATEXMK="$HOME/Library/TinyTeX/bin/universal-darwin/latexmk"
fi
if [ -z "$LATEXMK" ]; then
  echo "latexmk not found. Install TeX Live or TinyTeX, or add latexmk to PATH." >&2
  exit 1
fi

echo "==> Building paper.tex (latexmk pdf mode)"
"$LATEXMK" -pdf -interaction=nonstopmode -outdir=build paper.tex 2>&1 | tail -8

[ -f build/paper.pdf ] && cp build/paper.pdf paper.pdf

echo ""
echo "==> Errors / warnings (final pass):"
LASTLOG=$(ls -t build/*.log 2>/dev/null | head -1)
[ -n "$LASTLOG" ] && grep -E "^(\!|LaTeX (Error|Warning)|Package .* (Error|Warning))" "$LASTLOG" \
  | grep -v "Citation .* undefined" | head -10

echo ""
[ -f paper.pdf ] && echo "==> SUCCESS: $(pwd)/paper.pdf"
