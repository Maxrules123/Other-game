--!strict
local Shared = game:GetService("ReplicatedStorage").Shared
local C = require(Shared.Config)
local R = require(Shared.Rules)
local M = {}
function M.rotate(profile: any)
 local day = math.floor(os.time()/86400) -- UTC, server authoritative.
 if profile.Daily.Day ~= day then profile.Daily = {Day=day, Progress={}, Claimed={}} end
end
function M.definitions(profile: any): {any}
 M.rotate(profile)
 local result = {}
 for _,id in R.dailyIds(profile.Daily.Day,#C.DailyPool) do
  table.insert(result,{Id=tostring(id),Definition=C.DailyPool[id]})
 end
 return result
end
function M.event(profile: any, kind: string, amount: number): string?
 M.rotate(profile)
 local message = nil
 local starter = C.StarterMissions[profile.Starter]
 if starter and starter.Kind == kind then
  profile.StarterProgress += amount
  if profile.StarterProgress >= starter.Goal then
   profile.Cash += starter.Cash; profile.Reputation += starter.Rep
   profile.Starter += 1; profile.StarterProgress = 0
   message = "JOB COMPLETE · +$"..starter.Cash.." / +"..starter.Rep.." REP"
  end
 end
 for _,entry in M.definitions(profile) do
  local key,def = entry.Id,entry.Definition
  if def.Kind == kind and not profile.Daily.Claimed[key] then
   if kind == "rarity" then
    if amount >= def.Goal then profile.Daily.Progress[key] = def.Goal end
   else profile.Daily.Progress[key] = math.min(def.Goal,(profile.Daily.Progress[key] or 0)+amount) end
  end
 end
 return message
end
function M.claim(profile: any, id: string): boolean
 for _,entry in M.definitions(profile) do
  if entry.Id == id and not profile.Daily.Claimed[id] and (profile.Daily.Progress[id] or 0) >= entry.Definition.Goal then
   profile.Daily.Claimed[id] = true -- Claim before paying; no yields in this transaction.
   profile.Cash += entry.Definition.Cash; profile.Reputation += entry.Definition.Rep
   return true
  end
 end
 return false
end
return M
