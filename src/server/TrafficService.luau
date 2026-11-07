--!strict
local C=require(game:GetService("ReplicatedStorage").Shared.Config)
local R=require(game:GetService("ReplicatedStorage").Shared.Rules)
local F=require(script.Parent.ModelFactory)
local Traffic: any={Cars={},Signals={}}
local function pathPoint(distance: number,nodes: {Vector3}): (Vector3,Vector3,number)
 local remaining=distance
 for i=1,#nodes do
  local a,b=nodes[i],nodes[i%#nodes+1]; local length=(b-a).Magnitude
  if remaining<=length then return a:Lerp(b,remaining/length),(b-a).Unit,i end
  remaining-=length
 end
 return nodes[1],(nodes[2]-nodes[1]).Unit,1
end
function Traffic:Start(gameService: any)
 self.Game=gameService
 local folder=Instance.new("Folder"); folder.Name="Traffic"; folder.Parent=gameService.World.Root; self.Folder=folder
 local left=-108; local right=4*C.City.DistrictSpacing+108
 -- Rounded rectangular circulation: main avenue, perimeter return lane, corner diagonals.
 self.Nodes={Vector3.new(left,2,-8),Vector3.new(right-18,2,-8),Vector3.new(right,2,-26),Vector3.new(right,2,-130),Vector3.new(right-18,2,-148),Vector3.new(left+18,2,-148),Vector3.new(left,2,-130),Vector3.new(left,2,-26)}
 self.Paths={self.Nodes,{}}
 for _,point in self.Nodes do table.insert(self.Paths[2],Vector3.new(left+right-point.X,point.Y,-point.Z)) end
 self.Length=0; for i=1,#self.Nodes do self.Length+=(self.Nodes[i%#self.Nodes+1]-self.Nodes[i]).Magnitude end
 for n=1,C.Traffic.Count do
  local distance=(n-1)*self.Length/C.Traffic.Count
  local lane=n%2+1
  local pos,dir=pathPoint(distance,self.Paths[lane])
  local color=({Color3.fromRGB(157,185,172),Color3.fromRGB(79,98,124),Color3.fromRGB(191,151,115),Color3.fromRGB(157,146,174)})[n%4+1]
  local car=F.vehicle(folder,CFrame.lookAt(pos,pos+dir),false,color)
  car:SetAttribute("AmbientTraffic",true)
  for _,part in car:GetDescendants() do if part:IsA("BasePart") then part.CanCollide=false; part.CanTouch=false; part.CanQuery=false end end
  table.insert(self.Cars,{Model=car,Distance=distance,Speed=0,Lane=lane})
 end
 self.Signals=gameService.World.TrafficSignals
end
function Traffic:Green(now: number): boolean return now%(C.Traffic.GreenSeconds+C.Traffic.CrossingSeconds)<C.Traffic.GreenSeconds end
function Traffic:Tick(now: number,dt: number)
 local green=self:Green(now)
 for _,signal in self.Signals do
  signal.Green.Transparency=if green then 0 else 0.85; signal.Red.Transparency=if green then 0.85 else 0
 end
 local weather=C.Weather.Profiles[self.Game.Environment.State]
 local pedestrians={}
 for player in self.Game.State do local root=self.Game:Root(player);if root then table.insert(pedestrians,root.Position) end end
 if self.Game.NPC then for _,target in self.Game.NPC.Targets do local position=target.Model.PrimaryPart.Position;if math.abs(position.Z)<22 then table.insert(pedestrians,position) end end end
 for _,car in self.Cars do
  local root=car.Model.PrimaryPart; local pos,dir,segment=pathPoint(car.Distance,self.Paths[car.Lane])
  local desired=C.Traffic.Speed*weather.Drive
  if segment~=1 and segment~=5 then desired*=0.55 end -- Turns slow before heading changes.
  if segment==1 then
   for _,center in self.Game.World.Centers do
    local ahead=(center.X-pos.X)*dir.X
    if green then car.Committed={} end
    car.Committed=car.Committed or {}
    if not green and ahead>0 and ahead<55 then
     if car.LastGreen and ahead<car.Speed*car.Speed/(2*C.Traffic.Braking)+18 then car.Committed[center.X]=true end
     if not car.Committed[center.X] then desired=math.min(desired,math.max(0,(ahead-17)*1.2)) end
    end
   end
  end
  for _,other in self.Cars do
   if other~=car and other.Lane==car.Lane then
    local gap=(other.Distance-car.Distance)%self.Length
    if gap<C.Traffic.Gap then desired=math.min(desired,math.max(0,(gap-15)*1.5)) end
   end
  end
  for _,position in pedestrians do
   local delta=position-pos;local along=delta:Dot(dir);local across=(delta-dir*along).Magnitude
   if along>0 and along<26 and across<6 then desired=math.min(desired,math.max(0,(along-10)*1.3)) end
  end
  car.Speed=R.speedTowards(car.Speed,desired,if desired<car.Speed then C.Traffic.Braking else C.Traffic.Acceleration,dt)
  car.Distance=(car.Distance+car.Speed*dt)%self.Length
  local nextPos,nextDir=pathPoint(car.Distance,self.Paths[car.Lane])
  local heading=root.CFrame.LookVector:Lerp(nextDir,math.min(1,dt*4)); if heading.Magnitude<0.1 then heading=nextDir end
  car.Model:PivotTo(CFrame.lookAt(nextPos,nextPos+heading))
  car.LastGreen=green
  car.Model:SetAttribute("MotionTarget",car.Model.PrimaryPart.CFrame); car.Model:SetAttribute("Speed",car.Speed); car.Model:SetAttribute("Braking",desired<car.Speed-0.5)
 end
end
return Traffic
