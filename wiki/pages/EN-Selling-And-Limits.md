# Selling And Limits

[🇷🇺 Русская версия](RU-Скупка-и-лимиты)

**What it is:** how a trader decides whether to take your item and how much to pay. Configured through `SellCategories`, `SellPriceRatio`, `DefaultSellLimit`, `SellLimits`, `SellValueOverrides`, `HotItemPool` and `HotItemBoost` in the trader file, plus `DefaultSellValue` and `SellConditionFloor` in the main config.

---

## The sell price formula

For every piece the trader pays:

```
price = round( base × SellPriceRatio × hot × condition × stack )
```

| Factor | Where it comes from |
|---|---|
| **base** | This trader's price for the item → otherwise `SellValueOverrides` → otherwise `DefaultSellValue` |
| **`SellPriceRatio`** | Trader field. `0.5` = half price, `0.3` = a third |
| **hot** | `HotItemBoost`, if the item is the hot item of the current cycle. Otherwise `1.0` |
| **condition** | From the item's health: `SellConditionFloor + (1 − SellConditionFloor) × health` |
| **stack** | For consumables — the share of the contents left. For whole items `1.0` |

The price **does not decay over time** — the trader never dumps prices no matter how much you sell him. The only quantity restriction is the sell limit (below).

### The factors explained

**Base.** Lookup order:

1. The item is in this trader's `Items` → its `Price` is used.
2. Otherwise there is a `SellValueOverrides` entry → its `Value` is used.
3. Otherwise — `DefaultSellValue` from `SGTradersConfig.json` (`300` by default).

**Condition.** With `SellConditionFloor: 0.25`:

| Item health | Factor |
|---|---|
| 100 % | 1.00 |
| 60 % | 0.70 |
| 20 % | 0.40 |
| 0 % | 0.25 |

Edge cases: `SellConditionFloor: 1.0` — condition does not matter at all; `0.0` — a broken item is worth nothing. Items without health (ammo, food) always get `1.0`.

**Stack.**

* **Loose ammo** — paid per remaining round: a 60-round pile with 20 left → factor `20/60`.
* **Magazines** — paid in full regardless of how many rounds are inside.
* **Consumables with a quantity** (food, water, bandages, fuel) — paid proportionally to what is left, but never below 5 %.
* Everything else — `1.0`.

### Examples using the shipped defaults

| Selling | To whom | Calculation | You get |
|---|---|---|---|
| `AKM`, undamaged | Prapor (`ratio 0.5`, price 25 000) | 25 000 × 0.5 × 1.0 | **12 500 ₽** |
| `AKM`, 60 % health | Prapor | 25 000 × 0.5 × 0.70 | **8 750 ₽** |
| `Megaphone`, current hot item | Fence (`ratio 0.3`, price 3 000, `boost 1.5`) | 3 000 × 0.3 × 1.5 | **1 350 ₽** |
| `BearPelt` — not in the assortment | Fence (`ratio 0.3`, base = `DefaultSellValue` 300) | 300 × 0.3 | **90 ₽** |
| `Ammo_762x39`, 20 rounds in the pile | Prapor (`ratio 0.5`, price 1 200) | 1 200 × 0.5 × 20/60 | **200 ₽** |

The last row is the main reason to raise `DefaultSellValue` or write `SellValueOverrides`: without them any unfamiliar item is worth pennies.

---

## `SellCategories` — what the trader accepts at all

A trader only takes an item whose category is in his list. If the category is missing, the item simply does not appear in the sell list.

```json
"SellCategories": [ "WEAPONS", "MAGAZINES", "AMMO" ]
```

Available values (case-insensitive):

| Value | What lands here |
|---|---|
| `WEAPONS` | Firearms |
| `MAGAZINES` | Magazines |
| `AMMO` | Ammunition |
| `MEDICAL` | Medicine |
| `FOOD` | Food and drink |
| `CLOTHING` | Clothes, vests, backpacks |
| `VESTS` | Same as `CLOTHING` (legacy name, still works) |
| `BACKPACKS` | Same as `CLOTHING` (legacy name, still works) |
| `TOOLS` | Tools, optics, weapon attachments, melee weapons |
| `VALUABLES` | Valuables: batteries, radios, pelts, vehicle parts, seeds |
| `ALL` | All of the above at once |

The category is detected from the item class automatically. If you want to force an offer into a category, that is the item's `Category` field — it affects the assortment tab only, **not** selling.

⚠️ Even `ALL` does not make the trader buy **absolutely everything**. Items that could not be assigned to any category (logs, planks, building junk) are never bought — their category is empty.

---

## Sell limits

They protect the economy: they stop one player from dumping 500 rifles in an evening.

```json
"DefaultSellLimit": 10,
"SellLimits": [
    { "ClassName": "Morphine",   "MaxPerRestock": 5 },
    { "ClassName": "BloodBagIV", "MaxPerRestock": 4 }
]
```

| Field | What it does |
|---|---|
| `DefaultSellLimit` | The blanket limit: how many pieces of **one** item the trader buys from **one player** per restock cycle. `-1` = unlimited. |
| `SellLimits` | A per-classname limit. Overrides the blanket one. |

Details that matter:

* The limit is **per player**, just like the `MaxStock` of items: everybody has their own counter.
* The counter resets at the restock (`RestockMinutes`). With `RestockMinutes: 0` the limits **never recover**.
* A `SellLimits` entry with `MaxPerRestock` ≤ 0 is treated as invalid and removed at load time. To lift a limit, delete the entry — do not write `0`.
* If a player tries to sell more than the limit allows, only part of it sells: "Sold partially — the trader's buy limit is exhausted."
* When the limit is already used up: "The trader will not take more of this until the next restock."

---

## `SellValueOverrides` — your own sell value

Needed when a trader **accepts** an item but does not **sell** it, and the default 300 is not what you want.

```json
"SellValueOverrides": [
    { "ClassName": "BearPelt",  "Value": 2500 },
    { "ClassName": "WolfPelt",  "Value": 1800 }
]
```

With `SellPriceRatio: 0.3` a bear pelt would go for `2500 × 0.3 = 750`.

`SellValueOverrides` does **not** turn the item into an offer — it will not appear in the assortment. It only sets the sell value.

---

## The "hot item"

The Fence mechanic: every restock cycle the trader randomly picks one item from the list and pays more for it.

```json
"HotItemBoost": 1.5,
"HotItemPool": [
    "Battery9V", "CarBattery", "SparkPlug", "PersonalRadio", "Rangefinder",
    "Megaphone", "CableReel", "ElectronicRepairKit", "MetalPlate", "CanisterGasoline"
]
```

* Only works when `HotItemBoost` is **greater than 1.0**. The default `0.0` is off. Values like `0.5` or `1.0` also do nothing.
* An empty `HotItemPool` also disables it.
* The item is re-picked at every restock and stored in `SGTradersState.json`, so it survives a server restart.
* The player sees such an item tagged **HOT** with the bonus percentage.
* Broken classnames in the pool are removed at load time with a warning.

Want a hot item at another trader? Just give them a `HotItemBoost` and their own `HotItemPool`.

---

## What the trader will not take

* **An item with contents.** Something in the backpack, a scope mounted on the gun — the item is tagged **FULL** and will not sell until you empty it. Nothing inside is lost and none of it is folded into the price — take it out first, then sell the pieces separately.
* **A category not in `SellCategories`.**
* **More than the remaining limit** — only part of it sells.

### Assembled weapons and automatic buyer routing

A weapon with mounted modules can be sold two ways:

1. **Whole** — the gun plus every module in one deal (tagged **ASSEMBLED**).
2. **Piece by piece** — you can detach and sell a single module.

Modules are always sold to **whichever trader pays the most for them**, not necessarily the one whose board is open. The UI shows this with an arrow `→ Mechanic` next to the price, and after the deal you get "Sold to trader …". The money arrives in that trader's currency, and the turnover and reputation are credited to them too.

---

## Settings worth changing first

| I want to… | What to change |
|---|---|
| Make traders pay more/less overall | `SellPriceRatio` on each trader |
| Make "junk" worth more than 300 | `DefaultSellValue` in the main config |
| Make condition irrelevant | `SellConditionFloor: 1.0` |
| Stop hundreds of rifles being dumped | `DefaultSellLimit` (say `5`) |
| Have the Fence take everything cheaply | `SellCategories: ["ALL"]` + a low `SellPriceRatio` |
| Your own scarcity rotation | `HotItemBoost` + `HotItemPool` on the trader you want |

---

## Common mistakes

| Symptom | Cause |
|---|---|
| The item does not appear in the sell list | Its category is not in the trader's `SellCategories` |
| Everything sells for 90 ₽ | The item is in neither the assortment nor `SellValueOverrides` — `DefaultSellValue: 300` is in effect |
| The hot item does not work | `HotItemBoost` ≤ 1.0 or an empty `HotItemPool` |
| The sell limit never recovers | `RestockMinutes: 0` — automatic restock is off |
| The backpack will not sell | There is something inside, tag **FULL** |
| The log says `WARNING: ... invalid sell limit entry — removed` | `MaxPerRestock` ≤ 0 or an empty `ClassName` in `SellLimits` |
