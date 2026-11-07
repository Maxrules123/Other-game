--!nocheck
-- Generated city execution under lightweight geometry mocks. Not Roblox physics/rendering.
local total=0
local function check(value,message) assert(value,message); total+=1 end
local V={}
V.__index=function(t,k)
 if k=="Magnitude" then return math.sqrt(t.X*t.X+t.Y*t.Y+t.Z*t.Z) end
 if k=="Unit" then local n=math.sqrt(t.X*t.X+t.Y*t.Y+t.Z*t.Z); return setmetatable({X=t.X/n,Y=t.Y/n,Z=t.Z/n},V) end
 return V[k]
end
local function v(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},V) end
V.__add=function(a,b) return v(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
V.__sub=function(a,b) return v(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
function V:Lerp(other,t) return self+(other-self)*t end
function V:Dot(other) return self.X*other.X+self.Y*other.Y+self.Z*other.Z end
V.__mul=function(a,b) return v(a.X*b,a.Y*b,a.Z*b) end
local CF={}
CF.__index=function(t,key) if key=="LookVector" then return t.Look or v(0,0,-1) elseif key=="Rotation" then return setmetatable({Position=v()},CF) end; return CF[key] end
CF.__mul=function(a,b) return setmetatable({Position=a.Position+b.Position},CF) end
local function cf(x,y,z) return setmetatable({Position=if type(x)=="table" then x else v(x,y,z)},CF) end
function CF:Inverse() return cf(-self.Position.X,-self.Position.Y,-self.Position.Z) end
local Color={}
Color.__index=Color
function Color:Lerp(other,t) return setmetatable({R=self.R+(other.R-self.R)*t,G=self.G+(other.G-self.G)*t,B=self.B+(other.B-self.B)*t},Color) end
local function color(r,g,b) return setmetatable({R=r,G=g,B=b},Color) end
local methods={}
local meta={}
meta.__index=function(t,key)
 if methods[key] then return methods[key] end
 if key=="Position" and t.Properties.ClassName~="Attachment" then return t.Properties.CFrame and t.Properties.CFrame.Position or v() end
 if t.Properties[key]~=nil then return t.Properties[key] end
 for _,child in t.Children do if child.Name==key then return child end end
 return nil
end
meta.__newindex=function(t,key,value)
 if key=="Parent" then
  local old=t.Properties.Parent
  if old then local index=table.find(old.Children,t); if index then table.remove(old.Children,index) end end
  if value then table.insert(value.Children,t) end
 end
 t.Properties[key]=value
end
local function instance(class)
 local item=setmetatable({Properties={ClassName=class,Name=class,CFrame=cf(),Size=v(1,1,1),CanCollide=true,Transparency=0},Children={},Attributes={}},meta)
 return item
end
function methods:IsA(class) return self.ClassName==class or (class=="BasePart" and (self.ClassName=="Part" or self.ClassName=="VehicleSeat")) end
function methods:FindFirstChild(name)
 for _,child in self.Children do if child.Name==name then return child end end
 return nil
end
function methods:FindFirstChildOfClass(class)
 for _,child in self.Children do if child.ClassName==class then return child end end
 return nil
end
function methods:GetChildren() return table.clone(self.Children) end
function methods:GetDescendants()
 local result={}
 for _,child in self.Children do table.insert(result,child); for _,descendant in child:GetDescendants() do table.insert(result,descendant) end end
 return result
end
function methods:SetAttribute(key,value) self.Attributes[key]=value end
function methods:GetAttribute(key) return self.Attributes[key] end
function methods:Clone()
 local clone=instance(self.ClassName)
 for k,value in self.Properties do if k~="Parent" and k~="PrimaryPart" then clone[k]=value end end
 for key,value in self.Attributes do clone:SetAttribute(key,value) end
 for _,child in self.Children do local copy=child:Clone();copy.Parent=clone end
 return clone
end
function methods:Destroy() self.Parent=nil end
function methods:PivotTo(value)
 local origin=self.PrimaryPart.CFrame.Position
 for _,child in self:GetDescendants() do if child.ClassName=="Part" then child.CFrame=cf(child.Position-origin+value.Position) end end
end
local enum=setmetatable({},{__index=function(t,k) local group=setmetatable({},{__index=function(_,key) return key end}); rawset(t,k,group); return group end})
local world=instance("Workspace");function world:Raycast() return nil end
local shared={Config="Config",Rules="Rules",CosmeticModels="CosmeticModels"}; local modules={}
local replicated=instance("ReplicatedStorage"); replicated.Shared=shared
world.Terrain=instance("Terrain"); local lighting=instance("Lighting"); local materials=instance("MaterialService"); local worldTime=1000000
local env={
 PhysicalProperties={new=function(...) return {...} end},Vector3={new=v},Vector2={new=function(x,y) return {X=x,Y=y} end},
 Color3={fromRGB=color},Enum=enum,Instance={new=instance},RaycastParams={new=function() return {} end},task={spawn=function() end},
 CFrame={new=cf,Angles=function() return cf() end,lookAt=function(pos,target) local t=cf(pos); t.Look=(target-pos).Unit; return t end},
 UDim2={fromScale=function(x,y) return {x,y} end,fromOffset=function(x,y) return {x,y} end},UDim={new=function(x,y) return {x,y} end},
 Random={new=function() return {NextNumber=function(_,lo,hi) return (lo+hi)/2 end,NextInteger=function(_,lo,hi) return math.floor((lo+hi)/2) end} end},workspace=world,os={time=function() return worldTime end,clock=function() return worldTime end},script={Parent={ModelFactory="ModelFactory",StationModels="StationModels"}},game={GetService=function(_,name) return if name=="Lighting" then lighting elseif name=="MaterialService" then materials else replicated end},require=function(key) return modules[key] end,
}
setmetatable(env,{__index=getfenv()})
local function load(name)
 local fn=assert(loadstring(Sources[name],name)); setfenv(fn,env); local module=fn(); modules[name]=module; return module
end
local C=load("Config"); load("Rules"); load("CosmeticModels"); load("ModelFactory"); load("StationModels");local W=load("WorldService"); local N=load("NPCService")
W:Build(); N:Build(W)
check(#W.Centers==5,"five connected districts built")
check(#W.Targets==65,"65 NPC spawn routes exist")
check(#W.Guards==15,"15 guard spawns exist")
check(#N.Guards==15,"guard models created")
local targets=0; for _ in N.Targets do targets+=1 end
check(targets==65,"target models created without runtime indexing errors")
for id,target in N.Targets do
 check(not target.Prompt.RequiresLineOfSight,"citizen clothing cannot hide the native prompt / "..id)
 check(target.Prompt.MaxActivationDistance==C.InteractDistance and target.Prompt.ClickablePrompt,"native prompt range and click support match scouting / "..id)
 check(target.Prompt.Parent:IsA("Attachment") and target.Prompt.Parent.Parent==target.Model.PrimaryPart,"prompt uses a dedicated point above the body / "..id)
end
local secretCount=0; for _ in W.Secrets do secretCount+=1 end
check(secretCount==15,"all city secrets are placed")
for district=1,5 do
 local cp=W.Checkpoints[district].Position
 check(W:InsideSafe(cp),"checkpoint inside safe room "..district)
 check(W:DistrictAt(cp)==district,"checkpoint belongs to correct district "..district)
 for _,kind in {"Bank","Shop","Resupply","Practice","Hideout","Missions","Index","Press","Rinse","Payout","Wardrobe"} do
  check(W.Stations[kind][district]~=nil,"station exists: "..kind.." / "..district)
  check(W.StationParts[kind][district].Parent~=nil,"station has live interaction geometry")
  check(W:InsideSafe(W.Stations[kind][district]),"station inside safe room")
 end
 -- Every hallway is entered through a 14-stud clear door.
 local room=world.CardCity:FindFirstChild("Backroom / "..district)
 check(room~=nil,"clubhouse model exists")
 for _,p in room:GetChildren() do
  if p.Name=="Front partition" then check(math.abs(p.Position.X-cp.X)-p.Size.X/2>=10,"front wall leaves entrance clear") end
 end
end
local targetIds={}
for _,target in W.Targets do
 check(not targetIds[target.Id],"all target reservation identifiers are unique"); targetIds[target.Id]=true
 check(C.TargetStyles[target.Style]~=nil,"target style configured")
 check(#target.Route>=2,"target has an actual walk route")
 for _,point in target.Route do check(W:DistrictAt(point)==target.District,"route stays in target district") end
end
local shops=0; local boxes=0; local cafeSeats=0
for _,obj in world:GetDescendants() do
 if obj.Name=="Entrance lintel" then shops+=1 end
 if obj.Name=="Cartoon snack box" then boxes+=1 end
 if obj.Name=="Cafe stool" then cafeSeats+=1 end
end
check(shops==15,"all fifteen storefronts have open-entry geometry")
check(boxes>=20,"starter market is stocked")
check(cafeSeats>=8,"cafes and food court contain actual seating")
N:Tick(10,0.25)
check(true,"NPC status and route update executes")
local availability=N.Targets.D1N1
availability.Reserved={};N:Tick(11,0.25)
check(not availability.Model:GetAttribute("TargetAvailable") and not availability.Prompt.Enabled,"reserved targets hide both native and fallback actions")
availability.Reserved=nil;availability.Available=12;N:Tick(11,0.25)
check(not availability.Model:GetAttribute("TargetAvailable"),"recovery also suppresses the fallback action")
N:Tick(13,0.25)
check(availability.Model:GetAttribute("TargetAvailable") and availability.Prompt.Enabled,"recovery expiry restores both interaction paths")
for d=1,5 do
 check(W.Stations.Bank[5+d]~=nil,"every hidden workshop has an external van intake")
 check(W.VanSpawns[d]~=nil,"every garage has a van spawn")
end
check((W.Centers[5]-W.Centers[1]).Magnitude==960,"larger city has 960 studs between end districts")
local E=load("EnvironmentService"); E:Start()
check(world:GetAttribute("Weather")=="Clear","weather starts consistently")
worldTime+=C.Weather.Duration+1; E:Tick()
check(E.State=="Overcast","weather advances on authoritative server timer")
worldTime+=C.Weather.Duration+1; E:Tick()
check(E.State=="Rain","weather enters rain")
check(lighting.ClockTime>=0 and lighting.ClockTime<24,"day clock remains bounded")
local traffic=load("TrafficService")
local gameMock={World=W,State={},Environment=E,Root=function() return nil end}
traffic:Start(gameMock)
check(#traffic.Cars==24,"24 modelled traffic vehicles created")
check(traffic:Green(1) and not traffic:Green(C.Traffic.GreenSeconds+1),"traffic signals have a pedestrian interval")
traffic:Tick(1,0.1)
for _,car in traffic.Cars do check(car.Speed>=0 and car.Speed<=C.Traffic.Acceleration*.1+0.001,"traffic accelerates within configured limit") end
for step=2,100 do traffic:Tick(step*.1,.1) end
for _,car in traffic.Cars do check(car.Speed<=C.Traffic.Speed*C.Weather.Profiles.Rain.Drive+.001,"rain lowers traffic cruising cap") end
check(#W.Stations.CosmeticShop==5,"five modelled outfitters have validated purchase registers")
check(world.CardCity.Vegetation~=nil,"vegetation is grouped for streaming and sway")
check(#world.CardCity.Vegetation:GetChildren()>=35,"additional planting exists across the city")
local character=instance("Model");character.Name="WardrobeTestAvatar";character.Parent=world
for _,spec in {{"Head",v(2,1,1),v(0,5,0)},{"UpperTorso",v(2,1.6,1),v(0,3.8,0)}} do local part=instance("Part");part.Name=spec[1];part.Size=spec[2];part.CFrame=cf(spec[3]);part.Parent=character end
local accessory=instance("Accessory");accessory.Parent=character;local handle=instance("Part");handle.Name="Handle";handle.Transparency=0;handle.Parent=accessory;local attachment=instance("Attachment");attachment.Name="HatAttachment";attachment.Parent=handle
local cosmeticProfile={Cosmetics={Owned={canvas_mint=true,round_specs=true,courier_pack=true,mint_jacket=true},Equipped={Head="canvas_mint",Face="round_specs",Back="courier_pack",Outfit="mint_jacket"}}}
local cos=load("CosmeticService");cos:Init({Data={Get=function() return cosmeticProfile end}})
cos:Apply({Character=character})
check(#character.CityCosmetics:GetChildren()==4,"wardrobe builds all four actual wearable model slots")
check(handle.Transparency==1,"equipping a cap temporarily hides conflicting original headwear")
for _,part in character.CityCosmetics:GetDescendants() do if part:IsA("BasePart") then check(not part.Anchored and not part.CanCollide and part.Massless,"cosmetic model cannot alter character collision or movement") end end
cosmeticProfile.Cosmetics.Equipped.Head="";cos:Apply({Character=character})
check(handle.Transparency==0,"removing a cap restores original avatar headwear")
check(#character.CityCosmetics:GetChildren()==3,"reapplying clothes cleans up prior models")
-- Exercise the actual R15 construction path with a fixture at the external API boundary.
replicated.CreateHumanoidModelFromDescriptionAsync=function()
 local rig=instance("Model")
 for _,spec in {{"HumanoidRootPart",v(2,2,1),v(0,3,0)},{"Head",v(1.6,1.2,1),v(0,5,0)},{"UpperTorso",v(2,1.6,1),v(0,3.8,0)},{"RightHand",v(.4,.6,.4),v(1.4,3,0)},{"LeftHand",v(.4,.6,.4),v(-1.4,3,0)}} do
  local p=instance("Part");p.Name=spec[1];p.Size=spec[2];p.CFrame=cf(spec[3]);p.Parent=rig
 end
 local humanoid=instance("Humanoid");humanoid.Parent=rig
 return rig
end
N:Prepare()
check(N.AvatarTemplate~=nil,"R15 API success produces a reusable template")
local citizen=N:Actor(W.Root.Actors,"Detailed Citizen",v(0,0,25),C.Palette.Purple)
check(citizen:GetAttribute("R15Citizen"),"live citizen uses a real articulated-rig model path")
local rigPrompt=N:Prompt(citizen,"Target","rig-fixture","Scout citizen")
check(not rigPrompt.RequiresLineOfSight and rigPrompt.Parent.Position.Y>0,"R15 rigs also use an elevated prompt without self-occlusion")
check(citizen:FindFirstChild("Jacket left lapel")~=nil,"rig has modelled clothing detail")
check(citizen:FindFirstChild("CitizenPhone")~=nil,"rig has its living-city phone prop")
check(citizen:FindFirstChild("Umbrella canopy")~=nil,"rig has weather-reactive umbrella geometry")
local factory=modules.ModelFactory
local van=factory.vehicle(world,cf(0,2,100),true,C.Palette.Mint,true)
check(not van.PrimaryPart.Anchored,"player van chassis is physically unanchored")
check(van.DriverSeat~=nil and van.StashHandle~=nil,"van model has a real seat and storage interaction point")
local wheelContacts=0
for _,part in van:GetDescendants() do if part:IsA("BasePart") then
 if part.Name=="Wheel" then check(part.CanCollide,"physical wheel contacts exist");wheelContacts+=1 end
 if part~=van.PrimaryPart then check(part.Massless,"visual van parts do not destabilize vehicle mass") end
end end
check(wheelContacts==4,"player van has four physical wheel contacts")
local before=world.CardCity
W:Build()
check(before.Parent==nil,"rebuilding cleans up the old generated city")
check(#W.Targets==65 and #W.SafeZones==5,"rebuilding does not duplicate city state")
N.AvatarTemplate=nil;N:Build(W)
local roadKeys={}
local function geometryKey(x,z,w,d) return string.format("%.2f:%.2f:%.2f:%.2f",x,z,w,d) end
for _,part in W.Root:GetDescendants() do if part:IsA("BasePart") then roadKeys[geometryKey(part.Position.X,part.Position.Z,part.Size.X,part.Size.Z)]=true end end
for _,road in W.Map.Roads do check(roadKeys[geometryKey(road.X,road.Z,road.Width,road.Depth)],"map road dimensions match an actual generated part") end
check(#W.Map.Roads==35 and #W.Map.Buildings>=50,"navigation describes the generated city and its major footprints")
local markers={}
for _,marker in W.Map.Markers do check(not markers[marker.Id],"public map ids are unique");markers[marker.Id]=marker;check(marker.Kind~="Secret" and marker.Kind~="Player","map metadata does not disclose hidden entities") end
for district=1,5 do
 check(markers["hideout_"..district].Position==W.Stations.Bank[district],"workshop marker uses the actual intake position")
 check(markers["garage_"..district].Position==W.Stations.Garage[district],"garage marker uses the actual intercom position")
end
local localCitizen=N.Targets.D1N1;local farCitizen=N.Targets.D5N1
N:React(localCitizen.Model.PrimaryPart.Position,"Alert",22)
check(localCitizen.ReactUntil~=nil and farCitizen.ReactUntil==nil,"citizen reactions stay local to the event")
local oldRaycast=world.Raycast;world.Raycast=function()return {}end
local oldWaypoint=localCitizen.Waypoint;localCitizen.StuckAt=100;localCitizen.NextPath=1000
N:Step(localCitizen,localCitizen.Model.PrimaryPart.Position+v(8,0,0),120,.25,N:Parameters())
check(localCitizen.Waypoint~=oldWaypoint,"a persistently obstructed citizen tries a new route waypoint")
N.ActivePaths=0
for _,target in N.Targets do target.NextPath=0;target.Computing=false;N:Path(target,target.Route[1],200) end
check(N.ActivePaths==C.NPC.MaxPaths,"path calculations obey one shared concurrency budget")
for _,target in N.Targets do target.Computing=false end;N.ActivePaths=0;world.Raycast=oldRaycast
local fakePlayer={};N.Game={State={[fakePlayer]={}},Root=function()return {Position=v(10000,3,10000)}end}
N:Tick(1000002,.25);local last=localCitizen.LastThink
N:Tick(1000002.1,.1);check(localCitizen.LastThink==last,"distant citizens skip expensive movement updates")
N.Game.Root=function()return {Position=localCitizen.Model.PrimaryPart.Position+v(0,0,5)}end
N:Tick(1000005,.25);check(localCitizen.NextThink-1000005<=C.NPC.NearInterval+.001,"nearby citizens use the responsive update interval")
N.Game=nil
print("PASS: "..total.." city-generation assertions (mocked instances; no Roblox physics or rendering)")
