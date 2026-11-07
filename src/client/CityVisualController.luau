--!strict
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local H: any={Objects={},Machines={},WeatherParts={},Settings={ReducedMotion=false,WeatherEffects=true}}
function H:Init()
 task.spawn(function()
  while true do task.wait(0.6); self:Refresh() end
 end)
 RunService.RenderStepped:Connect(function(dt) self:Draw(math.min(0.1,dt)) end)
end
function H:Refresh()
 local city=workspace:FindFirstChild("CardCity"); if not city then return end
 local candidates={}
 for _,name in {"Actors","Traffic"} do local folder=city:FindFirstChild(name); if folder then for _,m in folder:GetChildren() do if m:IsA("Model") and m.PrimaryPart then candidates[m]=true end end end end
 local vans=workspace:FindFirstChild("CourierVans"); if vans then for _,van in vans:GetChildren() do if van:IsA("Model") and van.PrimaryPart then candidates[van]=true end end end
 for m in candidates do
  if not self.Objects[m] then
   local record={CF=m.PrimaryPart.CFrame,Wheels={},Joints={},Parts={},Lights={},Brakes={},Reverse={},Spin=0}
   for _,child in m:GetDescendants() do
    if child:IsA("BasePart") and (child:GetAttribute("WheelOffset") or child:GetAttribute("WheelPivot")) then table.insert(record.Wheels,child) end
    if child:IsA("SpotLight") and child.Name=="VehicleBeam" then table.insert(record.Lights,child) end
    if child:IsA("BasePart") and child.Name=="BrakeLight" then table.insert(record.Brakes,child) end
    if child:IsA("BasePart") and child.Name=="ReverseLight" then table.insert(record.Reverse,child) end
    if child:IsA("Motor6D") and (child.Name=="LeftShoulder" or child.Name=="RightShoulder" or child.Name=="LeftHip" or child.Name=="RightHip") then table.insert(record.Joints,{Motor=child,Base=child.C0,Sign=if string.find(child.Name,"Left") then 1 else -1}) end
   end
   self.Objects[m]=record
  end
 end
 for m in self.Objects do if not candidates[m] or not m.Parent then self.Objects[m]=nil end end
 self.Vegetation={}
 local greenery=city:FindFirstChild("Vegetation"); if greenery then for _,tree in greenery:GetChildren() do if tree:IsA("Model") and tree:GetAttribute("VegetationPivot") then table.insert(self.Vegetation,tree) end end end
 self.Machines={}
 for _,room in city:GetChildren() do
  if string.sub(room.Name,1,8)=="Backroom" then
   for _,machine in room:GetChildren() do
    if machine:IsA("Model") and (machine.Name=="IMAGINARY INK PRESS" or machine.Name=="CARTOON TOKEN RINSE") then
     local spindle=machine:FindFirstChild("Drum spindle"); local led=machine:FindFirstChild("Status LED")
     if spindle then table.insert(self.Machines,{Model=machine,Spindle=spindle,Base=spindle.CFrame,LED=led}) end
    end
   end
  end
 end
 local cam=workspace.CurrentCamera; if not cam then return end
 local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances=if Players.LocalPlayer.Character then {Players.LocalPlayer.Character} else {}
 self.UnderRoof=workspace:Raycast(cam.CFrame.Position,Vector3.new(0,50,0),params)~=nil
end
function H:Draw(dt: number)
 local cam=workspace.CurrentCamera; if not cam then return end
 if self.LastCamera~=cam then for _,r in self.WeatherParts do r.Part:Destroy() end; self.WeatherParts={}; self.LastCamera=cam end
 local now=os.clock()
 for model,data in self.Objects do
  local root=model.PrimaryPart
  if not root or not model.Parent or (root.Position-cam.CFrame.Position).Magnitude>210 then continue end
  local goal=model:GetAttribute("MotionTarget")
  if goal then data.CF=data.CF:Lerp(goal,math.min(1,dt*12)); model:PivotTo(data.CF) end
  local speed=model:GetAttribute("Speed") or model:GetAttribute("WalkSpeed") or 0
  data.Spin-=speed*dt/1.175
  local steer=model:GetAttribute("Steer") or 0
  for _,wheel in data.Wheels do
   local rotate=CFrame.Angles(0,if wheel:GetAttribute("Front") then steer*0.3 else 0,0)*CFrame.Angles(data.Spin,0,0)
   local motor=wheel:FindFirstChild("WheelMotor")
   if motor and motor:IsA("Motor6D") then
    local pivot=wheel:GetAttribute("WheelOffset") or wheel:GetAttribute("WheelPivot")
    local suffix=(if wheel:GetAttribute("Front") then "F" else "R")..(if pivot.Position.X<0 then "L" else "R")
    motor.Transform=CFrame.new(0,(model:GetAttribute("WheelTravel"..suffix) or 0)*.2,0)*rotate
   else
    local pivot=wheel:GetAttribute("WheelOffset") or wheel:GetAttribute("WheelPivot")
    wheel.CFrame=root.CFrame*pivot*rotate*(wheel:GetAttribute("SpokeLocal") or CFrame.new())
   end
  end
  local clock=workspace:GetAttribute("CityClock") or 16
  for _,light in data.Lights do light.Enabled=clock>=18 or clock<6 or workspace:GetAttribute("Weather")=="Rain" end
  for _,brake in data.Brakes do brake.Color=if model:GetAttribute("Braking") then Color3.fromRGB(252,96,83) else Color3.fromRGB(120,48,43) end
  for _,reverse in data.Reverse do reverse.Color=if model:GetAttribute("Reversing") then Color3.fromRGB(235,232,214) else Color3.fromRGB(80,84,85) end
  local activity=model:GetAttribute("Activity")
  local isPhone=activity=="Phone break"
  for _,name in {"CitizenPhone","PhoneScreen"} do local phone=model:FindFirstChild(name); if phone and phone:IsA("BasePart") then phone.LocalTransparencyModifier=if isPhone then 0 else 1 end end
  local outdoors=not (root.Position.Z < -31 and root.Position.Z > -63)
  for _,name in {"Umbrella canopy","Umbrella shaft"} do local part=model:FindFirstChild(name); if part and part:IsA("BasePart") then part.LocalTransparencyModifier=if outdoors and workspace:GetAttribute("Weather")=="Rain" then 0 else 1 end end
  local walking=model:GetAttribute("WalkSpeed") or 0
  local swing=if walking>0 then math.sin(now*7)*0.45 else math.sin(now*1.6)*0.025
  for _,joint in data.Joints do if joint.Motor.Parent then joint.Motor.C0=joint.Base*(if isPhone and joint.Motor.Name=="RightShoulder" then CFrame.Angles(-1.05,0,0.15) else CFrame.Angles(swing*joint.Sign,0,0)) end end
  if not model:GetAttribute("R15Citizen") and not model:GetAttribute("Vehicle") then
   for _,side in {-1,1} do
    local arm=model:FindFirstChild(if side<0 then "Left arm" else "Right arm"); local shoe=model:FindFirstChild(if side<0 then "Left shoe" else "Right shoe")
    if arm and arm:IsA("BasePart") then arm.CFrame=root.CFrame*CFrame.new(side*1.4,0,0)*CFrame.Angles(-side*swing,0,0) end
    if shoe and shoe:IsA("BasePart") then shoe.CFrame=root.CFrame*CFrame.new(side*0.55,-1.9,0)*CFrame.Angles(side*swing,0,0) end
   end
  end
 end
 for _,machine in self.Machines do
  if machine.Model.Parent and (machine.Spindle.Position-cam.CFrame.Position).Magnitude<100 then
   local active=(machine.Model.Name=="IMAGINARY INK PRESS" and self.ProcessStage=="Pressing") or (machine.Model.Name=="CARTOON TOKEN RINSE" and self.ProcessStage=="Rinsing")
   if active then machine.Spindle.CFrame=machine.Base*CFrame.Angles(0,0,now*3) end
   if machine.LED then machine.LED.Color=if active then Color3.fromRGB(124,224,196) else Color3.fromRGB(75,97,91) end
  end
 end
 local intensity=workspace:GetAttribute("RainIntensity") or 0
 for _,tree in self.Vegetation or {} do
  local pivot=tree:GetAttribute("VegetationPivot")
  if tree.Parent and (pivot.Position-cam.CFrame.Position).Magnitude<180 and not self.Settings.ReducedMotion then tree:PivotTo(pivot*CFrame.Angles(0,0,math.sin(now*0.8+pivot.Position.X)*0.006*(1+intensity))) end
 end
 local rain=intensity>0.08 and self.Settings.WeatherEffects and not self.Settings.ReducedMotion and not self.UnderRoof
 if rain and #self.WeatherParts==0 then
  for _=1,40 do
   local p=Instance.new("Part"); p.Name="LocalRain"; p.Size=Vector3.new(0.035,1.6,0.035); p.Color=Color3.fromRGB(178,196,211); p.Material=Enum.Material.Glass; p.Transparency=0.55; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Parent=cam
   table.insert(self.WeatherParts,{Part=p,Offset=Vector3.new(math.random(-28,28),math.random(-10,24),math.random(-28,28))})
  end
 elseif not rain and #self.WeatherParts>0 then for _,r in self.WeatherParts do r.Part:Destroy() end; self.WeatherParts={} end
 if rain then for _,r in self.WeatherParts do
  local offset=r.Offset-Vector3.new(-2,35,0)*dt
  if offset.Y < -12 then offset=Vector3.new(math.random(-28,28),24,math.random(-28,28)) end
  r.Offset=offset; r.Part.Transparency=1-intensity*0.45; r.Part.CFrame=CFrame.new(cam.CFrame.Position+offset)*CFrame.Angles(0,0,-0.08)
 end end
end
return H
