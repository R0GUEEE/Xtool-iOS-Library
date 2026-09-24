#!/usr/bin/env bash
set -euo pipefail

TAG="${1:-latest}"
DEST="${2:-Vendor/XtoolUnifiedCompiler}"
REPO="${XTOOL_COMPILER_REPO:-R0GUEEE/Xtool-iOS-Library}"
ASSET="XtoolUnifiedCompiler-ios-arm64.tar.gz"

command -v gh >/dev/null 2>&1 || {
  echo "error: gh CLI is required" >&2
  exit 1
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [ "$TAG" = "latest" ]; then
  gh release download     --repo "$REPO"     --pattern "$ASSET"     --dir "$TMP"
else
  gh release download "$TAG"     --repo "$REPO"     --pattern "$ASSET"     --dir "$TMP"
fi

test -f "$TMP/$ASSET"

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
"$SCRIPT_DIR/install-unified-toolchain-artifact.sh"   "$TMP/$ASSET"   "$DEST"

echo "Installed prebuilt compiler into: $DEST"
