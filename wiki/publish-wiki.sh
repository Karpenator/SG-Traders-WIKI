#!/usr/bin/env bash
# Publishes the markdown pages in ./pages/ to the GitHub wiki of this repository.
# Публикует страницы из ./pages/ в GitHub-вики этого репозитория.
#
# Usage / Использование:
#   ./publish-wiki.sh                       # Karpenator/SG-Traders-WIKI
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

REPO="${1:-Karpenator/SG-Traders-WIKI}"
WIKI_URL="https://github.com/${REPO}.wiki.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAGES_DIR="${SCRIPT_DIR}/pages"
WORK_DIR="$(mktemp -d)"

cleanup() { rm -rf "${WORK_DIR}"; }
trap cleanup EXIT

# Author identity: GIT_AUTHOR_* win, then the source repository's own git config
# (the wiki clone lives in a temp folder and has no config of its own),
# then a generic fallback.
# Автор: сначала GIT_AUTHOR_*, затем git-конфиг исходного репозитория (клон вики
# лежит во временной папке и своего конфига не имеет), затем запасной вариант.
GIT_NAME="${GIT_AUTHOR_NAME:-$(git -C "${SCRIPT_DIR}" config user.name 2>/dev/null || true)}"
GIT_MAIL="${GIT_AUTHOR_EMAIL:-$(git -C "${SCRIPT_DIR}" config user.email 2>/dev/null || true)}"
GIT_NAME="${GIT_NAME:-wiki-publisher}"
GIT_MAIL="${GIT_MAIL:-wiki-publisher@local}"

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

# Mirror deletions: a page removed from pages/ must disappear from the wiki too.
# cp only adds, so without this a deleted page stays published forever.
# Only *.md files are touched; anything else in the wiki (images, etc.) is left alone.
# Зеркалируем удаления: страница, удалённая из pages/, должна исчезнуть и из вики.
# cp только добавляет, поэтому без этого удалённая страница остаётся опубликованной.
# Задеваются только *.md; остальное в вики (картинки и т.п.) не трогаем.
for f in *.md; do
    [ -e "$f" ] || continue
    if [ ! -f "${PAGES_DIR}/${f}" ]; then
        echo "    removing ${f} (no longer in pages/)"
        rm -f "$f"
    fi
done

git add -A

if git diff --cached --quiet; then
    echo "==> Nothing changed, the wiki is already up to date."
    exit 0
fi

git -c user.name="${GIT_NAME}" \
    -c user.email="${GIT_MAIL}" \
    commit --quiet -m "Update SG_Traders configuration guide (RU/EN)"

git push --quiet origin HEAD

echo "==> Published: https://github.com/${REPO}/wiki"
