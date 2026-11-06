--!strict
-- Original reusable Roblox models. Published custom mesh templates can replace their visual skins.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local C=require(ReplicatedStorage.Shared.Config)
local F={}
local P=C.Palette
function F.part(parent: Instance,name: string,size: Vector3,cf: CFrame,color: Color3,material: Enum.Material?,shape: Enum.PartType?): Part
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.Shape=shape or Enum.PartType.Block; p.Anchored=true; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent; return p
end
function F.model(parent: Instance,name: string): Model
 local m=Instance.new("Model"); m.Name=name; m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic; m.Parent=parent; return m
end
function F.sign(parent: Instance,cf: CFrame,size: Vector3,value: string,color: Color3?): Part
 local p=F.part(parent,"Sign",size,cf,P.Panel,Enum.Material.Metal)
 local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Front; gui.PixelsPerStud=40; gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud; gui.Parent=p
 local text=Instance.new("TextLabel"); text.Size=UDim2.fromScale(0.94,0.86); text.Position=UDim2.fromScale(0.03,0.07); text.BackgroundTransparency=1; text.Text=value; text.TextColor3=color or P.White; text.Font=Enum.Font.GothamBold; text.TextScaled=true; text.TextWrapped=true; text.Parent=gui
 return p
end
function F.skin(model: Model,key: string,cf: CFrame): (boolean,Model?)
 local library=ReplicatedStorage:FindFirstChild("ArtAssets"); local template=library and library:FindFirstChild(C.AssetTemplates[key] or key)
 if not template or not template:IsA("Model") then return false,nil end
 local clone=template:Clone(); clone.Name="ImportedSkin"; clone:PivotTo(cf); clone.Parent=model
 for _,p in clone:GetDescendants() do
  if p:IsA("BaseScript") then p:Destroy()
  elseif p:IsA("BasePart") then p.Anchored=true; p.CanCollide=false; p.CanQuery=false end
 end
 if key~="VanBody" and key~="SedanBody" and key~="Wheel" then
  local box,size=clone:GetBoundingBox()
  if key=="Sofa" then box=cf*CFrame.new(0,1.2,0); size=Vector3.new(8.2,1,3.3)
  elseif key=="Chair" then box=cf*CFrame.new(0,1.4,0); size=Vector3.new(2.4,1,2.4)
  elseif key=="Tree" then box=cf*CFrame.new(0,4,0); size=Vector3.new(0.9,8,0.9)
  elseif key=="Streetlamp" then box=cf*CFrame.new(0,5.5,0); size=Vector3.new(0.4,11,0.4) end
  local collider=F.part(clone,"Imported collision",size,box,P.Panel); collider.Transparency=1
 end
 return true,clone
end
function F.sofa(parent: Instance,cf: CFrame,color: Color3): Model
 local m=F.model(parent,"Chester sofa")
 for n=-1,1 do local seat=Instance.new("Seat"); seat.Name="LoungeSeat"; seat.Size=Vector3.new(2.2,0.3,2.5); seat.CFrame=cf*CFrame.new(n*2.45,2.1,-0.2); seat.Transparency=1; seat.Anchored=true; seat.CanCollide=false; seat.Parent=m end
 if F.skin(m,"Sofa",cf) then return m end
 local function p(name: string,size: Vector3,off: CFrame,col: Color3,mat: Enum.Material?) return F.part(m,name,size,cf*off,col,mat or Enum.Material.Fabric) end
 p("Upholstered frame",Vector3.new(9,1,3.5),CFrame.new(0,1.2,0),P.Panel)
 for _,side in {-1,1} do
  p("Rounded padded arm",Vector3.new(1.1,2.2,3.7),CFrame.new(side*4.2,2.1,0),color)
  for _,z in {-1.3,1.3} do p("Tapered wooden leg",Vector3.new(0.45,1,0.45),CFrame.new(side*3.6,0.5,z),Color3.fromRGB(93,64,46),Enum.Material.Wood) end
 end
 for n=-1,1 do
  p("Seat cushion",Vector3.new(2.3,0.7,3),CFrame.new(n*2.45,1.95,-0.2),color)
  p("Back cushion",Vector3.new(2.35,2.2,0.7),CFrame.new(n*2.45,2.9,1.4)*CFrame.Angles(math.rad(-8),0,0),color)
  p("Cushion seam",Vector3.new(2.1,0.035,0.035),CFrame.new(n*2.45,3.65,0.98),color:Lerp(P.White,0.3))
 end
 p("Throw pillow",Vector3.new(1.5,1.5,0.45),CFrame.new(-2.8,2.7,0.65)*CFrame.Angles(0,0,0.2),P.Gold)
 return m
end
function F.chair(parent: Instance,cf: CFrame,color: Color3): Model
 local m=F.model(parent,"Cafe chair")
 local seat=Instance.new("Seat"); seat.Name="CafeSeat"; seat.Size=Vector3.new(2.2,0.3,2.2); seat.CFrame=cf*CFrame.new(0,2.25,0); seat.Transparency=1; seat.Anchored=true; seat.CanCollide=false; seat.Parent=m
 if F.skin(m,"Chair",cf) then return m end
 F.part(m,"Padded seat",Vector3.new(2.6,0.45,2.6),cf*CFrame.new(0,2,0),color,Enum.Material.Fabric)
 for _,x in {-1,1} do for _,z in {-1,1} do F.part(m,"Bent steel leg",Vector3.new(0.2,2.1,0.2),cf*CFrame.new(x,1,z)*CFrame.Angles(z*0.05,0,-x*0.05),P.Panel,Enum.Material.Metal) end end
 for _,x in {-1,1} do F.part(m,"Back support",Vector3.new(0.22,2,0.22),cf*CFrame.new(x,3,1.15),P.Panel,Enum.Material.Metal) end
 F.part(m,"Curved backrest",Vector3.new(2.5,1.2,0.4),cf*CFrame.new(0,3.65,1.15),color,Enum.Material.Wood)
 return m
end
function F.table(parent: Instance,cf: CFrame): Model
 local m=F.model(parent,"Reclaimed oak coffee table")
 F.part(m,"Oak top",Vector3.new(6,0.3,3.5),cf*CFrame.new(0,1.8,0),Color3.fromRGB(143,103,71),Enum.Material.WoodPlanks)
 for _,x in {-2.4,2.4} do for _,z in {-1.2,1.2} do F.part(m,"Steel hairpin leg",Vector3.new(0.16,1.7,0.16),cf*CFrame.new(x,0.85,z),P.Panel,Enum.Material.Metal) end end
 F.part(m,"Magazine",Vector3.new(1.7,0.08,1.1),cf*CFrame.new(-1,2,0)*CFrame.Angles(0,0.16,0),P.Purple)
 F.part(m,"Coffee mug",Vector3.new(0.45,0.6,0.45),cf*CFrame.new(1.5,2.2,0.3),P.Mint,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
 return m
end
function F.locker(parent: Instance,cf: CFrame,color: Color3): Model
 local m=F.model(parent,"Industrial storage lockers"); if F.skin(m,"Locker",cf) then return m end
 for n=-1,1 do
  F.part(m,"Locker body",Vector3.new(2.6,7,2.2),cf*CFrame.new(n*2.75,3.5,0),color,Enum.Material.Metal)
  F.part(m,"Locker door",Vector3.new(2.35,6.6,0.12),cf*CFrame.new(n*2.75,3.5,-1.16),color:Lerp(P.White,0.1),Enum.Material.Metal)
  F.part(m,"Chrome latch",Vector3.new(0.12,0.7,0.2),cf*CFrame.new(n*2.75+0.8,3.5,-1.3),P.Gold,Enum.Material.Metal)
  for y=5.4,6.2,0.25 do F.part(m,"Vent slot",Vector3.new(1.4,0.06,0.06),cf*CFrame.new(n*2.75,y,-1.24),P.Charcoal) end
 end
 return m
end
function F.machine(parent: Instance,cf: CFrame,name: string,color: Color3): Model
 local m=F.model(parent,name)
 local body=F.part(m,"Cabinet",Vector3.new(5,5.8,3),cf*CFrame.new(0,2.9,0),color,Enum.Material.Metal); m.PrimaryPart=body
 F.part(m,"Control fascia",Vector3.new(4.6,1.1,0.15),cf*CFrame.new(0,4.95,-1.6),P.Panel,Enum.Material.Metal)
 local drum=F.part(m,"Chrome circular drum",Vector3.new(0.35,3.4,3.4),cf*CFrame.new(0,2.7,-1.6)*CFrame.Angles(0,math.pi/2,0),P.Muted,Enum.Material.Metal,Enum.PartType.Cylinder)
 local glass=F.part(m,"Drum glass",Vector3.new(0.4,2.9,2.9),cf*CFrame.new(0,2.7,-1.8)*CFrame.Angles(0,math.pi/2,0),P.Mint,Enum.Material.Glass,Enum.PartType.Cylinder); glass.Transparency=0.45
 for n=-1,1 do F.part(m,"Selector knob",Vector3.new(0.2,0.45,0.45),cf*CFrame.new(n*1.6,4.95,-1.8)*CFrame.Angles(0,math.pi/2,0),P.White,Enum.Material.Metal,Enum.PartType.Cylinder) end
 F.part(m,"Drum spindle",Vector3.new(0.15,2.4,0.06),cf*CFrame.new(0,2.7,-1.84),P.Gold,Enum.Material.Metal).CanCollide=false
 F.part(m,"Status LED",Vector3.new(1.2,0.3,0.08),cf*CFrame.new(0,5,-1.74),P.Mint,Enum.Material.Neon)
 F.sign(m,cf*CFrame.new(0,6.3,-0.5),Vector3.new(5.5,0.7,0.1),name,P.Mint)
 return m
end
function F.vehicle(parent: Instance,cf: CFrame,isVan: boolean,color: Color3,dynamic: boolean?): Model
 local m=F.model(parent,if isVan then "Courier Van" else "City Sedan"); m:SetAttribute("Vehicle",true)
 local root=F.part(m,"Chassis",Vector3.new(6,0.8,if isVan then 13 else 11),cf,color,Enum.Material.Metal); root.Transparency=1; m.PrimaryPart=root
 local function p(name: string,size: Vector3,off: CFrame,col: Color3,mat: Enum.Material?,shape: Enum.PartType?): Part return F.part(m,name,size,cf*off,col,mat,shape) end
 local imported=F.skin(m,if isVan then "VanBody" else "SedanBody",cf)
 if not imported then
  p("Lower body sill",Vector3.new(6.1,1.5,if isVan then 12.5 else 10.8),CFrame.new(0,-0.1,0),color,Enum.Material.Metal)
  p("Hood",Vector3.new(5.8,0.5,3.1),CFrame.new(0,0.9,-4.2),color,Enum.Material.Metal)
  if isVan then
   p("Cargo rear shell",Vector3.new(5.9,4.5,7),CFrame.new(0,2,2),color,Enum.Material.Metal)
   for _,side in {-1,1} do
    p("Cargo door outline",Vector3.new(2.65,3.8,0.12),CFrame.new(side*1.4,2,5.58),color:Lerp(P.White,0.06),Enum.Material.Metal)
    p("Cargo chrome handle",Vector3.new(0.6,0.16,0.15),CFrame.new(side*0.5,2,5.72),P.Muted,Enum.Material.Metal)
    p("Ribbed cargo molding",Vector3.new(0.12,0.18,6),CFrame.new(side*3,0.8,2),P.Panel,Enum.Material.Metal)
   end
  else
   p("Rear trunk",Vector3.new(5.8,0.6,2.6),CFrame.new(0,0.8,4),color,Enum.Material.Metal)
   p("Rear window",Vector3.new(4.9,1.5,0.15),CFrame.new(0,2,2.6)*CFrame.Angles(-0.3,0,0),Color3.fromRGB(95,126,144),Enum.Material.Glass).Transparency=0.35
  end
  p("Cabin roof",Vector3.new(5.5,0.3,if isVan then 4 else 4.8),CFrame.new(0,3.2,if isVan then -2.8 else -0.2),color,Enum.Material.Metal)
  local windshield=p("Windshield",Vector3.new(5.1,1.8,0.12),CFrame.new(0,2,-4.1)*CFrame.Angles(0.22,0,0),Color3.fromRGB(122,170,190),Enum.Material.Glass); windshield.Transparency=0.4
  for _,side in {-1,1} do
   for _,z in {-3.8,-0.7} do p("Window pillar",Vector3.new(0.18,2,0.18),CFrame.new(side*2.7,2,z),color,Enum.Material.Metal) end
   p("Side window",Vector3.new(0.1,1.6,2.7),CFrame.new(side*2.72,2,-2.2),Color3.fromRGB(122,170,190),Enum.Material.Glass).Transparency=0.45
   p("Side mirror arm",Vector3.new(0.6,0.16,0.2),CFrame.new(side*3,1.9,-3.2),P.Panel,Enum.Material.Metal)
   p("Mirror",Vector3.new(0.3,0.7,0.8),CFrame.new(side*3.35,2,-3.2),color,Enum.Material.Metal)
   p("Door handle",Vector3.new(0.12,0.14,0.7),CFrame.new(side*3.07,0.8,-1),P.Muted,Enum.Material.Metal)
  end
 end
 for _,side in {-1,1} do
  local headlight=p("Headlight",Vector3.new(1.5,0.5,0.15),CFrame.new(side*1.8,0.45,-5.65),Color3.fromRGB(255,235,194),Enum.Material.Neon)
  local beam=Instance.new("SpotLight"); beam.Name="VehicleBeam"; beam.Face=Enum.NormalId.Front; beam.Angle=45; beam.Range=32; beam.Brightness=0.8; beam.Shadows=false; beam.Parent=headlight
  p("BrakeLight",Vector3.new(1.3,0.4,0.12),CFrame.new(side*1.9,0.6,if isVan then 6.35 else 5.5),Color3.fromRGB(150,55,49),Enum.Material.Neon)
  p("Bumper",Vector3.new(5.8,0.35,0.3),CFrame.new(0,-0.55,side*(if isVan then 6.4 else 5.6)),P.Panel,Enum.Material.Metal)
 end
 F.sign(m,cf*CFrame.new(0,-0.15,-5.84),Vector3.new(2,0.5,0.08),if isVan then "CRUMB / COURIER" else "CARD CITY",P.Gold)
 p("Front grille",Vector3.new(2,0.4,0.12),CFrame.new(0,0.5,-5.75),P.Charcoal,Enum.Material.Metal)
 for _,side in {-1,1} do for _,end_ in {-1,1} do
  local offset=CFrame.new(side*3,-0.55,end_*(if isVan then 4.3 else 3.6))
  local importedWheel,wheelModel=F.skin(m,"Wheel",cf*offset)
  if importedWheel and wheelModel then
   for _,part in wheelModel:GetDescendants() do if part:IsA("BasePart") then
    part:SetAttribute("WheelPivot",offset); part:SetAttribute("SpokeLocal",(cf*offset):ToObjectSpace(part.CFrame)); part:SetAttribute("Front",end_<0)
   end end
   local collider=p("WheelCollider",Vector3.new(0.8,2.35,2.35),offset,P.Panel,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder); collider.Transparency=1
  else
   local wheel=p("Wheel",Vector3.new(0.8,2.35,2.35),offset,Color3.fromRGB(29,31,36),Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
   wheel:SetAttribute("WheelOffset",offset); wheel:SetAttribute("Front",end_<0)
   for n=1,5 do
    local localCF=CFrame.new(side*0.47,0,0)*CFrame.Angles(n*math.pi*2/5,0,0)*CFrame.new(0,0.35,0)
    local spoke=p("Wheel spoke",Vector3.new(0.1,0.75,0.13),offset*localCF,P.Muted,Enum.Material.Metal); spoke:SetAttribute("WheelPivot",offset); spoke:SetAttribute("SpokeLocal",localCF); spoke:SetAttribute("Front",end_<0)
   end
   local hub=p("Wheel hub",Vector3.new(0.85,1.35,1.35),offset,P.Muted,Enum.Material.Metal,Enum.PartType.Cylinder); hub:SetAttribute("WheelOffset",offset); hub:SetAttribute("Front",end_<0)
  end
 end end
 if isVan then local cover=p("Cover occluder",Vector3.new(5.8,4,7),CFrame.new(0,1.9,2),P.Panel); cover.Transparency=1; cover.CanCollide=false end
 if dynamic then
  local seat=Instance.new("VehicleSeat"); seat.Name="DriverSeat"; seat.Size=Vector3.new(2,0.6,2); seat.CFrame=cf*CFrame.new(-1.35,0.9,-2); seat.Anchored=false; seat.CanCollide=false; seat.Transparency=1; seat.Parent=m
  local stash=p("StashHandle",Vector3.new(2,1,0.4),CFrame.new(0,1.5,6.9),P.Mint,Enum.Material.Metal); stash.Transparency=0.5
  for _,item in m:GetDescendants() do
   if item:IsA("BasePart") then
    item.Anchored=false; item.Massless=item~=root; item.CanCollide=item==root or (item.Name=="Wheel" or item.Name=="WheelCollider"); item.CanTouch=item==seat; item.CollisionGroup="CityVehicles"
    if item~=root then
     if item:GetAttribute("WheelOffset") or item:GetAttribute("WheelPivot") then local motor=Instance.new("Motor6D"); motor.Name="WheelMotor"; motor.Part0=root; motor.Part1=item; motor.C0=item:GetAttribute("WheelOffset") or item:GetAttribute("WheelPivot"); if item:GetAttribute("SpokeLocal") then motor.C1=item:GetAttribute("SpokeLocal"):Inverse() end; motor.Parent=item
     else local weld=Instance.new("WeldConstraint"); weld.Part0=root; weld.Part1=item; weld.Parent=item end
    end
   end
  end
  root.CustomPhysicalProperties=PhysicalProperties.new(0.8,0.8,0.05)
 end
 return m
end
function F.tree(parent: Instance,cf: CFrame): Model
 local m=F.model(parent,"Street tree"); m:SetAttribute("VegetationPivot",cf); m.WorldPivot=cf; if F.skin(m,"Tree",cf) then return m end
 F.part(m,"Bark trunk",Vector3.new(7,0.9,0.9),cf*CFrame.new(0,3.5,0)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(106,84,65),Enum.Material.Wood,Enum.PartType.Cylinder)
 for i,offset in {Vector3.new(0,8.5,0),Vector3.new(-2.3,7,0),Vector3.new(2.1,7.6,0.6),Vector3.new(0,7.3,-2)} do
  local leaves=F.part(m,"Leaf canopy",Vector3.new(5.4,5.8,5.2),cf*CFrame.new(offset),Color3.fromRGB(75+i*7,122+i*7,93+i*4),Enum.Material.Grass,Enum.PartType.Ball); leaves.CanCollide=false; leaves.CanQuery=false
 end
 m.WorldPivot=cf
 return m
end
function F.lamp(parent: Instance,cf: CFrame): Model
 local m=F.model(parent,"Cast-metal streetlamp")
 if not F.skin(m,"Streetlamp",cf) then
  F.part(m,"Tapered light column",Vector3.new(11,0.35,0.35),cf*CFrame.new(0,5.5,0)*CFrame.Angles(0,0,math.pi/2),P.Panel,Enum.Material.Metal,Enum.PartType.Cylinder)
  F.part(m,"Lamp arm",Vector3.new(0.3,0.3,2.5),cf*CFrame.new(0,11,-1.1),P.Panel,Enum.Material.Metal)
  F.part(m,"Cast light housing",Vector3.new(1.7,0.5,2),cf*CFrame.new(0,10.8,-2),P.Panel,Enum.Material.Metal)
 end
 local emitter=F.part(m,"Streetlight emitter",Vector3.new(1.3,0.12,1.6),cf*CFrame.new(0,10.5,-2),P.Gold,Enum.Material.Neon)
 local light=Instance.new("PointLight"); light.Range=21; light.Brightness=0.6; light.Color=Color3.fromRGB(255,217,173); light.Parent=emitter
 return m
end
function F.dumpster(parent: Instance,cf: CFrame): Model
 local m=F.model(parent,"Service dumpster"); if F.skin(m,"Dumpster",cf) then return m end
 F.part(m,"Steel bin",Vector3.new(7,4,4),cf*CFrame.new(0,2,0),Color3.fromRGB(65,97,88),Enum.Material.Metal)
 F.part(m,"Hinged lid",Vector3.new(7.4,0.3,4.4),cf*CFrame.new(0,4.2,0)*CFrame.Angles(0.04,0,0),P.Panel,Enum.Material.DiamondPlate)
 for _,side in {-1,1} do F.part(m,"Bin handle",Vector3.new(0.2,0.2,1.8),cf*CFrame.new(side*3.7,2.5,0),P.Muted,Enum.Material.Metal) end
 return m
end
return F
