--!strict
-- Pure logic: also exercised by the standalone Luau verification suite.
local R = {}
function R.upgradeCost(base: number, growth: number, level: number): number
 return math.floor(base * growth ^ level)
end
function R.capacity(level: number, config: any): number return config.Inventory.Base + level * config.Inventory.PerLevel end
function R.identityBonus(identities: number, config: any): number return 1 + math.min(config.Prestige.BonusCap, identities * config.Prestige.BonusPerIdentity) end
function R.position(elapsed: number, duration: number): number
 return math.clamp(elapsed / duration, 0, 1)
end
function R.grade(elapsed: number, duration: number, center: number, width: number): string
 if elapsed < 0 or elapsed > duration then return "Miss" end
 local distance = math.abs(R.position(elapsed, duration) - center)
 if distance <= width * 0.2 then return "Perfect" end
 if distance <= width * 0.5 then return "Good" end
 return "Miss"
end
function R.penalty(count: number, fraction: number): number return math.ceil(count * fraction) end
function R.dailyIds(day: number, count: number): {number}
 local start = day % count
 return {start + 1, (start + 1) % count + 1, (start + 2) % count + 1}
end
function R.canBuy(cash: number, cost: number, level: number, max: number): boolean
 return level < max and cash >= cost and cost >= 0
end
function R.lootValue(base: number, variant: number, terminal: number, identities: number, config: any): number
 return math.floor(base * variant * (1 + terminal * config.TerminalPerLevel) * R.identityBonus(identities, config))
end
return R
