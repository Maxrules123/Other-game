--!strict
local C = require(game:GetService("ReplicatedStorage").Shared.Config)
local W: any = { Centers = {}, Checkpoints = {}, SafeZones = {}, Targets = {}, Guards = {} }
local function part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): Part
 local p = Instance.new("Part")
 p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Anchored = true
 p.Material = material or Enum.Material.SmoothPlastic
 p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
 p.Parent = parent
 return p
end
local function label(p: BasePart, text: string, color: Color3?)
 local gui = Instance.new("SurfaceGui"); gui.Face = Enum.NormalId.Front; gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud; gui.PixelsPerStud = 25; gui.Parent = p
 local t = Instance.new("TextLabel"); t.Size = UDim2.fromScale(1,1); t.BackgroundTransparency = 1; t.Text = text; t.Font = Enum.Font.GothamBold; t.TextScaled = true; t.TextColor3 = color or C.Palette.White; t.Parent = gui
 local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0.12,0); pad.PaddingBottom = UDim.new(0.12,0); pad.PaddingLeft = UDim.new(0.06,0); pad.PaddingRight = UDim.new(0.06,0); pad.Parent = t
end
local function prompt(p: BasePart, text: string, kind: string, id: string?)
 local q = Instance.new("ProximityPrompt"); q.ActionText = text; q.ObjectText = p.Name; q.KeyboardKeyCode = Enum.KeyCode.E; q.GamepadKeyCode = Enum.KeyCode.ButtonX; q.MaxActivationDistance = 11; q.RequiresLineOfSight = true; q.HoldDuration = 0; q:SetAttribute("Action",kind); q:SetAttribute("Id",id or ""); q.Parent = p
end
function W:InsideSafe(position: Vector3): boolean
 for _,center in self.SafeZones do
  if math.abs(position.X-center.X) < 12 and math.abs(position.Z-center.Z) < 10 then return true end
 end
 return false
end
function W:DistrictAt(position: Vector3): number?
 for i,center in self.Centers do
  if math.abs(position.X-center.X) <= 76 and math.abs(position.Z) <= 90 then return i end
 end
 return nil
end
local function building(parent: Instance, x: number, z: number, width: number, height: number, depth: number, color: Color3, name: string)
 part(parent,name,Vector3.new(width,height,depth),CFrame.new(x,height/2,z),color)
 part(parent,"Roof cap",Vector3.new(width+1,1,depth+1),CFrame.new(x,height+0.5,z),C.Palette.Charcoal)
 local front = if z < 0 then z+depth/2+0.1 else z-depth/2-0.1
 local rotate = if z < 0 then math.pi else 0
 local sign = part(parent,"Shop sign",Vector3.new(width-2,3,0.25),CFrame.new(x,7,front)*CFrame.Angles(0,rotate,0),C.Palette.Panel)
 label(sign,name)
 for offset = -1,1,2 do
  local window = part(parent,"Display window",Vector3.new(width*0.25,4,0.3),CFrame.new(x+offset*width*0.27,3.5,front),Color3.fromRGB(141,204,209),Enum.Material.Glass)
  window.Transparency = 0.25
 end
 for floor = 1, math.min(6,math.floor((height-7)/5)) do
  for offset = -1,1 do
   part(parent,"Upper window",Vector3.new(3,2.8,0.3),CFrame.new(x+offset*width*0.28,9+floor*4.5,front),Color3.fromRGB(188,206,220),Enum.Material.Glass)
  end
 end
 part(parent,"Door",Vector3.new(3.2,5.8,0.4),CFrame.new(x,2.9,front),C.Palette.Charcoal)
end
local function tree(parent: Instance, x: number, z: number)
 part(parent,"Tree trunk",Vector3.new(1.3,7,1.3),CFrame.new(x,3.5,z),Color3.fromRGB(115,83,73),Enum.Material.Wood)
 local crown = part(parent,"Tree canopy",Vector3.new(8,8,8),CFrame.new(x,10,z),Color3.fromRGB(102,159,133))
 crown.Shape = Enum.PartType.Ball
end
function W:Build()
 local old = workspace:FindFirstChild("CardCity"); if old then old:Destroy() end
 local root = Instance.new("Folder"); root.Name = "CardCity"; root.Parent = workspace; self.Root = root
 for i,d in C.Districts do
  local x = (i-1)*160
  self.Centers[i] = Vector3.new(x,0,0)
  self.Checkpoints[i] = CFrame.new(x-48,4,25)
  local folder = Instance.new("Model"); folder.Name = d.Name; folder.ModelStreamingMode = Enum.ModelStreamingMode.Atomic; folder.Parent = root
  part(folder,"District ground",Vector3.new(160,2,180),CFrame.new(x,-1,0),Color3.fromRGB(117,141,129),Enum.Material.Grass)
  part(folder,"Road",Vector3.new(160,0.25,24),CFrame.new(x,0.1,0),Color3.fromRGB(53,57,71),Enum.Material.Asphalt)
  for side = -1,1,2 do
   part(folder,"Wide sidewalk",Vector3.new(160,0.7,14),CFrame.new(x,0.35,side*19),Color3.fromRGB(191,192,200),Enum.Material.Concrete)
   part(folder,"Curb",Vector3.new(160,0.9,0.6),CFrame.new(x,0.45,side*12),d.Color)
   part(folder,"Backdrop hedge",Vector3.new(160,5,3),CFrame.new(x,2.5,side*88),Color3.fromRGB(74,111,98))
  end
  for dx = -65,65,13 do part(folder,"Road dash",Vector3.new(6,0.1,0.3),CFrame.new(x+dx,0.3,0),C.Palette.Gold) end
  for dx = -6,6,3 do part(folder,"Crosswalk",Vector3.new(1.5,0.1,22),CFrame.new(x+dx,0.32,0),C.Palette.White) end
  local names = if i==1 then {"CRUMB MART","BUBBLE LAUNDRY","NOODLE NOOK"} elseif i==2 then {"BANANA ARCADE","FOOD COURT","GOBLIN GOODS"} elseif i==3 then {"MOONVAULT TRANSIT","CLOUD OFFICE","PAPERWORK HQ"} elseif i==4 then {"ROYAL RACCOON ESTATE","TOPIARY CLUB","GOLDEN GARDEN"} else {"VOID UNLIMITED","MOONVAULT EXCHANGE","NIGHT MARKET"}
  for n = 1,3 do
   local height = if i==3 then 35+n*9 elseif i==5 then 28+n*7 elseif i==4 then 18 else 12+n*2
   building(folder,x+(n-2)*45,-48,34,height,32,d.Color:Lerp(C.Palette.White,n*0.07),names[n])
  end
  building(folder,x+25,49,32,if i==4 then 21 else 15,28,d.Color:Lerp(C.Palette.Charcoal,0.2),if i==1 then "MINT HIDEOUT ANNEX" else "CITY CLUB / "..i)
  local safe = Vector3.new(x-48,0,37)
  table.insert(self.SafeZones,safe)
  local tile = part(folder,"SAFE / HIDEOUT",Vector3.new(24,0.25,20),CFrame.new(safe+Vector3.new(0,0.85,0)),C.Palette.Mint)
  tile.Transparency = 0.35; tile.CanCollide = false
  part(folder,"Hideout shelter",Vector3.new(24,1,18),CFrame.new(safe+Vector3.new(0,11,0)),C.Palette.Charcoal)
  for side = -1,1,2 do part(folder,"Shelter column",Vector3.new(1,10,1),CFrame.new(safe+Vector3.new(side*11,5,7)),d.Color) end
  local terminal = part(folder,"Hideout Terminal",Vector3.new(5,5,2),CFrame.new(safe+Vector3.new(0,3,3)),C.Palette.Panel)
  label(terminal,"BANK CARDS\n100% FICTIONAL",C.Palette.Mint); prompt(terminal,"Bank carried cards","Bank")
  local shop = part(folder,"Equipment",Vector3.new(4,4,2),CFrame.new(safe+Vector3.new(-8,2,3)),C.Palette.Purple)
  label(shop,"UPGRADES"); prompt(shop,"Browse upgrades","Shop")
  local board = part(folder,"Mission board",Vector3.new(4,5,1),CFrame.new(safe+Vector3.new(8,3,3)),C.Palette.Panel)
  label(board,"ODD JOBS",C.Palette.Gold); prompt(board,"View missions","Missions")
  for dx = -65,65,26 do
   local pole = part(folder,"Streetlight",Vector3.new(0.5,12,0.5),CFrame.new(x+dx,6,25),C.Palette.Charcoal)
   local lamp = part(folder,"Lamp",Vector3.new(2,0.6,2),pole.CFrame*CFrame.new(0,6,0),C.Palette.Gold,Enum.Material.Neon)
   local light = Instance.new("PointLight"); light.Brightness = 0.55; light.Range = 15; light.Color = C.Palette.Gold; light.Parent = lamp
   part(folder,"Planter",Vector3.new(6,2,4),CFrame.new(x+dx,1,-25),C.Palette.Panel)
   tree(folder,x+dx,-26)
  end
  for dx = -20,20,40 do
   part(folder,"Bench seat",Vector3.new(7,0.6,2),CFrame.new(x+dx,2,24),Color3.fromRGB(136,99,78),Enum.Material.Wood)
   part(folder,"Bench back",Vector3.new(7,2,0.4),CFrame.new(x+dx,3,25),Color3.fromRGB(136,99,78),Enum.Material.Wood)
   for leg = -1,1,2 do part(folder,"Bench leg",Vector3.new(0.6,2,1.3),CFrame.new(x+dx+leg*2.5,1,24),C.Palette.Charcoal) end
  end
  local bus = part(folder,"Bus stop",Vector3.new(9,0.5,5),CFrame.new(x+52,8,21),d.Color)
  part(folder,"Bus stop panel",Vector3.new(9,7,0.5),bus.CFrame*CFrame.new(0,-3.5,2.5),C.Palette.Panel)
  local vending = part(folder,"SODA / decorative",Vector3.new(3,5,2),CFrame.new(x+62,2.5,-30),C.Palette.Purple); label(vending,"SODA\nPOP!")
  local car = part(folder,"Parked cartoon car",Vector3.new(10,2,5),CFrame.new(x+48,2,7),d.Color)
  part(folder,"Car roof",Vector3.new(5,2,4.5),car.CFrame*CFrame.new(0,1.7,0),C.Palette.Panel)
  for wx = -1,1,2 do for wz = -1,1,2 do
   local wheel = part(folder,"Wheel",Vector3.new(2.2,1,2.2),car.CFrame*CFrame.new(wx*3,-0.6,wz*2.5)*CFrame.Angles(math.pi/2,0,0),C.Palette.Charcoal)
   wheel.Shape = Enum.PartType.Cylinder
  end end
  local sign = part(folder,"District welcome",Vector3.new(19,5,1),CFrame.new(x-66,8,-29)*CFrame.Angles(0,math.pi,0),C.Palette.Panel)
  label(sign,string.upper(d.Name),d.Color)
  if i>1 then
   local gate = part(folder,"District access",Vector3.new(1,8,24),CFrame.new(x-79,4,0),d.Color)
   gate.CanCollide = false; gate.Transparency = 0.7; gate:SetAttribute("District",i)
   prompt(gate,"View district requirements","Districts",tostring(i))
  end
  for n = 1,6 do
   table.insert(self.Targets,{ Id = string.format("D%dN%d",i,n), District = i, Position = Vector3.new(x-35+(n-1)*13,0,if n%2==0 then 17 else -17) })
  end
  for n = 1,2 do table.insert(self.Guards,{District = i, Position = Vector3.new(x-28+(n-1)*56,0,0)}) end
  if i==4 then
   for dx = -63,63,18 do part(folder,"Estate fence",Vector3.new(1,5,1),CFrame.new(x+dx,2.5,-30),C.Palette.Gold) end
   part(folder,"Estate rail",Vector3.new(140,0.4,0.4),CFrame.new(x,4,-30),C.Palette.Gold)
  elseif i==5 then
   for n = 1,3 do part(folder,"Restrained neon trim",Vector3.new(28,0.4,0.4),CFrame.new(x+(n-2)*45,12,-31.5),C.Palette.Purple,Enum.Material.Neon) end
  end
 end
 -- Continuous boundary prevents walking around district access over the lawn.
 for side = -1,1,2 do
  local boundary = part(root,"City boundary",Vector3.new(830,40,2),CFrame.new(320,20,side*91),C.Palette.Charcoal)
  boundary.Transparency = 1
 end
 for x = -81,721,802 do local wall=part(root,"City end",Vector3.new(2,40,184),CFrame.new(x,20,0),C.Palette.Charcoal); wall.Transparency=1 end
 local spawn = Instance.new("SpawnLocation"); spawn.Name = "Starter checkpoint"; spawn.Size = Vector3.new(6,1,6); spawn.CFrame = self.Checkpoints[1]*CFrame.new(0,-2.5,0); spawn.Anchored = true; spawn.Neutral = true; spawn.Transparency = 1; spawn.CanCollide = false; spawn.Parent = root
 local vault = part(root,"Vault Run kiosk",Vector3.new(5,6,2),CFrame.new(-63,3,37),C.Palette.Purple); label(vault,"VAULT RUN\n90 REP",C.Palette.Gold); prompt(vault,"Start Vault Run","Vault")
 return root
end
W.Part = part
W.Label = label
return W
