#!/usr/bin/env bash
set -euo pipefail

ARCHIVE="${1:?usage: validate-unified-toolchain.sh <archive.a>}"

if [ ! -f "$ARCHIVE" ]; then
  echo "Missing archive: $ARCHIVE" >&2
  exit 1
fi

ARCHS="$(xcrun lipo -archs "$ARCHIVE")"
case " $ARCHS " in
  *" arm64 "*) ;;
  *)
    echo "Expected arm64 archive, found: $ARCHS" >&2
    exit 1
    ;;
esac

SYMBOLS="$(mktemp)"
trap 'rm -f "$SYMBOLS"' EXIT
xcrun nm -gU "$ARCHIVE" > "$SYMBOLS"

require_any() {
  description="$1"
  shift

  for pattern in "$@"; do
    if grep -q "$pattern" "$SYMBOLS"; then
      echo "Found $description: $pattern"
      return 0
    fi
  done

  echo "Missing $description" >&2
  printf '  expected one of: %s\n' "$*" >&2
  exit 1
}

require_any   "Swift frontend"   "performFrontend"

require_any   "Clang compiler invocation"   "CreateFromArgs"   "ExecuteCompilerInvocation"

require_any   "LLD entry point"   "lldMain"

echo "Unified toolchain archive validated:"
echo "  $ARCHIVE"
echo "  architectures: $ARCHS"
