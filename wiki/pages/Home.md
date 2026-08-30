# SG_Traders — Configuration Guide / Руководство по настройке

Traders with loyalty levels for DayZ. Eight traders out of the box, everything tuned through JSON — no code changes needed.

Торговцы с уровнями лояльности для DayZ. Восемь торговцев из коробки, вся настройка через JSON — без правки кода.

---

## Choose your language / Выберите язык

| 🇷🇺 Русский | 🇬🇧 English |
|---|---|
| [Быстрый старт](RU-Быстрый-старт) | [Quick Start](EN-Quick-Start) |
| [Главный конфиг](RU-Главный-конфиг) | [Main Config](EN-Main-Config) |
| [Файл торговца](RU-Файл-торговца) | [Trader File](EN-Trader-File) |
| [Товары и бартеры](RU-Товары-и-бартеры) | [Items And Barters](EN-Items-And-Barters) |
| [Скупка и лимиты](RU-Скупка-и-лимиты) | [Selling And Limits](EN-Selling-And-Limits) |
| [Лояльность и репутация](RU-Лояльность-и-репутация) | [Loyalty And Reputation](EN-Loyalty-And-Reputation) |
| [Админка и решение проблем](RU-Админка-и-решение-проблемы) | [Admin And Troubleshooting](EN-Admin-And-Troubleshooting) |

Start here / Начните отсюда: **[Быстрый старт](RU-Быстрый-старт)** · **[Quick Start](EN-Quick-Start)**

---

## In 60 seconds / За 60 секунд

**EN.** After the first server start the mod creates `$profile:SG_Traders\` with a main config and one JSON file per trader. Edit those files, restart the server, done. The three things people change most often:

1. **`TradeZones`** in `SGTradersConfig.json` — where the board can be opened. Without a zone covering your base the mod looks broken.
2. **`Items`** in a trader file — the assortment: classname, price, loyalty level, per-player stock.
3. **`SellPriceRatio` + `SellCategories`** — what the trader buys and for how much.

**RU.** После первого запуска сервер создаёт `$profile:SG_Traders\` с главным конфигом и отдельным JSON-файлом на каждого торговца. Правите файлы, перезапускаете сервер — готово. Три вещи, которые меняют чаще всего:

1. **`TradeZones`** в `SGTradersConfig.json` — где можно открыть доску. Без зоны на вашей базе мод выглядит «сломанным».
2. **`Items`** в файле торговца — ассортимент: класснейм, цена, уровень лояльности, личный лимит.
3. **`SellPriceRatio` + `SellCategories`** — что торговец скупает и по чём.

---

## Files at a glance / Файлы одним взглядом

| File / Файл | Edit? / Править? | Purpose / Назначение |
|---|---|---|
| `SGTradersConfig.json` | ✅ | Zones, admins, global prices, trader roster / Зоны, админы, общие цены, список торговцев |
| `Traders\SGTrader_<ID>.json` | ✅ | One trader: currency, assortment, loyalty / Один торговец: валюта, ассортимент, лояльность |
| `SGTradersState.json` | ❌ | Restock timers, current hot item / Таймеры завоза, текущий «горячий товар» |
| `players\<SteamID64>.json` | ❌ | Wallet, turnover, reputation, limits / Кошелёк, оборот, репутация, лимиты |

---

## Safety rules / Правила безопасности

* **EN:** Stop the server before editing. Never edit a running server — the admin panel rewrites the config files from memory and will wipe live hand edits.
* **RU:** Останавливайте сервер перед правкой. Не правьте на работающем сервере — админ-панель перезаписывает конфиги из памяти и сотрёт «живые» правки.

* **EN:** JSON has no comments. A `//` line, a trailing comma or a smart quote will make the whole file fail to load.
* **RU:** В JSON нет комментариев. Строка с `//`, лишняя запятая или «ёлочки» вместо кавычек — и файл не загрузится целиком.

* **EN:** A typo in a classname never crashes the server — the offer is dropped and a `WARNING` appears in the log.
* **RU:** Опечатка в класснейме не роняет сервер — товар удаляется, а в лог уходит `WARNING`.
