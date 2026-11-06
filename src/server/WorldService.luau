--!strict
local C=require(game:GetService("ReplicatedStorage").Shared.Config)
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
 for _,side in {-1,1} do block(m,"Shop side wall",x+side*w/2,h/2,z,1,h,32,color) end
 block(m,"Back wall",x,h/2,z-16,w,h,1,color)
 for _,side in {-1,1} do
  block(m,"Front pier",x+side*(w/2-1.5),5,z+16,3,10,1,color)
  local glass=block(m,"Window beside open door",x+side*(w/4+2),4,z+16,w/2-8,6,0.3,Color3.fromRGB(162,214,219),Enum.Material.Glass); glass.Transparency=0.58
 end
 block(m,"Entrance lintel",x,9.5,z+16,w,2,1,color)
 block(m,"Roof slab",x,h,z,w+1,0.8,33,P.Panel)
 if h>12 then
  block(m,"Upper building mass",x,(h+11)/2,z,w-1,h-11,31,color)
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
 for i,center in self.Centers do if math.abs(pos.X-center.X)<=80 and math.abs(pos.Z)<=135 then return i end end
 return nil
end
function W:Hideout(parent: Instance,x: number,district: number)
 local center=Vector3.new(x-45,0,60); self.SafeZones[district]=center; self.Checkpoints[district]=CFrame.new(x-45,4,42)
 local m=model(parent,if district==1 then "CRUMB CLUB / Starter Hideout" else "CRUMB CLUB / Satellite "..district)
 block(m,"Clubhouse floor",center.X,0.45,60,58,0.9,44,Color3.fromRGB(77,75,92),Enum.Material.WoodPlanks)
 for _,side in {-1,1} do
  block(m,"Clubhouse side",center.X+side*29,6.5,60,1,13,44,P.Panel)
  block(m,"Front brick wall",center.X+side*18,6.5,38,22,13,1,Color3.fromRGB(123,99,107),Enum.Material.Brick)
  local window=block(m,"Club window",center.X+side*18,7,37.4,14,5,0.3,P.Mint,Enum.Material.Glass); window.Transparency=0.35
 end
 block(m,"Back brick wall",center.X,6.5,82,58,13,1,Color3.fromRGB(123,99,107),Enum.Material.Brick)
 block(m,"Door lintel",center.X,11.5,38,14,3,1,P.Panel)
 block(m,"Skylight frame",center.X,13,60,60,0.8,46,P.Panel)
 -- Translucent roof keeps the interior readable while preserving a cozy enclosure.
 local roof=m:FindFirstChild("Skylight frame") :: Part; roof.Material=Enum.Material.Glass; roof.Transparency=0.72; roof.Color=P.Purple
 sign(m,center.X,10.8,37,15,2.3,"CRUMB CLUB / SAFE",P.Mint)
 block(m,"Mint entry runner",center.X,0.95,48,8,0.1,19,P.Mint).CanCollide=false
 for _,side in {-1,1} do plant(m,center.X+side*8,35) end
 local function station(name: string,dx: number,z: number,action: string,title: string,color: Color3,w: number?): Part
  local pos=Vector3.new(center.X+dx,3,z)
  local p=block(m,name,pos.X,pos.Y,pos.Z,w or 5,5,2,color)
  label(p,title,color==P.Panel and P.Mint or P.Charcoal); prompt(p,if action=="Bank" then "Bank carried cards" else "Use "..name,action)
  self.Stations[action]=self.Stations[action] or {}; self.Stations[action][district]=pos
  self.StationParts[action]=self.StationParts[action] or {}; self.StationParts[action][district]=p
  return p
 end
 station("Hideout Terminal",0,76,"Bank","BANK / FICTIONAL CARDS",P.Panel,8)
 station("Equipment Workbench",-19,72,"Shop","GEAR / UPGRADES",P.Purple,8)
 station("Confetti Supply Bench",-19,63,"Resupply","RESTOCK / DECOYS",P.Mint,8)
 station("Practice Arcade",18,58,"Practice","PRACTICE / NO RISK",P.Gold,6)
 station("Courier Route Board",19,76,"Hideout","CLUBHOUSE / TRAVEL",P.Mint,8)
 station("Odd Jobs Board",18,67,"Missions","ODD JOBS",P.Gold,7)
 local gallery=station("Collection Gallery",-24,51,"Index","YOUR CARD GALLERY",P.Panel,6)
 gallery:SetAttribute("Gallery",true)
 for n=1,3 do
  local couchX=center.X+9
  block(m,"Lounge cushion",couchX+n*2.3,1.8,47,2.2,1.2,3.5,P.Purple)
  block(m,"Lounge back",couchX+n*2.3,3,49,2.2,2.4,0.7,P.Panel)
 end
 block(m,"Lounge coffee table",center.X+14,1.8,42,7,0.4,3,Color3.fromRGB(150,110,88))
 sign(m,center.X,9,81.3,17,3,"SMALL CARDS / BIG PLANS",P.Gold)
 sign(m,center.X-18,9,81.3,13,2,"EVERY UPGRADE HAS A JOB",P.Purple)
 for _,dx in {-22,0,22} do
  local lamp=block(m,"Warm hanging lamp",center.X+dx,11,60,2,0.4,2,P.Gold,Enum.Material.Neon)
  local light=Instance.new("PointLight"); light.Color=P.Gold; light.Range=18; light.Brightness=0.6; light.Parent=lamp
 end
end
function W:Build()
 local old=workspace:FindFirstChild("CardCity"); if old then old:Destroy() end
 self.Centers={}; self.Checkpoints={}; self.SafeZones={}; self.Targets={}; self.Guards={}; self.Stations={}; self.StationParts={}; self.Secrets={}; self.SecretParts={}
 local root=Instance.new("Folder"); root.Name="CardCity"; root.Parent=workspace; self.Root=root
 local secrets=Instance.new("Folder"); secrets.Name="Secrets"; secrets.Parent=root
 local shopNames={{"CRUMB MART","BUBBLE LAUNDRY","NOODLE NOOK"},{"BANANA EXPRESS","GOBLIN GOODS","FOOD COURT"},{"MOONVAULT LOBBY","PAPERWORK HQ","CLOUD COFFEE"},{"ROYAL RACCOON","TOPIARY CLUB","GOLDEN TEA"},{"VOID UNLIMITED","MOONVAULT EXCHANGE","MIDNIGHT NOODLES"}}
 for i,d in C.Districts do
  local x=(i-1)*160; self.Centers[i]=Vector3.new(x,0,0)
  local ground=model(root,d.Name.." / Streets")
  block(ground,"District ground",x,-1,0,160,2,270,Color3.fromRGB(103,133,115),Enum.Material.Grass)
  block(ground,"Main road",x,0.1,0,160,0.2,24,Color3.fromRGB(49,53,66),Enum.Material.Asphalt)
  for _,side in {-1,1} do
   block(ground,"Paved sidewalk",x,0.35,side*20,160,0.7,16,Color3.fromRGB(190,191,198),Enum.Material.Concrete)
   block(ground,"Mint curb",x,0.45,side*12.2,160,0.9,0.6,d.Color)
   for dx=-64,64,16 do block(ground,"Sidewalk seam",x+dx,0.72,side*20,0.08,0.02,14,Color3.fromRGB(163,164,173)).CanCollide=false end
  end
  block(ground,"Back lane",x,0.2,-79,160,0.4,12,Color3.fromRGB(118,123,137),Enum.Material.Cobblestone)
  for _,dx in {-70,-23,23,70} do block(ground,"Connected alley",x+dx,0.2,-50,8,0.4,70,Color3.fromRGB(159,158,164),Enum.Material.Concrete) end
  block(ground,"Courtyard footpath",x+44,0.25,57,54,0.5,64,Color3.fromRGB(178,174,161),Enum.Material.Cobblestone)
  block(ground,"Rear neighborhood walk",x,0.25,98,160,0.5,10,Color3.fromRGB(170,172,176),Enum.Material.Concrete)
  for _,dx in {-77,77} do block(ground,"Around-the-block walkway",x+dx,0.25,58,5,0.5,83,Color3.fromRGB(170,172,176),Enum.Material.Concrete) end
  for dx=-68,68,17 do block(ground,"Lane dash",x+dx,0.26,0,7,0.05,0.3,P.Gold).CanCollide=false end
  for dx=-7,7,3.5 do block(ground,"Zebra crossing",x+dx,0.27,0,1.8,0.06,23,P.White).CanCollide=false end
  local facade=model(root,d.Name.." / Shops")
  for n=1,3 do
   local height=if i==3 then 31+n*9 elseif i==5 then 25+n*7 elseif i==4 then 17 else 12+n*2
   local kind=if i==1 and n==1 then "Market" elseif i==1 and n==2 then "Laundry" elseif i==3 and n<3 then "Office" elseif i==5 and n<3 then "Bank" else "Cafe"
   shop(facade,x+(n-2)*46,-46,32,height,shopNames[i][n],d.Color:Lerp(P.White,n*0.08),kind)
  end
  self:Hideout(root,x,i)
  local detail=model(root,d.Name.." / Street Life")
  for n=-2,2 do
   local dx=n*29
   local pole=block(detail,"Streetlight pole",x+dx,6.5,27,0.45,13,0.45,P.Charcoal)
   local lamp=block(detail,"Streetlight shade",x+dx,13.1,26,2.5,0.5,3,P.Gold,Enum.Material.Neon)
   local light=Instance.new("PointLight"); light.Brightness=0.5; light.Range=17; light.Color=P.Gold; light.Parent=lamp
   if n%2==0 then plant(detail,x+dx,-26,true) else bench(detail,x+dx,25) end
   block(detail,"Storm drain",x+dx,0.3,-11,3,0.1,1.4,P.Charcoal).CanCollide=false
  end
  for _,dx in {-62,62} do
   block(detail,"Fire hydrant",x+dx,1.3,24,0.8,2.6,0.8,Color3.fromRGB(207,102,93))
   for _,side in {-1,1} do block(detail,"Safety bollard",x+dx+side*3,1.5,14,0.6,3,0.6,P.Gold) end
  end
  local bus=block(detail,"Bus shelter roof",x+47,8,22,13,0.6,6,d.Color)
  block(detail,"Bus shelter back",x+47,4,25,13,8,0.4,P.Panel)
  sign(detail,x+47,5.5,24.6,9,2,"CARD CITY / EASTBOUND",P.Mint)
  bench(detail,x+47,23)
  for _,dx in {41,53} do block(detail,"Bus shelter post",x+dx,4,19,0.5,8,0.5,P.Charcoal) end
  local car=block(detail,"Cartoon delivery van",x-52,2.7,7,11,4.4,5,d.Color)
  block(detail,"Van cabin",x-56,4,7,4,2,4.4,P.Panel)
  for _,wx in {-1,1} do for _,wz in {-1,1} do
   local wheel=block(detail,"Rubber tire",x-52+wx*3.5,1.4,7+wz*2.6,2.5,1,2.5,P.Charcoal); wheel.Shape=Enum.PartType.Cylinder; wheel.Size=Vector3.new(1,2.5,2.5); wheel.CFrame*=CFrame.Angles(0,math.pi/2,0)
  end end
  sign(detail,x-51,3,4.4,7,2,"CRUMB COURIER",P.White)
  block(detail,"Dumpster",x-59,2,-67,7,4,4,Color3.fromRGB(77,112,108))
  block(detail,"Dumpster lid",x-59,4.1,-67,7.4,0.4,4.4,P.Panel)
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
  for n=1,8 do
   local dx=-56+(n-1)*15
   local pos=Vector3.new(x+dx,0,if n%2==0 then 18 else -18)
   table.insert(self.Targets,{Id=string.format("D%dN%d",i,n),District=i,Position=pos,Style=if n==6 then "VIP" elseif n==4 or n==8 then "Collector" elseif n%3==0 then "Commuter" else "Daydreamer",Route={pos+Vector3.new(-3,3,0),pos+Vector3.new(6,3,0),pos+Vector3.new(3,3,3)}})
  end
  -- Extra back-lane target makes exploration useful beyond souvenir rewards.
  table.insert(self.Targets,{Id=string.format("D%dN9",i),District=i,Position=Vector3.new(x+10,0,-78),Style="Collector",Route={Vector3.new(x-8,3,-78),Vector3.new(x+20,3,-78)}})
  for _,dx in {-28,28} do table.insert(self.Guards,{District=i,Position=Vector3.new(x+dx,0,0)}) end
  table.insert(self.Guards,{District=i,Position=Vector3.new(x+12,0,-78),BackLane=true})
  if i>1 then
   local gate=block(detail,"District access marker",x-79,4,0,0.5,8,24,d.Color); gate.CanCollide=false; gate.Transparency=0.8; prompt(gate,"District requirements","Districts",tostring(i))
  end
 end
 for _,side in {-1,1} do block(root,"City boundary",320,20,side*136,802,40,2,P.Panel).Transparency=1 end
 for _,x in {-81,721} do block(root,"City end",x,20,0,2,40,274,P.Panel).Transparency=1 end
 local spawn=Instance.new("SpawnLocation"); spawn.Name="Clubhouse checkpoint"; spawn.Size=Vector3.new(6,1,6); spawn.CFrame=self.Checkpoints[1]*CFrame.new(0,-2.5,0); spawn.Anchored=true; spawn.Neutral=true; spawn.Transparency=1; spawn.CanCollide=false; spawn.Parent=root
 local vault=block(root,"Vault Run kiosk",-63,3,37,5,6,2,P.Purple); label(vault,"VAULT RUN / 90 REP",P.Gold); prompt(vault,"Start Vault Run","Vault")
 return root
end
W.Part=part; W.Label=label
return W
