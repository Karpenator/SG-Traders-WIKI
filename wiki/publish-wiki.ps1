# Publishes the markdown pages in .\pages\ to the GitHub wiki of this repository.
# Публикует страницы из .\pages\ в GitHub-вики этого репозитория.
#
# Usage / Использование:
#   .\publish-wiki.ps1                          # Karpenator/Syndicate-Project
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
    [string]$Repo = "Karpenator/Syndicate-Project"
)

$ErrorActionPreference = "Stop"

$WikiUrl  = "https://github.com/$Repo.wiki.git"
$PagesDir = Join-Path $PSScriptRoot "pages"
$WorkDir  = Join-Path ([System.IO.Path]::GetTempPath()) ("sgwiki-" + [guid]::NewGuid().ToString("N"))

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
        git add -A

        git diff --cached --quiet
        if ($LASTEXITCODE -eq 0) {
            Write-Host "==> Nothing changed, the wiki is already up to date."
            exit 0
        }

        git commit --quiet -m "Update SG_Traders configuration guide (RU/EN)"
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
