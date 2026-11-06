--!strict
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local C = require(Shared.Config)
local Data: any = { Profiles = {}, Sessions = {}, Closing = false }
local dev = RunService:IsStudio() and C.StudioTestData
local store = if dev then nil else DataStoreService:GetDataStore(C.StoreName)
local function copy(value: any): any
 if type(value) ~= "table" then return value end
 local result = {}
 for k,v in value do result[k] = copy(v) end
 return result
end
local function defaults(): any
 local upgrades = {}
 for name in C.Upgrades do upgrades[name] = 0 end
 return { Schema = C.Schema, Cash = 0, Reputation = 0, Upgrades = upgrades, Districts = {["1"] = true}, Collection = {}, Milestones = {}, Starter = 1, StarterProgress = 0, Daily = {Day = -1, Progress = {}, Claimed = {}}, Identities = 0, Badges = {}, Settings = {Music = 0.35, Effects = 0.7, ReducedMotion = false, Shake = true} }
end
local function reconcile(value: any, template: any): any
 if type(value) ~= "table" then error("Profile has an invalid structure") end
 for key, fallback in template do
  if value[key] == nil then value[key] = copy(fallback)
  elseif type(value[key]) ~= type(fallback) then error("Invalid profile field: " .. key)
  elseif type(fallback) == "table" then reconcile(value[key], fallback) end
 end
 return value
end
function Data:Get(player: Player): any
 local session = self.Sessions[player]
 if session and not session.Closing and (dev or os.time() < session.Expires) then return self.Profiles[player] end
 return nil
end
function Data:Load(player: Player): boolean
 if self.Closing then return false end
 local token = HttpService:GenerateGUID(false)
 local profile = nil
 local expires = os.time() + C.LeaseSeconds
 if dev then profile = defaults() else
  for attempt = 1, 4 do
   local ok, record = pcall(function()
    return store:UpdateAsync("player_" .. player.UserId, function(old: any)
     if old and (type(old) ~= "table" or type(old.Data) ~= "table") then error("Invalid saved profile") end
     if old and old.Lease and old.Lease.Token ~= token and old.Lease.Expires > os.time() then return nil end
     local data = if old then copy(old.Data) else defaults()
     if type(data.Schema) ~= "number" or data.Schema > C.Schema then error("Unsupported data version") end
     reconcile(data, defaults())
     data.Schema = C.Schema
     expires = os.time() + C.LeaseSeconds
     return {Data = data, Lease = {Token = token, Expires = expires}, Revision = (if old then old.Revision or 0 else 0) + 1}
    end)
   end)
   if ok and record and record.Lease.Token == token then profile = record.Data; break end
   if attempt < 4 then task.wait(attempt * 1.5) end
  end
 end
 if not profile then
  player:Kick("Your saved progress could not be opened safely. It may be active on another server. Please wait a minute and rejoin; nothing was replaced.")
  return false
 end
 self.Profiles[player] = profile
 self.Sessions[player] = {Token = token, Expires = expires, Busy = false, Closing = false}
 if player.Parent == nil or self.Closing then self:Release(player); return false end
 return true
end
function Data:Save(player: Player, release: boolean?): boolean
 local session = self.Sessions[player]
 if not session then return false end
 while session.Busy do task.wait(0.1) end
 if self.Sessions[player] ~= session then return false end
 session.Busy = true
 if release then session.Closing = true end
 local snapshot = copy(self.Profiles[player])
 local success = dev
 local lost = false
 if not dev then
  for attempt = 1, 3 do
   local expires = os.time() + C.LeaseSeconds
   local ok, record = pcall(function()
    return store:UpdateAsync("player_" .. player.UserId, function(old: any)
     if not old or not old.Lease or old.Lease.Token ~= session.Token or old.Lease.Expires <= os.time() then lost = true; return nil end
     return {Data = snapshot, Lease = if release then nil else {Token = session.Token, Expires = expires}, Revision = (old.Revision or 0) + 1}
    end)
   end)
   if ok and record and not lost then session.Expires = expires; success = true; break end
   if lost then break end
   task.wait(attempt)
  end
 end
 session.Busy = false
 if lost then
  session.Closing = true
  player:Kick("Your save session changed. Rejoin to safely reload your progress.")
 elseif not success and os.time() >= session.Expires - 20 then
  session.Closing = true
  player:Kick("Saving is unavailable. Please rejoin later. Your last successful save remains safe.")
 end
 if release then self.Profiles[player] = nil; self.Sessions[player] = nil end
 return success
end
function Data:Release(player: Player) self:Save(player, true) end
function Data:Start()
 task.spawn(function()
  while not self.Closing do
   task.wait(C.SaveInterval)
   for player in self.Sessions do
    task.spawn(function() self:Save(player, false) end)
   end
  end
 end)
 game:BindToClose(function()
  self.Closing = true
  for player in self.Sessions do task.spawn(function() self:Release(player) end) end
  local deadline = os.clock() + 25
  while next(self.Sessions) and os.clock() < deadline do task.wait(0.1) end
 end)
end
Data.IsDevelopment = dev
return Data
