# City Shift progression and controls

## The complete money loop

Scout a fictional citizen → choose Careful/Bold → read a lane route and clear its skill phases → pocket a card → secure cards at the alley intake or in your van → deposit at the workshop → press imaginary ink tokens → run a cartoon rinse → claim in-game Cash → buy gear, cosmetics, home improvements and district access.

**Depositing does not pay instant Cash.** Queue value/cards, active batch value/cards, stage and timer are saved. A batch is Pressing → Pressed → Rinsing → Ready. Pressed and Ready wait for you to use the next station. Completed timers refresh after rejoin. Claims clear the finished batch before awarding anything, so replaying a claim cannot duplicate Cash. Up to 200 cards can wait in the intake; active batches are separate.

The base queue value is `floor(card base × variant × assigned quality × intake/Terminal bonus × gallery bonus × identity bonus)` per card. Batch payout is `floor(queue value × (1 + Yield level × 0.04))`, locked when pressing starts. Fixed quest rewards use their own values. This is an entirely imaginary arcade conversion process, not a real financial technique.

## Equipment

Cash buys equipment in a safe workshop. Reputation is checked but kept. Tier requirements for levels 1–8 are 0, 0, 20, 50, 100, 200, 400, 650 REP. Cost is `floor(base × growth ^ current level)`.

| Track | Base / growth / cap | Effect |
| --- | --- | --- |
| Sleight | 40 / 1.85 / 8 | 1.8% more phase time per level; rating opens tougher targets. |
| Focus | 55 / 1.9 / 8 | +0.6 percentage points of base success width per level, before mode modifiers and bounds. |
| Capacity | 60 / 1.9 / 8 | Five pockets +2 per level, maximum 21. |
| Sneakers | 65 / 1.9 / 6 | 16 speed +0.8 per level, capped at 20.8. |
| Disguise | 50 / 1.85 / 8 | 7% slower lingering suspicion per level. |
| Intake/Terminal | 75 / 1.95 / 8 | +6% intake value per level. |
| Composure | 90 / 1.9 / 6 | 4% less interaction Heat per level. |
| Gadgets | 125 / 2.1 / 4 | Decoys: 1 + floor(level/2) base charges; cooldown 28 − 3 × level seconds. |
| Appraisal | 110 / 1.95 / 6 | +4% rarity luck per level, with increasing benefit to higher rarities. |
| Press | 100 / 1.85 / 6 | 7% less press time per level. |
| Rinse | 120 / 1.85 / 6 | 7% less rinse time per level. |
| Yield | 180 / 1.95 / 6 | +4% batch payout per level, locked at batch start. |
| Van Slots | 160 / 1.9 / 6 | Eight storage slots +4 per level, maximum 32. |
| Engine | 200 / 1.9 / 4 | 18 van cruising speed +2 per level, maximum 26; rain reduces it. |

Press time starts at 18 seconds and rinse at 14; upgraded time is `ceil(base × (1 − level × 0.07))` with a three-second lower bound. At level 6 the stages take 11 and 9 seconds.

## Skill rounds and risk

The first onboarding round teaches lane 2 with a four-second phase. Normal rounds have 2–4 connected phases; practice has three, and the daily drill has four. READ shows a numbered route, then LIFT/SWITCH/CLEAR change lane, direction and (later) drift. High-stakes routes introduce memory from district 3. Every generated phase has a reachable mint/gold interval.

Controls: J/K/L map to lanes 1/2/3; touch the lane button; or use arrows/D-pad/shoulders to select and Space/A to commit. Character movement is suspended during rounds/results. Timing uses synchronized input time with a server-owned token and bounded backdating (ping + 0.1 seconds, capped at 0.4), never a client success/reward flag.

Duration is `clamp((3.25 − (district−1)×0.16) × (1 + Sleight×0.018) × mode, 2.4, 4.6)`, with mode 1.08 Careful/Practice or 0.92 Bold/Daily. Width is `clamp((0.235 − (district−1)×0.017 + Focus×0.006) × mode, 0.12, 0.34)`, with mode 1.05 or 0.87. Daily drill uses fixed zero gear and the current UTC-day seed, so retrying gear does not change its route.

One primary mistake opens STABILIZE: lane 2, no drift, wider zone, 3.5 seconds. Clearing preserves 80% round quality; another primary/recovery failure grants no card. One owned decoy charge may instead stabilize an action at an 80% quality/medal cost. It cannot revive an expired phase.

After a complete street route, SECURE keeps the earned card. BONUS adds one disclosed bounce phase: clear for +15% round quality; miss for 75% current quality and additional Heat while retaining one card. Seven seconds without choosing secures automatically. The onboarding round and training finish directly.

Careful adds 20% less Heat; Bold adds 40% more, +20% base card quality and +15% rarity luck. Every mistake adds six Heat before approach/composure modifiers. Existing bounded streak/style bonuses remain. Rewards are granted once after server validation; no partial phase payout. Practice/daily save scores and medals without money, loot or Heat. Gold requires all primary phases perfect without mistakes; Platinum additionally clears the bonus. Recoveries earn Bronze. Bests are saved per mode and district; the daily best is date-scoped.

## Home, van, weather and cosmetics

Home Lounge/Workshop/Gallery/Network remain three-level permanent tracks. Lounge adds 4 safe-zone recovery/second per level; Workshop adds one supply charge per level; Gallery adds 2% intake value per level after five discoveries; Network enables empty-pocket, cool-player courier travel. Courier fees and minimum levels appear in Districts. A decoy removes 12 Heat and suppresses its owner's pursuit for 3.5 seconds; a hot player may be seen again afterwards.

The van is $650 / 30 REP at a garage. It is physically drivable, with validated occupant/input rules, steering/acceleration limits, and a 0.6-second input watchdog. Its saved stash is private and protected from capture. Rear-door transfers obey both van and pocket capacity. Unloading into processing requires the van rear and player to be close to an external workshop intake. Summoning requires a garage and cooldown; occupied vans cannot be remotely respawned. Crossing locked/out-of-bounds districts returns the vehicle to Starter. Driving and the Plaza delivery bay support Jax's story chain.

The day/night cycle lasts 24 minutes. Weather duration varies roughly 150–270 seconds, transitions blend over 24 seconds, and weighted next states avoid abrupt Clear→heavy Rain jumps. Rain slows vehicles to 80%; Fog reduces guard acquisition range. Local rain and vegetation motion respect settings. Indoor lights stay usable independently of the street-light schedule.

Ten cosmetics have fixed visible Cash/REP prices and no random crates or gameplay benefits. Purchase at an Outfitters register, then equip at a workshop wardrobe. One item per Head/Face/Back/Outfit slot; remove restores the original avatar layers/headwear. Ownership and equipped styles are saved and survive New Identity.

## New Identity

Requires all districts, completed starter jobs, $100,000 and 1,000 REP. Resets Cash/REP, normal gear, districts, pockets, van stash, processing queue/batch, Heat/streak/decoy charges and starter jobs. Keeps van ownership, home upgrades, cosmetics/outfit, collection, souvenirs, career stats, story contract and daily progress/claims, settings and identity badges. Awards one identity badge and +5% permanent card value per identity, capped at +50%.
