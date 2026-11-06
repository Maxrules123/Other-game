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
  profile.StarterProgress=if kind=="clean" then math.max(profile.StarterProgress,amount) else profile.StarterProgress+amount
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
 local active=profile.Contracts.Active
 local contract=C.Contracts[active]
 if contract and contract.Kind==kind and not profile.Contracts.Claimed[active] then
  profile.Contracts.Progress[active]=math.min(contract.Goal,(profile.Contracts.Progress[active] or 0)+amount)
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
function M.accept(profile: any,id: string): boolean
 local def=C.Contracts[id]
 if not def or profile.Contracts.Active~="" or profile.Contracts.Claimed[id] or not profile.Districts[tostring(def.District)] then return false end
 if def.Previous and not profile.Contracts.Claimed[def.Previous] then return false end
 profile.Contracts.Active=id
 -- Ownership/discovery objectives should not deadlock returning players.
 if def.Kind=="van" and profile.Van.Owned then profile.Contracts.Progress[id]=1 end
 if def.Kind=="facility" then local n=0; for _,level in profile.Hideout do n+=level end; profile.Contracts.Progress[id]=math.min(def.Goal,n) end
 if def.Kind=="secret" then local n=0; for _ in profile.Secrets do n+=1 end; profile.Contracts.Progress[id]=math.min(def.Goal,n) end
 return true
end
function M.claimContract(profile: any,id: string): boolean
 local def=C.Contracts[id]
 if not def or profile.Contracts.Active~=id or profile.Contracts.Claimed[id] or (profile.Contracts.Progress[id] or 0)<def.Goal then return false end
 profile.Contracts.Claimed[id]=true; profile.Contracts.Active=""
 profile.Cash+=def.Cash; profile.Reputation+=def.Rep
 return true
end
return M
