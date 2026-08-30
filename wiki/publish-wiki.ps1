# Publishes the markdown pages in .\pages\ to the GitHub wiki of this repository.
# Публикует страницы из .\pages\ в GitHub-вики этого репозитория.
#
# Usage / Использование:
#   .\publish-wiki.ps1                          # Karpenator/SG-Traders-WIKI
#   .\publish-wiki.ps1 -Repo Owner/Other-Repo   # another repository
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

param(
    [string]$Repo = "Karpenator/SG-Traders-WIKI"
)

$ErrorActionPreference = "Stop"

$WikiUrl  = "https://github.com/$Repo.wiki.git"
$PagesDir = Join-Path $PSScriptRoot "pages"
$WorkDir  = Join-Path ([System.IO.Path]::GetTempPath()) ("sgwiki-" + [guid]::NewGuid().ToString("N"))

# Author identity: GIT_AUTHOR_* win, then the source repository's own git config
# (the wiki clone lives in a temp folder and has no config of its own),
# then a generic fallback. Same logic as publish-wiki.sh.
# Автор: сначала GIT_AUTHOR_*, затем git-конфиг исходного репозитория, затем запасной
# вариант. Та же логика, что и в publish-wiki.sh.
function Read-SourceGitConfig([string]$Key) {
    # Defensive on purpose: $ErrorActionPreference is "Stop" here, and redirecting a
    # native command's stderr under that setting can turn stderr output into a
    # terminating error. Lower the preference for the call and swallow failures, so
    # a missing key or a missing git binary just means "no value", not a crash.
    # Намеренно защитно: $ErrorActionPreference здесь "Stop", а перенаправление stderr
    # внешней команды в этом режиме может превратить вывод в завершающую ошибку.
    # Снижаем предпочтение на время вызова: нет ключа или нет git — значит просто
    # "нет значения", а не падение.
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try {
        $v = & git -C $PSScriptRoot config $Key 2>$null
        if ($LASTEXITCODE -ne 0) { return $null }
        $s = ($v | Out-String).Trim()
        if ([string]::IsNullOrWhiteSpace($s)) { return $null }
        return $s
    }
    catch {
        return $null
    }
    finally {
        $ErrorActionPreference = $prev
    }
}

$GitName = $env:GIT_AUTHOR_NAME
if (-not $GitName) { $GitName = Read-SourceGitConfig "user.name" }
if (-not $GitName) { $GitName = "wiki-publisher" }

$GitMail = $env:GIT_AUTHOR_EMAIL
if (-not $GitMail) { $GitMail = Read-SourceGitConfig "user.email" }
if (-not $GitMail) { $GitMail = "wiki-publisher@local" }

if (-not (Test-Path $PagesDir)) {
    Write-Error "ERROR: $PagesDir not found. Run this script from the wiki\ folder."
    exit 1
}

Write-Host "==> Checking $WikiUrl"
git ls-remote $WikiUrl *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "The wiki repository does not exist yet / Репозиторий вики ещё не создан."
    Write-Host ""
    Write-Host "Do this once in the browser / Сделайте один раз в браузере:"
    Write-Host "  1. https://github.com/$Repo/settings  ->  Features  ->  enable `"Wikis`""
    Write-Host "  2. Wiki tab -> `"Create the first page`" -> Save page"
    Write-Host ""
    Write-Host "Then run this script again / Затем запустите этот скрипт ещё раз."
    exit 1
}

try {
    Write-Host "==> Cloning the wiki"
    git clone --quiet $WikiUrl $WorkDir
    if ($LASTEXITCODE -ne 0) { throw "git clone failed" }

    $pages = Get-ChildItem -Path $PagesDir -Filter *.md
    Write-Host "==> Copying $($pages.Count) pages"
    Copy-Item -Path (Join-Path $PagesDir "*.md") -Destination $WorkDir -Force

    Push-Location $WorkDir
    try {
        # Mirror deletions: a page removed from pages\ must disappear from the wiki too.
        # Copy-Item only adds, so without this a deleted page stays published forever.
        # Only *.md files are touched; anything else in the wiki is left alone.
        # Зеркалируем удаления: страница, удалённая из pages\, должна исчезнуть и из вики.
        # Copy-Item только добавляет, поэтому без этого удалённая страница остаётся опубликованной.
        # Задеваются только *.md; остальное в вики не трогаем.
        Get-ChildItem -Path $WorkDir -Filter *.md | ForEach-Object {
            if (-not (Test-Path (Join-Path $PagesDir $_.Name))) {
                Write-Host "    removing $($_.Name) (no longer in pages\)"
                Remove-Item -Path $_.FullName -Force
            }
        }

        git add -A

        git diff --cached --quiet
        if ($LASTEXITCODE -eq 0) {
            Write-Host "==> Nothing changed, the wiki is already up to date."
            exit 0
        }

        # Quote each -c argument as a whole: with user.name="First Last" an unquoted
        # form would split on the space and hand git two broken arguments.
        # Кавычки вокруг аргумента целиком: при user.name="First Last" незакавыченная
        # форма развалилась бы по пробелу и передала git два битых аргумента.
        git -c "user.name=$GitName" -c "user.email=$GitMail" commit --quiet -m "Update SG_Traders configuration guide (RU/EN)"
        if ($LASTEXITCODE -ne 0) { throw "git commit failed" }

        git push --quiet origin HEAD
        if ($LASTEXITCODE -ne 0) { throw "git push failed" }
    }
    finally {
        Pop-Location
    }

    Write-Host "==> Published: https://github.com/$Repo/wiki"
}
finally {
    if (Test-Path $WorkDir) {
        Remove-Item -Recurse -Force $WorkDir
    }
}
