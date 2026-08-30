# Admin And Troubleshooting

[🇷🇺 Русская версия](RU-Админка-и-решение-проблемы)

**What it is:** the built-in admin panel inside the traders board, plus a reference for the messages in the server log.

---

## How to open it

1. Put your SteamID64 into `AdminSteamIds` in `SGTradersConfig.json`.
2. Restart the server and join it (admin status is granted on connect).
3. Open the traders board inside a trade zone (**F8**).
4. Press the **ADMIN** button.

Non-admins simply do not see the button. The admin list is never sent to clients — only a yes/no flag leaves the server.

---

## What the panel can do

### Traders
Switch between all traders from `TraderIds`. The panel always works with one selected trader.

### Turnover thresholds
Fields for levels II / III / IV: turnover and reputation. Plus the **"REP FOR TURNOVER"** block — enable/disable it and set the interval and the gain.

* Thresholds are automatically forced into ascending order: if III is entered lower than II, the server raises III to `II + 1`.
* Reputation is clamped into `0…9.99`.
* The decimal part can be typed with a comma or a dot — both are understood.
* Saved into `LoyaltyThresholds`, `LoyaltyReputationThresholds` and `TurnoverReputation*`.

### Items
A table of the whole assortment: item, price, level, `MaxStock`, sell limit.

* Edit a row + **OK** — saves the change.
* **X** — removes the item.
* **ADD ITEM** — adds a new one: an item picker with search opens, so you do not need to remember the classname.
* The "buy limit" column shows the item's own limit; when there is none, the trader's `DefaultSellLimit` is shown.

### Barters
A table of barters. The cost format is:

```
CarBattery:1;SparkPlug:2
```

that is `Classname:Quantity`, several entries separated by a **semicolon**. The `|` character cannot be used inside the cost — the panel rejects it.

* **+ NEW BARTER** — an empty row for a new barter.
* Classname, cost, level and `MaxStock` are edited right in the row.

### Players online
The list of everyone currently on the server: turnover, level and reputation **with the selected trader**, plus roubles and dollars.

| Action | What it does |
|---|---|
| Buttons **1 / 2 / 3 / 4** | Sets the loyalty level: writes turnover equal to that level's threshold and raises reputation to the required floor. What the player earned is never lowered. |
| **REPUTATION** + value | Sets reputation directly (`0…9.99`) |
| **WALLET** + `+` / `−` | Adds or subtracts an amount in roubles or dollars |

The level cannot be set higher than the trader's number of thresholds allows: with two thresholds the maximum will be 3.

### Where it is saved

**Every configuration change is written to disk immediately** — into `SGTradersConfig.json` and into the file of the affected trader under `Traders\`. All boards currently open are refreshed instantly, no restart needed.

⚠️ **The flip side:** the panel rewrites the files from what is in server memory. If you edited a config by hand without stopping the server, those edits are lost the first time the panel saves. The correct order is: stop the server → edit the files → start it.

---

## Debug logging

`"DebugLogging": true` in `SGTradersConfig.json` turns on detailed lines like:

```
[SG_Traders][DEBUG] Buy: 76561198012345678 bought AKM from PRAPOR for 23750
[SG_Traders][DEBUG] Sell: 76561198012345678 sold 4x BearPelt to FENCE for 360
[SG_Traders][DEBUG] Restocked PRAPOR
[SG_Traders][DEBUG] Admin 76561198012345678 set thresholds of PRAPOR to 12000/45000/120000 rep 0.04/0.09/0.15 ...
```

Warnings (`WARNING`) are printed regardless of that flag.

Separately, there is the constant `SGTR_TRACE_UI` in the code (`scripts/3_Game/SGTradersConstants.c`, `true` by default) — it prints the board-opening chain: key press → RPC → menu. Set it to `false` once everything works, otherwise the log fills up with `DBG:` lines. That is a code change, not a config one — the mod has to be rebuilt.

---

## What the log lines mean

Every line starts with `[SG_Traders] `.

### While loading the config

| Log line | What happened | What to do |
|---|---|---|
| `Config loaded from ... (8 trader files)` | All good | — |
| `Loaded 8 traders, 1 trade zones.` | The config was applied | — |
| `Default config written to ... (8 trader files)` | There was no config, the default set was created | Normal on first start |
| `Legacy config migrated: traders split into $profile:SG_Traders\Traders\` | The old single file was split per trader | Normal, happens once |
| `Config load failed, keeping defaults. Check the JSON syntax of ...` | **Broken JSON** | Check the syntax: trailing comma, typographic quotes instead of `"`, a `//` comment |
| `No traders could be loaded from ... — regenerating defaults` | Not a single trader loaded, the default set was created | Check `TraderIds` and the files in `Traders\` |
| `Trader file missing: ... — skipped` | The ID is in `TraderIds` but there is no file | Check the file name: `SGTrader_<ID>.json` |
| `Trader file invalid: ... — skipped` | The file could not be read or the `Id` is empty | Check the JSON syntax of that file |
| `Trader with empty or duplicated Id removed at index N` | Empty or duplicated `Id` | `Id` must be unique |
| `Trader X: broken NameKey 'Y' replaced by '#STR_SGTR_trader_x'` | `NameKey` did not start with `#` | Use a stringtable key, not plain text |

### While validating the content

| Log line | What happened | What to do |
|---|---|---|
| `X: unknown currency 'Y', falling back to RUB.` | The currency is neither `RUB` nor `USD` | Only those two are available |
| `X: offer 'Y' is not a valid item classname — removed.` | Typo in an item's `ClassName` | Check the classname |
| `X: barter reward 'Y' is not a valid item classname — removed.` | Typo in a barter reward | Check the classname |
| `X: barter cost 'Y' invalid — cost line removed.` | Broken barter cost line | Classname or `Quantity ≤ 0` |
| `X: barter Y has no cost lines — removed.` | No cost survived validation | Add at least one valid `Cost` entry |
| `X: hot pool entry 'Y' is not a valid item classname — removed.` | Typo in `HotItemPool` | Check the classname |
| `X: invalid sell limit entry — removed.` | Empty `ClassName` or `MaxPerRestock ≤ 0` in `SellLimits` | Delete the entry to lift the limit |
| `X: negative TurnoverReputationInterval — progression disabled for this trader.` | Negative interval | Replaced with `0`, the progression is off |
| `X: negative TurnoverReputationGain — progression disabled for this trader.` | Negative gain | Replaced with `0`, the progression is off |

### At runtime

| Log line | What happened |
|---|---|
| `No trade zones configured — the board cannot be opened anywhere.` | Empty `TradeZones` — the board will not open anywhere |
| `Restocked X` | The trader's restock cycle passed |
| `Open request outside trade zone by ...` (only with `DebugLogging`) | A player tried to open the board outside a zone |

None of these warnings **stops the server**: a broken entry is simply dropped and the mod carries on without it.

---

## Common problems

### The board does not open

In order:

1. **Does the player have the mod?** It is a client-server mod: without it on the client the interface will not appear at all.
2. **Is the player inside a zone?** Check the coordinates in `TradeZones` and the radius. If the on-screen hint is there, the zone was found.
3. **Is the zone list non-empty?** Look for `No trade zones configured` in the log.
4. **Is the key free?** `F8` can conflict with another mod. Rebind it in the control settings, section `SG_Traders`.
5. **Is the player alive?** The board does not open for the dead.
6. **Is another menu open?** While the inventory or the map is open, the board will not open.

### "Not enough money", but there is money

Check the currency: the Peacekeeper trades in **dollars**, everybody else in **roubles**. The wallet is shared server-wide but each currency has its own balance.

### An item disappeared after a restart

Most likely the log has a line `is not a valid item classname — removed`. The classname does not exist in your build (for example an item from a mod that is not on the server).

### Changes do not apply

* The server was not restarted — the config is read only at startup.
* The changes were made on a running server and overwritten by the admin panel.
* The wrong file is being edited: make sure it is `$profile:SG_Traders\...` and not a copy inside the mod folder.

### A player cannot sell an item

* The item's category is not in the trader's `SellCategories`.
* The item is **FULL** — there is something inside.
* The sell limit is used up until the next restock.
* The item is not classified into any category at all (planks, logs) — those are never bought, even with `ALL`.

### How to reset the economy completely

With the server stopped, delete:

```
$profile:SG_Traders\players\*            ← wallets, turnover, reputation, limits
$profile:SG_Traders\SGTradersState.json  ← restock timers and the hot item
```

The configs (`SGTradersConfig.json` and `Traders\`) are not affected.

### How to get the default settings back

With the server stopped, delete `SGTradersConfig.json` and the `Traders\` folder. On the next start the server recreates them with the eight default traders.

---

## See also

* [Quick Start](EN-Quick-Start) — installation and first steps
* [Main Config](EN-Main-Config) — zones, admins, global settings
* [Trader File](EN-Trader-File) — how it is built and how to add your own
* [Items And Barters](EN-Items-And-Barters) — the assortment
* [Selling And Limits](EN-Selling-And-Limits) — sell prices
* [Loyalty And Reputation](EN-Loyalty-And-Reputation) — progression
