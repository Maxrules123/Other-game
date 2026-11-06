--!nocheck
-- Execute every production UI panel under lightweight UI/event mocks. No rendering claims.
local count=0
local function check(ok,message) assert(ok,message); count+=1 end
local function event()
 local e={Callbacks={}}
 function e:Connect(fn) local c={Active=true}; function c:Disconnect() self.Active=false end; table.insert(self.Callbacks,{Connection=c,Fn=fn}); return c end
 function e:Fire(...) for _,v in self.Callbacks do if v.Connection.Active then v.Fn(...) end end end
 return e
end
local V={}
V.__index=function(t,k) if k=="Magnitude" then return math.sqrt(t.X*t.X+t.Y*t.Y+t.Z*t.Z) elseif k=="Unit" then local length=math.sqrt(t.X*t.X+t.Y*t.Y+t.Z*t.Z);return setmetatable({X=t.X/length,Y=t.Y/length,Z=t.Z/length},V) end;return V[k] end
local function vec(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},V) end
V.__add=function(a,b) return vec(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
V.__sub=function(a,b) return vec(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
V.__mul=function(a,b) return vec(a.X*b,a.Y*b,a.Z*b) end
local CF={};CF.__mul=function(a,b) return setmetatable({Position=a.Position+b.Position},CF) end
local function cf(x,y,z) return setmetatable({Position=if type(x)=="table" then x else vec(x,y,z)},CF) end
local Color={};Color.__index=Color
function Color:Lerp(other,t) return setmetatable({R=self.R+(other.R-self.R)*t,G=self.G+(other.G-self.G)*t,B=self.B+(other.B-self.B)*t},Color) end
local function color(r,g,b) return setmetatable({R=r,G=g,B=b},Color) end
local methods={}; local meta={}
local guiClasses={Frame=true,TextLabel=true,TextButton=true,ScrollingFrame=true}
meta.__index=function(t,k)
 if methods[k] then return methods[k] end
 if k=="Position" and t.Props.CFrame then return t.Props.CFrame.Position end
 if t.Props[k]~=nil then return t.Props[k] end
 for _,c in t.Children do if c.Name==k then return c end end
 return nil
end
meta.__newindex=function(t,k,v)
 if k=="Parent" then
  local old=t.Props.Parent; if old then local i=table.find(old.Children,t); if i then table.remove(old.Children,i) end end
  if v then table.insert(v.Children,t) end
 end
 t.Props[k]=v
 if t.Signals[k] then t.Signals[k]:Fire() end
end
local function new(class)
 return setmetatable({Props={ClassName=class,Name=class,AbsoluteSize={X=1000,Y=760},ZIndex=1,CanvasPosition={X=0,Y=0},Activated=event(),Visible=true},Children={},Signals={}},meta)
end
function methods:IsA(class) return self.ClassName==class or (class=="GuiObject" and guiClasses[self.ClassName]) or (class=="BasePart" and self.ClassName=="Part") end
function methods:GetChildren() return table.clone(self.Children) end
function methods:GetDescendants() local out={}; for _,child in self.Children do table.insert(out,child); for _,d in child:GetDescendants() do table.insert(out,d) end end; return out end
function methods:FindFirstChild(name) for _,c in self.Children do if c.Name==name then return c end end; return nil end
function methods:WaitForChild(name) return assert(self:FindFirstChild(name),name) end
function methods:FindFirstChildOfClass(class) for _,c in self.Children do if c:IsA(class) then return c end end; return nil end
function methods:FindFirstChildWhichIsA(class,recursive) for _,c in self.Children do if c:IsA(class) then return c end; if recursive then local item=c:FindFirstChildWhichIsA(class,true); if item then return item end end end; return nil end
function methods:IsDescendantOf(parent) local p=self.Parent; while p do if p==parent then return true end; p=p.Parent end; return false end
function methods:GetPropertyChangedSignal(key) self.Signals[key]=self.Signals[key] or event(); return self.Signals[key] end
function methods:GetBoundingBox()
 local lo=vec(math.huge,math.huge,math.huge);local hi=vec(-math.huge,-math.huge,-math.huge)
 for _,p in self:GetDescendants() do if p:IsA("BasePart") then local a=p.Position-p.Size*.5;local b=p.Position+p.Size*.5;lo=vec(math.min(lo.X,a.X),math.min(lo.Y,a.Y),math.min(lo.Z,a.Z));hi=vec(math.max(hi.X,b.X),math.max(hi.Y,b.Y),math.max(hi.Z,b.Z)) end end
 return cf((lo+hi)*.5),hi-lo
end
function methods:Clone()
 local copy=new(self.ClassName)
 for key,value in self.Props do if key~="Parent" then copy[key]=value end end
 for _,child in self.Children do local cloned=child:Clone();cloned.Parent=copy end
 return copy
end
function methods:Destroy() self.Parent=nil end
local function vector(x,y) return {X=x,Y=y} end
local function dim2(sx,ox,sy,oy) return {X={Scale=sx or 0,Offset=ox or 0},Y={Scale=sy or 0,Offset=oy or 0}} end
local player=new("Player"); local pg=new("PlayerGui"); pg.Parent=player
local avatar=new("Model");avatar.Name="Avatar";avatar.Archivable=false
local head=new("Part");head.Name="Head";head.Size=vec(2,1,1);head.CFrame=cf(0,5,0);head.Parent=avatar
local torso=new("Part");torso.Name="UpperTorso";torso.Size=vec(2,2,1);torso.CFrame=cf(0,3.5,0);torso.Parent=avatar
player.Character=avatar
local shared={Config="Config",Rules="Rules",CosmeticModels="CosmeticModels"}; local modules={}; local enum=setmetatable({},{__index=function(t,k) local v=setmetatable({},{__index=function(_,name) return name end}); rawset(t,k,v);return v end})
local remote={OnClientEvent=event(),Sent={}}
function remote:FireServer(action,arg) table.insert(self.Sent,{action,arg}) end
local render=event()
local services={Players={LocalPlayer=player},ReplicatedStorage={Shared=shared,FindFirstChild=function() return nil end},UserInputService={GamepadEnabled=false},GuiService={},RunService={RenderStepped=render},TextService={GetTextSize=function(_,value,size,font,bounds) return {X=bounds.X,Y=math.ceil(#value*size*.55/bounds.X)*size*1.2} end}}
local env={Instance={new=new},game={GetService=function(_,name) return assert(services[name],name) end},Enum=enum,Color3={fromRGB=color,new=color},Vector3={new=vec,zero=vec()},CFrame={new=cf,Angles=function() return cf() end,lookAt=function(p) return cf(p) end},Vector2={new=vector,zero=vector(0,0)},UDim2={new=dim2,fromOffset=function(x,y) return dim2(0,x,0,y) end,fromScale=function(x,y) return dim2(x,0,y,0) end},UDim={new=function(s,o) return {Scale=s,Offset=o} end},workspace={GetServerTimeNow=function() return 1000 end},task={spawn=function() end,delay=function() end},script={Parent={UIComponents="UIComponents"}},require=function(k) return modules[k] end}
setmetatable(env,{__index=getfenv()})
local function load(name) local f=assert(loadstring(Sources[name],name));setfenv(f,env);local m=f();modules[name]=m;return m end
local C=load("Config");local R=load("Rules");load("CosmeticModels");local K=load("UIComponents");local U=load("UIController")
local audio={Play=function() end,Update=function() end};local effects={Tween=function(_,object,props) for k,v in props do object[k]=v end end,Shake=function() end,Celebrate=function() end}
U:Init(remote,audio,effects)
local profile={Cosmetics={Owned={canvas_mint=true,round_specs=true,courier_pack=true,mint_jacket=true},Equipped={Head="canvas_mint",Face="",Back="",Outfit=""}},Cash=100000,Reputation=1000,Starter=8,StarterProgress=0,Identities=2,Upgrades={},Hideout={},Districts={},Collection={},Milestones={},Secrets={},Badges={},Stats={Successes=25,Perfects=10,BestCombo=5,Banked=6000},Settings={Music=.35,Effects=.7,ReducedMotion=false,Shake=true,WeatherEffects=true},Daily={Day=2000,Progress={},Claimed={}},Processing={PendingCards=4,PendingValue=150,Stage="Pressing",Value=200,Cards=5,Ends=1006,Started=992,Duration=14},Contracts={Active="mara_2",Progress={mara_2=1},Claimed={mara_1=true}},Van={Owned=true,Stash={{Id="D1R1",Variant="Foil",Quality=1.1}}}}
for name,def in C.Upgrades do profile.Upgrades[name]=math.floor(def.Max/2) end
for name in C.HideoutUpgrades do profile.Hideout[name]=2 end
for i=1,5 do profile.Districts[tostring(i)]=true end
profile.Collection['D1R1:Standard']=true
local packet={Profile=profile,Loot={{Id="D1R1",Variant="Standard",Quality=1}},Value=24,Heat=40,Chase=false,Immunity=0,Development=true,Combo=2,Gadget={Charges=2,Max=3,Cooldown=0},Weather="Rain",Clock=18.5}
U:UpdateState(packet)
local panels={"Overview","Pockets","Collection","Equipment","Operations","Hideout","Van","Style Shop","Wardrobe","Districts","Quests","Settings"}
for _,size in {{X=1200,Y=800},{X=390,Y=760},{X=844,Y=300}} do
 U.Gui.AbsoluteSize=size
 for _,name in panels do
  U:Open(name)
  check(U.Menu.Visible and U.Current==name,"panel opens at "..size.X.."px / "..name)
  check(#U.Body:GetChildren()>2,"panel has actual content / "..name)
  for _,child in U.Body:GetDescendants() do if child:IsA("TextButton") then check(child.Size.Y.Offset>=44,"action has 44px touch height / "..name) end end
  U:Close();check(not U.Menu.Visible,"panel closes intentionally / "..name)
 end
 check(U.DialogScale.Scale==1 and U.TimingScale.Scale==1,"landscape never shrinks interactive targets")
end
U:Open("Upgrades");check(U.Current=="Equipment","old equipment prompt maps to new page")
U:Open("Index");check(U.Current=="Collection","old index prompt maps to new page")
U:Open("Missions");check(U.Current=="Quests","mission prompt maps to journal")
U:Receive("Scout",{Style="VIP",Name="Lady Raccoon",District=4,Stages=3,Suspicion=20,Requirement=4,Id="D4N6"})
check(U.Modal.Visible,"scouting creates an intentional choice dialog")
check(U.DialogCancel.Text=="Bold +20%","scouting offers the riskier approach")
U:ConfirmDialog()
check(remote.Sent[#remote.Sent][1]=="Begin" and remote.Sent[#remote.Sent][2].Approach=="Careful","careful choice sends an approach, never a reward")
local timing={Stage=3,Stages=3,Practice=false,Approach="Bold",Pattern="Bounce",LastGrade="Good",Start=999.5,Duration=1.4,Width=.11,Drift=.1,Center=.55,Token="server-token"}
U:StartTiming(timing); render:Fire(.016)
check(U.TimingLayer.Visible,"timing overlay opens")
check(U.StopButton.Size.Y.Offset>=44,"compact timing button remains touch-friendly")
U:StopTiming()
check(remote.Sent[#remote.Sent][1]=="Stop" and remote.Sent[#remote.Sent][2]=="server-token","timing submits only the server token")
U:EndTiming();check(not U.TimingLayer.Visible and U.Timing==nil,"timing cleanup removes the active connection/state")
U:Receive("Reveal",{Loot={Id="D1R1",Variant="Foil",Quality=1.2},Grade="Perfect",Combo=3,Milestone=0})
check(U.Reveal.Visible,"reveal is visible")
U:SkipReveal();check(not U.Reveal.Visible,"reveal can be skipped")
U:Receive("PrestigeInfo",{Token="prestige-token"})
check(string.find(U.DialogText.Text,"queued/active processing",1,true)~=nil,"prestige dialog declares processing reset")
check(string.find(U.DialogText.Text,"van ownership",1,true)~=nil,"prestige dialog declares kept van ownership")
check(not avatar.Archivable,"avatar preview restores the original character clone setting")
check(pg:FindFirstChild("CardCityUI")==U.Gui,"one persistent HUD exists")
print("PASS: "..count.." UI component assertions (mocked events/layout sizes; not device or rendering tests)")
