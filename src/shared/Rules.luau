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
function R.processSeconds(kind: string,level: number,config: any): number
 local base=if kind=="Press" then config.Processing.PressSeconds else config.Processing.RinseSeconds
 return math.max(3,math.ceil(base*(1-level*config.Processing.SpeedPerLevel)))
end
function R.challenge(district: number,stage: number,sleight: number,focus: number,approach: any,style: any,config: any): any
 local duration=math.max(0.95,(config.Timing.BaseDuration-district*config.Timing.DistrictSpeed)*(1-sleight*config.Timing.SleightSpeed)*approach.Duration)
 local width=math.clamp((config.Timing.BaseWidth-district*config.Timing.DistrictWidth+focus*config.Timing.FocusWidth)*approach.Width*style.Width,0.085,0.36)
 return {Duration=duration,Width=width,Drift=math.min(0.12,config.Stealing.Drift+(district-1)*0.012+(stage-1)*0.008),Pattern=({"Sweep","Reverse","Bounce"})[stage]}
end
function R.speedTowards(current: number,target: number,acceleration: number,dt: number): number
 return current+math.clamp(target-current,-acceleration*dt,acceleration*dt)
end
function R.cursor(elapsed: number, duration: number, pattern: string): number
 local t=R.position(elapsed,duration)
 if pattern=="Reverse" then return 1-t end
 if pattern=="Bounce" then return 1-math.abs(1-2*t) end
 return t
end
function R.zone(elapsed: number, duration: number, center: number, drift: number, width: number): number
 return math.clamp(center+math.sin(R.position(elapsed,duration)*math.pi*2)*drift,width/2,1-width/2)
end
function R.stageGrade(elapsed: number, attempt: any): string
 if elapsed<0 or elapsed>attempt.Duration then return "Miss" end
 local center=R.zone(elapsed,attempt.Duration,attempt.Center,attempt.Drift,attempt.Width)
 local distance=math.abs(R.cursor(elapsed,attempt.Duration,attempt.Pattern)-center)
 if distance<=attempt.Width*0.2 then return "Perfect" end
 if distance<=attempt.Width*0.5 then return "Good" end
 return "Miss"
end
function R.stageCount(district: number, style: string, config: any): number
 return math.clamp(config.TargetStyles[style].Stages+(if district>=4 then 1 else 0),1,3)
end
function R.heatScale(level: number, config: any): number return 1-level*config.Stealing.Composure end
function R.rarityWeight(base: number, rarity: number, luck: number, config: any): number
 if rarity<=1 then return base end
 return base*(1+(luck-1)*(1+(rarity-2)*config.Stealing.RaritySlope))
end
function R.charges(profile: any, config: any): number
 local level=profile.Upgrades.Gadgets
 return if level==0 then 0 else config.Gadget.BaseCharges+math.floor(level/config.Gadget.ChargeLevels)+profile.Hideout.Workshop
end
function R.galleryBonus(profile: any, config: any): number
 local count=0; for _ in profile.Collection do count+=1 end
 return if count>=config.Hideout.DisplayDiscoveries then 1+profile.Hideout.Display*config.Hideout.DisplayBonus else 1
end
function R.travelCost(level: number, district: number, config: any): number
 return math.floor(config.Hideout.TravelFare*(district-1)*(1-level*config.Hideout.TravelDiscount))
end
function R.upgradeEffect(name: string, level: number, config: any): string
 if name=="Sleight" then return string.format("%d%% shorter stages · access rating %d",level*config.Timing.SleightSpeed*100,level)
 elseif name=="Focus" then return string.format("+%.1f%% success window",level*config.Timing.FocusWidth*100)
 elseif name=="Capacity" then return tostring(R.capacity(level,config)).." card slots"
 elseif name=="Sneakers" then return string.format("%.1f movement speed",16+level*0.8)
 elseif name=="Disguise" then return string.format("%d%% less lingering suspicion",level*config.Suspicion.DisguiseReduction*100)
 elseif name=="Terminal" then return string.format("+%d%% banking value",level*config.TerminalPerLevel*100)
 elseif name=="Composure" then return string.format("%d%% less interaction Heat",level*config.Stealing.Composure*100)
 elseif name=="Press" or name=="Rinse" then return string.format("%d%% faster batches",level*config.Processing.SpeedPerLevel*100)
 elseif name=="Yield" then return string.format("+%d%% batch payout",level*config.Processing.YieldPerLevel*100)
 elseif name=="VanSlots" then return tostring(config.Van.BaseSlots+level*config.Van.SlotsPerLevel).." secured van slots"
 elseif name=="Engine" then return tostring(config.Van.Speed+level*config.Van.SpeedPerLevel).." studs/s van speed"
 elseif name=="Appraisal" then return string.format("+%d%% rarity luck (stronger on higher tiers)",level*config.Stealing.Appraisal*100)
 else return if level==0 then "Decoy locked" else string.format("%d base charges · %ds cooldown",config.Gadget.BaseCharges+math.floor(level/config.Gadget.ChargeLevels),config.Gadget.Cooldown-level*config.Gadget.CooldownPerLevel) end
end
return R
