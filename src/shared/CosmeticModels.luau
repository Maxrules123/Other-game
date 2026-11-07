--!strict
-- Shared original cosmetic geometry: the same models appear in shop previews and on characters.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local C=require(ReplicatedStorage.Shared.Config)
local M={}
function M.build(parent: Instance,id: string,cf: CFrame,anchorSize: Vector3): Model
 local def=C.Cosmetics[id]; assert(def,"Unknown cosmetic")
 local m=Instance.new("Model"); m.Name=def.Name; m.Parent=parent
 local library=ReplicatedStorage:FindFirstChild("ArtAssets"); local template=library and library:FindFirstChild(def.Model)
 if template and template:IsA("Model") then
  local skin=template:Clone(); skin:PivotTo(cf); skin.Parent=m
  for _,item in skin:GetDescendants() do if item:IsA("LuaSourceContainer") then item:Destroy() elseif item:IsA("BasePart") then item.Anchored=true; item.CanCollide=false; item.CanQuery=false end end
 else
   local function part(name: string,size: Vector3,off: CFrame,color: Color3,shape: Enum.PartType?): Part
   local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf*off; p.Color=color; p.Material=if def.Model=="RoundSpecs" or string.find(name,"Brass") then Enum.Material.Metal else Enum.Material.Fabric; p.Shape=shape or Enum.PartType.Block; p.Anchored=true; p.CanCollide=false; p.CanQuery=false; p.Parent=m; return p
  end
   if def.Model=="CanvasCap" then
    part("Stitched canvas crown",Vector3.new(1.85,0.9,1.7),CFrame.new(0,0.25,0.05),def.Color,Enum.PartType.Ball)
    part("Curved visor",Vector3.new(1.85,0.12,1.2),CFrame.new(0,0.05,-0.85),def.Color)
    part("Cap front patch",Vector3.new(0.45,0.25,0.04),CFrame.new(0,0.37,-0.75),C.Palette.Gold)
    part("Crown button",Vector3.new(0.16,0.12,0.16),CFrame.new(0,0.7,0),def.Color)
   elseif def.Model=="Beanie" then
    part("Knitted crown",Vector3.new(1.8,1.1,1.7),CFrame.new(0,0.35,0),def.Color,Enum.PartType.Ball)
    part("Rolled knit band",Vector3.new(1.86,0.3,1.75),CFrame.new(0,0.02,0),def.Color:Lerp(C.Palette.White,0.12))
    part("Woven tag",Vector3.new(0.35,0.22,0.04),CFrame.new(0.4,0.05,-0.89),C.Palette.Gold)
   elseif def.Model=="RoundSpecs" then
    for _,side in {-1,1} do
     for n=1,12 do
      local angle=n*math.pi*2/12
      part("Segmented round frame",Vector3.new(0.16,0.06,0.08),CFrame.new(side*0.36+math.cos(angle)*0.27,math.sin(angle)*0.27,0)*CFrame.Angles(0,0,angle+math.pi/2),def.Color)
     end
     local glass=part("Clear lens",Vector3.new(0.11,0.43,0.43),CFrame.new(side*0.36,0,-0.015)*CFrame.Angles(0,math.pi/2,0),Color3.fromRGB(137,173,186),Enum.PartType.Cylinder); glass.Material=Enum.Material.Glass; glass.Transparency=0.65
     part("Frame arm",Vector3.new(0.07,0.07,0.65),CFrame.new(side*0.68,0,0.3),def.Color)
    end
    part("Nose bridge",Vector3.new(0.22,0.07,0.1),CFrame.new(0,0.06,0),def.Color)
   elseif def.Model=="Backpack" then
    part("Canvas bag",Vector3.new(1.5,1.8,0.65),CFrame.new(0,-0.1,0),def.Color)
    part("Front pouch",Vector3.new(1.15,0.65,0.2),CFrame.new(0,-0.5,0.4),def.Color:Lerp(C.Palette.Charcoal,0.15))
    part("Leather flap",Vector3.new(1.55,0.4,0.7),CFrame.new(0,0.65,0.04),def.Color:Lerp(C.Palette.White,0.12))
    for _,side in {-1,1} do
     part("Shoulder strap",Vector3.new(0.14,1.8,0.2),CFrame.new(side*0.48,0,-0.45),C.Palette.Charcoal)
     part("Brass buckle",Vector3.new(0.16,0.18,0.1),CFrame.new(side*0.4,0.35,0.45),C.Palette.Gold)
    end
   else
    local w,h,d=anchorSize.X+0.12,anchorSize.Y+0.06,anchorSize.Z+0.12
    part("Tailored front",Vector3.new(w,h,0.08),CFrame.new(0,0,-d/2),def.Color)
    part("Tailored back",Vector3.new(w,h,0.08),CFrame.new(0,0,d/2),def.Color)
    for _,side in {-1,1} do part("Jacket side",Vector3.new(0.08,h,d),CFrame.new(side*w/2,0,0),def.Color); part("Lapel",Vector3.new(0.25,h*0.7,0.06),CFrame.new(side*0.3,h*0.1,-d/2-0.08)*CFrame.Angles(0,0,-side*0.12),def.Color:Lerp(C.Palette.White,0.15)) end
    for n=1,3 do part("Brass button",Vector3.new(0.08,0.08,0.04),CFrame.new(0,h*.3-n*.2,-d/2-.1),C.Palette.Gold) end
   end
 end
 return m
end
return M
