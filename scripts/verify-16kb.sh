#!/usr/bin/env bash
# Проверяет 16 KB-выравнивание 64-битных библиотек в AAB.
# Использование: scripts/verify-16kb.sh path/to/app.aab
set -euo pipefail

AAB="${1:?usage: verify-16kb.sh <app.aab>}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

unzip -q "$AAB" 'base/lib/*' -d "$WORK"

READELF="$(find "${ANDROID_SDK_ROOT:-$ANDROID_HOME}/ndk" -name llvm-readelf -type f | head -1)"
if [ -z "$READELF" ]; then
  echo "llvm-readelf not found in NDK" >&2
  exit 1
fi

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
