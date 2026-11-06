--!strict
local Shared = game:GetService("ReplicatedStorage").Shared
local C = require(Shared.Config)
local R = require(Shared.Rules)
local I = {}
local rng = Random.new()
local function weighted(entries: {any}, weight: (any)->number): number
 local total = 0
 for _,entry in entries do total += weight(entry) end
 local roll = rng:NextNumber(0,total)
 for index,entry in entries do roll -= weight(entry); if roll<=0 then return index end end
 return #entries
end
function I.roll(district: number, perfect: boolean): any
 local weights = table.clone(C.Districts[district].Weights)
 if perfect then
  for r = 2,#weights do weights[r] *= 1.3 end
 end
 local rarity = weighted(weights,function(v) return v end)
 local variant = C.Variants[weighted(C.Variants,function(v) return v.Weight end)]
 return {Id=string.format("D%dR%d",district,rarity),Variant=variant.Name}
end
function I.value(profile: any, loot: {any}): number
 local total=0
 for _,entry in loot do
  local card=C.Cards[entry.Id]
  local multiplier=1
  for _,variant in C.Variants do if variant.Name==entry.Variant then multiplier=variant.Multiplier end end
  total += R.lootValue(card.Value,multiplier,profile.Upgrades.Terminal,profile.Identities,C)
 end
 return total
end
function I.discover(profile: any, card: any): number
 profile.Collection[card.Id..":"..card.Variant]=true
 local count=0
 for _ in profile.Collection do count+=1 end
 local reward=0
 for index,milestone in C.Milestones do
  if count>=milestone.Count and not profile.Milestones[tostring(index)] then
   profile.Milestones[tostring(index)]=true; reward+=milestone.Cash
  end
 end
 profile.Cash+=reward
 return reward
end
return I
