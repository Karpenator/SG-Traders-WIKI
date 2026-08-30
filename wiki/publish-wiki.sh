#!/usr/bin/env bash
# Publishes the markdown pages in ./pages/ to the GitHub wiki of this repository.
# Публикует страницы из ./pages/ в GitHub-вики этого репозитория.
#
# Usage / Использование:
#   ./publish-wiki.sh                       # Karpenator/Syndicate-Project
#   ./publish-wiki.sh Owner/Other-Repo      # another repository
#
# One-time preparation in the browser (the wiki git repository does not exist
# until this is done):
#   1. Settings -> General -> Features -> enable "Wikis"
#   2. Open the Wiki tab -> "Create the first page" -> Save
#
# Одноразовая подготовка в браузере (git-репозиторий вики не существует, пока
# это не сделано):
#   1. Settings -> General -> Features -> включить "Wikis"
#   2. Вкладка Wiki -> "Create the first page" -> Save

set -euo pipefail

REPO="${1:-Karpenator/Syndicate-Project}"
WIKI_URL="https://github.com/${REPO}.wiki.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAGES_DIR="${SCRIPT_DIR}/pages"
WORK_DIR="$(mktemp -d)"

cleanup() { rm -rf "${WORK_DIR}"; }
trap cleanup EXIT

if [ ! -d "${PAGES_DIR}" ]; then
    echo "ERROR: ${PAGES_DIR} not found. Run this script from the wiki/ folder." >&2
    exit 1
fi

echo "==> Checking ${WIKI_URL}"
if ! git ls-remote "${WIKI_URL}" >/dev/null 2>&1; then
    cat >&2 <<MSG

The wiki repository does not exist yet / Репозиторий вики ещё не создан.

Do this once in the browser / Сделайте один раз в браузере:
  1. https://github.com/${REPO}/settings  ->  Features  ->  enable "Wikis"
  2. Wiki tab -> "Create the first page" -> Save page

Then run this script again / Затем запустите этот скрипт ещё раз.

MSG
    exit 1
fi

echo "==> Cloning the wiki"
git clone --quiet "${WIKI_URL}" "${WORK_DIR}/wiki"

echo "==> Copying $(ls -1 "${PAGES_DIR}"/*.md | wc -l | tr -d ' ') pages"
cp -f "${PAGES_DIR}"/*.md "${WORK_DIR}/wiki/"

cd "${WORK_DIR}/wiki"
git add -A

if git diff --cached --quiet; then
    echo "==> Nothing changed, the wiki is already up to date."
    exit 0
fi

git -c user.name="${GIT_AUTHOR_NAME:-$(git config user.name || echo 'wiki-publisher')}" \
    -c user.email="${GIT_AUTHOR_EMAIL:-$(git config user.email || echo 'wiki-publisher@local')}" \
    commit --quiet -m "Update SG_Traders configuration guide (RU/EN)"

git push --quiet origin HEAD

echo "==> Published: https://github.com/${REPO}/wiki"
