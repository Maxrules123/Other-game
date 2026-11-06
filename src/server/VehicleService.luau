--!strict
local Players=game:GetService("Players")
local Shared=game:GetService("ReplicatedStorage").Shared
local C=require(Shared.Config)
local R=require(Shared.Rules)
local F=require(script.Parent.ModelFactory)
local V: any={Vehicles={}}
function V:Init(gameService: any,network: Instance)
 self.Game=gameService
 local folder=Instance.new("Folder"); folder.Name="CourierVans"; folder.Parent=workspace; self.Folder=folder
 local physics=game:GetService("PhysicsService")
 pcall(function() physics:RegisterCollisionGroup("CityVehicles") end); pcall(function() physics:RegisterCollisionGroup("CityPlayers") end)
 physics:CollisionGroupSetCollidable("CityVehicles","CityPlayers",false)
 local controls=Instance.new("RemoteEvent"); controls.Name="VanControl"; controls.Parent=network
 controls.OnServerEvent:Connect(function(player,throttle,steer)
  local v=self.Vehicles[player]
  if not v or type(throttle)~="number" or type(steer)~="number" or throttle~=throttle or steer~=steer or math.abs(throttle)>1 or math.abs(steer)>1 then return end
  if not self.Game.Data:Get(player) or not player.Character or v.Seat.Occupant~=player.Character:FindFirstChildOfClass("Humanoid") or os.clock()-(v.InputAt or 0)<0.075 then return end
  v.Throttle=throttle; v.Steer=steer; v.InputAt=os.clock()
 end)
end
function V:Capacity(profile: any): number return C.Van.BaseSlots+profile.Upgrades.VanSlots*C.Van.SlotsPerLevel end
function V:Near(player: Player): boolean
 local v=self.Vehicles[player]; local root=self.Game:Root(player)
 return v~=nil and root~=nil and (root.Position-v.Model.StashHandle.Position).Magnitude<13
end
function V:Clear(player: Player)
 local v=self.Vehicles[player]
 if v then
  if v.Seat.Occupant then v.Seat.Occupant.Sit=false end
  v.Model:Destroy(); self.Vehicles[player]=nil
 end
end
function V:Act(player: Player,action: string)
 local G=self.Game; local p=G.Data:Get(player); local s=G.State[player]; local root=G:Root(player)
 if not p or not s or not root or s.Vault or s.Attempt then return end
 if action=="Purchase" then
  if not G:NearStation(player,"Garage") or p.Van.Owned then return end
  if p.Cash<C.Van.Price or p.Reputation<C.Van.Reputation then G:Notify(player,"Van requires $"..C.Van.Price.." and "..C.Van.Reputation.." REP."); return end
  p.Cash-=C.Van.Price; p.Van.Owned=true; G:Event(player,"van",1); G:Notify(player,"VAN OWNED · Summon it at an alley garage. Ownership survives New Identity.","Success")
 elseif action=="Summon" then
  if not p.Van.Owned or not G:NearStation(player,"Garage") then G:Notify(player,"Use an alley garage after buying the van."); return end
  if (s.VanReady or 0)>os.clock() then G:Notify(player,"Garage is cooling down."); return end
  local previous=self.Vehicles[player]
  if previous and previous.Seat.Occupant then G:Notify(player,"Exit the van before summoning it again."); return end
  self:Clear(player)
  local district=G.World:DistrictAt(root.Position) or 1
  local cf=G.World.VanSpawns[district]
  local m=F.vehicle(self.Folder,cf,true,Color3.fromRGB(87,112,110),true); m.Name="Van_"..player.UserId; m:SetAttribute("OwnerId",player.UserId)
  local chassis=m.PrimaryPart; chassis:SetNetworkOwner(nil)
  local attachment=Instance.new("Attachment"); attachment.Parent=chassis
  local stabilizer=Instance.new("AlignOrientation"); stabilizer.Mode=Enum.OrientationAlignmentMode.OneAttachment; stabilizer.Attachment0=attachment; stabilizer.MaxTorque=1000000; stabilizer.Responsiveness=12; stabilizer.CFrame=cf.Rotation; stabilizer.Parent=chassis
  local prompt=Instance.new("ProximityPrompt"); prompt.ActionText="Open van storage"; prompt.ObjectText=player.DisplayName.."'s van"; prompt.MaxActivationDistance=12; prompt:SetAttribute("Action","Van"); prompt:SetAttribute("OwnerId",player.UserId); prompt.Parent=m.StashHandle
  local enter=Instance.new("ProximityPrompt"); enter.ActionText="Drive your van"; enter.ObjectText="Courier Van"; enter.MaxActivationDistance=10; enter:SetAttribute("Action","DriveVan"); enter:SetAttribute("OwnerId",player.UserId); enter.Parent=m.DriverSeat
  local _,yaw=cf:ToOrientation()
  self.Vehicles[player]={Model=m,Seat=m.DriverSeat,Stabilizer=stabilizer,Yaw=yaw,Throttle=0,Steer=0,Speed=0,InputAt=0,LastPosition=chassis.Position,Distance=0}
  s.VanReady=os.clock()+C.Van.SummonCooldown
  G:Notify(player,"VAN READY · Sit in the driver's seat. Store cards at the rear. WASD / thumbstick to drive.","Success")
 elseif action=="Enter" then
  local v=self.Vehicles[player]
  if v and (root.Position-v.Seat.Position).Magnitude<13 and not v.Seat.Occupant then
   local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
   if hum then v.Seat:Sit(hum) end
  end
 elseif action=="Store" then
  if not p.Van.Owned or not self:Near(player) then G:Notify(player,"Stand at the rear of your own van."); return end
  local count=#s.Loot
  if count==0 then return end
  if #p.Van.Stash+count>self:Capacity(p) then G:Notify(player,"Van storage full. Upgrade Van Slots or deposit a batch."); return end
  for _,loot in s.Loot do if s.CaughtTrip then loot.Clean=false end; table.insert(p.Van.Stash,loot) end
  s.Loot={}; s.CaughtTrip=false
  G:Notify(player,"STORED · "..count.." cards secured in the van. Storage is saved; Cash still needs processing.","Bank")
 elseif action=="Withdraw" then
  if not self:Near(player) then return end
  local room=R.capacity(p.Upgrades.Capacity,C)-#s.Loot; local count=math.min(room,#p.Van.Stash)
  for _=1,count do table.insert(s.Loot,table.remove(p.Van.Stash)) end
  G:Notify(player,"WITHDRAWN · "..count.." cards returned to unbanked pockets.","Click")
 elseif action=="Deposit" then
  -- Remote deposits are never allowed from the street; both van and intake must be nearby.
  if not self:Near(player) or not G:NearStation(player,"Bank") then G:Notify(player,"Park beside the hideout intake and stand between the van and terminal."); return end
  G.Processing:Deposit(player,true)
 elseif action=="Deliver" then
  local v=self.Vehicles[player]; local destination=G.World.DeliveryBay
  if v and (v.Model.PrimaryPart.Position-destination).Magnitude<22 and (root.Position-destination).Magnitude<20 then G:Event(player,"delivery",1); G:Notify(player,"COURIER DROP-OFF · Contract progress updated.","Success") end
 end
end
function V:Tick(now: number,dt: number)
 local G=self.Game
 for player,v in self.Vehicles do
  local p=G.Data:Get(player); local chassis=v.Model.PrimaryPart
  if not p or not chassis then continue end
  local occupant=v.Seat.Occupant
  if occupant and (not player.Character or occupant.Parent~=player.Character) then occupant.Sit=false; occupant=nil end
  local district=G.World:DistrictAt(chassis.Position)
  if chassis.Position.Y < -8 or not district or not p.Districts[tostring(district)] then
   if occupant then occupant.Sit=false end
   v.Model:PivotTo(G.World.VanSpawns[1]); chassis.AssemblyLinearVelocity=Vector3.zero; v.Speed=0; v.LastPosition=chassis.Position
   continue
  end
  local throttle=if occupant and now-v.InputAt<0.6 then v.Throttle else 0
  local steer=if occupant and now-v.InputAt<0.6 then v.Steer else 0
  local cap=(C.Van.Speed+p.Upgrades.Engine*C.Van.SpeedPerLevel)*C.Weather.Profiles[G.Environment.State].Drive
  v.Speed=R.speedTowards(v.Speed,throttle*cap,C.Van.Acceleration*(if throttle==0 then 1.8 else 1),dt)
  v.Yaw-=steer*C.Van.TurnRate*(v.Speed/math.max(1,cap))*dt
  v.Stabilizer.CFrame=CFrame.Angles(0,v.Yaw,0)
  local forward=CFrame.Angles(0,v.Yaw,0).LookVector
  local velocity=forward*v.Speed
  chassis.AssemblyLinearVelocity=Vector3.new(velocity.X,math.clamp(chassis.AssemblyLinearVelocity.Y,-70,15),velocity.Z)
  chassis.AssemblyAngularVelocity=Vector3.new(0,-steer*C.Van.TurnRate*(v.Speed/math.max(1,cap)),0)
  local distance=(chassis.Position-v.LastPosition).Magnitude; v.LastPosition=chassis.Position
  if occupant and distance<cap*dt*3+4 then
   v.Distance+=distance
   local whole=math.floor(v.Distance)
   if whole>0 then v.Distance-=whole; G:Event(player,"drive",whole) end
  end
  v.Model:SetAttribute("Braking",throttle==0 and math.abs(v.Speed)>0.2); v.Model:SetAttribute("Speed",v.Speed); v.Model:SetAttribute("Steer",steer)
 end
end
return V
