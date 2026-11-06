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
V.__mul=function(a,b) return v(a.X*b,a.Y*b,a.Z*b) end
local CF={}
CF.__mul=function(a,b) return setmetatable({Position=a.Position+b.Position},CF) end
local function cf(x,y,z) return setmetatable({Position=if type(x)=="table" then x else v(x,y,z)},CF) end
local Color={}
Color.__index=Color
function Color:Lerp(other,t) return setmetatable({R=self.R+(other.R-self.R)*t,G=self.G+(other.G-self.G)*t,B=self.B+(other.B-self.B)*t},Color) end
local function color(r,g,b) return setmetatable({R=r,G=g,B=b},Color) end
local methods={}
local meta={}
meta.__index=function(t,key)
 if methods[key] then return methods[key] end
 if key=="Position" then return t.Properties.CFrame and t.Properties.CFrame.Position or v() end
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
function methods:Destroy() self.Parent=nil end
function methods:PivotTo(value)
 local origin=self.PrimaryPart.CFrame.Position
 for _,child in self:GetDescendants() do if child.ClassName=="Part" then child.CFrame=cf(child.Position-origin+value.Position) end end
end
local enum=setmetatable({},{__index=function(t,k) local group=setmetatable({},{__index=function(_,key) return key end}); rawset(t,k,group); return group end})
local world=instance("Workspace")
local shared={Config="Config"}; local modules={}
local env={
 Vector3={new=v},Vector2={new=function(x,y) return {X=x,Y=y} end},
 Color3={fromRGB=color},Enum=enum,Instance={new=instance},
 CFrame={new=cf,Angles=function() return cf() end,lookAt=function(pos) return cf(pos) end},
 UDim2={fromScale=function(x,y) return {x,y} end,fromOffset=function(x,y) return {x,y} end},UDim={new=function(x,y) return {x,y} end},
 workspace=world,game={GetService=function() return {Shared=shared} end},require=function(key) return modules[key] end,
}
setmetatable(env,{__index=getfenv()})
local function load(name)
 local fn=assert(loadstring(Sources[name],name)); setfenv(fn,env); local module=fn(); modules[name]=module; return module
end
local C=load("Config"); local W=load("WorldService"); local N=load("NPCService")
W:Build(); N:Build(W)
check(#W.Centers==5,"five connected districts built")
check(#W.Targets==45,"45 NPC spawn routes exist")
check(#W.Guards==15,"15 guard spawns exist")
check(#N.Guards==15,"guard models created")
local targets=0; for _ in N.Targets do targets+=1 end
check(targets==45,"target models created without runtime indexing errors")
local secretCount=0; for _ in W.Secrets do secretCount+=1 end
check(secretCount==15,"all city secrets are placed")
for district=1,5 do
 local cp=W.Checkpoints[district].Position
 check(W:InsideSafe(cp),"checkpoint inside safe room "..district)
 check(W:DistrictAt(cp)==district,"checkpoint belongs to correct district "..district)
 for _,kind in {"Bank","Shop","Resupply","Practice","Hideout","Missions","Index"} do
  check(W.Stations[kind][district]~=nil,"station exists: "..kind.." / "..district)
  check(W.StationParts[kind][district].Parent~=nil,"station has live interaction geometry")
  check(W:InsideSafe(W.Stations[kind][district]),"station inside safe room")
 end
 -- Every hallway is entered through a 14-stud clear door.
 local room=world.CardCity:FindFirstChild(if district==1 then "CRUMB CLUB / Starter Hideout" else "CRUMB CLUB / Satellite "..district)
 check(room~=nil,"clubhouse model exists")
 for _,p in room:GetChildren() do
  if p.Name=="Front brick wall" then check(math.abs(p.Position.X-cp.X)-p.Size.X/2>=7,"front wall leaves entrance clear") end
 end
end
for _,target in W.Targets do
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
check(cafeSeats>=20,"cafes and food court contain actual seating")
N:Tick(10,0.25)
check(true,"NPC status and route update executes")
local before=world.CardCity
W:Build()
check(before.Parent==nil,"rebuilding cleans up the old generated city")
check(#W.Targets==45 and #W.SafeZones==5,"rebuilding does not duplicate city state")
print("PASS: "..total.." city-generation assertions (mocked instances; no Roblox physics or rendering)")
