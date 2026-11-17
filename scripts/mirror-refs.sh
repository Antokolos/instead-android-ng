#!/usr/bin/env bash
# Зеркалирует ветки и теги текущего репозитория в парный (PEER).
# Fast-forward-only: чужие коммиты не перезаписываются, расхождение — ошибка.
#
# Переменные:
#   PEER        owner/repo второго репозитория (обязательно)
#   MIRROR_TOKEN token с правом Contents: read/write на оба репозитория
#   PEER_URL    необязательно: явный URL (для локальных тестов)
set -euo pipefail

PEER="${PEER:?PEER (owner/repo) is required}"

if [ -n "${PEER_URL:-}" ]; then
  REMOTE_URL="$PEER_URL"
else
  REMOTE_URL="https://x-access-token:${MIRROR_TOKEN:?MIRROR_TOKEN is required}@github.com/${PEER}.git"
fi

git config user.name "${GIT_AUTHOR_NAME:-instead-mirror-bot}"
git config user.email "${GIT_AUTHOR_EMAIL:-instead-mirror-bot@users.noreply.github.com}"

# Свой репозиторий читаем токеном Actions (нужно для приватных репозиториев),
# в второй пишем personal access token'ом его владельца.
if [ -n "${GITHUB_TOKEN:-}" ] && [ -n "${GITHUB_REPOSITORY:-}" ]; then
  git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
fi

git fetch origin '+refs/heads/*:refs/remotes/origin/*' '+refs/tags/*:refs/tags/*'

git remote remove peer > /dev/null 2>&1 || true
git remote add peer "$REMOTE_URL"
git fetch peer '+refs/heads/*:refs/remotes/peer/*'

status=0

for branch in $(git for-each-ref --format='%(refname:lstrip=3)' refs/remotes/origin); do
  [ "$branch" = "HEAD" ] && continue
  local="refs/remotes/origin/$branch"
  remote="refs/remotes/peer/$branch"

  if ! git rev-parse --verify "$remote" > /dev/null 2>&1; then
    echo "create $branch"
    git push peer "$local:refs/heads/$branch"
    continue
  fi

  if git merge-base --is-ancestor "$remote" "$local"; then
    echo "update $branch"
    git push peer "$local:refs/heads/$branch"
  elif git merge-base --is-ancestor "$local" "$remote"; then
    echo "skip $branch: peer is ahead"
  else
    echo "::error::Branch '$branch' has diverged between the repositories; merge it manually and push again"
    status=1
  fi
done

for tag in $(git tag); do
  if ! git ls-remote --tags peer "refs/tags/$tag" | grep -q .; then
    echo "create tag $tag"
    git push peer "refs/tags/$tag"
  fi
done

exit "$status"
