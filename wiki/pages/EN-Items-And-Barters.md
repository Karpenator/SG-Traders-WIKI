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
| `VehicleAttachments` | array of strings | `[]` | **Only for vehicles.** Kit spawned on the vehicle. Each entry is an attachment classname; **duplicates mean multiple pieces**. Supports `"Class:Qty"` shorthand (e.g. `"CivSedanWheel:4"`). Empty or omitted = legacy auto-equip; **non-empty completely replaces** the legacy kit. See Vehicles below. |

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

### Vehicles — `VehicleAttachments`

When `ClassName` is a vehicle, the offer spawns as a **vehicle in the world** instead of an item in inventory. How to tell: `IsVehicle` checks `Transport` / `Car` / `Boat` / `Helicopter` family, `CarScript` etc., plus the `simulation` field in `CfgVehicles` — so modded vehicles with a vehicle simulation are also recognised.

```json
{
    "ClassName": "CivilianSedan",
    "Price": 85000,
    "LoyaltyLevel": 2,
    "MaxStock": 1,
    "QuestUnlock": "",
    "Category": "",
    "VehicleAttachments": [
        "CivSedanWheel:4",
        "CivSedanDoors_Driver_Black",
        "CivSedanDoors_CoDriver_Black",
        "CivSedanDoors_BackLeft_Black",
        "CivSedanDoors_BackRight_Black",
        "CivSedanHood_Black",
        "CivSedanTrunk_Black",
        "CarBattery",
        "CarRadiator",
        "SparkPlug",
        "HeadlightH7:2"
    ]
}
```

* **Empty or omitted `VehicleAttachments`** (`[]` or missing) — legacy auto-equip: the mod builds a vanilla kit from the vehicle family (e.g. `CivilianSedan` → 4×`CivSedanWheel` + 4 doors + hood + trunk in the offer’s colour variant; `Truck_01` → `Wheel`×2 + `WheelDouble`×4 …; modded vehicle → `OnDebugSpawn`), **plus** a battery / radiator / plug / 2 headlights. Same as before the field existed.
* **Non-empty** — the list **fully replaces** the legacy kit: what is listed is what appears. No implicit doors, wheels or battery. You must list **everything** the vehicle needs (with correct colour suffix, e.g. `_Black`, `_BlueRust`).
* **Shorthand `"Class:Qty"`** — `"HeadlightH7:2"` equals two `HeadlightH7` lines, `"CivSedanWheel:4"` equals four wheels. `Qty` is clamped to `1…20`. Both forms can be mixed.
* Fluids and health are still filled automatically in both modes: **10 % fuel**, **coolant / oil / brake = full**, battery charged, plug at full health.
* Invalid classnames inside the list are removed on load with `WARNING: ... vehicle attachment 'X' invalid — removed`.
* Where the vehicle appears is configured per trader via `VehicleSpawnPosition` / `VehicleSpawnOrientation` / `VehicleSpawnRadius` — see [Trader File](EN-Trader-File).

In the board a vehicle is shown in a **256×128** cell (weapons are 128×64, plain items 64×64) and the centre preview is spawned with **all listed attachments** attached, not an empty hull.

The Mechanic’s out-of-the-box set is a working reference:

| Vehicle | Kit (abridged) | Price | Lvl |
|---|---|---|---|
| `CivilianSedan` | `CivSedanWheel:4` + 4 black doors/hood/trunk + battery/radiator/plug + `HeadlightH7:2` | 85 000₽ | 2 |
| `OffroadHatchback` | `HatchbackWheel:4` + blue doors/hood/trunk + battery… | 95 000₽ | 2 |
| `Hatchback_02` | `Hatchback_02_Wheel:4` + black doors/hood/trunk + battery… | 90 000₽ | 2 |
| `Sedan_02` | `Sedan_02_Wheel:4` + grey doors/hood/trunk + battery… | 105 000₽ | 3 |
| `Offroad_02` | `Offroad_02_Wheel:4` + doors/hood/trunk + battery… | 125 000₽ | 3 |
| `Truck_01_Covered` | `Truck_01_Wheel:2` + `WheelDouble:4` + blue doors/hood + `TruckBattery`/`TruckRadiator`/`GlowPlug` | 180 000₽ | 3 |
| `Truck_02` | same heavy-truck kit as above | 190 000₽ | 3 |

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
| `VehicleAttachments` | Same as on `Items`: **only for vehicle rewards**, fully replaces the legacy kit when non-empty. Empty = legacy auto-equip. See Vehicles above. |

Rules:

* Every item in `Cost` must be on the player (in hands, pockets, vest or backpack). Not enough → "You do not carry the required barter items."
* `Quantity` must be greater than zero. A line with `Quantity: 0` or a broken classname is removed.
* If no `Cost` lines survive validation, **the whole barter is removed** with a warning in the log.
* Items in `Cost` do not have to be part of the trader's assortment — you can demand anything.
* **Vehicle barter rewards** work the same as vehicle items: add `VehicleAttachments` to the barter when `ClassName` is a vehicle. The barter preview and the spawned vehicle use that kit; empty = legacy auto-equip.

```json
{
    "ClassName": "Truck_01_Covered_Blue",
    "LoyaltyLevel": 3,
    "MaxStock": 1,
    "QuestUnlock": "",
    "Category": "",
    "Cost": [
        { "ClassName": "CarBattery", "Quantity": 1 },
        { "ClassName": "MetalPlate", "Quantity": 4 }
    ],
    "VehicleAttachments": [
        "Truck_01_Wheel:2",
        "Truck_01_WheelDouble:4",
        "Truck_01_Door_1_1_Blue",
        "Truck_01_Door_2_1_Blue",
        "TruckBattery",
        "TruckRadiator",
        "GlowPlug",
        "HeadlightH7:2"
    ]
}
```

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
