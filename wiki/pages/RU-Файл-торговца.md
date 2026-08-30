# Файл торговца — `Traders\SGTrader_<ID>.json`

[🇬🇧 English version](EN-Trader-File)

**Что это:** один файл = один торговец. Внутри — его валюта, цены скупки, уровни лояльности и весь ассортимент. Файлы независимы: можно править одного торговца, не трогая остальных.

Путь: `$profile:SG_Traders\Traders\SGTrader_PRAPOR.json` и так далее.

---

## 8 торговцев из коробки

| ID | Имя | Валюта | Доля скупки | Завоз, мин | Пороги оборота (II/III/IV) | Пороги репутации | Общий лимит скупки | `SellCategories` | Товаров | Бартеров |
|---|---|---|---|---|---|---|---|---|---|---|
| `PRAPOR` | Прапор | RUB | 0.50 | 120 | 12 000 / 45 000 / 120 000 | 0.04 / 0.09 / 0.15 | без лимита | `WEAPONS`, `MAGAZINES`, `AMMO` | 99 | 0 |
| `THERAPIST` | Терапевт | RUB | 0.55 | 120 | 6 000 / 22 000 / 65 000 | 0.04 / 0.09 / 0.15 | 10 | `MEDICAL`, `FOOD` | 147 | 0 |
| `MECHANIC` | Механик | RUB | 0.50 | 180 | 9 000 / 32 000 / 90 000 | 0.04 / 0.09 / 0.15 | без лимита | `TOOLS`, `VALUABLES`, `MAGAZINES` | 417 | 2 |
| `SKIER` | Лыжник | RUB | 0.45 | 180 | 8 000 / 30 000 / 85 000 | 0.05 / 0.10 / 0.16 | без лимита | `VESTS`, `BACKPACKS`, `CLOTHING` | 821 | 1 |
| `FENCE` | Скупщик | RUB | 0.30 | 90 | 15 000 / 60 000 / 180 000 | — (не заданы) | 5 | `ALL` | 219 | 0 |
| `PEACEKEEPER` | Миротворец | **USD** | 0.50 | 240 | 800 / 3 500 / 12 000 | 0.06 / 0.12 / 0.18 | без лимита | `WEAPONS`, `MAGAZINES`, `AMMO`, `VALUABLES` | 63 | 0 |
| `JAEGER` | Егерь | RUB | 0.50 | 150 | 5 000 / 18 000 / 50 000 | 0.05 / 0.10 / 0.16 | 12 | `FOOD`, `TOOLS`, `WEAPONS`, `AMMO` | 52 | 0 |
| `REF` | Реф | RUB | 0.40 | 240 | 4 000 / 15 000 / 40 000 | 0.05 / 0.11 / 0.17 | 6 | `VALUABLES`, `TOOLS` | 156 | 1 |

Итого 1 974 товара и 4 бартера. У Скупщика (`FENCE`) пороги репутации не заданы — его уровни зависят только от оборота.

---

## Как выглядит файл (сокращённо)

```json
{
    "Id": "PRAPOR",
    "NameKey": "#STR_SGTR_trader_prapor",
    "Portrait": "prapor",
    "Currency": "RUB",
    "SellPriceRatio": 0.5,
    "DefaultSellLimit": -1,
    "RestockMinutes": 120,
    "HotItemBoost": 0.0,
    "HotItemPool": [],
    "LoyaltyThresholds": [ 12000, 45000, 120000 ],
    "LoyaltyReputationThresholds": [ 0.04, 0.09, 0.15 ],
    "TurnoverReputationEnabled": true,
    "TurnoverReputationInterval": 100000,
    "TurnoverReputationGain": 0.1,
    "SellCategories": [ "WEAPONS", "MAGAZINES", "AMMO" ],
    "Items": [
        {
            "ClassName": "AKM",
            "Price": 25000,
            "LoyaltyLevel": 2,
            "MaxStock": 2,
            "QuestUnlock": "",
            "Category": ""
        }
    ],
    "Barters": [],
    "SellValueOverrides": [],
    "SellLimits": [
        { "ClassName": "AKM", "MaxPerRestock": 3 },
        { "ClassName": "SVD", "MaxPerRestock": 2 }
    ]
}
```

---

## Все поля торговца

| Поле | Тип | По умолчанию | Что делает |
|---|---|---|---|
| `Id` | строка | — | Уникальный идентификатор. Совпадает с именем файла. Менять нельзя, если не хотите потерять прогресс игроков. |
| `NameKey` | строка | `#STR_SGTR_trader_<id>` | Что написано на карточке. Начинается с `#` — это ключ перевода из `stringtable.csv`. |
| `Portrait` | строка | `""` | Картинка `gui/traders/sg_trader_<Portrait>.edds`. Пусто — берётся `Id`. |
| `Currency` | `"RUB"` или `"USD"` | `"RUB"` | Валюта этого торговца. Любое другое значение сервер заменит на `RUB` и напишет предупреждение. |
| `SellPriceRatio` | дробное | `0.45` | Долю от цены предмета торговец платит при скупке. `0.5` = половина цены. |
| `DefaultSellLimit` | целое | `-1` | Сколько штук одного предмета торговец купит у **одного игрока** за цикл завоза. `-1` = без ограничений. |
| `RestockMinutes` | целое | `120` | Через сколько минут обнуляются лимиты и перекатывается «горячий товар». `0` = автозавоз выключен. |
| `HotItemBoost` | дробное | `0.0` | Множитель цены скупки для «горячего» товара. Работает только если значение **больше 1.0**. |
| `HotItemPool` | список строк | `[]` | Из чего выбирается «горячей товар» на каждый цикл. |
| `LoyaltyThresholds` | 3 числа | `[]` | Оборот для уровней II, III, IV. |
| `LoyaltyReputationThresholds` | 3 числа | `[]` | Репутация, нужная **вместе** с оборотом для тех же уровней. Пустой список = уровень зависит только от оборота. |
| `TurnoverReputationEnabled` | `true`/`false` | `true` | Начислять ли репутацию за оборот у этого торговца. |
| `TurnoverReputationInterval` | целое | `100000` | Каждые сколько оборота выдаётся шаг репутации. |
| `TurnoverReputationGain` | дробное | `0.1` | Сколько репутации даёт один шаг. |
| `SellCategories` | список строк | `[]` | Какие **категории** вещей торговец вообще принимает. |
| `Items` | список | `[]` | Что торговец продаёт. |
| `Barters` | список | `[]` | Обмены «предметы на предмет». |
| `SellValueOverrides` | список | `[]` | Личная цена предмета для скупки, если он не входит в ассортимент. |
| `SellLimits` | список | `[]` | Личные лимиты скупки на конкретные предметы. |

Детали по `Items` и `Barters` — [Товары и бартеры](RU-Товары-и-бартеры).
Детали по скупке (`SellPriceRatio`, `SellCategories`, `SellLimits`, `SellValueOverrides`, `HotItemPool`) — [Скупка и лимиты](RU-Скупка-и-лимиты).
Детали по `LoyaltyThresholds`, `LoyaltyReputationThresholds` и `TurnoverReputation*` — [Лояльность и репутация](RU-Лояльность-и-репутация).

---

## Добавить своего торговца

**Шаг 1.** Создайте файл `Traders\SGTrader_MYTRADER.json`:

```json
{
    "Id": "MYTRADER",
    "NameKey": "#STR_SGTR_trader_mytrader",
    "Portrait": "",
    "Currency": "RUB",
    "SellPriceRatio": 0.5,
    "DefaultSellLimit": -1,
    "RestockMinutes": 120,
    "HotItemBoost": 0.0,
    "HotItemPool": [],
    "LoyaltyThresholds": [ 10000, 40000, 100000 ],
    "LoyaltyReputationThresholds": [],
    "TurnoverReputationEnabled": true,
    "TurnoverReputationInterval": 100000,
    "TurnoverReputationGain": 0.1,
    "SellCategories": [ "FOOD", "MEDICAL" ],
    "Items": [
        { "ClassName": "CanOfBakedBeans", "Price": 120, "LoyaltyLevel": 1, "MaxStock": -1, "QuestUnlock": "", "Category": "" }
    ],
    "Barters": [],
    "SellValueOverrides": [],
    "SellLimits": []
}
```

**Шаг 2.** Добавьте `"MYTRADER"` в `TraderIds` в `SGTradersConfig.json`. Без этого файл не загрузится.

**Шаг 3.** Перезапустите сервер.

### Как будет называться торговец

`NameKey` — это ключ строки перевода, а не само имя. Работает так:

* `#STR_SGTR_trader_mytrader` — сервер ищет строку `STR_SGTR_trader_mytrader` в таблицах перевода. Если её нет, игрок увидит сырой ключ.
* Чтобы имя было своим, добавьте в `stringtable.csv` своего мода строку с ключом `STR_SGTR_trader_mytrader` (ID пишется **строчными** буквами).
* Можно указать любой свой ключ, например `#STR_MY_SHOP_NAME` — главное, чтобы он начинался с `#` и существовал в вашей таблице строк.

⚠️ **Не вписывайте имя прямо текстом.** Если `NameKey` не начинается с `#`, сервер сочтёт его повреждённым и заменит на `#STR_SGTR_trader_<id в нижнем регистре>`, а в лог уйдёт:
`WARNING: Trader MYTRADER: broken NameKey 'Мой торговец' replaced by '#STR_SGTR_trader_mytrader'`.

### Портрет

`Portrait` ищет файл `SG_Traders/gui/traders/sg_trader_<Portrait>.edds`. В моде уже лежат: `prapor`, `therapist`, `mechanic`, `skier`, `fence`, `peacekeeper`, `jaeger`, `ref`. Если `Portrait` пустой, берётся `Id` — для `MYTRADER` это будет `sg_trader_MYTRADER.edds`, которого нет, поэтому картинка просто не отрисуется.

---

## Убрать торговца

Удалите его `Id` из `TraderIds` в `SGTradersConfig.json`. Файл торговца можно не удалять — он останется на диске, но загружаться не будет.

Прогресс игроков по этому торговцу лежит в `players\<steamId>.json` и никуда не денется: вернёте ID в список — оборот и репутация будут на месте.

---

## Важные мелочи

* **`Id` должен быть уникальным.** Дубликат или пустой `Id` — торговец удаляется из списка с предупреждением в лог.
* **Пустой или битый файл не роняет сервер.** Сервер напишет `WARNING: Trader file invalid: ... — skipped` и продолжит без него.
* **Если не загрузился ни один торговец**, сервер пересоздаёт дефолтный набор целиком: `No traders could be loaded from ... — regenerating defaults`.
* **Старый формат поддерживается.** Если у вас один большой `SGTradersConfig.json` со всеми торговцами внутри (версия до разделения), сервер при старте сам разложит их по файлам `Traders\` и напишет `Legacy config migrated: traders split into $profile:SG_Traders\Traders\`.
