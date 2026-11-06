--!strict
local C=require(game:GetService("ReplicatedStorage").Shared.Config)
local F=require(script.Parent.ModelFactory)
local CosmeticModels=require(game:GetService("ReplicatedStorage").Shared.CosmeticModels)
local P=C.Palette
local W: any={Centers={},Checkpoints={},SafeZones={},Targets={},Guards={},Stations={},StationParts={},Secrets={},SecretParts={}}
local function part(parent: Instance,name: string,size: Vector3,cf: CFrame,color: Color3,material: Enum.Material?): Part
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color; p.Anchored=true; p.Material=material or Enum.Material.SmoothPlastic; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent
 return p
end
local function block(parent: Instance,name: string,x: number,y: number,z: number,w: number,h: number,d: number,color: Color3,material: Enum.Material?): Part
 return part(parent,name,Vector3.new(w,h,d),CFrame.new(x,y,z),color,material)
end
local function label(p: BasePart,value: string,color: Color3?)
 local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Front; gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud; gui.PixelsPerStud=30; gui.Parent=p
 local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Size=UDim2.fromScale(1,1); t.Text=value; t.TextColor3=color or P.White; t.Font=Enum.Font.GothamBold; t.TextScaled=true; t.TextWrapped=true; t.Parent=gui
 local padding=Instance.new("UIPadding"); padding.PaddingLeft=UDim.new(0.06,0); padding.PaddingRight=UDim.new(0.06,0); padding.PaddingTop=UDim.new(0.1,0); padding.PaddingBottom=UDim.new(0.1,0); padding.Parent=t
end
local function prompt(p: BasePart,title: string,action: string,id: string?)
 local q=Instance.new("ProximityPrompt"); q.ActionText=title; q.ObjectText=p.Name; q.KeyboardKeyCode=Enum.KeyCode.E; q.GamepadKeyCode=Enum.KeyCode.ButtonX; q.MaxActivationDistance=11; q.RequiresLineOfSight=true; q:SetAttribute("Action",action); q:SetAttribute("Id",id or ""); q.Parent=p
end
local function model(parent: Instance,name: string): Model
 local m=Instance.new("Model"); m.Name=name; m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic; m.Parent=parent; return m
end
local function sign(parent: Instance,x: number,y: number,z: number,w: number,h: number,value: string,color: Color3?,reverse: boolean?): Part
 local p=block(parent,"Sign / "..value,x,y,z,w,h,0.35,P.Charcoal)
 if reverse then p.CFrame*=CFrame.Angles(0,math.pi,0) end
 label(p,value,color); return p
end
local function plant(parent: Instance,x: number,z: number,large: boolean?)
 if large then F.tree(W.Vegetation or parent,CFrame.new(x,0.7,z)); return end
 block(parent,"Terracotta planter",x,0.9,z,if large then 5 else 2,1.8,if large then 5 else 2,Color3.fromRGB(157,106,84))
 block(parent,"Plant stem",x,if large then 4 else 2,z,0.6,if large then 6 else 2,0.6,Color3.fromRGB(110,88,66))
 local top=block(parent,"Rounded foliage",x,if large then 8 else 3,z,if large then 7 else 2.5,if large then 7 else 2.5,if large then 7 else 2.5,Color3.fromRGB(90,153,118)); top.Shape=Enum.PartType.Ball
end
local function bench(parent: Instance,x: number,z: number,color: Color3?)
 block(parent,"Bench seat",x,2,z,7,0.6,2.2,color or Color3.fromRGB(139,101,78),Enum.Material.Wood)
 block(parent,"Bench back",x,3,z+1,7,2,0.5,color or Color3.fromRGB(139,101,78),Enum.Material.Wood)
 for _,side in {-1,1} do block(parent,"Bench steel foot",x+side*2.5,1,z,0.6,2,2,P.Charcoal) end
end
local function cafeTable(parent: Instance,x: number,z: number,color: Color3)
 local top=block(parent,"Cafe table",x,2.5,z,4,0.4,4,color); top.Shape=Enum.PartType.Cylinder; top.CFrame*=CFrame.Angles(0,0,math.pi/2); top.Size=Vector3.new(0.4,4,4)
 block(parent,"Table foot",x,1.2,z,0.5,2.4,0.5,P.Panel)
 for _,side in {-1,1} do
  block(parent,"Cafe stool",x+side*3.4,1.7,z,2,0.4,2,P.Panel)
  block(parent,"Stool foot",x+side*3.4,0.8,z,0.5,1.6,0.5,P.Panel)
 end
end
local function fountain(parent: Instance,x: number,z: number,color: Color3)
 local base=block(parent,"Fountain basin",x,0.8,z,13,1.6,13,Color3.fromRGB(164,173,184)); base.Shape=Enum.PartType.Cylinder; base.Size=Vector3.new(1.6,13,13); base.CFrame*=CFrame.Angles(0,0,math.pi/2)
 local water=block(parent,"Still mint water",x,1.65,z,11,0.15,11,color,Enum.Material.Glass); water.Transparency=0.3; water.CanCollide=false
 block(parent,"Fountain plinth",x,3,z,2.2,4,2.2,P.Panel)
 local orb=block(parent,"Fountain sculpture",x,5.5,z,3,3,3,color,Enum.Material.Metal); orb.Shape=Enum.PartType.Ball
end
local function interior(parent: Instance,x: number,z: number,kind: string,color: Color3)
 -- Shop front is at z+16. Central aisle and entrance remain clear.
 if kind=="Market" then
  for _,side in {-1,1} do
   for level=1,3 do
    block(parent,"Stocked shop shelf",x+side*10,level*1.6,z,5,0.3,15,P.Panel)
    for n=1,4 do block(parent,"Cartoon snack box",x+side*10,level*1.6+0.65,z-7+n*3,2,1,1.6,if n%2==0 then P.Gold else color) end
   end
  end
  block(parent,"Checkout counter",x,2,z-10,12,4,3,color)
  sign(parent,x,6,z-14,12,2,"CRUMBS / NOT CASH",P.Gold,true)
 elseif kind=="Laundry" then
  for n=-1,1 do
   local washer=block(parent,"Bubble washer",x+n*8,2.5,z-8,6,5,5,P.White)
   local glass=block(parent,"Round washer window",x+n*8,2.6,z-5.4,3,3,0.25,color,Enum.Material.Glass); glass.Shape=Enum.PartType.Ball; glass.CanCollide=false
   block(parent,"Washer dial",washer.Position.X+1.8,4.3,z-5.3,0.6,0.6,0.2,P.Purple)
  end
  bench(parent,x,z+4)
 elseif kind=="Outfitter" then
  block(parent,"Clothing shop counter",x,2,z-10,10,4,3,color,Enum.Material.WoodPlanks)
  for _,side in {-1,1} do
   block(parent,"Clothes rail",x+side*10,5.5,z,0.18,0.18,19,P.Muted,Enum.Material.Metal)
   for n=1,3 do
    CosmeticModels.build(parent,({"mint_jacket","rust_jacket","night_jacket"})[n],CFrame.new(x+side*10,3.8,z-8+n*4),Vector3.new(2,1.6,1))
   end
   for _,dz in {-9,9} do block(parent,"Rack support",x+side*10,2.8,z+dz,0.18,5.5,0.18,P.Panel,Enum.Material.Metal) end
  end
  for n,id in {"canvas_mint","night_beanie","round_specs","courier_pack"} do
   block(parent,"Accessory pedestal",x-9+n*4,2,z-9,3,4,3,P.Panel,Enum.Material.Wood)
   CosmeticModels.build(parent,id,CFrame.new(x-9+n*4,if id=="courier_pack" then 5 else 4.3,z-9),Vector3.new(2,1.6,1))
  end
  sign(parent,x,6,z-14,16,2,"SECOND SHIFT / APPEARANCE ONLY",P.Gold,true)
 elseif kind=="Office" then
  block(parent,"Reception desk",x,2,z-8,13,4,4,color)
  for _,side in {-1,1} do bench(parent,x+side*10,z+3); plant(parent,x+side*12,z-9) end
  sign(parent,x,7,z-14,15,2,"LOBBY / FICTIONAL BUSINESS",P.Gold,true)
 else
  block(parent,"Service counter",x,2,z-9,23,4,4,color)
  for n=-1,1 do cafeTable(parent,x+n*9,z+4,color) end
  sign(parent,x,6,z-14,18,2,if kind=="Bank" then "NO REAL ACCOUNTS HERE" else "TODAY'S SPECIAL / NOODLES",P.Gold,true)
 end
end
local function shop(parent: Instance,x: number,z: number,w: number,h: number,name: string,color: Color3,kind: string)
 local m=model(parent,name)
 block(m,"Shop floor",x,0.4,z,w,0.8,32,Color3.fromRGB(198,191,182),Enum.Material.Concrete)
 for _,side in {-1,1} do block(m,"Shop side wall",x+side*w/2,h/2,z,1,h,32,color,Enum.Material.Brick) end
 block(m,"Back wall",x,h/2,z-16,w,h,1,color,Enum.Material.Brick)
 for _,side in {-1,1} do
  block(m,"Front pier",x+side*(w/2-1.5),5,z+16,3,10,1,color,Enum.Material.Brick)
  local glass=block(m,"Window beside open door",x+side*(w/4+2),4,z+16,w/2-8,6,0.3,Color3.fromRGB(162,214,219),Enum.Material.Glass); glass.Transparency=0.58
 end
 block(m,"Entrance lintel",x,9.5,z+16,w,2,1,color,Enum.Material.Concrete)
 block(m,"Roof slab",x,h,z,w+1,0.8,33,P.Panel)
 if h>12 then
  block(m,"Upper building mass",x,(h+11)/2,z,w-1,h-11,31,color,Enum.Material.Brick)
  for y=15,h-2,5 do for n=-1,1 do block(m,"Upper window",x+n*w*0.3,y,z+15.7,5,3,0.35,Color3.fromRGB(168,200,221),Enum.Material.Glass) end end
 end
 local awning=block(m,"Striped awning",x,8.2,z+18,w+1,0.6,5,color:Lerp(P.White,0.25))
 for n=-3,3 do block(m,"Awning stripe",x+n*4,8.55,z+18,1.8,0.12,5,P.White).CanCollide=false end
 sign(m,x,10.8,z+16.7,w-3,2.2,name,P.White,true)
 block(m,"Roof vent",x-7,h+1.6,z-4,5,2.4,5,Color3.fromRGB(100,110,122),Enum.Material.Metal)
 block(m,"Roof water barrel",x+8,h+2.5,z-5,4,5,4,color:Lerp(P.Charcoal,0.3),Enum.Material.Metal)
 interior(m,x,z,kind,color)
 return m
end
function W:InsideSafe(pos: Vector3): boolean
 for _,center in self.SafeZones do if math.abs(pos.X-center.X)<C.Hideout.Width/2 and math.abs(pos.Z-center.Z)<C.Hideout.Depth/2 and pos.Y>-2 and pos.Y<15 then return true end end
 return false
end
function W:DistrictAt(pos: Vector3): number?
 for i,center in self.Centers do if math.abs(pos.X-center.X)<=C.City.HalfWidth and math.abs(pos.Z)<=C.City.HalfDepth-1 then return i end end
 return nil
end
function W:Hideout(parent: Instance,x: number,district: number)
 local cx=x+C.City.HideoutX; local cz=C.City.HideoutZ
 local center=Vector3.new(cx,0,cz); self.SafeZones[district]=center; self.Checkpoints[district]=CFrame.new(cx,4,cz-17)
 local m=model(parent,"Backroom / "..district)
 block(m,"Herringbone timber floor",cx,0.45,cz,64,0.9,48,Color3.fromRGB(95,78,66),Enum.Material.WoodPlanks)
 for _,side in {-1,1} do
  block(m,"Exposed brick side",cx+side*32,7,cz,1,14,48,Color3.fromRGB(103,80,76),Enum.Material.Brick)
  block(m,"Front partition",cx+side*21,7,cz-24,22,14,1,P.Panel,Enum.Material.Concrete)
  block(m,"Steel ceiling beam",cx+side*22,13.5,cz,0.45,0.5,48,P.Panel,Enum.Material.Metal)
 end
 block(m,"Backroom rear wall",cx,7,cz+24,64,14,1,Color3.fromRGB(103,80,76),Enum.Material.Brick)
 block(m,"Door lintel",cx,12,cz-24,20,4,1,P.Panel)
 block(m,"Opaque workshop roof",cx,14,cz,66,0.7,50,Color3.fromRGB(58,61,69),Enum.Material.Metal)
 -- Street-facing closed business conceals the playable workshop behind it.
 block(m,"Closed repair-shop facade",cx,7,52,52,14,42,Color3.fromRGB(117,113,108),Enum.Material.Brick)
 block(m,"Closed corrugated shutter",cx,5,30.8,29,9,0.35,Color3.fromRGB(84,94,102),Enum.Material.DiamondPlate)
 sign(m,cx,11,30.4,30,2.5,"BUBBLE REPAIRS / CLOSED",P.Muted)
 block(m,"Alley pavers",x-106,0.25,81,17,0.5,105,Color3.fromRGB(102,105,109),Enum.Material.Cobblestone)
 block(m,"Hidden entrance landing",cx,0.25,79,58,0.5,8,Color3.fromRGB(102,105,109),Enum.Material.Cobblestone)
 sign(m,cx,8,cz-24.6,8,1.2,"BACK ROOM / MEMBERS",P.Mint)
 local bulb=block(m,"Quiet green entry light",cx-8,8,cz-25,0.7,0.7,0.7,P.Mint,Enum.Material.Neon)
 local point=Instance.new("PointLight"); point.Color=P.Mint; point.Brightness=0.5; point.Range=12; point.Parent=bulb
 F.sofa(m,CFrame.new(cx+17,0.8,cz-10),Color3.fromRGB(66,94,98))
 F.table(m,CFrame.new(cx+17,0.8,cz-16))
 local rug=block(m,"Woven lounge rug",cx+17,0.96,cz-13,13,0.08,12,Color3.fromRGB(72,66,87),Enum.Material.Fabric); rug.CanCollide=false
 for n=-2,2 do block(m,"Rug woven stripe",cx+17+n*2.2,1.01,cz-13,0.15,0.02,11,Color3.fromRGB(151,116,91)).CanCollide=false end
 F.locker(m,CFrame.new(cx-17,0.8,cz-20),Color3.fromRGB(91,112,105))
 F.chair(m,CFrame.new(cx+10,0.8,cz+2)*CFrame.Angles(0,-0.4,0),Color3.fromRGB(113,102,126))
 F.chair(m,CFrame.new(cx+19,0.8,cz+2)*CFrame.Angles(0,0.4,0),Color3.fromRGB(113,102,126))
 block(m,"Planning desk",cx+15,3,cz+7,13,0.4,5,Color3.fromRGB(139,105,77),Enum.Material.Wood)
 for _,dx in {10,20} do block(m,"Desk steel leg",cx+dx,1.8,cz+7,0.3,3.6,4,P.Panel,Enum.Material.Metal) end
 for n=1,4 do block(m,"Planning papers",cx+11+n*1.8,3.3,cz+7,1.5,0.06,2.2,Color3.fromRGB(219,210,183)).CFrame*=CFrame.Angles(0,n*0.13,0) end
 F.machine(m,CFrame.new(cx-23,0.8,cz+10),"IMAGINARY INK PRESS",P.Purple)
 F.machine(m,CFrame.new(cx-23,0.8,cz),"CARTOON TOKEN RINSE",Color3.fromRGB(104,154,139))
 local function station(name: string,dx: number,dz: number,action: string,title: string,col: Color3,w: number?): Part
  local pos=Vector3.new(cx+dx,3,cz+dz)
  local p=block(m,name,pos.X,pos.Y,pos.Z,w or 5,4,1.4,col,Enum.Material.Metal)
  label(p,title,P.White); prompt(p,"Use "..name,action)
  self.Stations[action]=self.Stations[action] or {}; self.Stations[action][district]=pos
  self.StationParts[action]=self.StationParts[action] or {}; self.StationParts[action][district]=p
  return p
 end
 station("Card Intake",0,17,"Bank","DEPOSIT / SECURE CARDS",P.Panel,7)
 local press=station("Press controls",-23,7.7,"Press","01 / INK PRESS",P.Panel); press.Transparency=1; press.CanCollide=false
 local rinse=station("Rinse controls",-23,-2.3,"Rinse","02 / CARTOON RINSE",P.Panel); rinse.Transparency=1; rinse.CanCollide=false
 station("Cash Printer",0,6,"Payout","03 / CLAIM PAYOUT",P.Panel,7)
 station("Gear bench",-23,-10,"Shop","EQUIPMENT / OPERATIONS",P.Panel,8)
 station("Confetti supplies",-23,-19,"Resupply","DECOY SUPPLIES",P.Mint,6)
 station("Practice console",23,-3,"Practice","PRACTICE / NO RISK",P.Purple,5)
 station("Courier route board",23,18,"Hideout","ROUTES / CLUBHOUSE",P.Panel,7)
 station("Quest ledger",16,11,"Missions","PEOPLE / CONTRACTS",P.Panel,6)
 local wardrobePrompt=station("Wardrobe",28,-18,"Wardrobe","WARDROBE / YOUR STYLE",P.Purple,6); wardrobePrompt.Transparency=1; wardrobePrompt.CanCollide=false
 local wardrobeGui=wardrobePrompt:FindFirstChildOfClass("SurfaceGui"); if wardrobeGui then wardrobeGui.Enabled=false end
 local cabinet=model(m,"Open wardrobe cabinet")
 for _,side in {-1,1} do block(cabinet,"Wardrobe side",cx+28+side*4,4.8,cz-18,0.4,8,3.4,Color3.fromRGB(108,91,77),Enum.Material.WoodPlanks) end
 block(cabinet,"Wardrobe back",cx+28,4.8,cz-16.4,8.4,8,0.3,Color3.fromRGB(108,91,77),Enum.Material.WoodPlanks)
 for _,height in {0.9,8.7} do block(cabinet,"Wardrobe shelf",cx+28,height,cz-18,8.4,0.3,3.4,Color3.fromRGB(139,109,79),Enum.Material.Wood) end
 block(cabinet,"Clothes rail",cx+28,6.5,cz-18,7.4,0.16,0.16,P.Muted,Enum.Material.Metal)
 for n,id in {"mint_jacket","rust_jacket","night_jacket"} do CosmeticModels.build(cabinet,id,CFrame.new(cx+23.8+n*2.1,4.7,cz-18),Vector3.new(2,1.6,1)) end
 sign(cabinet,cx+28,9.4,cz-19.8,8,0.9,"WARDROBE",P.Mint)
 station("Card gallery",-29,-5,"Index","COLLECTION / PRIVATE",P.Panel,4)
 -- The external dock allows van unloading without driving through a doorway.
 local dockPos=Vector3.new(cx-32.8,3,cz+18)
 local dock=block(m,"Dock card intake",dockPos.X,dockPos.Y,dockPos.Z,0.5,3,3,P.Mint,Enum.Material.Metal); prompt(dock,"Deposit cards / van intake","Bank")
 local index=#C.Districts+district; self.Stations.Bank[index]=dockPos; self.StationParts.Bank[index]=dock
 local garagePos=Vector3.new(x-104,3,cz-7)
 local garage=block(m,"Garage intercom",garagePos.X,garagePos.Y,garagePos.Z,3,4,0.7,P.Panel,Enum.Material.Metal); label(garage,"COURIER / GARAGE",P.Mint); prompt(garage,"Van garage","Garage")
 self.Stations.Garage=self.Stations.Garage or {}; self.Stations.Garage[district]=garagePos
 self.StationParts.Garage=self.StationParts.Garage or {}; self.StationParts.Garage[district]=garage
 self.VanSpawns[district]=CFrame.new(x-106,2.1,cz+7)
 for _,dx in {-26,-6,14} do
  local lamp=block(m,"Caged workshop pendant",cx+dx,11.8,cz,1.2,0.35,1.2,P.Gold,Enum.Material.Neon)
  local light=Instance.new("PointLight"); light.Color=Color3.fromRGB(255,205,147); light.Brightness=0.7; light.Range=20; light.Parent=lamp
  block(m,"Pendant cable",cx+dx,13,cz,0.05,2.2,0.05,P.Panel,Enum.Material.Metal)
 end
 for n=1,5 do block(m,"Conduit pipe",cx-31.2,10+n*0.3,cz,0.16,0.16,43,Color3.fromRGB(96,108,111),Enum.Material.Metal) end
 sign(m,cx+12,8.5,cz+23.3,24,4,"CITY / AFTER HOURS\nEVERY CARD IS FICTIONAL",P.Muted)
 block(m,"Kitchen counter",cx+24,2.3,cz+12,8,4.6,4,Color3.fromRGB(107,115,106),Enum.Material.WoodPlanks)
 block(m,"Countertop",cx+24,4.8,cz+12,8.3,0.3,4.2,P.Muted,Enum.Material.Marble)
 block(m,"Mini fridge",cx+28,3,cz+19,4,6,3.5,Color3.fromRGB(133,144,140),Enum.Material.Metal)
 for n=1,3 do block(m,"Coffee tin",cx+21+n*1.3,5.3,cz+13,0.75,0.9,0.75,if n%2==0 then P.Gold else P.Purple) end
end
function W:Build()
 local old=workspace:FindFirstChild("CardCity"); if old then old:Destroy() end
 self.Centers={}; self.Checkpoints={}; self.SafeZones={}; self.Targets={}; self.Guards={}; self.Stations={}; self.StationParts={}; self.Secrets={}; self.SecretParts={}; self.VanSpawns={}; self.TrafficSignals={}; self.QuestPositions={}
 local root=Instance.new("Folder"); root.Name="CardCity"; root.Parent=workspace; self.Root=root
 local vegetation=Instance.new("Folder"); vegetation.Name="Vegetation"; vegetation.Parent=root; self.Vegetation=vegetation
 local secrets=Instance.new("Folder"); secrets.Name="Secrets"; secrets.Parent=root
 local shopNames={{"CRUMB MART","BUBBLE LAUNDRY","NOODLE NOOK"},{"BANANA EXPRESS","GOBLIN GOODS","FOOD COURT"},{"MOONVAULT LOBBY","PAPERWORK HQ","CLOUD COFFEE"},{"ROYAL RACCOON","TOPIARY CLUB","GOLDEN TEA"},{"VOID UNLIMITED","MOONVAULT EXCHANGE","MIDNIGHT NOODLES"}}
 for i,d in C.Districts do
  local x=(i-1)*C.City.DistrictSpacing; self.Centers[i]=Vector3.new(x,0,0)
  local ground=model(root,d.Name.." / Streets")
  block(ground,"District ground",x,-1,0,240,2,390,Color3.fromRGB(103,133,115),Enum.Material.Grass)
  block(ground,"Main road",x,0.1,0,240,0.2,36,Color3.fromRGB(49,53,66),Enum.Material.Asphalt)
  for _,side in {-1,1} do
   block(ground,"Paved sidewalk",x,0.35,side*26,240,0.7,16,Color3.fromRGB(190,191,198),Enum.Material.Concrete)
   block(ground,"Mint curb",x,0.45,side*18.2,240,0.9,0.6,d.Color)
   for dx=-112,112,16 do block(ground,"Sidewalk seam",x+dx,0.72,side*26,0.08,0.02,14,Color3.fromRGB(163,164,173)).CanCollide=false end
  end
  block(ground,"Back lane",x,0.2,-79,240,0.4,12,Color3.fromRGB(118,123,137),Enum.Material.Cobblestone)
  for _,dx in {-70,-23,23,70} do block(ground,"Connected alley",x+dx,0.2,-50,8,0.4,70,Color3.fromRGB(159,158,164),Enum.Material.Concrete) end
  block(ground,"Courtyard footpath",x+44,0.25,57,54,0.5,64,Color3.fromRGB(178,174,161),Enum.Material.Cobblestone)
  block(ground,"Rear neighborhood walk",x,0.25,98,240,0.5,10,Color3.fromRGB(170,172,176),Enum.Material.Concrete)
  for _,dx in {-112,112} do block(ground,"Around-the-block walkway",x+dx,0.25,58,5,0.5,83,Color3.fromRGB(170,172,176),Enum.Material.Concrete) end
  for dx=-108,108,18 do block(ground,"Lane dash",x+dx,0.26,0,7,0.05,0.3,P.Gold).CanCollide=false end
  for dx=-7,7,3.5 do block(ground,"Zebra crossing",x+dx,0.27,0,1.8,0.06,35,P.White).CanCollide=false end
  local facade=model(root,d.Name.." / Shops")
  for n=1,3 do
   local height=if i==3 then 31+n*9 elseif i==5 then 25+n*7 elseif i==4 then 17 else 12+n*2
   local kind=if n==3 then "Outfitter" elseif i==1 and n==1 then "Market" elseif i==1 and n==2 then "Laundry" elseif i==3 and n<3 then "Office" elseif i==5 and n<3 then "Bank" else "Cafe"
   shop(facade,x+(n-2)*46,-46,32,height,(if n==3 then "SECOND SHIFT OUTFITTERS" else shopNames[i][n]),d.Color:Lerp(P.White,n*0.08),kind)
  end
  self:Hideout(root,x,i)
  local counterPos=Vector3.new(x+46,3,-49)
  local counter=block(facade,"Outfitters register",counterPos.X,counterPos.Y,counterPos.Z,4,3,1,P.Panel,Enum.Material.Metal); label(counter,"STYLE SHOP",P.Gold); prompt(counter,"Browse cosmetics","CosmeticShop")
  self.Stations.CosmeticShop=self.Stations.CosmeticShop or {}; self.Stations.CosmeticShop[i]=counterPos
  self.StationParts.CosmeticShop=self.StationParts.CosmeticShop or {}; self.StationParts.CosmeticShop[i]=counter
  local detail=model(root,d.Name.." / Street Life")
  for n=-2,2 do
   local dx=n*29
   F.lamp(detail,CFrame.new(x+dx,0.7,30))
   if n%2==0 then plant(detail,x+dx,-21,true) else bench(detail,x+dx,32) end
   block(detail,"Storm drain",x+dx,0.3,-11,3,0.1,1.4,P.Charcoal).CanCollide=false
  end
  for _,dx in {-62,62} do
   block(detail,"Fire hydrant",x+dx,1.3,24,0.8,2.6,0.8,Color3.fromRGB(207,102,93))
   for _,side in {-1,1} do block(detail,"Safety bollard",x+dx+side*3,1.5,14,0.6,3,0.6,P.Gold) end
  end
  local bus=block(detail,"Bus shelter roof",x+47,8,36,13,0.6,6,d.Color)
  block(detail,"Bus shelter back",x+47,4,39,13,8,0.4,P.Panel)
  sign(detail,x+47,5.5,38.6,9,2,"CARD CITY / EASTBOUND",P.Mint)
  bench(detail,x+47,36)
  for _,dx in {41,53} do block(detail,"Bus shelter post",x+dx,4,33,0.5,8,0.5,P.Charcoal) end
  local car=block(detail,"Cartoon delivery van",x+83,2.7,54,11,4.4,5,d.Color)
  block(detail,"Van cabin",x+79,4,54,4,2,4.4,P.Panel)
  for _,wx in {-1,1} do for _,wz in {-1,1} do
   local wheel=block(detail,"Rubber tire",x+83+wx*3.5,1.4,54+wz*2.6,2.5,1,2.5,P.Charcoal); wheel.Shape=Enum.PartType.Cylinder; wheel.Size=Vector3.new(1,2.5,2.5); wheel.CFrame*=CFrame.Angles(0,math.pi/2,0)
  end end
  sign(detail,x+84,3,51.4,7,2,"CRUMB COURIER",P.White)
  F.dumpster(detail,CFrame.new(x-59,0.7,-67))
  for n=1,3 do block(detail,"Stacked delivery crates",x+59,1+n,-69-n,3,2,3,Color3.fromRGB(153,120,81),Enum.Material.WoodPlanks) end
  sign(detail,x-68,7,-28,17,3,string.upper(d.Name),d.Color,true)
  sign(detail,x+69,5,-72,8,3,"BACK LANE\nSHOPS / SECRETS",P.Gold,true)
  local landmark=model(root,d.Name.." / Courtyard")
  if i==1 then
   fountain(landmark,x+45,58,P.Mint)
   for _,dx in {28,62} do cafeTable(landmark,x+dx,76,d.Color); plant(landmark,x+dx,42,true) end
   sign(landmark,x+45,6,87,22,3,"CRUMB SQUARE / LOCAL LEGENDS",P.Mint)
  elseif i==2 then
   for n=1,3 do
    local dx=x+22+n*12
    block(landmark,"Food stall counter",dx,2,75,10,4,4,d.Color)
    block(landmark,"Food stall canopy",dx,7,75,11,0.6,6,if n==2 then P.Purple else P.Gold)
    sign(landmark,dx,5,72.6,8,2,({"BANANA BUNS","GOBLIN RAMEN","MOON SHAKES"})[n],P.White)
    cafeTable(landmark,dx,51,d.Color)
   end
   sign(landmark,x+45,8,88,30,4,"PLAZA / THE FOOD LOOP",P.Gold)
  elseif i==3 then
   block(landmark,"Transit canopy",x+46,10,63,34,1,22,P.Panel)
   for _,dx in {31,61} do block(landmark,"Transit column",x+dx,5,63,1,10,1,d.Color) end
   for n=1,5 do block(landmark,"Transit seating tier",x+45,0.2+n*0.5,77+n*1.4,28,n,1.5,Color3.fromRGB(133,145,163)) end
   sign(landmark,x+46,7,53,28,4,"MOONVAULT TRANSIT\nNEXT TRAIN / EVENTUALLY",P.Mint)
   for _,dx in {28,64} do plant(landmark,x+dx,45,true) end
  elseif i==4 then
   fountain(landmark,x+45,58,P.Gold)
   for _,dx in {25,65} do for _,z in {42,78} do plant(landmark,x+dx,z,true) end end
   for dx=24,66,7 do block(landmark,"Estate fence post",x+dx,2.5,88,0.5,5,0.5,P.Gold) end
   sign(landmark,x+45,7,88,24,3,"ROYAL GARDEN / KEEP IT CLASSY",P.Gold)
  else
   block(landmark,"Exchange plaza stage",x+45,1,61,28,2,23,P.Panel)
   local sculpture=block(landmark,"Giant fictional card sculpture",x+45,9,65,11,7,0.7,P.Purple,Enum.Material.Metal); sculpture.CFrame*=CFrame.Angles(0,0,math.rad(13)); label(sculpture,"VOID / FICTION",P.Gold)
   for _,dx in {28,62} do block(landmark,"Mint accent pillar",x+dx,5,65,0.6,10,0.6,P.Mint,Enum.Material.Neon); plant(landmark,x+dx,44) end
   sign(landmark,x+45,7,88,28,3,"NIGHT EXCHANGE / NO REAL MONEY",P.Purple)
  end
  for _,offset in {Vector3.new(-83,0,178),Vector3.new(-40,0,178),Vector3.new(8,0,178),Vector3.new(62,0,178),Vector3.new(84,0,98)} do plant(detail,x+offset.X,offset.Z,true) end
  -- Larger blocks include both perimeter traffic lanes, residential walks, and service alleys.
  for _,side in {-1,1} do
   block(ground,"Perimeter road",x,0.1,side*148,240,0.2,22,Color3.fromRGB(51,55,61),Enum.Material.Asphalt)
   block(ground,"Perimeter pavement",x,0.4,side*166,240,0.8,12,Color3.fromRGB(157,158,160),Enum.Material.Concrete)
  end
  for _,dx in {-112,112} do block(ground,"Cross avenue",x+dx,0.15,0,22,0.3,308,Color3.fromRGB(51,55,61),Enum.Material.Asphalt) end
  for _,dx in {-92,91} do
   local row=model(root,d.Name.." / Residential terrace")
   for n=1,3 do
    local z=-36-n*25
    block(row,"Terrace brick house",x+dx,10,z,18,20,21,d.Color:Lerp(P.Muted,0.25),Enum.Material.Brick)
    block(row,"Terrace cornice",x+dx,20.5,z,19,0.7,22,P.Panel,Enum.Material.Concrete)
    for _,wx in {-5,5} do for _,y in {6,14} do block(row,"Sash window",x+dx+wx,y,z+10.7,3,4,0.2,Color3.fromRGB(166,191,198),Enum.Material.Glass) end end
    block(row,"Rain downpipe",x+dx+8.8,10,z+10.9,0.18,20,0.18,P.Panel,Enum.Material.Metal)
   end
  end
  for _,side in {-1,1} do
   local sx=x+side*16
   block(detail,"Crossing signal pole",sx,5.5,-20,0.35,11,0.35,P.Panel,Enum.Material.Metal)
   block(detail,"Signal housing",sx,9,-20,1.5,3.5,0.8,P.Charcoal)
   local red=block(detail,"Red crossing signal",sx,9.8,-20.5,0.8,0.8,0.15,P.Danger,Enum.Material.Neon)
   local green=block(detail,"Green crossing signal",sx,8.4,-20.5,0.8,0.8,0.15,P.Mint,Enum.Material.Neon)
   table.insert(self.TrafficSignals,{Red=red,Green=green})
  end
  for n=1,3 do
   local cx=x+28+n*15
   F.chair(landmark,CFrame.new(cx,0.8,63),d.Color)
  end
  -- Back-lane details and a deliberate route around each building block.
  local back=model(root,d.Name.." / Back Lane")
  for _,dx in {-48,0,48} do
   block(back,"Distant rowhouse",x+dx,9,-116,28,18,22,d.Color:Lerp(P.Charcoal,0.25))
   block(back,"Rowhouse roof",x+dx,18.5,-116,30,1,24,P.Panel)
   for _,wx in {-7,7} do block(back,"Rowhouse window",x+dx+wx,9,-104.8,4,5,0.3,P.Gold,Enum.Material.Glass) end
  end
  for n=1,3 do
   local offsets={{-61,-70},{61,71},{12,-91}}
   local pos=Vector3.new(x+offsets[n][1],2.5,offsets[n][2]); local id=string.format("S%d_%d",i,n)
   local m=model(secrets,id)
   local trinket=block(m,"City souvenir",pos.X,pos.Y,pos.Z,1.6,1.6,1.6,P.Gold,Enum.Material.Metal); trinket.Shape=Enum.PartType.Ball; trinket.CanCollide=false; trinket:SetAttribute("SecretId",id)
   prompt(trinket,"Discover "..C.Secrets[id].Name,"Secret",id); self.Secrets[id]=pos; self.SecretParts[id]=trinket
  end
  if i<=4 then
   local speaker=({"Mara","Jax","Wren","Iris"})[i]
   self.QuestPositions[speaker]=Vector3.new(x+72,0,76)
  end
  for n=1,12 do
   local dx=-82+(n-1)*14
   local pos=Vector3.new(x+dx,0,if n%2==0 then 26 else -26)
   local route={pos+Vector3.new(-3,3.8,0),pos+Vector3.new(6,3.8,0),pos+Vector3.new(3,3.8,3)}
   local activity="Phone break"
   if n==3 or n==7 then
    local door=x+(if n==3 then -46 else 0)
    route={Vector3.new(door,3.8,-26),Vector3.new(door,3.8,-38),Vector3.new(door,3.8,-26),pos+Vector3.new(0,3.8,0)}
    activity=if n==3 then "Browsing shelves" else "Laundry break"
   elseif n==10 then route={pos+Vector3.new(0,3.8,0),Vector3.new(x+47,3.8,29),Vector3.new(x+47,3.8,34)}; activity="Waiting for bus" end
   table.insert(self.Targets,{Id=string.format("D%dN%d",i,n),District=i,Position=pos,Style=if n==6 then "VIP" elseif n==4 or n==8 then "Collector" elseif n%3==0 then "Commuter" else "Daydreamer",PauseLabel=activity,Route=route})
  end
  -- Extra back-lane target makes exploration useful beyond souvenir rewards.
  table.insert(self.Targets,{Id=string.format("D%dN13",i),District=i,Position=Vector3.new(x+10,0,-78),Style="Collector",Route={Vector3.new(x-8,3.8,-78),Vector3.new(x+20,3.8,-78)}})
  for _,dx in {-28,28} do table.insert(self.Guards,{District=i,Position=Vector3.new(x+dx,0,0)}) end
  table.insert(self.Guards,{District=i,Position=Vector3.new(x+12,0,-78),BackLane=true})
  if i>1 then
   local gate=block(detail,"District access marker",x-119,4,0,0.5,8,24,d.Color); gate.CanCollide=false; gate.Transparency=0.8; prompt(gate,"District requirements","Districts",tostring(i))
  end
 end
 for _,side in {-1,1} do block(root,"City boundary",480,20,side*196,1202,40,2,P.Panel).Transparency=1 end
 for _,x in {-121,1081} do block(root,"City end",x,20,0,2,40,394,P.Panel).Transparency=1 end
 local spawn=Instance.new("SpawnLocation"); spawn.Name="Clubhouse checkpoint"; spawn.Size=Vector3.new(6,1,6); spawn.CFrame=self.Checkpoints[1]*CFrame.new(0,-2.5,0); spawn.Anchored=true; spawn.Neutral=true; spawn.Transparency=1; spawn.CanCollide=false; spawn.Parent=root
 local vault=block(root,"Vault Run kiosk",C.City.HideoutX+8,3,C.City.HideoutZ-20,5,6,2,P.Purple); label(vault,"VAULT RUN / 90 REP",P.Gold); prompt(vault,"Start Vault Run","Vault")
 self.DeliveryBay=Vector3.new(C.City.DistrictSpacing+82,2,51)
 local delivery=block(root,"Plaza delivery bay",self.DeliveryBay.X,0.3,self.DeliveryBay.Z,12,0.2,20,P.Gold); delivery.CanCollide=false; prompt(delivery,"Deliver courier parcel","Deliver")
 return root
end
W.Part=part; W.Label=label
return W
