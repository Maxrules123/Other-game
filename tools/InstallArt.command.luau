-- Original After Hours asset installer. Paste into the Studio Command Bar after selecting imported models.
-- This moves selected originals into ReplicatedStorage.ArtAssets; it never downloads or runs Toolbox code.
local bounds = {
 ["SedanBody"]={Center=Vector3.new(0.0,1.26,-0.2224999999999997),Size=Vector3.new(7.15,4.22,11.555)},
 ["VanBody"]={Center=Vector3.new(0.0,1.675,0.07250000000000023),Size=Vector3.new(7.15,5.05,12.645)},
 ["Wheel"]={Center=Vector3.new(0.07,0.0,0.0),Size=Vector3.new(0.9400000000000001,2.35,2.35)},
 ["Sofa"]={Center=Vector3.new(0.0,2.0,0.0),Size=Vector3.new(9.5,4.0,3.7)},
 ["Chair"]={Center=Vector3.new(0.0,2.1,0.0),Size=Vector3.new(2.6,4.2,2.6)},
 ["Locker"]={Center=Vector3.new(0.0,3.5,-0.12),Size=Vector3.new(8.1,7.0,2.4400000000000004)},
 ["Streetlamp"]={Center=Vector3.new(0.0,5.5625,-1.175),Size=Vector3.new(1.7,11.125,3.65)},
 ["Dumpster"]={Center=Vector3.new(0.0,2.0000000000000004,0.0),Size=Vector3.new(7.5,4.6000000000000005,4.4)},
 ["Tree"]={Center=Vector3.new(-0.14999999999999947,5.689433837004503,-0.7000000000000002),Size=Vector3.new(9.1,11.378867674009006,7.4)},
}
local selection=game:GetService("Selection"):Get()
local storage=game:GetService("ReplicatedStorage")
local library=storage:FindFirstChild("ArtAssets") or Instance.new("Folder")
library.Name="ArtAssets";library.Parent=storage
local installed=0
for _,object in selection do
 local name=object.Name:gsub("%.obj$",""):gsub("_Model$","")
 local expected=bounds[name]
 if expected and (object:IsA("Model") or object:IsA("MeshPart")) then
  local model=object
  if object:IsA("MeshPart") then model=Instance.new("Model");model.Name=name;model.Parent=workspace;object.Parent=model end
  model.PrimaryPart=nil
  local box,size=model:GetBoundingBox()
  local ratio=size.Y/expected.Size.Y
  if ratio>0 and math.abs(size.X/expected.Size.X/ratio-1)<0.08 and math.abs(size.Z/expected.Size.Z/ratio-1)<0.08 then
   model:ScaleTo(model:GetScale()/ratio)
   box,size=model:GetBoundingBox()
   model.WorldPivot=box*CFrame.new(-expected.Center)
   model:PivotTo(CFrame.new())
   local old=library:FindFirstChild(name);if old then old:Destroy() end
   for _,item in model:GetDescendants() do if item:IsA("LuaSourceContainer") then item:Destroy() end end
   model.Name=name;model.Parent=library;model:SetAttribute("Source","AfterHours original mesh pack");installed+=1
  else warn(name..": dimensions/orientation do not match. Import Y-up without rotation, then retry.") end
 end
end
print("After Hours: installed "..installed.." model templates. Stop/restart Play to use them. Save/publish the place to retain imported assets.")
