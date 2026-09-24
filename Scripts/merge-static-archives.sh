#!/usr/bin/env bash
set -euo pipefail

INPUT_DIR="${1:?usage: merge-static-archives.sh <input-dir> <output.a> [manifest.txt]}"
OUTPUT="${2:?usage: merge-static-archives.sh <input-dir> <output.a> [manifest.txt]}"
MANIFEST="${3:-${OUTPUT%.a}.libraries.txt}"

command -v xcrun >/dev/null

mapfile_safe() {
  while IFS= read -r -d '' file; do
    printf '%s\n' "$file"
  done
}

LIBS=()
while IFS= read -r file; do
  LIBS+=("$file")
done < <(find "$INPUT_DIR" -type f -name '*.a' -print0 | mapfile_safe | sort)

if [ "${#LIBS[@]}" -eq 0 ]; then
  echo "No static archives found under $INPUT_DIR" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"
rm -f "$OUTPUT"

printf '%s\n' "${LIBS[@]}" > "$MANIFEST"

# Apple libtool can combine static archives directly. Build in chunks to avoid
# command-line length limits on large Swift/LLVM library sets.
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

CHUNK_SIZE=40
CHUNKS=()
index=0

while [ "$index" -lt "${#LIBS[@]}" ]; do
  chunk="$WORK_DIR/chunk-$((index / CHUNK_SIZE)).a"
  slice=("${LIBS[@]:index:CHUNK_SIZE}")
  xcrun libtool -static -o "$chunk" "${slice[@]}"
  CHUNKS+=("$chunk")
  index=$((index + CHUNK_SIZE))
done

xcrun libtool -static -o "$OUTPUT" "${CHUNKS[@]}"

echo "Merged ${#LIBS[@]} archives into:"
echo "  $OUTPUT"
echo "Manifest:"
echo "  $MANIFEST"
