--!strict
-- Personal, noncolliding decorations; server geometry and gameplay checks remain authoritative.
local C=require(game:GetService("ReplicatedStorage").Shared.Config)
local H: any={Signature="",Folder=nil}
local function prop(parent: Instance,name: string,position: Vector3,size: Vector3,color: Color3): Part
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=position; p.Color=color; p.Material=Enum.Material.SmoothPlastic; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Parent=parent; return p
end
local function words(p: Part,value: string,color: Color3)
 local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Front; gui.PixelsPerStud=36; gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud; gui.Parent=p
 local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=value; t.TextColor3=color; t.Font=Enum.Font.GothamBold; t.TextScaled=true; t.TextWrapped=true; t.Size=UDim2.fromScale(1,1); t.Parent=gui
end
function H:Update(packet: any)
 local p=packet.Profile; local discoveries={}
 for key in p.Collection do table.insert(discoveries,key) end
 table.sort(discoveries)
 local signature=table.concat({p.Hideout.Lounge,p.Hideout.Workshop,p.Hideout.Display,p.Hideout.Network,p.Identities,#discoveries},":")
 if signature==self.Signature then return end
 self.Signature=signature
 if self.Folder then self.Folder:Destroy() end
 local folder=Instance.new("Folder"); folder.Name="MyClubhouseDecor"; folder.Parent=workspace; self.Folder=folder
 local shift=Vector3.new(C.City.HideoutX+45,0,C.City.HideoutZ-60)
 local banner=prop(folder,"Personal clubhouse banner",Vector3.new(-45,8,37.3),Vector3.new(13,1.5,0.08),C.Palette.Panel)
 words(banner,"IDENTITY "..p.Identities.." / "..#discoveries.." DISCOVERIES",C.Palette.Gold)
 if p.Hideout.Lounge>0 then
  prop(folder,"Lounge rug",Vector3.new(-29,0.96,45),Vector3.new(15,0.06,10),C.Palette.Purple)
  for n=1,p.Hideout.Lounge do
   local pillow=prop(folder,"Luxury cushion",Vector3.new(-33+n*2,2.7,47),Vector3.new(1.2,1.2,0.5),C.Palette.Mint); pillow.CFrame*=CFrame.Angles(0,0,math.rad(n*8))
  end
 end
 for n=1,p.Hideout.Workshop do
  prop(folder,"Workbench tool rail",Vector3.new(-73.3,4+n*1.2,63),Vector3.new(0.15,0.2,6),C.Palette.Gold)
  for i=1,3 do prop(folder,"Decorative gadget tool",Vector3.new(-73,4.2+n*1.2,60.5+i*1.2),Vector3.new(0.3,0.8,0.3),C.Palette.Mint) end
 end
 if p.Hideout.Display>0 then
  local count=math.min(#discoveries,p.Hideout.Display*3)
  for n=1,count do
   local key=discoveries[n]; local id,variant=string.match(key,"([^:]+):(.+)"); local card=id and C.Cards[id]
   if not card then continue end
   local z=44+(n-1)%3*5.5; local y=5+math.floor((n-1)/3)*2.6
   local display=prop(folder,"Personal discovered card",Vector3.new(-73.2,y,z),Vector3.new(4.8,2.2,0.18),C.RarityColors[card.Rarity])
   display.CFrame*=CFrame.Angles(0,-math.pi/2,0)
   words(display,card.Brand.."\n"..variant,C.Palette.Charcoal)
   prop(folder,"Gallery shelf",Vector3.new(-72.8,y-1.3,z),Vector3.new(1.7,0.2,5.2),C.Palette.Gold)
  end
 end
 if p.Hideout.Network>0 then
  local map=prop(folder,"Courier route map",Vector3.new(-26,7.7,80.9),Vector3.new(12,2,0.12),C.Palette.Panel)
  words(map,"COURIER NETWORK / LEVEL "..p.Hideout.Network.."\nSTARTER → PLAZA → BUSINESS → HEIGHTS → NEON",C.Palette.Mint)
 end
 for _,item in folder:GetDescendants() do if item:IsA("BasePart") then item.CFrame+=shift end end
end
function H:RefreshSecrets(profile: any)
 local city=workspace:FindFirstChild("CardCity"); local secrets=city and city:FindFirstChild("Secrets")
 if not secrets then return end
 for _,model in secrets:GetChildren() do
  local part=model:FindFirstChild("City souvenir")
  if part and part:IsA("BasePart") then
   local discovered=profile.Secrets[model.Name]==true
   part.LocalTransparencyModifier=if discovered then 1 else 0
   local prompt=part:FindFirstChildOfClass("ProximityPrompt")
   if prompt then prompt.Enabled=not discovered end
  end
 end
end
return H
