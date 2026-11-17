#!/usr/bin/env bash
# Повышает версию приложения в version.properties.
# Использование: scripts/bump-version.sh <launcher|redhood> <patch|minor|major> [file]
set -euo pipefail

COMPONENT="${1:?usage: bump-version.sh <launcher|redhood> <patch|minor|major> [file]}"
BUMP="${2:?usage: bump-version.sh <launcher|redhood> <patch|minor|major> [file]}"
FILE="${3:-version.properties}"

case "$COMPONENT" in
  launcher|redhood) ;;
  *) echo "::error::Unknown component '$COMPONENT'" >&2; exit 1 ;;
esac
case "$BUMP" in
  patch|minor|major) ;;
  *) echo "::error::Unknown bump '$BUMP'" >&2; exit 1 ;;
esac

NAME_KEY="${COMPONENT}.versionName"
CODE_KEY="${COMPONENT}.versionCode"

CURRENT="$(sed -n "s/^${NAME_KEY}=//p" "$FILE" | head -1)"
CURRENT_CODE="$(sed -n "s/^${CODE_KEY}=//p" "$FILE" | head -1)"

IFS=. read -r major minor patch <<< "$CURRENT"

case "$BUMP" in
  major) major=$((major + 1)); minor=0; patch=0 ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  patch) patch=$((patch + 1)) ;;
esac

NEW="$major.$minor.$patch"

if [ "$COMPONENT" = "launcher" ]; then
  # 1.8.0 -> 1080000, 1.8.1 -> 1080100, 1.9.0 -> 1090000, 2.0.0 -> 2000000
  NEW_CODE=$((major * 1000000 + minor * 10000 + patch * 100))
else
  # У игры своя нумерация (105006), поэтому просто монотонный инкремент.
  NEW_CODE=$((CURRENT_CODE + 1))
fi

if [ "$NEW_CODE" -le "$CURRENT_CODE" ]; then
  echo "::error::versionCode must increase ($CURRENT_CODE -> $NEW_CODE)" >&2
  exit 1
fi

sed -i.bak "s/^${NAME_KEY}=.*/${NAME_KEY}=${NEW}/" "$FILE"
sed -i.bak "s/^${CODE_KEY}=.*/${CODE_KEY}=${NEW_CODE}/" "$FILE"
rm -f "${FILE}.bak"

echo "component=$COMPONENT"
echo "previous=$CURRENT"
echo "version=$NEW"
echo "code=$NEW_CODE"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    echo "component=$COMPONENT"
    echo "previous=$CURRENT"
    echo "version=$NEW"
    echo "code=$NEW_CODE"
  } >> "$GITHUB_OUTPUT"
fi
