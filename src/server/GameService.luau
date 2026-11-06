--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local HttpService=game:GetService("HttpService")
local Shared=ReplicatedStorage.Shared
local C=require(Shared.Config)
local R=require(Shared.Rules)
local G: any={State={}}
G.Data=require(script.Parent.PlayerDataService)
G.World=require(script.Parent.WorldService)
G.NPC=require(script.Parent.NPCService)
G.Inventory=require(script.Parent.InventoryService)
G.Missions=require(script.Parent.MissionService)
G.Security=require(script.Parent.SecurityService)
G.Vault=require(script.Parent.VaultService)
function G:Root(player: Player): BasePart?
 local char=player.Character
 local hum=if char then char:FindFirstChildOfClass("Humanoid") else nil
 local root=if char then char:FindFirstChild("HumanoidRootPart") else nil
 return if root and root:IsA("BasePart") and hum and hum.Health>0 then root else nil
end
function G:Notify(player: Player, message: string, sound: string?)
 self.Remote:FireClient(player,"Notice",{Text=message,Sound=sound or "Click"})
end
function G:Event(player: Player, kind: string, amount: number)
 local profile=self.Data:Get(player); if not profile then return end
 local message=self.Missions.event(profile,kind,amount)
 if message then self:Notify(player,message,"Success") end
end
function G:CancelInteraction(player: Player)
 local s=self.State[player]; if not s then return end
 if s.Attempt then
  local target=self.NPC.Targets[s.Attempt.Target]
  if target and target.Reserved==player then target.Reserved=nil; target.Available=os.clock()+3 end
  s.Attempt=nil; self.Remote:FireClient(player,"TimingEnd",{})
 end
end
function G:Heat(player: Player, amount: number)
 local s=self.State[player]; if not s then return end
 s.Heat=math.clamp(s.Heat+amount,0,100); s.LastTrouble=os.clock()
end
function G:Begin(player: Player, id: string)
 local p=self.Data:Get(player); local s=self.State[player]; local target=self.NPC.Targets[id]; local root=self:Root(player)
 if not p or not s or not root or not target or s.Attempt or s.Vault then return end
 if target.Reserved or target.Available>os.clock() then self:Notify(player,"That target is recovering or busy."); return end
 if not p.Districts[tostring(target.District)] then self:Notify(player,"Unlock this district first."); return end
 if p.Upgrades.Sleight<C.Districts[target.District].Equipment then self:Notify(player,"This target needs Sleight "..C.Districts[target.District].Equipment..". Upgrade at the hideout."); return end
 if #s.Loot>=R.capacity(p.Upgrades.Capacity,C) then self:Notify(player,"Pockets full. Bank at a mint hideout terminal."); return end
 if (root.Position-target.Model.PrimaryPart.Position).Magnitude>C.InteractDistance or not self.Security:Visible(root.Position,target.Model.PrimaryPart.Position) then return end
 local duration=(C.Timing.BaseDuration-target.District*C.Timing.DistrictSpeed)*(1-p.Upgrades.Sleight*C.Timing.SleightSpeed)
 local width=C.Timing.BaseWidth-target.District*C.Timing.DistrictWidth+p.Upgrades.Focus*C.Timing.FocusWidth
 local token=HttpService:GenerateGUID(false)
 local start=workspace:GetServerTimeNow()+C.InteractionLead
 target.Reserved=player
 s.Attempt={Target=id,Token=token,Start=start,Duration=duration,Center=Random.new():NextNumber(C.Timing.MinCenter,C.Timing.MaxCenter),Width=width}
 local packet=table.clone(s.Attempt); packet.Name=C.Districts[target.District].Name
 self.Remote:FireClient(player,"Timing",packet)
end
function G:Resolve(player: Player, token: string, expired: boolean?)
 local p=self.Data:Get(player); local s=self.State[player]; local root=self:Root(player)
 if not p or not s or not s.Attempt then return end
 local a=s.Attempt
 if a.Token~=token then return end
 local target=self.NPC.Targets[a.Target]
 if not target or target.Reserved~=player then self:CancelInteraction(player); return end
 local elapsed=workspace:GetServerTimeNow()-a.Start
 if not expired and elapsed < -0.1 then return end
 s.Attempt=nil; target.Reserved=nil; target.Available=os.clock()+C.TargetCooldown
 self.Remote:FireClient(player,"TimingEnd",{})
 local compensation=math.clamp(player:GetNetworkPing(),0,C.LatencyAllowance)
 local grade=if expired then "Miss" else R.grade(elapsed-compensation,a.Duration,a.Center,a.Width)
 if not root or (root.Position-target.Model.PrimaryPart.Position).Magnitude>C.InteractDistance or not self.Security:Visible(root.Position,target.Model.PrimaryPart.Position) then grade="Miss" end
 if not p.Districts[tostring(target.District)] or #s.Loot>=R.capacity(p.Upgrades.Capacity,C) then grade="Miss" end
 if grade=="Miss" then
  self:Heat(player,C.Heat.Failure); target.Suspicion=math.min(100,target.Suspicion+45)
  for _,other in self.NPC.Targets do if (other.Origin-target.Origin).Magnitude<22 then other.Suspicion=math.min(100,other.Suspicion+20) end end
  self:Notify(player,"OOPS · Target alerted. +"..C.Heat.Failure.." Heat. Try a different tourist.","Failure")
 else
  local loot=self.Inventory.roll(target.District,grade=="Perfect")
  table.insert(s.Loot,loot)
  local milestone=self.Inventory.discover(p,loot)
  p.Reputation+=if grade=="Perfect" then 3 else 2
  self:Heat(player,C.Heat.Success)
  self:Event(player,"success",1); self:Event(player,"collect",1); self:Event(player,"rarity",C.Cards[loot.Id].Rarity)
  self.Remote:FireClient(player,"Reveal",{Loot=loot,Grade=grade,Milestone=milestone})
 end
 self:Snapshot(player)
end
function G:Bank(player: Player)
 local p=self.Data:Get(player); local s=self.State[player]; local root=self:Root(player)
 if not p or not s or not root or s.Vault or s.Attempt then return end
 local near=false
 for _,center in self.World.SafeZones do if (root.Position-(center+Vector3.new(0,3,3))).Magnitude<14 then near=true; break end end
 if not near then self:Notify(player,"Walk to a mint hideout terminal to bank."); return end
 if #s.Loot==0 then self:Notify(player,"Empty pockets. Find a tourist across the street."); return end
 local count=#s.Loot; local amount=self.Inventory.value(p,s.Loot)
 s.Loot={}; p.Cash+=amount; p.Reputation+=count
 self:Event(player,"bank",amount)
 if not s.CaughtTrip then self:Event(player,"clean",count) end
 s.CaughtTrip=false
 self:Notify(player,"BANKED · +$"..amount.." · "..count.." cards safe!","Bank")
end
function G:Buy(player: Player, name: string)
 local p=self.Data:Get(player); local s=self.State[player]; local root=self:Root(player); local def=C.Upgrades[name]
 if not p or not s or not root or not def or s.Vault then return end
 if not self.World:InsideSafe(root.Position) then self:Notify(player,"Visit a mint hideout to buy upgrades."); return end
 local level=p.Upgrades[name]; local price=R.upgradeCost(def.BaseCost,def.Growth,level)
 if not R.canBuy(p.Cash,price,level,def.Max) then self:Notify(player,if level>=def.Max then "Already maxed." else "Need $"..price.." Cash."); return end
 p.Cash-=price; p.Upgrades[name]+=1
 self:ApplyMovement(player); self:Event(player,"upgrade",1)
 self:Notify(player,name.." upgraded to "..p.Upgrades[name].."!","Success")
end
function G:Unlock(player: Player, index: number)
 if index%1~=0 or index<2 or index>#C.Districts then return end
 local p=self.Data:Get(player); if not p then return end
 local d=C.Districts[index]
 if p.Districts[tostring(index)] then return end
 if not p.Districts[tostring(index-1)] then self:Notify(player,"Unlock the previous district first."); return end
 if p.Cash<d.Cash or p.Reputation<d.Rep then self:Notify(player,"Requires $"..d.Cash.." and "..d.Rep.." REP. Reputation is a requirement and is kept."); return end
 p.Cash-=d.Cash; p.Districts[tostring(index)]=true; self:Event(player,"district",1)
 self:Notify(player,"DISTRICT OPEN · Welcome to "..d.Name.."!","Success")
end
function G:ApplyMovement(player: Player)
 local p=self.Data:Get(player); local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if hum and p then hum.WalkSpeed=16+math.min(p.Upgrades.Sneakers,6)*0.8 end
end
function G:Capture(player: Player, dying: boolean?)
 local s=self.State[player]; local root=self:Root(player)
 if not s or s.Vault or (not dying and (not root or s.Immunity>os.clock())) then return end
 self:CancelInteraction(player)
 local lost=R.penalty(#s.Loot,C.CaptureFraction)
 for _=1,lost do table.remove(s.Loot) end
 s.CaughtTrip=true; s.Heat=15; s.Chase=false; s.Immunity=os.clock()+C.CaptureImmunity
 local district=if root then self.World:DistrictAt(root.Position) or 1 else 1
 if root and not dying then root.CFrame=self.World.Checkpoints[district]; s.LastPosition=root.Position end
 self.Remote:FireClient(player,"Capture",{Lost=lost,Kept=#s.Loot,Fraction=C.CaptureFraction,Died=dying==true})
end
function G:Prestige(player: Player, token: string)
 local p=self.Data:Get(player); local s=self.State[player]; local root=self:Root(player)
 if not p or not s or not root or s.Vault or not s.Prestige or s.Prestige.Token~=token or s.Prestige.Ends<os.clock() then return end
 s.Prestige=nil
 if not self.World:InsideSafe(root.Position) then self:Notify(player,"New Identity is available inside a hideout."); return end
 if p.Cash<C.Prestige.Cash or p.Reputation<C.Prestige.Reputation or not p.Districts["5"] or p.Starter<=#C.StarterMissions then self:Notify(player,"Finish all starter jobs, unlock all districts, and reach $100,000 / 1,000 REP."); return end
 self:CancelInteraction(player)
 p.Cash=0; p.Reputation=0; p.Districts={["1"]=true}
 for name in p.Upgrades do p.Upgrades[name]=0 end
 p.Starter=1; p.StarterProgress=0
 p.Identities+=1; p.Badges["Identity "..p.Identities]=true
 s.Loot={}; s.CaughtTrip=false; s.Heat=0; s.Chase=false; s.Immunity=os.clock()+10
 root.CFrame=self.World.Checkpoints[1]; s.LastPosition=root.Position
 self:ApplyMovement(player)
 self:Notify(player,"NEW IDENTITY · Badge earned. Permanent bank bonus now "..math.floor((R.identityBonus(p.Identities,C)-1)*100+0.5).."%.","Success")
end
function G:Snapshot(player: Player)
 local p=self.Data:Get(player); local s=self.State[player]; if not p or not s or player.Parent==nil then return end
 self.Missions.rotate(p)
 self.Remote:FireClient(player,"State",{Profile=p,Loot=s.Loot,Value=self.Inventory.value(p,s.Loot),Heat=s.Heat,Chase=s.Chase,Immunity=math.max(0,s.Immunity-os.clock()),Development=self.Data.IsDevelopment,Vault=if s.Vault then {Remaining=math.max(0,s.Vault.Ends-os.clock()),Collected=s.Vault.Collected,Stage=s.Vault.Stage} else nil})
end
function G:Request(player: Player, action: any, arg: any)
 local s=self.State[player]; if not s then return end
 local now=os.clock(); s.Tokens=math.min(16,s.Tokens+(now-s.TokenTime)*6); s.TokenTime=now
 if s.Tokens<1 then return end
 s.Tokens-=1
 if type(action)~="string" or not self.Data:Get(player) then return end
 if action=="Ready" then self:Snapshot(player)
 elseif action=="Begin" and type(arg)=="string" and #arg<32 then self:Begin(player,arg)
 elseif action=="Stop" and type(arg)=="string" and #arg<64 then self:Resolve(player,arg)
 elseif action=="Cancel" then self:CancelInteraction(player)
 elseif action=="Bank" then self:Bank(player)
 elseif action=="Buy" and type(arg)=="string" and #arg<30 then self:Buy(player,arg)
 elseif action=="Unlock" and type(arg)=="number" and arg==arg then self:Unlock(player,arg)
 elseif action=="Claim" and type(arg)=="string" and #arg<4 then
  if self.Missions.claim(self.Data:Get(player),arg) then self:Notify(player,"Daily reward claimed!","Success") end
 elseif action=="Vault" then self.Vault:Start(player)
 elseif action=="VaultLeave" then self.Vault:Finish(player,false,"Vault left. Replay at the kiosk.")
 elseif action=="PrestigeInfo" then
  s.Prestige={Token=HttpService:GenerateGUID(false),Ends=now+30}
  self.Remote:FireClient(player,"PrestigeInfo",{Token=s.Prestige.Token})
 elseif action=="Prestige" and type(arg)=="string" then self:Prestige(player,arg)
 elseif action=="Setting" and type(arg)=="table" and type(arg.Key)=="string" then
  local p=self.Data:Get(player)
  if (arg.Key=="Music" or arg.Key=="Effects") and type(arg.Value)=="number" and arg.Value==arg.Value then p.Settings[arg.Key]=math.clamp(arg.Value,0,1)
  elseif (arg.Key=="ReducedMotion" or arg.Key=="Shake") and type(arg.Value)=="boolean" then p.Settings[arg.Key]=arg.Value end
 end
 self:Snapshot(player)
end
function G:Character(player: Player, character: Model)
 local root=character:WaitForChild("HumanoidRootPart",15)
 if not root then return end
 local s=self.State[player]
 if not s then return end
 self:CancelInteraction(player)
 if s.Vault then self.Vault:Finish(player,false,"Vault ended after respawn.") end
 if #s.Loot>0 then s.CaughtTrip=true end
 root.CFrame=self.World.Checkpoints[1]; s.LastPosition=root.Position; s.Immunity=os.clock()+C.CaptureImmunity
 s.Heat=math.min(s.Heat,20); s.Chase=false
 self:ApplyMovement(player)
 if s.DeathConnection then s.DeathConnection:Disconnect() end
 local humanoid=character:FindFirstChildOfClass("Humanoid")
 if humanoid then
  s.DeathConnection=humanoid.Died:Connect(function()
   if self.State[player]~=s then return end
   if s.Vault then self.Vault:Finish(player,false,"Vault ended after respawn.")
   elseif #s.Loot>0 or s.Attempt or s.Heat>0 then self:Capture(player,true) end
  end)
 end
end
function G:Add(player: Player)
 if self.State[player] then return end
 self.State[player]={Loot={},Heat=0,LastTrouble=0,Immunity=os.clock()+10,Chase=false,VaultCooldown=0,Tokens=16,TokenTime=os.clock(),Suspicion={},Connections={}}
 local s=self.State[player]
 table.insert(s.Connections,player.CharacterAdded:Connect(function(char) self:Character(player,char) end))
 if not self.Data:Load(player) then self.State[player]=nil; for _,connection in s.Connections do connection:Disconnect() end; return end
 if player.Character then task.spawn(function() self:Character(player,player.Character) end) end
 self:Snapshot(player)
end
function G:Remove(player: Player)
 local s=self.State[player]
 if s then
  self:CancelInteraction(player)
  if s.Vault then self.Vault:Finish(player,false) end
  for _,connection in s.Connections do connection:Disconnect() end
  if s.DeathConnection then s.DeathConnection:Disconnect() end
  for _,guard in self.NPC.Guards do if guard.Target==player then guard.Target=nil end end
  self.State[player]=nil
 end
 self.Data:Release(player)
end
function G:Tick(now: number, dt: number)
 for player,s in self.State do
  local p=self.Data:Get(player); local root=self:Root(player)
  if not p or not root then continue end
  if s.Attempt and workspace:GetServerTimeNow()>s.Attempt.Start+s.Attempt.Duration+C.LatencyAllowance+0.2 then self:Resolve(player,s.Attempt.Token,true) end
  if not s.Vault then
   local district=self.World:DistrictAt(root.Position)
   if district and not p.Districts[tostring(district)] then
    self:CancelInteraction(player)
    local prior=math.max(1,district-1)
    while prior>1 and not p.Districts[tostring(prior)] do prior-=1 end
    root.CFrame=self.World.Checkpoints[prior]; s.LastPosition=root.Position
    self:Notify(player,"District locked. Open Districts to see the requirements.")
   end
   if root.Position.Y < -15 then root.CFrame=self.World.Checkpoints[1]; s.LastPosition=root.Position end
   local safe=self.World:InsideSafe(root.Position)
   if safe then s.Heat=math.max(0,s.Heat-C.Heat.SafeDecay*dt)
   elseif now-s.LastTrouble>C.Heat.QuietSeconds then
    local seen=false
    for _,guard in self.NPC.Guards do if guard.Target==player and now-guard.LastSeen<1 then seen=true; break end end
    if not seen then s.Heat=math.max(0,s.Heat-C.Heat.Decay*dt) end
   end
   for id,target in self.NPC.Targets do
    local nearby=(target.Model.PrimaryPart.Position-root.Position).Magnitude<C.Suspicion.Distance and not safe
    local suspicion=s.Suspicion[id] or 0
    suspicion=math.clamp(suspicion+(if nearby then dt*C.Suspicion.Rise*(1-p.Upgrades.Disguise*C.Suspicion.DisguiseReduction) else -dt*C.Suspicion.Decay),0,100)
    s.Suspicion[id]=suspicion
    if nearby then target.Suspicion=math.max(target.Suspicion,suspicion) end
    if suspicion>=100 then
     s.Suspicion[id]=35; self:Heat(player,C.Suspicion.AlertHeat); target.Available=math.max(target.Available,now+4)
     self:Notify(player,"That tourist noticed you lingering. Move along! +12 Heat.","Alert")
    end
   end
  end
 end
 self.NPC:Tick(now,dt); self.Security:Tick(now,dt); self.Vault:Tick(now)
end
function G:Start()
 self.World:Build(); self.NPC:Build(self.World); self.Security:Init(self); self.Vault:Init(self)
 local network=Instance.new("Folder"); network.Name="Network"; network.Parent=ReplicatedStorage
 local remote=Instance.new("RemoteEvent"); remote.Name="Game"; remote.Parent=network; self.Remote=remote
 remote.OnServerEvent:Connect(function(player,action,arg)
  local ok,err=pcall(function() self:Request(player,action,arg) end)
  if not ok then warn("Request failed: ",action,err) end
 end)
 Players.PlayerAdded:Connect(function(player) self:Add(player) end)
 Players.PlayerRemoving:Connect(function(player) self:Remove(player) end)
 for _,player in Players:GetPlayers() do task.spawn(function() self:Add(player) end) end
 self.Data:Start()
 task.spawn(function()
  local previous=os.clock(); local snapshots=0
  while true do
   task.wait(0.25)
   local now=os.clock(); local dt=math.min(0.5,now-previous); previous=now
   self:Tick(now,dt); snapshots+=1
   if snapshots%2==0 then for player in self.State do self:Snapshot(player) end end
  end
 end)
 print("Card City ready. Studio test data:",self.Data.IsDevelopment)
end
return G
