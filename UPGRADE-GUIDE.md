# Equipment, tricks, and clubhouse progression

## Equipment

Equipment is purchased with Cash in a clubhouse. Reputation thresholds unlock later tiers but are never spent. For levels 1–8 the thresholds are **0, 0, 20, 50, 100, 200, 400, 650 REP**. Tracks with lower caps stop earlier. Each purchase costs `floor(base cost × growth ^ current level)`.

| Track | Base / growth / cap | Actual effect |
| --- | --- | --- |
| Sleight | $40 / 1.85 / 8 | Each stage is 4% shorter per level, up to 32%; rating unlocks tougher district targets. |
| Focus | $55 / 1.9 / 8 | Adds 1.2 percentage points to the base success-zone width per level, before approach/style modifiers. |
| Capacity | $60 / 1.9 / 8 | Five starting card slots, +2 per level, maximum 21. |
| Sneakers | $65 / 1.9 / 6 | Movement starts at 16, +0.8 per level, maximum 20.8. |
| Disguise | $50 / 1.85 / 8 | Reduces lingering suspicion growth by 7% per level, maximum 56%. It does not make guards ignore high Heat. |
| Hideout Terminal | $75 / 1.95 / 8 | +6% card banking value per level, maximum +48%. |
| Composure | $90 / 1.9 / 6 | Reduces successful/failed interaction Heat by 4% per level, maximum 24%. |
| Gadgets | $125 / 2.1 / 4 | Unlocks confetti decoys. Base charges = 1 + floor(level / 2); cooldown = 28 − 3 × level seconds. Restock at the supply bench. |
| Appraisal | $110 / 1.95 / 6 | Adds 4% rarity luck per level. Luck increasingly favors higher tiers instead of raising all non-Common weights equally. |

Ranks are DIY, Streetwise, Professional, and Legendary, advancing every two levels. Ranks label progression; their benefits are the explicit level effects, not hidden extra multipliers.

Early choices: Sleight opens access, Focus makes timing more forgiving, Capacity increases exposure before banking, Terminal improves secured income, and Composure/Disguise manage different sources of risk. Gadgets provides an active escape option; it needs restocking and does not replace cover or safe rooms.

## Target choices and staged timing

Scouting shows the personality, district, stage count, equipment requirement, suspicion, and possible rarities. A preview pauses the NPC for eight seconds without reserving its reward. Only beginning a valid attempt reserves it. Another player can claim an idle target while you are still reading its preview.

| Personality | Stages in districts 1–3 | Other properties |
| --- | --- | --- |
| Daydreamer | 1 | Wider zone, ordinary value/luck, slower walk. |
| Commuter | 2 | Ordinary zone, 1.05 value and 1.1 rarity luck. |
| Card Collector | 2 | Slightly narrower zone, 1.1 value and 1.5 rarity luck. |
| Fancy VIP | 3 | Narrower zone, 1.25 value and 1.35 rarity luck. |

Luxury and Neon add one stage, capped at three. The first onboarding success uses a single stage to keep the introduction short.

- **Careful:** 15% wider window, 12% longer stage, 20% less interaction Heat. No extra value/luck multiplier.
- **Bold:** 15% narrower window, 10% shorter stage, 40% more interaction Heat, 20% additional card value, 1.15 rarity-luck multiplier.
- Stage 1 sweeps forward. Stage 2 sweeps in reverse. Stage 3 bounces out and back. Later stages drift the mint success zone.
- Mint gives Good; its gold center gives Perfect. Every stage must pass before one card is granted. Perfect on all stages applies an additional 1.3 rarity-luck multiplier.
- Tokens change on every stage. The server computes positions from its start time and validates receipt time, target reservation, reach, capacity, line of sight, and district access. It never accepts a client result or reward amount.
- A five-trick streak gives up to 12% quality value: `1 + 0.03 × (streak − 1)`. Misses, live cancellations, capture, or death reset the streak. Canceled live tricks add 10 Heat; practice cancellations do not.
- Quality is assigned to the actual card when awarded, so later banking never retroactively changes its approach/streak bonus.

For a rarity `r` from 2 to 6, its weight is multiplied by `1 + (luck − 1) × (1 + (r − 2) × 0.45)`. Common is unchanged; zero weights stay zero. Final probabilities depend on all weights, so a 15% luck multiplier is not a guaranteed 15-percentage-point change in drop chance.

## Permanent clubhouse improvements

These are separate from normal equipment and **survive New Identity**. Buy them in the Hideout menu while in a safe room. Each has three levels; the Reputation requirement is the listed base multiplied by the next level.

| Room | Base / growth / base REP | Effect |
| --- | --- | --- |
| Recovery Lounge | $90 / 2.6 / 0 | Adds 4 Heat recovery per second per level in safe rooms. Maximum recovery becomes 26 Heat/second including the base 14. |
| Gadget Workshop | $160 / 2.6 / 20 | Adds one supply-bench decoy charge per level. Gadgets must be unlocked; maximum combined capacity is six. |
| Collector Gallery | $140 / 2.6 / 20 | After five card/variant discoveries, adds 2% banking value per level, maximum 6%. Displays up to nine personal discovered cards. |
| Courier Network | $220 / 2.8 / 30 | Level 1 serves Starter, Plaza, and Business; level 2 reaches every unlocked district; level 3 further reduces fares. |

Courier fare = `floor(20 × (destination district − 1) × (1 − network level × 0.2))`. You must use a route board, own the destination unlock, have empty pockets, be out of a chase, and be below 20 Heat. Returning to Starter is free after the network is unlocked. Travel cannot be used to extract unbanked cards.

The practice arcade has three stages and gives no loot, Cash, Reputation, Heat, streak, or career-attempt rewards. The supply bench refills charges for free but does not reset a running gadget cooldown.

A decoy removes 12 Heat and suppresses guards' pursuit of its owner for 3.5 seconds. Other players' states are unchanged. A still-hot player can be detected again afterwards. Use the opening to get behind cover.

## Banking and persistence

Each banked card is worth:

`floor(base card value × variant × quality × terminal bonus × gallery bonus × identity bonus)`

Variants: Standard ×1, Foil ×1.5, Glitched ×2.2, Golden ×3.5. Identity bonus is 5% per identity capped at 50%. Fixed mission/Vault rewards use their own configured amounts.

New Identity resets Cash, Reputation, normal equipment, district access, carried cards, Heat, live streak, decoy charges, and starter jobs. It keeps card discoveries, milestone claims, daily progress/claims, settings, identity badges, clubhouse levels, discovered city secrets, and career stats.

Fifteen city souvenirs pay once per player. Each gives `35 + 25 × district` Cash and `4 + district` Reputation. The Hideout journal gives clues. Their rewards are independent of card timing and do not count as stolen cards.

All formulas and values are centralized in Config and Rules. Balance changes should preserve the bounded movement speed and per-phase server validation.
