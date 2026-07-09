#!/usr/bin/env bash
# Re-vendor deps/yoga from a facebook/yoga tag. See deps/yoga/UPSTREAM.md.
#   scripts/update-yoga.sh v3.2.0
set -euo pipefail

TAG="${1:?usage: scripts/update-yoga.sh <upstream-tag, e.g. v3.2.0>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/deps/yoga"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Fetching facebook/yoga@$TAG ..."
curl -fsSL "https://github.com/facebook/yoga/archive/refs/tags/$TAG.tar.gz" | tar -xz -C "$TMP"
SRC="$(echo "$TMP"/yoga-*)"
SHA="$(curl -fsSL "https://api.github.com/repos/facebook/yoga/git/ref/tags/$TAG" | sed -n 's/.*"sha": "\([0-9a-f]*\)".*/\1/p' | head -1)"

KEEP=(yoga cmake CMakeLists.txt LICENSE LICENSE-examples README.md Yoga.podspec Package.swift yogaConfig.cmake CODE_OF_CONDUCT.md CONTRIBUTING.md)

echo "Replacing trim in $DEST (preserving build/ + UPSTREAM.md) ..."
for item in "${KEEP[@]}"; do
	rm -rf "${DEST:?}/$item"
	[ -e "$SRC/$item" ] && cp -R "$SRC/$item" "$DEST/$item"
done

TODAY="$(date +%Y-%m-%d)"
sed -i '' \
	-e "s|^- \*\*Vendored from\*\*:.*|- **Vendored from**: tag \`$TAG\` (${SHA:-sha-unknown}), $TODAY|" \
	"$DEST/UPSTREAM.md"

echo "Done. Next:"
echo "  scripts/build-yoga.sh macos"
echo "  msc build test/layout.test.ms --gc=drc --output=out/t && ./out/t"
echo "  git add -A deps/yoga && git commit -m 'chore: bump yoga to $TAG'"
