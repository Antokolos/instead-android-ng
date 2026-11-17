#!/usr/bin/env bash
# Проверяет 16 KB-выравнивание 64-битных библиотек в AAB.
# Использование: scripts/verify-16kb.sh path/to/app.aab
set -euo pipefail

AAB="${1:?usage: verify-16kb.sh <app.aab>}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

unzip -q "$AAB" 'base/lib/*' -d "$WORK"

READELF=""
NDK_DIR="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [ -n "$NDK_DIR" ] && [ -d "$NDK_DIR/ndk" ]; then
  # Без -type f: llvm-readelf в NDK может быть симлинком.
  READELF="$(find "$NDK_DIR/ndk" -name llvm-readelf 2>/dev/null | head -1)"
fi
if [ -z "$READELF" ]; then
  READELF="$(command -v llvm-readelf || true)"
fi
if [ -z "$READELF" ]; then
  READELF="$(command -v readelf || true)"
fi
if [ -z "$READELF" ]; then
  echo "No ELF reader found (llvm-readelf or readelf)" >&2
  exit 1
fi
echo "Using $READELF"

fail=0
for so in $(find "$WORK/base/lib" -name '*.so' | grep -E '/(arm64-v8a|x86_64)/' | sort); do
  align="$("$READELF" -l "$so" | awk '/LOAD/{print $NF}' | sort -u | tail -1)"
  echo "$so -> $align"
  if [ "$align" != "0x4000" ]; then
    echo "FAIL: $so is not 16 KB aligned" >&2
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "16 KB alignment OK"
