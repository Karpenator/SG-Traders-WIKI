# Items And Barters

[🇷🇺 Русская версия](RU-Товары-и-бартеры)

**What it is:** the `Items` and `Barters` sections of a trader file. `Items` is what the trader sells for money. `Barters` is what he hands over in exchange for other items.

---

## `Items` — what the trader sells

One entry = one row in the assortment:

```json
{
    "ClassName": "AKM",
    "Price": 25000,
    "LoyaltyLevel": 2,
    "MaxStock": 2,
    "QuestUnlock": "",
    "Category": ""
}
```

| Field | Type | Default | What to put |
|---|---|---|---|
| `ClassName` | string | `""` | The exact DayZ classname. With a typo the row is silently dropped at load time. |
| `Price` | integer | `0` | Price in the trader's currency, **before** the loyalty discount. |
| `LoyaltyLevel` | `1…4` | `1` | Minimum loyalty level. `1` — available to everyone. |
| `MaxStock` | integer | `-1` | How many pieces **one player** may buy per restock cycle. `-1` = unlimited. |
| `QuestUnlock` | string | `""` | ID of a quest from the `SG_Quest` mod. Empty — available to everyone. |
| `Category` | string | `""` | Which filter tab the item goes to. Empty — detected automatically. |

### ⚠️ `MaxStock` is a per-player limit, not the trader's warehouse

The most common misunderstanding. `MaxStock: 2` means:

> "Every player may buy 2 pieces until the restock cycle passes."

With 50 players that is 100 rifles sold. There is no shared warehouse that everybody drains together. Every player has their own counter and it resets at the restock (`RestockMinutes`).

What the player sees:

| `MaxStock` | What the player sees |
|---|---|
| `-1` | `MANY` |
| `5` | `5` → `4` → … as they buy |
| used up | `SOLD OUT` and the message "Out of stock. Wait for the next restock." |

### `Category` — the assortment tab

By default the category is detected from the item class. Sometimes the detection is not what you want (a grenade landing in "Tools", for example). Then set the tab explicitly:

| Value | UI tab |
|---|---|
| `WEAPONS` | WPN |
| `MAGAZINES` | MAG |
| `AMMO` | AMMO |
| `MEDICAL` | MED |
| `FOOD` | FOOD |
| `CLOTHING` | CLT |
| `VESTS` | CLT (vests count as clothing) |
| `BACKPACKS` | CLT (backpacks count as clothing) |
| `TOOLS` | TOOL |
| `VALUABLES` | VAL |
| `""` | detect automatically |

Case does not matter: `weapons`, `WEAPONS` and `Weapons` all work. An unknown value is ignored and the item is auto-detected.

The **VAL** tab is the catch-all: it shows valuables and everything that could not be classified at all, so no offer ever disappears from view.

### `QuestUnlock` — an item behind a quest

```json
{ "ClassName": "NVGoggles", "Price": 45000, "LoyaltyLevel": 3, "MaxStock": 1, "QuestUnlock": "QUEST_NIGHT_HUNT", "Category": "" }
```

Until the player completes the quest `QUEST_NIGHT_HUNT`, the row is invisible and unpurchasable for them.

**Important:** `SG_Traders` itself knows nothing about quests — it only asks the `SG_Quest` mod whether the quest is done. If `SG_Quest` is not installed, **any** offer with a non-empty `QuestUnlock` stays locked for everyone, forever. Do not leave a filled `QuestUnlock` if there is no quest mod on the server.

---

## `Barters` — item for item

A barter is an item with no price: instead of money the player hands over a set of items.

```json
{
    "ClassName": "PSO1Optic",
    "LoyaltyLevel": 2,
    "MaxStock": 1,
    "QuestUnlock": "",
    "Category": "",
    "Cost": [
        { "ClassName": "CarBattery", "Quantity": 1 },
        { "ClassName": "SparkPlug",  "Quantity": 2 }
    ]
}
```

The fields are the same as for `Items`, except there is no `Price` — instead there is the `Cost` array.

| Field | What it is |
|---|---|
| `ClassName` | What the player **receives** |
| `Cost` | What the player **gives**: `ClassName` + `Quantity` |
| `LoyaltyLevel`, `MaxStock`, `QuestUnlock`, `Category` | Behave exactly like on regular items |

Rules:

* Every item in `Cost` must be on the player (in hands, pockets, vest or backpack). Not enough → "You do not carry the required barter items."
* `Quantity` must be greater than zero. A line with `Quantity: 0` or a broken classname is removed.
* If no `Cost` lines survive validation, **the whole barter is removed** with a warning in the log.
* Items in `Cost` do not have to be part of the trader's assortment — you can demand anything.

### How much turnover a barter gives

A barter has no price, but it does grant turnover (and therefore loyalty). It is computed as:

```
turnover = sum( base value of each Cost item × its quantity )
```

The base value is resolved the same way as for selling: the price in this trader's assortment → otherwise `SellValueOverrides` → otherwise `DefaultSellValue` from the main config.

**The practical consequence:** if you build a barter out of items the trader has no price for and there are no `SellValueOverrides`, each of them counts towards turnover as `DefaultSellValue` (300 by default). If you want a barter to actually level the player up, add `SellValueOverrides` for its ingredients.

---

## Working examples

### A plain item, available to everyone, unlimited

```json
{ "ClassName": "Rag", "Price": 25, "LoyaltyLevel": 1, "MaxStock": -1, "QuestUnlock": "", "Category": "MEDICAL" }
```

### Scarce: one piece per player per cycle, level 4 only

```json
{ "ClassName": "NVGoggles", "Price": 45000, "LoyaltyLevel": 4, "MaxStock": 1, "QuestUnlock": "", "Category": "TOOLS" }
```

### Barter "a knife, two ropes and two planks for a crossbow"

```json
{
    "ClassName": "Crossbow",
    "LoyaltyLevel": 2,
    "MaxStock": 1,
    "QuestUnlock": "",
    "Category": "WEAPONS",
    "Cost": [
        { "ClassName": "HuntingKnife", "Quantity": 1 },
        { "ClassName": "Rope",         "Quantity": 2 },
        { "ClassName": "WoodenPlank",  "Quantity": 2 }
    ]
}
```

This is the real barter shipped with Ref.

---

## Changing items quickly, without editing JSON

Admins (`AdminSteamIds`) get an **ADMIN** button on the board: there you can change price, level and stock, add and remove items and barters, and **every change is saved straight into the `Traders\` files**. It is much more convenient than hunting for a line in an 800-item file.

Details — [Admin And Troubleshooting](EN-Admin-And-Troubleshooting).

---

## Common mistakes

| Symptom | Cause |
|---|---|
| The item is not in the list, the log says `WARNING: ... offer 'X' is not a valid item classname — removed` | Typo in `ClassName`. Check the name against the DayZ wiki or your build's `types.xml`. |
| The item is visible but cannot be bought: "Your loyalty level with this trader is too low." | `LoyaltyLevel` is above the player's level with this trader |
| The item is visible but cannot be bought: "Out of stock." | The player used up their `MaxStock` for this cycle |
| The barter disappeared, the log says `barter ... has no cost lines — removed` | All `Cost` lines were broken (classname or `Quantity`) |
| The item is not there for some players | `QuestUnlock` is filled and the `SG_Quest` mod is not installed |
| The item landed on the wrong tab | Category auto-detection. Set `Category` explicitly |
