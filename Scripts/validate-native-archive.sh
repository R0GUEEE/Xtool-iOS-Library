#!/usr/bin/env bash
set -euo pipefail

ARCHIVE="${1:?usage: validate-native-archive.sh <archive.a> <kind>}"
KIND="${2:?usage: validate-native-archive.sh <archive.a> <kind>}"

if [ ! -f "$ARCHIVE" ]; then
  echo "Missing archive: $ARCHIVE" >&2
  exit 1
fi

ARCHS="$(xcrun lipo -archs "$ARCHIVE")"
case " $ARCHS " in
  *" arm64 "*) ;;
  *)
    echo "Archive is missing arm64 architecture: $ARCHS" >&2
    exit 1
    ;;
esac

SYMBOLS="$(mktemp)"
trap 'rm -f "$SYMBOLS"' EXIT
xcrun nm -gU "$ARCHIVE" > "$SYMBOLS"

require_symbol() {
  pattern="$1"
  description="$2"

  if ! grep -q "$pattern" "$SYMBOLS"; then
    echo "Missing required symbol: $description ($pattern)" >&2
    exit 1
  fi
}

case "$KIND" in
  llvm)
    require_symbol "lldMain" "LLD library entry point"
    require_symbol "ExecuteCompilerInvocation" "Clang frontend execution"
    require_symbol "CreateFromArgs" "Clang compiler invocation parser"
    ;;
  swift)
    require_symbol "performFrontend" "Swift frontend library entry point"
    ;;
  *)
    echo "Unknown archive kind: $KIND" >&2
    exit 1
    ;;
esac

echo "Validated $KIND archive:"
echo "  $ARCHIVE"
echo "  architectures: $ARCHS"
