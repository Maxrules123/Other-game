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
G.Interaction=require(script.Parent.InteractionService)
G.Processing=require(script.Parent.ProcessingService)
G.Vehicles=require(script.Parent.VehicleService)
G.Environment=require(script.Parent.EnvironmentService)
G.Traffic=require(script.Parent.TrafficService)
G.Cosmetics=require(script.Parent.CosmeticService)
G.Navigation=require(script.Parent.NavigationService)
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
 if kind=="escape" then profile.Stats.Escapes+=amount elseif kind=="vault" then profile.Stats.VaultClears+=amount end
end
function G:CancelInteraction(player: Player,penalize: boolean?) self.Interaction:Cancel(player,penalize) end
function G:NearStation(player: Player,kind: string): boolean
 local root=self:Root(player); if not root then return false end
 for index,pos in self.World.Stations[kind] or {} do
  if (root.Position-pos).Magnitude<14 and self.Security:Visible(root.Position,pos,self.World.StationParts and self.World.StationParts[kind] and self.World.StationParts[kind][index]) then return true end
 end
 return false
end
function G:Unseat(player: Player)
 local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if hum and hum.SeatPart then local seat=hum.SeatPart; hum.Sit=false; local joint=seat:FindFirstChild("SeatWeld"); if joint then joint:Destroy() end end
end
function G:Heat(player: Player, amount: number)
 local s=self.State[player]; if not s then return end
 s.Heat=math.clamp(s.Heat+amount,0,100); s.LastTrouble=os.clock()
end
function G:Begin(player: Player,id: string,approach: string?) self.Interaction:Begin(player,id,approach) end
function G:Resolve(player: Player,hit: any,expired: boolean?) self.Interaction:Resolve(player,hit,expired) end
function G:Bank(player: Player) self.Processing:Deposit(player,false) end
function G:Talk(player: Player,speaker: string)
 local root=self:Root(player);local s=self.State[player];local def=C.Speakers[speaker];local position=self.World.QuestPositions[speaker]
 if not root or not s or s.Attempt or s.Vault or not def or not position or (root.Position-position).Magnitude>18 or not self.Security:Visible(root.Position,position+Vector3.new(0,3,0)) then return end
 s.Dialogue=s.Dialogue or {};local index=(s.Dialogue[speaker] or 0)%#def.Lines+1;s.Dialogue[speaker]=index
 self.Remote:FireClient(player,"Dialogue",{Speaker=speaker,Role=def.Role,Text=def.Lines[index]})
end
function G:Quest(player: Player,action: string,id: string)
 local p=self.Data:Get(player); local root=self:Root(player); local s=self.State[player]; local def=C.Contracts[id]
 if not p or not root or not s or s.Attempt or s.Vault or not def then return end
 local pos=self.World.QuestPositions[def.Speaker]
 if not pos or (root.Position-pos).Magnitude>18 or not self.Security:Visible(root.Position,pos+Vector3.new(0,3,0)) then self:Notify(player,"Talk to "..def.Speaker.." in their district courtyard."); return end
 if action=="Accept" then
  if self.Missions.accept(p,id) then s.NavPin=nil;self:Notify(player,"CONTRACT ACCEPTED / "..def.Title,"Success") else self:Notify(player,"Finish or pause your active contract and meet this contract's requirements.") end
 elseif action=="Claim" and self.Missions.claimContract(p,id) then self:Notify(player,"CONTRACT COMPLETE / +$"..def.Cash.." / +"..def.Rep.." REP","Bank") end
end
function G:Buy(player: Player, name: string)
 local p=self.Data:Get(player); local s=self.State[player]; local root=self:Root(player); local def=C.Upgrades[name]
 if not p or not s or not root or not def or s.Vault then return end
 if not self.World:InsideSafe(root.Position) then self:Notify(player,"Visit a mint hideout to buy upgrades."); return end
 local level=p.Upgrades[name]
 local rep=C.UpgradeRep[level+1] or 0
 if p.Reputation<rep then self:Notify(player,"This tier needs "..rep.." REP (kept, not spent)."); return end
 local price=R.upgradeCost(def.BaseCost,def.Growth,level)
 if not R.canBuy(p.Cash,price,level,def.Max) then self:Notify(player,if level>=def.Max then "Already maxed." else "Need $"..price.." Cash."); return end
 p.Cash-=price; p.Upgrades[name]+=1
 self:ApplyMovement(player); self:Event(player,"upgrade",1)
 self:Notify(player,name.." upgraded to "..p.Upgrades[name].."!","Success")
end
function G:HideoutBuy(player: Player,name: string)
 local p=self.Data:Get(player); local s=self.State[player]; local root=self:Root(player); local def=C.HideoutUpgrades[name]
 if not p or not s or not root or not def or s.Vault or s.Attempt then return end
 if not self.World:InsideSafe(root.Position) then self:Notify(player,"Buy clubhouse improvements inside a safe room."); return end
 local level=p.Hideout[name]; local price=R.upgradeCost(def.BaseCost,def.Growth,level); local rep=def.Rep*(level+1)
 if p.Reputation<rep then self:Notify(player,"This clubhouse tier needs "..rep.." REP."); return end
 if not R.canBuy(p.Cash,price,level,def.Max) then self:Notify(player,if level>=def.Max then "This room is fully upgraded." else "Need $"..price.." Cash."); return end
 p.Cash-=price; p.Hideout[name]+=1; self:Event(player,"facility",1)
 self:Notify(player,def.Name.." improved! Clubhouse upgrades survive New Identity.","Success")
end
function G:Resupply(player: Player)
 local p=self.Data:Get(player); local s=self.State[player]
 if not p or not s or s.Vault or s.Attempt then return end
 if not self:NearStation(player,"Resupply") then self:Notify(player,"Walk to the mint supply bench in a clubhouse."); return end
 local charges=R.charges(p,C)
 if charges==0 then self:Notify(player,"Buy Gadgets level 1 to unlock the confetti decoy."); return end
 s.GadgetCharges=charges
 self:Notify(player,"Workbench restocked · "..charges.." confetti decoy charges. G / R1 / DECOY button.","Success")
end
function G:Decoy(player: Player)
 local p=self.Data:Get(player); local s=self.State[player]; local root=self:Root(player); local now=os.clock()
 if not p or not s or not root or s.Vault or s.Attempt or p.Upgrades.Gadgets<1 then return end
 if self.World:InsideSafe(root.Position) then self:Notify(player,"Save confetti for the street. Restock at the mint workbench."); return end
 if (s.GadgetCharges or 0)<1 then self:Notify(player,"No charges. Restock at the clubhouse supply bench."); return end
 if (s.GadgetReady or 0)>now then self:Notify(player,"Decoy cooling down: "..math.ceil(s.GadgetReady-now).."s."); return end
 s.GadgetCharges-=1; s.GadgetReady=now+C.Gadget.Cooldown-p.Upgrades.Gadgets*C.Gadget.CooldownPerLevel
 s.DecoyUntil=now+C.Gadget.DistractSeconds; s.Heat=math.max(0,s.Heat-C.Gadget.HeatRelief)
 self.NPC:React(root.Position,"Distracted",18)
 self.Remote:FireClient(player,"Decoy",{})
 self:Notify(player,"CONFETTI DISTRACTION · Move! Nearby security loses your trail briefly.","Success")
end
function G:Travel(player: Player,index: number)
 if index%1~=0 or index<1 or index>#C.Districts then return end
 local p=self.Data:Get(player); local s=self.State[player]; local root=self:Root(player)
 if not p or not s or not root or s.Vault or s.Attempt then return end
 if not self:NearStation(player,"Hideout") then self:Notify(player,"Use the courier route board at the back of a clubhouse."); return end
 if (s.TravelReady or 0)>os.clock() then return end
 if not p.Districts[tostring(index)] then self:Notify(player,"Unlock that district before booking a courier."); return end
 local required=math.max(1,math.ceil((index-1)/2))
 if p.Hideout.Network<required then self:Notify(player,"Courier Network "..required.." required."); return end
 if #s.Loot>0 or s.Heat>=C.Hideout.TravelHeat or s.Chase then self:Notify(player,"Bank all cards and cool below "..C.Hideout.TravelHeat.." Heat before traveling."); return end
 if self.World:DistrictAt(root.Position)==index then self:Notify(player,"You are already in this district."); return end
 local fare=R.travelCost(p.Hideout.Network,index,C)
 if p.Cash<fare then self:Notify(player,"Courier fare is $"..fare.."."); return end
 self:Unseat(player)
 p.Cash-=fare; s.TravelReady=os.clock()+3
 root.CFrame=self.World.Checkpoints[index]; s.LastPosition=root.Position; s.Immunity=os.clock()+3
 self:Notify(player,"COURIER ARRIVAL · "..C.Districts[index].Name.." · $"..fare,"Success")
end
function G:Secret(player: Player,id: string)
 local p=self.Data:Get(player); local s=self.State[player]; local root=self:Root(player); local def=C.Secrets[id]; local pos=self.World.Secrets[id]
 if not p or not s or not root or not def or not pos or s.Vault or s.Attempt or p.Secrets[id] then return end
 if not p.Districts[tostring(def.District)] or (root.Position-pos).Magnitude>12 then return end
 if not self.Security:Visible(root.Position,pos,self.World.SecretParts[id]) then return end
 p.Secrets[id]=true; p.Cash+=def.Cash; p.Reputation+=def.Rep; self:Event(player,"secret",1)
 self:Notify(player,"CITY SECRET · "..def.Name.." · +$"..def.Cash.." / +"..def.Rep.." REP. Check the clubhouse journal.","Reveal")
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
 for _,loot in s.Loot do loot.Clean=false end
 s.Combo=0; s.CaughtTrip=true; s.Heat=15; s.Chase=false; s.Immunity=os.clock()+C.CaptureImmunity
 local district=if root then self.World:DistrictAt(root.Position) or 1 else 1
 if root and not dying then self:Unseat(player); root.CFrame=self.World.Checkpoints[district]; s.LastPosition=root.Position end
 self.Remote:FireClient(player,"Capture",{Lost=lost,Kept=#s.Loot,Fraction=C.CaptureFraction,Died=dying==true})
end
function G:Prestige(player: Player, token: string)
 local p=self.Data:Get(player); local s=self.State[player]; local root=self:Root(player)
 if not p or not s or not root or s.Vault or not s.Prestige or s.Prestige.Token~=token or s.Prestige.Ends<os.clock() then return end
 s.Prestige=nil
 if not self.World:InsideSafe(root.Position) then self:Notify(player,"New Identity is available inside a hideout."); return end
 if p.Cash<C.Prestige.Cash or p.Reputation<C.Prestige.Reputation or not p.Districts["5"] or p.Starter<=#C.StarterMissions then self:Notify(player,"Finish all starter jobs, unlock all districts, and reach $100,000 / 1,000 REP."); return end
 self:CancelInteraction(player)
 p.Cash=0; p.Reputation=0; p.Processing={PendingValue=0,PendingCards=0,PendingClean=0,Stage="Idle",Value=0,Cards=0,Clean=0,Ends=0,Started=0,Duration=0}; p.Van.Stash={}; p.Districts={["1"]=true}
 for name in p.Upgrades do p.Upgrades[name]=0 end
 p.Starter=1; p.StarterProgress=0
 p.Identities+=1; p.Badges["Identity "..p.Identities]=true
 s.Loot={}; s.Combo=0; s.GadgetCharges=0; s.CaughtTrip=false; s.Heat=0; s.Chase=false; s.Immunity=os.clock()+10
 self:Unseat(player); root.CFrame=self.World.Checkpoints[1]; s.LastPosition=root.Position
 self:ApplyMovement(player)
 self:Notify(player,"NEW IDENTITY · Badge earned. Permanent bank bonus now "..math.floor((R.identityBonus(p.Identities,C)-1)*100+0.5).."%.","Success")
end
function G:Snapshot(player: Player)
 local p=self.Data:Get(player); local s=self.State[player]; if not p or not s or player.Parent==nil then return end
 self.Missions.rotate(p); self.Processing:Refresh(p)
 self.Remote:FireClient(player,"State",{Profile=p,Loot=s.Loot,Value=self.Inventory.value(p,s.Loot),Heat=s.Heat,Chase=s.Chase,Weather=self.Environment.State,Clock=self.Environment.Clock,Immunity=math.max(0,s.Immunity-os.clock()),Development=self.Data.IsDevelopment,Combo=s.Combo or 0,Gadget={Charges=s.GadgetCharges or 0,Max=R.charges(p,C),Cooldown=math.max(0,(s.GadgetReady or 0)-os.clock())},Navigation=self.Navigation:Resolve(player),Vault=if s.Vault then {Remaining=math.max(0,s.Vault.Ends-os.clock()),Collected=s.Vault.Collected,Stage=s.Vault.Stage} else nil})
end
function G:Request(player: Player, action: any, arg: any)
 local s=self.State[player]; if not s then return end
 local now=os.clock(); s.Tokens=math.min(16,s.Tokens+(now-s.TokenTime)*6); s.TokenTime=now
 if s.Tokens<1 then return end
 s.Tokens-=1
 if type(action)~="string" or not self.Data:Get(player) then return end
 if action=="Ready" then if not s.MapSent then self.Remote:FireClient(player,"Map",self.World.Map);s.MapSent=true end;self:Snapshot(player)
 elseif action=="Navigate" then self.Navigation:Pin(player,arg)
 elseif action=="Talk" and type(arg)=="string" and #arg<24 then self:Talk(player,arg)
 elseif action=="Scout" and type(arg)=="string" and #arg<32 then self.Interaction:Scout(player,arg)
 elseif action=="Begin" and type(arg)=="string" and #arg<32 then self:Begin(player,arg)
 elseif action=="Begin" and type(arg)=="table" and type(arg.Id)=="string" and #arg.Id<32 and type(arg.Approach)=="string" and #arg.Approach<16 then self:Begin(player,arg.Id,arg.Approach)
 elseif action=="CosmeticBuy" and type(arg)=="string" and #arg<32 then self.Cosmetics:Act(player,"Buy",arg)
 elseif action=="CosmeticEquip" and type(arg)=="string" and #arg<32 then self.Cosmetics:Act(player,"Equip",arg)
 elseif action=="CosmeticRemove" and type(arg)=="string" and #arg<16 then self.Cosmetics:Act(player,"Unequip",arg)
 elseif action=="Process" and type(arg)=="string" and #arg<16 then self.Processing:Act(player,arg)
 elseif action=="Van" and type(arg)=="string" and #arg<16 then self.Vehicles:Act(player,arg)
 elseif action=="QuestAccept" and type(arg)=="string" and #arg<32 then self:Quest(player,"Accept",arg)
 elseif action=="QuestClaim" and type(arg)=="string" and #arg<32 then self:Quest(player,"Claim",arg)
 elseif action=="QuestPause" then self.Data:Get(player).Contracts.Active=""
 elseif action=="Practice" and (arg==nil or arg=="Practice" or arg=="DailyDrill") then self.Interaction:Practice(player,arg)
 elseif action=="RoundChoice" then self.Interaction:Choice(player,arg)
 elseif action=="RoundTool" and type(arg)=="string" and #arg<64 then self.Interaction:Tool(player,arg)
 elseif action=="Resupply" then self:Resupply(player)
 elseif action=="Decoy" then self:Decoy(player)
 elseif action=="HideoutBuy" and type(arg)=="string" and #arg<24 then self:HideoutBuy(player,arg)
 elseif action=="Travel" and type(arg)=="number" and arg==arg then self:Travel(player,arg)
 elseif action=="Secret" and type(arg)=="string" and #arg<24 then self:Secret(player,arg)
 elseif action=="Stop" and type(arg)=="table" and type(arg.Token)=="string" and #arg.Token<64 then self:Resolve(player,arg)
 elseif action=="Cancel" then self:CancelInteraction(player,true)
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
  elseif (arg.Key=="ReducedMotion" or arg.Key=="Shake" or arg.Key=="WeatherEffects" or arg.Key=="MinimapRotate" or arg.Key=="VehicleCamera") and type(arg.Value)=="boolean" then p.Settings[arg.Key]=arg.Value
  elseif arg.Key=="MinimapZoom" and type(arg.Value)=="number" and arg.Value%1==0 and arg.Value>=1 and arg.Value<=3 then p.Settings.MinimapZoom=arg.Value end
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
 for _,part in character:GetDescendants() do if part:IsA("BasePart") then part.CollisionGroup="CityPlayers" end end
 root.CFrame=self.World.Checkpoints[1]; s.LastPosition=root.Position; s.Immunity=os.clock()+C.CaptureImmunity
 s.Heat=math.min(s.Heat,20); s.Chase=false
 self:ApplyMovement(player); self.Cosmetics:Apply(player)
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
 self.State[player]={Loot={},Combo=0,GadgetCharges=0,GadgetReady=0,DecoyUntil=0,Heat=0,LastTrouble=0,Immunity=os.clock()+10,Chase=false,VaultCooldown=0,Tokens=16,TokenTime=os.clock(),Suspicion={},Connections={}}
 local s=self.State[player]
 table.insert(s.Connections,player.CharacterAdded:Connect(function(char) self:Character(player,char) end))
 table.insert(s.Connections,player.CharacterAppearanceLoaded:Connect(function() self.Cosmetics:Apply(player) end))
 if not self.Data:Load(player) then self.State[player]=nil; for _,connection in s.Connections do connection:Disconnect() end; return end
 if player.Character then task.spawn(function() self:Character(player,player.Character) end) end
 self:Snapshot(player)
end
function G:Remove(player: Player)
 self.Vehicles:Clear(player)
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
  if p then self.Processing:Refresh(p) end
  if not p or not root then continue end
  if s.Attempt then self.Interaction:Tick(player) end
  self.Navigation:Discover(player,now)
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
   if safe then s.Heat=math.max(0,s.Heat-(C.Heat.SafeDecay+p.Hideout.Lounge*C.Hideout.SafeRecovery)*dt)
   elseif now-s.LastTrouble>C.Heat.QuietSeconds then
    local seen=false
    for _,guard in self.NPC.Guards do if guard.Target==player and now-guard.LastSeen<1 then seen=true; break end end
    if not seen then s.Heat=math.max(0,s.Heat-C.Heat.Decay*dt) end
   end
   for id,target in self.NPC.Targets do
    local nearby=(target.Model.PrimaryPart.Position-root.Position).Magnitude<C.Suspicion.Distance and not safe and not (s.Attempt and s.Attempt.Target==id)
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
 self.World:Build(); self.NPC:Prepare(); self.NPC:Build(self.World); self.Security:Init(self); self.Vault:Init(self); self.Interaction:Init(self); self.Processing:Init(self); self.Cosmetics:Init(self);self.Navigation:Init(self);self.NPC.Game=self
 local network=Instance.new("Folder"); network.Name="Network"; network.Parent=ReplicatedStorage
 local remote=Instance.new("RemoteEvent"); remote.Name="Game"; remote.Parent=network; self.Remote=remote
 self.Vehicles:Init(self,network); self.Environment:Start(); self.Traffic:Start(self)
 remote.OnServerEvent:Connect(function(player,action,arg)
  local ok,err=pcall(function() self:Request(player,action,arg) end)
  if not ok then warn("Request failed: ",action,err) end
 end)
 Players.PlayerAdded:Connect(function(player) self:Add(player) end)
 Players.PlayerRemoving:Connect(function(player) self:Remove(player) end)
 for _,player in Players:GetPlayers() do task.spawn(function() self:Add(player) end) end
 self.Data:Start()
 task.spawn(function()
  local previous=os.clock(); local snapshots=0; local gameplayDt=0
  while true do
   task.wait(0.1)
   local now=os.clock(); local dt=math.min(0.5,now-previous); previous=now
   gameplayDt+=dt
   if gameplayDt>=0.25 then self:Tick(now,gameplayDt); gameplayDt=0 end
   self.Vehicles:Tick(now,dt); self.Traffic:Tick(now,dt); snapshots+=1
   if snapshots%10==0 then self.Environment:Tick() end
   if snapshots%5==0 then for player in self.State do self:Snapshot(player) end end
  end
 end)
 print("Card City ready. Studio test data:",self.Data.IsDevelopment)
end
return G
