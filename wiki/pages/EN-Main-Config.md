# Main Config — `SGTradersConfig.json`

[🇷🇺 Русская версия](RU-Главный-конфиг)

**What it is:** one file with the global settings of the whole system. Trade zones, the admin list, base prices and the trader roster live here. The items themselves are **not** here — they live in separate files under `Traders\`.

Path: `$profile:SG_Traders\SGTradersConfig.json`

---

## The whole file

```json
{
    "DebugLogging": false,
    "DefaultSellValue": 300,
    "SellConditionFloor": 0.25,
    "LoyaltyDiscountStep": 0.05,
    "AdminSteamIds": [
        "76561198012345678"
    ],
    "TradeZones": [
        {
            "Position": [ 11802.33, 2.18, 3265.71 ],
            "Radius": 50.0
        }
    ],
    "TraderIds": [
        "PRAPOR",
        "THERAPIST",
        "MECHANIC",
        "SKIER",
        "FENCE",
        "PEACEKEEPER",
        "JAEGER",
        "REF"
    ]
}
```

> The server generates this file on first start. Always start editing from the generated file rather than from the wiki example — that way the format is guaranteed correct.

---

## Every field

| Field | Type | Default | What it does |
|---|---|---|---|
| `DebugLogging` | `true` / `false` | `false` | Prints the details of every trade to the server log: `[SG_Traders][DEBUG] Buy: ... bought AKM from PRAPOR for 9500`. Useful while tuning, better off in production. |
| `DefaultSellValue` | integer | `300` | **Fallback price.** What an item is "worth" when the trader does not sell it and there is no explicit override. The sell price is derived from this. |
| `SellConditionFloor` | float `0…1` | `0.25` | The share of the price a fully broken item still gets. `0.25` = a broken item sells for 25 %, a brand new one for 100 %. |
| `LoyaltyDiscountStep` | float | `0.05` | Buy discount per loyalty level above the first. `0.05` = 5 % per level. `0` disables discounts. |
| `AdminSteamIds` | array of strings | `[]` | SteamID64 of the admins. They get an **ADMIN** button on the board. The list never leaves the server. |
| `TradeZones` | array of zones | 1 example zone | Circles on the map inside which the board can be opened. |
| `TraderIds` | array of strings | 8 entries | Which trader files to load, and in which order to show them on the board. |

---

## `TradeZones` — where trading is allowed

```json
"TradeZones": [
    {
        "Position": [ 7500.0, 0.0, 5200.0 ],
        "Radius": 50.0
    },
    {
        "Position": [ 4300.0, 0.0, 6400.0 ],
        "Radius": 25.0
    }
]
```

* The check is a **plain 3D distance**, so `Radius` must also cover the height difference. If the trader base is on a hill, take a generous radius.
* Any number of zones is allowed. A player sees the hint and can open the board while inside **at least one** of them.
* With an empty list the server logs:
  `WARNING: No trade zones configured — the board cannot be opened anywhere.`

## `AdminSteamIds` — who can do everything

```json
"AdminSteamIds": [
    "76561198012345678",
    "76561198087654321"
]
```

* It has to be a **SteamID64** (17 digits, starting with `76561198…`), no spaces.
* Find yours in your Steam profile URL, or with any "steam id finder" service.
* Admin status is resolved when you join the server. After adding your ID, reconnect.

## `LoyaltyDiscountStep` — how the discount is computed

Purchase formula:

```
price = round( Price × (1 − step × (level − 1)) )
```

The result never drops below 50 % of `Price`, and the step itself is capped at `0.15` — even if you write `0.5`, the server uses `0.15`.

Example with `LoyaltyDiscountStep: 0.05` and `Price: 10000`:

| Loyalty level | Factor | Final price |
|---|---|---|
| 1 | 1.00 | 10 000 |
| 2 | 0.95 | 9 500 |
| 3 | 0.90 | 9 000 |
| 4 | 0.85 | 8 500 |

The discount applies **only to purchases** (it does not touch barters) and is computed separately for each trader.

## `SellConditionFloor` and `DefaultSellValue` — in short

Both affect only **how much the trader pays you**. The full formula and examples are on [Selling And Limits](EN-Selling-And-Limits).

* `SellConditionFloor: 1.0` — item condition does not matter at all.
* `SellConditionFloor: 0.0` — a broken item is worth nothing.
* Raise `DefaultSellValue` if you want "junk" (anything not in the assortment) to be worth more.

## `TraderIds` — order and roster

* The order in the list is the order of the trader cards on the board.
* Every ID must have a matching file `Traders\SGTrader_<ID>.json`. Missing file → the trader is skipped with `WARNING: Trader file missing: ...`.
* To remove a trader, delete its ID from the list. The file itself can stay on disk — it simply will not be loaded.

Adding your own trader is covered on [Trader File](EN-Trader-File).

---

## Common mistakes

| Symptom | Cause |
|---|---|
| The board does not open anywhere | Empty `TradeZones`, or the zone is not where the player stands |
| Changes do not apply | The server was not restarted, or you edited a running server and the admin panel overwrote it |
| `Config load failed, keeping defaults. Check the JSON syntax` | Broken JSON: trailing comma, typographic quotes instead of `"`, a `//` comment |
| The ADMIN button does not appear | Wrong SteamID, or the admin did not reconnect after the edit |

JSON **does not support comments** — do not leave `//` in the file. It is the most common reason a config fails to load.
