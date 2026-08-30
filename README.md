# SG_Traders Wiki / Вики SG_Traders

**👉 Live wiki / Живая вики: <https://github.com/Karpenator/SG-Traders-WIKI/wiki>**

Bilingual (RU/EN) configuration guide for the **SG_Traders** DayZ mod: traders with loyalty levels, 8 traders out of the box, everything tuned through JSON.

Двуязычное (RU/EN) руководство по настройке мода **SG_Traders** для DayZ: торговцы с уровнями лояльности, 8 торговцев из коробки, вся настройка через JSON.

This repository holds the wiki **sources**. The published wiki is a separate git repository (`Karpenator/SG-Traders-WIKI.wiki.git`) that the publisher script pushes to.

В этом репозитории лежат **исходники** вики. Опубликованная вики — это отдельный git-репозиторий (`Karpenator/SG-Traders-WIKI.wiki.git`), в который пушит скрипт публикации.

---

## Pages / Страницы

| 🇷🇺 | 🇬🇧 | Contents / Содержимое |
|---|---|---|
| [RU Быстрый старт](https://github.com/Karpenator/SG-Traders-WIKI/wiki/RU-Быстрый-старт) | [EN Quick Start](https://github.com/Karpenator/SG-Traders-WIKI/wiki/EN-Quick-Start) | Installation, file layout, trade zones, first run / Установка, файлы, зоны, первый запуск |
| [RU Главный конфиг](https://github.com/Karpenator/SG-Traders-WIKI/wiki/RU-Главный-конфиг) | [EN Main Config](https://github.com/Karpenator/SG-Traders-WIKI/wiki/EN-Main-Config) | `SGTradersConfig.json` field by field / Главный конфиг по полям |
| [RU Файл торговца](https://github.com/Karpenator/SG-Traders-WIKI/wiki/RU-Файл-торговца) | [EN Trader File](https://github.com/Karpenator/SG-Traders-WIKI/wiki/EN-Trader-File) | Trader file, the 8 defaults, adding and removing traders / Файл торговца, 8 стандартных |
| [RU Товары и бартеры](https://github.com/Karpenator/SG-Traders-WIKI/wiki/RU-Товары-и-бартеры) | [EN Items And Barters](https://github.com/Karpenator/SG-Traders-WIKI/wiki/EN-Items-And-Barters) | `Items`, `Barters`, categories, `QuestUnlock` / Товары, бартеры, категории |
| [RU Скупка и лимиты](https://github.com/Karpenator/SG-Traders-WIKI/wiki/RU-Скупка-и-лимиты) | [EN Selling And Limits](https://github.com/Karpenator/SG-Traders-WIKI/wiki/EN-Selling-And-Limits) | Sell price formula, categories, limits, hot item / Формула скупки, лимиты, горячий товар |
| [RU Лояльность и репутация](https://github.com/Karpenator/SG-Traders-WIKI/wiki/RU-Лояльность-и-репутация) | [EN Loyalty And Reputation](https://github.com/Karpenator/SG-Traders-WIKI/wiki/EN-Loyalty-And-Reputation) | Levels, thresholds, discount, turnover reputation / Уровни, пороги, скидка |
| [RU Админка и решение проблем](https://github.com/Karpenator/SG-Traders-WIKI/wiki/RU-Админка-и-решение-проблемы) | [EN Admin And Troubleshooting](https://github.com/Karpenator/SG-Traders-WIKI/wiki/EN-Admin-And-Troubleshooting) | Admin panel and every log message / Админ-панель и сообщения лога |

---

## Layout / Структура

```
wiki/
├── pages/                     ← wiki page sources / исходники страниц
│   ├── Home.md                    landing page / главная
│   ├── _Sidebar.md                wiki navigation / навигация
│   ├── _Footer.md                 footer on every page / подвал
│   ├── RU-*.md                    7 Russian pages / 7 русских страниц
│   └── EN-*.md                    7 English pages / 7 английских страниц
├── publish-wiki.sh            publisher for Linux / macOS / Git Bash
├── publish-wiki.ps1           publisher for Windows PowerShell
└── README.md                  details on publishing / подробности публикации
```

## Editing and publishing / Правки и публикация

1. Edit the markdown files in `wiki/pages/`. Правьте markdown-файлы в `wiki/pages/`.
2. Run `./wiki/publish-wiki.sh` (or `wiki\publish-wiki.ps1` on Windows). Запустите `./wiki/publish-wiki.sh` (или `wiki\publish-wiki.ps1` в Windows).
3. The script clones the wiki repository, copies `pages/`, commits and pushes — it does nothing when there are no changes. Скрипт клонирует репозиторий вики, копирует `pages/`, делает коммит и пушит; если изменений нет — ничего не происходит.

Details, manual publishing through the web editor and the page naming rules: [`wiki/README.md`](wiki/README.md).

Подробности, публикация вручную через веб-редактор и правила наименования страниц: [`wiki/README.md`](wiki/README.md).
