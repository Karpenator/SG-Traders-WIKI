# Trader File — `Traders\SGTrader_<ID>.json`

[🇷🇺 Русская версия](RU-Файл-торговца)

**What it is:** one file = one trader. Inside: its currency, sell ratios, loyalty levels and the whole assortment. The files are independent — you can edit one trader without touching the rest.

Path: `$profile:SG_Traders\Traders\SGTrader_PRAPOR.json` and so on.

---

## The 8 traders out of the box

| ID | Name | Currency | Sell ratio | Restock, min | Turnover thresholds (II/III/IV) | Reputation thresholds | Default sell limit | Buys | Items | Barters |
|---|---|---|---|---|---|---|---|---|---|---|
| `PRAPOR` | Prapor | RUB | 0.50 | 120 | 12 000 / 45 000 / 120 000 | 0.04 / 0.09 / 0.15 | unlimited | WEAPONS, MAGAZINES, AMMO | 99 | 0 |
| `THERAPIST` | Therapist | RUB | 0.55 | 120 | 6 000 / 22 000 / 65 000 | 0.04 / 0.09 / 0.15 | 10 | MEDICAL, FOOD | 147 | 0 |
| `MECHANIC` | Mechanic | RUB | 0.50 | 180 | 9 000 / 32 000 / 90 000 | 0.04 / 0.09 / 0.15 | unlimited | TOOLS, VALUABLES, MAGAZINES | 417 | 2 |
| `SKIER` | Skier | RUB | 0.45 | 180 | 8 000 / 30 000 / 85 000 | 0.05 / 0.10 / 0.16 | unlimited | VESTS, BACKPACKS, CLOTHING | 821 | 1 |
| `FENCE` | Fence | RUB | 0.30 | 90 | 15 000 / 60 000 / 180 000 | — (none set) | 5 | ALL | 219 | 0 |
| `PEACEKEEPER` | Peacekeeper | **USD** | 0.50 | 240 | 800 / 3 500 / 12 000 | 0.06 / 0.12 / 0.18 | unlimited | WEAPONS, MAGAZINES, AMMO, VALUABLES | 63 | 0 |
| `JAEGER` | Jaeger | RUB | 0.50 | 150 | 5 000 / 18 000 / 50 000 | 0.05 / 0.10 / 0.16 | 12 | FOOD, TOOLS, WEAPONS, AMMO | 52 | 0 |
| `REF` | Ref | RUB | 0.40 | 240 | 4 000 / 15 000 / 40 000 | 0.05 / 0.11 / 0.17 | 6 | VALUABLES, TOOLS | 156 | 1 |

1 974 items and 4 barters in total. The Fence has no reputation thresholds set — his levels depend on turnover alone.

---

## What the file looks like (abridged)

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

## Every trader field

| Field | Type | Default | What it does |
|---|---|---|---|
| `Id` | string | — | Unique identifier. Matches the file name. Do not change it unless you are happy to lose the players' progress with this trader. |
| `NameKey` | string | `#STR_SGTR_trader_<id>` | What is written on the card. Starting with `#` it is a stringtable key. |
| `Portrait` | string | `""` | Image `gui/traders/sg_trader_<Portrait>.edds`. Empty → falls back to `Id`. |
| `Currency` | `"RUB"` or `"USD"` | `"RUB"` | This trader's currency. Any other value is replaced with `RUB` and logged as a warning. |
| `SellPriceRatio` | float | `0.45` | The share of an item's price the trader pays when buying it. `0.5` = half price. |
| `DefaultSellLimit` | integer | `-1` | How many pieces of one item the trader buys from **one player** per restock cycle. `-1` = unlimited. |
| `RestockMinutes` | integer | `120` | Minutes between restocks: resets the limits and re-rolls the hot item. `0` = automatic restock disabled. |
| `HotItemBoost` | float | `0.0` | Sell-price multiplier for the "hot item". Only works when the value is **greater than 1.0**. |
| `HotItemPool` | array of strings | `[]` | What the hot item is picked from each cycle. |
| `LoyaltyThresholds` | 3 numbers | `[]` | Turnover required for levels II, III, IV. |
| `LoyaltyReputationThresholds` | 3 numbers | `[]` | Reputation required **together with** turnover for the same levels. Empty list = level depends on turnover alone. |
| `TurnoverReputationEnabled` | `true`/`false` | `true` | Whether turnover grants reputation with this trader. |
| `TurnoverReputationInterval` | integer | `100000` | How much turnover makes one reputation step. |
| `TurnoverReputationGain` | float | `0.1` | How much reputation one step grants. |
| `SellCategories` | array of strings | `[]` | Which **categories** of items the trader accepts at all. |
| `Items` | array | `[]` | What the trader sells. |
| `Barters` | array | `[]` | Item-for-item exchanges. |
| `SellValueOverrides` | array | `[]` | Explicit sell value for an item that is not part of the assortment. |
| `SellLimits` | array | `[]` | Per-classname sell limits. |

`Items` and `Barters` in detail — [Items And Barters](EN-Items-And-Barters).
Selling (`SellPriceRatio`, `SellCategories`, `SellLimits`, `SellValueOverrides`, `HotItemPool`) — [Selling And Limits](EN-Selling-And-Limits).
`LoyaltyThresholds`, `LoyaltyReputationThresholds` and `TurnoverReputation*` — [Loyalty And Reputation](EN-Loyalty-And-Reputation).

---

## Adding your own trader

**Step 1.** Create `Traders\SGTrader_MYTRADER.json`:

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

**Step 2.** Add `"MYTRADER"` to `TraderIds` in `SGTradersConfig.json`. Without it the file will not be loaded.

**Step 3.** Restart the server.

### What the trader will be called

`NameKey` is a stringtable key, not the name itself. It works like this:

* `#STR_SGTR_trader_mytrader` — the server looks up the string `STR_SGTR_trader_mytrader` in the stringtables. If it is missing, the player sees the raw key.
* To use your own name, add a row with the key `STR_SGTR_trader_mytrader` to your own mod's `stringtable.csv` (the ID part is **lowercase**).
* You can point at any key of your own, e.g. `#STR_MY_SHOP_NAME` — it only has to start with `#` and exist in your stringtable.

⚠️ **Do not put the name in as plain text.** If `NameKey` does not start with `#`, the server treats it as broken and replaces it with `#STR_SGTR_trader_<id in lowercase>`, logging:
`WARNING: Trader MYTRADER: broken NameKey 'My Trader' replaced by '#STR_SGTR_trader_mytrader'`.

### Portrait

`Portrait` resolves to `SG_Traders/gui/traders/sg_trader_<Portrait>.edds`. The mod already ships: `prapor`, `therapist`, `mechanic`, `skier`, `fence`, `peacekeeper`, `jaeger`, `ref`. With an empty `Portrait` the `Id` is used — for `MYTRADER` that would be `sg_trader_MYTRADER.edds`, which does not exist, so no picture is drawn.

---

## Removing a trader

Delete its `Id` from `TraderIds` in `SGTradersConfig.json`. The trader file does not have to be deleted — it stays on disk but is not loaded.

The players' progress with that trader lives in `players\<steamId>.json` and stays put: put the ID back into the list and the turnover and reputation will still be there.

---

## Worth knowing

* **`Id` must be unique.** A duplicate or empty `Id` removes that trader from the roster with a warning in the log.
* **An empty or broken file does not take the server down.** The server logs `WARNING: Trader file invalid: ... — skipped` and carries on without it.
* **If not a single trader loads**, the server regenerates the whole default set: `No traders could be loaded from ... — regenerating defaults`.
* **The old format is supported.** If you have one big `SGTradersConfig.json` with all traders inline (from before the split), the server splits them into `Traders\` files on startup and logs `Legacy config migrated: traders split into $profile:SG_Traders\Traders\`.
