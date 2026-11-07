--!strict
local Players=game:GetService("Players")
local Shared=game:GetService("ReplicatedStorage").Shared
local C=require(Shared.Config)
local R=require(Shared.Rules)
local Driving=require(Shared.VehicleRules)
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
  for _,connection in v.Connections or {} do connection:Disconnect() end
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
  local district=G.World:DistrictAt(root.Position) or 1
  local cf=self:SpawnPoint(district,previous and previous.Model)
  if not cf then G:Notify(player,"The garage bay is occupied. Move the other vehicle and try again.");return end
  self:Clear(player)
  local m=F.vehicle(self.Folder,cf,true,Color3.fromRGB(87,112,110),true); m.Name="Van_"..player.UserId; m:SetAttribute("OwnerId",player.UserId)
  local chassis=m.PrimaryPart; chassis:SetNetworkOwner(nil)
  local attachment=Instance.new("Attachment"); attachment.Parent=chassis
  local stabilizer=Instance.new("AlignOrientation"); stabilizer.Mode=Enum.OrientationAlignmentMode.OneAttachment; stabilizer.Attachment0=attachment; stabilizer.MaxTorque=45000; stabilizer.Responsiveness=8; stabilizer.CFrame=cf.Rotation; stabilizer.Parent=chassis
  local prompt=Instance.new("ProximityPrompt"); prompt.ActionText="Open van storage"; prompt.ObjectText=player.DisplayName.."'s van"; prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.Exclusivity=Enum.ProximityPromptExclusivity.OnePerButton; prompt:SetAttribute("Action","Van"); prompt:SetAttribute("OwnerId",player.UserId); prompt.Parent=m.StashHandle
  local enter=Instance.new("ProximityPrompt"); enter.ActionText="Drive your van"; enter.ObjectText="Courier Van"; enter.MaxActivationDistance=10;enter.RequiresLineOfSight=false;enter.GamepadKeyCode=Enum.KeyCode.ButtonX;enter.Exclusivity=Enum.ProximityPromptExclusivity.OnePerButton; enter:SetAttribute("Action","DriveVan"); enter:SetAttribute("OwnerId",player.UserId); enter.Parent=m.DriverSeat
  local _,yaw=cf:ToOrientation()
  self.Vehicles[player]={Model=m,Seat=m.DriverSeat,Stabilizer=stabilizer,Yaw=yaw,Throttle=0,Steer=0,Speed=0,InputAt=0,LastPosition=chassis.Position,Distance=0,LastDriven=os.clock(),RecoverAt=0,SmoothSteer=0,Connections={}}
  local vehicle=self.Vehicles[player]
  table.insert(vehicle.Connections,vehicle.Seat:GetPropertyChangedSignal("Occupant"):Connect(function()
   local occupant=vehicle.Seat.Occupant
   if occupant and (not player.Character or occupant.Parent~=player.Character) then occupant.Sit=false end
   vehicle.Throttle=0;vehicle.Steer=0;vehicle.InputAt=0
  end))
  s.VanReady=os.clock()+C.Van.SummonCooldown
  G:Notify(player,"VAN READY · Sit in the driver's seat. Store cards at the rear. WASD / thumbstick to drive.","Success")
 elseif action=="Enter" then
  local v=self.Vehicles[player]
  if v and (root.Position-v.Seat.Position).Magnitude<13 and not v.Seat.Occupant then
   local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
   if hum then v.Seat:Sit(hum) end
  end
 elseif action=="Recover" then
  local v=self.Vehicles[player]
  if not v or (root.Position-v.Model.PrimaryPart.Position).Magnitude>25 or os.clock()<(v.RecoverAt or 0) then return end
  if math.abs(v.Speed)>1.5 and v.Model.PrimaryPart.CFrame.UpVector.Y>.45 then G:Notify(player,"Stop before recovering your van.");return end
  local district=G.World:DistrictAt(v.Model.PrimaryPart.Position) or 1
  local cf=self:SpawnPoint(district,v.Model)
  if not cf then G:Notify(player,"Garage recovery bays are occupied.");return end
  G:Unseat(player);self:Reset(v,cf);v.RecoverAt=os.clock()+20;v.LastDriven=os.clock()
  G:Notify(player,"Van recovered to a clear garage bay. Your stored cards are safe.","Success")
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
function V:SpawnPoint(district: number,exclude: Model?): CFrame?
 local G=self.Game;local base=G.World.VanSpawns[district];if not base then return nil end
 local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
 local filter: {Instance}={}
 if exclude then table.insert(filter,exclude) end
 if G.NPC.Folder then table.insert(filter,G.NPC.Folder) end
 for _,player in Players:GetPlayers() do if player.Character then table.insert(filter,player.Character) end end
 params.FilterDescendantsInstances=filter;params.RespectCanCollide=true
 for _,offset in {0,20,-20} do
  local cf=base*CFrame.new(0,0,offset);local blocked=false
  for _,part in workspace:GetPartBoundsInBox(cf*CFrame.new(0,2.5,0),Vector3.new(7,6,14.5),params) do if part.CanCollide then blocked=true;break end end
  if not blocked then return cf end
 end
 return nil
end
function V:Reset(v: any,cf: CFrame)
 v.Model:PivotTo(cf);local chassis=v.Model.PrimaryPart;chassis.AssemblyLinearVelocity=Vector3.zero;chassis.AssemblyAngularVelocity=Vector3.zero
 local _,yaw=cf:ToOrientation();v.Yaw=yaw;v.Speed=0;v.Throttle=0;v.Steer=0;v.SmoothSteer=0;v.LastPosition=chassis.Position;v.InputAt=0;v.Stabilizer.CFrame=cf.Rotation
end
function V:Tick(now: number,dt: number)
 local G=self.Game
 for player,v in self.Vehicles do
  local p=G.Data:Get(player);local chassis=v.Model.PrimaryPart
  if not p or not chassis or not v.Model.Parent then self:Clear(player);continue end
  local occupant=v.Seat.Occupant
  if occupant and (not player.Character or occupant.Parent~=player.Character or occupant.Health<=0) then occupant.Sit=false;occupant=nil end
  if occupant then v.LastDriven=now elseif now-v.LastDriven>C.Van.AbandonSeconds then self:Clear(player);continue end
  local district=G.World:DistrictAt(chassis.Position)
  if chassis.Position.Y < -8 or not district or not p.Districts[tostring(district)] then
   if occupant then G:Unseat(player) end
   local cf=self:SpawnPoint(1,v.Model)
   if cf then self:Reset(v,cf) else self:Clear(player) end
   continue
  end
  local active=occupant~=nil and now-v.InputAt<C.Van.InputTimeout and not G.State[player].Attempt and not G.State[player].Vault
  local throttle=if active then v.Throttle else 0;local steer=if active then v.Steer else 0
  if chassis.CFrame.UpVector.Y<.25 then throttle=0;steer=0 end
  v.SmoothSteer+=(steer-v.SmoothSteer)*math.min(1,dt*6)
  local cap=(C.Van.Speed+p.Upgrades.Engine*C.Van.SpeedPerLevel)*C.Weather.Profiles[G.Environment.State].Drive
  local speed,yawRate,wheelAngle=Driving.step(v.Speed,throttle,v.SmoothSteer,cap,dt,C)
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
  local filter: {Instance}={v.Model,G.NPC.Folder}
  for _,other in Players:GetPlayers() do if other.Character then table.insert(filter,other.Character) end end
  params.FilterDescendantsInstances=filter;params.RespectCanCollide=true
  local direction=chassis.CFrame.LookVector*(if speed<0 then -1 else 1)
  local blocked=false
  for _,side in {-2.5,0,2.5} do
   local origin=(chassis.CFrame*CFrame.new(side,0,if speed<0 then 5.8 else -5.8)).Position
   local hit=workspace:Raycast(origin,direction*(math.abs(speed)*dt+1),params)
   if hit and hit.Normal.Y<.55 then blocked=true;break end
  end
  if blocked then speed=0;yawRate=0 end
  local up=Vector3.zero;local grounded=0
  for _,side in {-1,1} do for _,end_ in {-1,1} do
   local point=(chassis.CFrame*CFrame.new(side*2.6,1,end_*4.3)).Position
   local hit=workspace:Raycast(point,Vector3.new(0,-5.4,0),params)
   local suffix=(if end_<0 then "F" else "R")..(if side<0 then "L" else "R")
   local compression=0
   if hit then up+=hit.Normal;grounded+=1;compression=math.clamp((3.3-hit.Distance)/1.2,-.3,.4) end
   v.Model:SetAttribute("WheelTravel"..suffix,compression)
  end end
  if grounded==0 then speed=v.Speed*.98;yawRate=0 else v.Yaw-=yawRate*dt end
  v.Speed=speed
  local normal=if grounded>0 and up.Magnitude>0 and up.Unit.Y>.7 then up.Unit else Vector3.new(0,1,0)
  local forward=CFrame.Angles(0,v.Yaw,0).LookVector
  local planar=forward-normal*forward:Dot(normal)
  if planar.Magnitude>.1 then v.Stabilizer.CFrame=CFrame.lookAt(Vector3.zero,planar.Unit,normal) end
  local velocity=forward*speed
  if grounded>0 then chassis.AssemblyLinearVelocity=Vector3.new(velocity.X,math.clamp(chassis.AssemblyLinearVelocity.Y,-65,12),velocity.Z) end
  chassis.AssemblyAngularVelocity=Vector3.new(0,-yawRate,0)
  local delta=chassis.Position-v.LastPosition;local distance=Vector3.new(delta.X,0,delta.Z).Magnitude;v.LastPosition=chassis.Position
  if occupant and grounded>0 and active and not blocked and distance<cap*dt*2+1 and math.abs(speed)>1 then
   v.Distance+=distance;local whole=math.floor(v.Distance)
   if whole>0 then v.Distance-=whole;G:Event(player,"drive",whole) end
  end
  v.Model:SetAttribute("Braking",blocked or (math.abs(v.Speed)>.2 and (throttle==0 or throttle*v.Speed<0)))
  v.Model:SetAttribute("Reversing",speed<-.1);v.Model:SetAttribute("Speed",speed);v.Model:SetAttribute("Steer",wheelAngle/.3);v.Model:SetAttribute("Grounded",grounded>0);v.Model:SetAttribute("Overturned",chassis.CFrame.UpVector.Y<.45)
 end
end
return V
