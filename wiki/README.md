# SG_Traders Wiki / Вики SG_Traders

Bilingual (RU/EN) configuration guide for the **SG_Traders** mod, published at <https://github.com/Karpenator/SG-Traders-WIKI/wiki>.

Двуязычное (RU/EN) руководство по настройке мода **SG_Traders**, опубликовано на <https://github.com/Karpenator/SG-Traders-WIKI/wiki>.

---

## What is here / Что здесь

```
wiki/
├── pages/                     ← the wiki pages themselves / сами страницы вики
│   ├── Home.md                    landing page, both languages / главная
│   ├── _Sidebar.md                wiki navigation / навигация вики
│   ├── _Footer.md                 footer on every page / подвал
│   ├── RU-*.md                    7 Russian pages / 7 русских страниц
│   └── EN-*.md                    7 English pages / 7 английских страниц
├── publish-wiki.sh            publisher for Linux / macOS / Git Bash
├── publish-wiki.ps1           publisher for Windows PowerShell
└── README.md                  this file / этот файл
```

The pages are plain GitHub-wiki markdown: they can be published as they are, or copied into the wiki editor by hand.

Страницы — обычный markdown для GitHub-вики: их можно опубликовать как есть или скопировать в редактор вики вручную.

---

## Publishing / Публикация

A GitHub wiki is a separate git repository (`<repo>.wiki.git`), and GitHub only creates it **after** the wiki is enabled and the first page is saved through the web interface. That part has to be done by someone with admin rights on the repository, once.

GitHub-вики — это отдельный git-репозиторий (`<repo>.wiki.git`), и GitHub создаёт его **только после** того, как вики включена и первая страница сохранена через веб-интерфейс. Эту часть один раз делает кто-то с правами администратора репозитория.

**✅ Already done for this repository.** Wikis are enabled on `Karpenator/SG-Traders-WIKI` and `https://github.com/Karpenator/SG-Traders-WIKI.wiki.git` exists, so you can go straight to the publisher below.

**✅ Для этого репозитория уже сделано.** Вики в `Karpenator/SG-Traders-WIKI` включена, `https://github.com/Karpenator/SG-Traders-WIKI.wiki.git` существует — можно сразу запускать публикацию.

### Publishing to another repository — one-time step in the browser / Публикация в другой репозиторий — одноразовый шаг в браузере

1. Open <https://github.com/Owner/Repo/settings> → **General** → **Features** → tick **Wikis** → **Save changes**.
   Откройте <https://github.com/Owner/Repo/settings> → **General** → **Features** → включите **Wikis** → **Save changes**.
2. Open the **Wiki** tab → **Create the first page** → **Save page** (any content, it will be overwritten).
   Откройте вкладку **Wiki** → **Create the first page** → **Save page** (содержимое любое, оно перезапишется).

### Run the publisher / Запустить публикацию

```bash
# Linux / macOS / Git Bash
cd wiki
./publish-wiki.sh
```

```powershell
# Windows PowerShell
cd wiki
.\publish-wiki.ps1
```

The script clones `https://github.com/Karpenator/SG-Traders-WIKI.wiki.git` into a temporary folder, copies everything from `pages/`, commits and pushes. It uses your existing GitHub credentials — the same ones `git push` uses for this repository. Nothing is written anywhere else.

Скрипт клонирует `https://github.com/Karpenator/SG-Traders-WIKI.wiki.git` во временную папку, копирует всё из `pages/`, делает коммит и пушит. Используются ваши обычные учётные данные GitHub — те же, что и для `git push` в этом репозитории. Больше ничего никуда не пишется.

For another repository: `./publish-wiki.sh Owner/Repo` or `.\publish-wiki.ps1 -Repo Owner/Repo`.

Для другого репозитория: `./publish-wiki.sh Owner/Repo` или `.\publish-wiki.ps1 -Repo Owner/Repo`.

### Publishing by hand / Публикация вручную

If you prefer the web interface: for every file in `pages/`, create a wiki page whose **title** is the file name without `.md` and with the dashes replaced by spaces (`RU-Быстрый-старт.md` → title `RU Быстрый старт`), then paste the file content. The links inside the pages are written for exactly those titles.

Если удобнее через веб-интерфейс: для каждого файла из `pages/` создайте страницу вики, у которой **название** совпадает с именем файла без `.md` и с пробелами вместо дефисов (`RU-Быстрый-старт.md` → название `RU Быстрый старт`), и вставьте содержимое файла. Ссылки внутри страниц написаны ровно под такие названия.

---

## Updating / Обновление

Edit the files in `pages/`, then run the publisher again. It skips the push when nothing changed, so it is safe to run after every edit.

Правьте файлы в `pages/` и снова запускайте публикацию. Если изменений нет, скрипт ничего не пушит — запускать его после каждой правки безопасно.

The field tables in the pages were written from `SGTradersConfig.c` in the mod's source tree (this repository holds documentation only — the mod itself lives elsewhere). If the config fields change there, update the matching page.

Таблицы полей на страницах составлены по файлу `SGTradersConfig.c` из исходников мода (в этом репозитории только документация — сам мод лежит отдельно). Если поля конфига там меняются, обновите соответствующую страницу.

---

## Page map / Карта страниц

| 🇷🇺 | 🇬🇧 | Contents / Содержимое |
|---|---|---|
| `RU-Быстрый-старт.md` | `EN-Quick-Start.md` | Installation, file layout, trade zones, first run / Установка, файлы, зоны, первый запуск |
| `RU-Главный-конфиг.md` | `EN-Main-Config.md` | `SGTradersConfig.json` field by field / Главный конфиг по полям |
| `RU-Файл-торговца.md` | `EN-Trader-File.md` | Trader file, the 8 defaults, adding and removing traders / Файл торговца, 8 стандартных, добавление и удаление |
| `RU-Товары-и-бартеры.md` | `EN-Items-And-Barters.md` | `Items`, `Barters`, categories, `QuestUnlock` / Товары, бартеры, категории |
| `RU-Скупка-и-лимиты.md` | `EN-Selling-And-Limits.md` | Sell price formula, categories, limits, hot item / Формула скупки, категории, лимиты, горячий товар |
| `RU-Лояльность-и-репутация.md` | `EN-Loyalty-And-Reputation.md` | Levels, thresholds, discount, turnover reputation / Уровни, пороги, скидка, репутация за оборот |
| `RU-Админка-и-решение-проблемы.md` | `EN-Admin-And-Troubleshooting.md` | Admin panel and every log message / Админ-панель и все сообщения лога |
