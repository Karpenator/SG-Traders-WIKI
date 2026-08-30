# Loyalty And Reputation

[🇷🇺 Русская версия](RU-Лояльность-и-репутация)

**What it is:** a player's progression with each trader. It decides which offers are available and how big the discount is. Configured through `LoyaltyThresholds`, `LoyaltyReputationThresholds`, `TurnoverReputationEnabled`, `TurnoverReputationInterval` and `TurnoverReputationGain` in the trader file, plus `LoyaltyDiscountStep` in the main config.

---

## Two separate values

| Value | What it is | Range |
|---|---|---|
| **Turnover** | The sum of all the player's deals with this trader: purchases, barters and sales. Only grows. | 0 … 2 000 000 000 |
| **Reputation** | A separate "trust" bar. | 0.00 … 9.99 |

Both are tracked **separately per trader**: you can be level 4 with Prapor and level 1 with the Peacekeeper.

Turnover is credited like this:

* purchase → plus the amount actually paid (already discounted);
* sale → plus the amount received;
* barter → plus the sum of the base values of the items handed over.

Reputation grows in three ways: turnover steps (below), quest rewards from `SG_Quest`, and manually through the admin panel.

---

## How the loyalty level is computed

There are four levels. The first one is free, the other three are set by thresholds:

```json
"LoyaltyThresholds": [ 12000, 45000, 120000 ],
"LoyaltyReputationThresholds": [ 0.04, 0.09, 0.15 ]
```

The first number is for level **II**, the second for **III**, the third for **IV**.

The algorithm is simple: the level starts at 1 and goes up by one for every threshold the player has cleared **on both scales at once**:

```
level = 1
for every threshold i:
    if turnover   < LoyaltyThresholds[i]            → threshold not cleared
    if reputation < LoyaltyReputationThresholds[i]  → threshold not cleared
    otherwise                                       → level +1
capped at 4
```

Example for Prapor (thresholds 12 000 / 45 000 / 120 000, reputation 0.04 / 0.09 / 0.15):

| Turnover | Reputation | Level | Why |
|---|---|---|---|
| 20 000 | 0.02 | **I** | Turnover for II is there, but 0.04 reputation is not |
| 20 000 | 0.05 | **II** | First threshold cleared on both scales |
| 50 000 | 0.05 | **II** | III needs 0.09 reputation |
| 50 000 | 0.10 | **III** | Two thresholds cleared |
| 500 000 | 0.10 | **III** | IV needs 0.15 reputation |
| 500 000 | 0.15 | **IV** | All three thresholds cleared |

### When reputation thresholds are not set

`"LoyaltyReputationThresholds": []` — the level depends **only on turnover**. That is how the Fence is configured.

You can also set them partially: with two numbers in the list, level IV requires no reputation.

### ⚠️ The level is not stored — it is recomputed every time

Worth understanding before you touch the thresholds:

* Nobody is "recorded" as a level 3 player anywhere. The level is recalculated from their turnover and reputation on every access.
* **Change the thresholds and everybody's level changes immediately**, the next time the board is opened.
* Lower a threshold — everyone instantly goes up. Raise it — half the server drops a level.

If you want to "reset the progression", delete the files in `players\` rather than lowering the thresholds.

---

## The loyalty discount

Every level above the first drops the purchase price by `LoyaltyDiscountStep`:

```
price = round( Price × (1 − step × (level − 1)) )
```

Limits built into the code:

* the price never drops below **50 %** of `Price`;
* the step cannot exceed **0.15** — a larger value is treated as 0.15;
* `LoyaltyDiscountStep: 0` disables discounts entirely.

| `LoyaltyDiscountStep` | I | II | III | IV |
|---|---|---|---|---|
| `0.05` | 100 % | 95 % | 90 % | 85 % |
| `0.10` | 100 % | 90 % | 80 % | 70 % |
| `0.15` | 100 % | 85 % | 70 % | 55 % |

The discount affects **purchases for money only**. It does not make barters cheaper.

---

## Reputation from turnover

So that reputation grows on its own, without quests, every trader has three fields:

```json
"TurnoverReputationEnabled": true,
"TurnoverReputationInterval": 100000,
"TurnoverReputationGain": 0.1
```

Meaning: **every 100 000 of turnover grants 0.1 reputation**.

| Turnover with the trader | Reputation granted |
|---|---|
| 99 999 | 0 |
| 100 000 | 0.1 |
| 250 000 | 0.2 |
| 1 000 000 | 1.0 |

Rules:

* Each step is granted **once** — the server remembers how many steps it has already handed out.
* It is granted at the moment of a deal (buy, sell, barter), not on a timer.
* If you enable the mechanic for a player who has already traded 500 000, their very next deal grants `+0.5` for all the steps already passed.
* To switch it off: `TurnoverReputationEnabled: false`, or `Interval: 0`, or `Gain: 0`. Negative values are replaced with `0` and logged as a warning.
* Reputation cannot exceed **9.99** — the excess is simply cut off.

### Picking sensible values

The reputation thresholds and the growth rate have to line up, otherwise a level becomes unreachable.

Sanity check: with the defaults (`100000` / `0.1`), a player with 120 000 turnover at Prapor has 0.12 reputation, while level II needs 0.04. There is headroom, the progression works.

If you set `TurnoverReputationInterval: 1000000` while keeping a 0.15 reputation requirement for level IV, players will hit a wall: 120 000 turnover is enough for IV, but 0.15 reputation can never be reached. Either shrink the interval or lower the reputation thresholds.

---

## Where it is stored — the player file

`$profile:SG_Traders\players\<SteamID64>.json`:

```json
{
    "SteamId": "76561198012345678",
    "Roubles": 45200,
    "Dollars": 120,
    "Turnovers": [
        { "TraderId": "PRAPOR",    "Amount": 128000 },
        { "TraderId": "THERAPIST", "Amount": 9400 }
    ],
    "Quotas": [
        { "Key": "S:PRAPOR:S:I:7", "CycleStamp": 5400, "Used": 2 },
        { "Key": "L:PRAPOR:AKM",   "CycleStamp": 5400, "Used": 3 }
    ],
    "ReputationEntries": [
        { "TraderId": "PRAPOR", "Amount": 0.2, "TurnoverRepSteps": 1 }
    ]
}
```

| Block | What it is |
|---|---|
| `Roubles` / `Dollars` | The player's wallet |
| `Turnovers` | Turnover per trader — the level is derived from it |
| `Quotas` | Used purchase and sell limits for the current restock cycle |
| `ReputationEntries` | Reputation and how many turnover steps were already credited |

Keys in `Quotas`:

| Key | What it limits |
|---|---|
| `S:<trader>:S:I:<index>` | The `MaxStock` of the item at this **array index** in `Items` |
| `S:<trader>:S:B:<index>` | The `MaxStock` of the barter at this index in `Barters` |
| `L:<trader>:<classname>` | The sell limit of this item |

⚠️ **The purchase limit is tied to the item's array index, not to its classname.** If you insert a new item in the middle of the `Items` array or reorder the rows, the players' counters will shift onto the neighbouring offers. It is safe to **append new items at the end** of the array.

`CycleStamp` is the trader's last restock time. At the next restock the stamp stops matching and the counter reads as zero — nothing ever needs cleaning up.

### Editing player files by hand?

Technically possible, but only with the **server stopped**: profiles are held in memory and rewritten on every deal and when the player leaves. For one-off fixes (grant money, raise a level, adjust reputation) use the admin panel — it does the same thing safely and immediately.

---

## Cheat sheet

| I want to… | What to change |
|---|---|
| Levels to come faster | Lower `LoyaltyThresholds` |
| Levels from money only, no reputation | `LoyaltyReputationThresholds: []` |
| Levels from quests only | `TurnoverReputationEnabled: false` + keep the reputation thresholds |
| A bigger discount for regulars | `LoyaltyDiscountStep` (up to `0.15`) |
| No discounts at all | `LoyaltyDiscountStep: 0` |
| Reputation to grow faster | Lower `TurnoverReputationInterval` or raise `TurnoverReputationGain` |
| Different pacing per trader | These three fields exist per trader |

---

## Common mistakes

| Symptom | Cause |
|---|---|
| The player traded a lot but the level does not grow | Not enough **reputation** — the level requires both scales |
| The level dropped after editing the config | The thresholds were raised; the level is recomputed on the fly |
| Reputation is stuck | `TurnoverReputationEnabled: false`, or `Interval`/`Gain` are zero, or the step has not been reached yet |
| No discount | `LoyaltyDiscountStep: 0`, or the offer is a barter (the discount does not apply to barters) |
| The log says `WARNING: ... negative TurnoverReputationInterval` | Negative value; the server replaced it with `0`, the progression is off for this trader |
