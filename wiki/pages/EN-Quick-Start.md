# Quick Start

[🇷🇺 Русская версия](RU-Быстрый-старт)

**SG_Traders** is a Tarkov-style trader system for DayZ: 8 traders, loyalty levels, buying, selling and bartering, trade zones. Everything is configured through JSON files — you never need to touch the code.

This page is the minimum to get the mod running. Every file is covered in detail on the other wiki pages.

---

## 1. Installation

1. Copy the `SG_Traders` folder into your server's mods folder.
2. Add `SG_Traders` to the server's mod list (`-mod=` in your startup script, or `DZSALauncher` / `Server DZ mods`).
3. The mod is needed on **both** the server and the clients: it contains server logic (`4_World`) and the client interface (`5_Mission`, `gui/`). Server-only installation means the traders board will never open.
4. Start the server.

The mod has no hard dependencies. If `SG_Quest` is installed, traders can gate offers behind completed quests; without it those offers simply stay locked.

## 2. Where the configs live

On the **first** start the server creates the config folder and writes a ready-made set of 8 traders into it:

```
$profile:SG_Traders\
├── SGTradersConfig.json        ← main file: zones, admins, global settings
├── Traders\
│   ├── SGTrader_PRAPOR.json    ← one file per trader
│   ├── SGTrader_THERAPIST.json
│   ├── SGTrader_MECHANIC.json
│   ├── SGTrader_SKIER.json
│   ├── SGTrader_FENCE.json
│   ├── SGTrader_PEACEKEEPER.json
│   ├── SGTrader_JAEGER.json
│   └── SGTrader_REF.json
├── SGTradersState.json         ← restock timers and the hot item (do not edit)
└── players\
    └── 76561198XXXXXXXXX.json  ← player wallet, turnover, reputation (do not edit)
```

`$profile:` is the server profile directory:

| Platform | Path |
|---|---|
| Windows | `<DayZServer folder>\ServerProfile\SG_Traders\` |
| Linux | the folder from the `-profiles=` argument (default `~/.local/share/dayz/`), then `SG_Traders/` inside it |

**Only `SGTradersConfig.json` and the files in `Traders\` are meant to be edited by hand.** The server manages the other two itself.

## 3. Four rules that will save you an evening

1. **Stop the server before editing configs.** The config is read once at server start — changes only apply after a restart.
2. **Never edit configs on a running server.** Every admin-panel action rewrites *all* config files from what is currently in server memory. Hand edits made "live" will be wiped.
3. **Back up the `SG_Traders` folder before editing.** If the JSON is broken the server says so in the log and keeps running on the old/default values.
4. **Classnames must be exact.** A typo in `ClassName` will not crash the server — the trader simply loses that offer and the log gets a line `WARNING: ... is not a valid item classname — removed`.

## 4. The one setting without which the mod "does not work"

The most common complaint after installing: **the board does not open**. The cause is almost always the trade zones — the default one is created with example coordinates that are probably nowhere near your players.

Open `SGTradersConfig.json` and put in your own coordinates:

```json
"TradeZones": [
    {
        "Position": [ 7500.0, 0.0, 5200.0 ],
        "Radius": 50.0
    }
]
```

* `Position` — `[X, Y, Z]` in DayZ coordinates. `X` and `Z` are the map coordinates, `Y` is height (usually written as `0`; the check is a 3D distance, so a small height error does not matter).
* `Radius` — zone radius in metres. `50` is a comfortable size for a trader base.

Getting the coordinates: read them off the in-game map, take them from any teleport mod, or convert a map grid reference (DayZ grid `075, 052` is roughly `7500, 5200` — the grid numbers are multiplied by 100).

You can have as many zones as you like — just add more objects to the array.

## 5. How a player opens the board

* The player walks into a trade zone → an on-screen hint appears.
* They press **F8** (the `UASGTradersOpen` action, rebindable in DayZ's control settings under the `SG_Traders` section).
* The server **re-checks** whether the player is inside a zone. A client-side mod cannot bypass this.

## 6. Where players get money

Starting wallet: **0**. Money appears in only two ways:

1. A player **sells** items to traders.
2. An admin grants money through the **admin panel** (the Wallet section).

There are two currencies: roubles (`RUB`) and dollars (`USD`). Only the Peacekeeper (`PEACEKEEPER`) trades in dollars — everyone else uses roubles.

## 7. How to check that everything loaded

Turn on debug logging in `SGTradersConfig.json`:

```json
"DebugLogging": true
```

then look for `[SG_Traders]` lines in the server log. On startup you should see something like:

```
[SG_Traders] Config loaded from ...SGTradersConfig.json (8 trader files)
[SG_Traders] Loaded 8 traders, 1 trade zones.
```

If you see `WARNING` lines instead, every one of them is explained in the table on [Admin And Troubleshooting](EN-Admin-And-Troubleshooting).

---

## Where to read next

| I want to… | Page |
|---|---|
| Set up zones, admins, global prices | [Main Config](EN-Main-Config) |
| Add my own trader / remove one | [Trader File](EN-Trader-File) |
| Add an item, change a price, make a barter | [Items And Barters](EN-Items-And-Barters) |
| Control what a trader buys and for how much | [Selling And Limits](EN-Selling-And-Limits) |
| Understand loyalty levels and reputation | [Loyalty And Reputation](EN-Loyalty-And-Reputation) |
| Hand out money and levels, fix an error | [Admin And Troubleshooting](EN-Admin-And-Troubleshooting) |
