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
local CF={};CF.__index=function(t,key) return if key=="LookVector" then t.Look or vec(0,0,-1) else CF[key] end;CF.__mul=function(a,b) return setmetatable({Position=a.Position+b.Position},CF) end
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
 return setmetatable({Props={ClassName=class,Name=class,AbsoluteSize={X=1000,Y=760},ZIndex=1,CanvasPosition={X=0,Y=0},Activated=event(),Visible=true},Children={},Signals={},Attributes={}},meta)
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
function methods:SetAttribute(key,value) self.Attributes[key]=value end
function methods:GetAttribute(key) return self.Attributes[key] end
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
function methods:Destroy() for _,child in self:GetChildren() do child:Destroy() end;self.Parent=nil end
local function vector(x,y) return {X=x,Y=y} end
local function dim2(sx,ox,sy,oy) return {X={Scale=sx or 0,Offset=ox or 0},Y={Scale=sy or 0,Offset=oy or 0}} end
local player=new("Player"); local pg=new("PlayerGui"); pg.Parent=player
local avatar=new("Model");avatar.Name="Avatar";avatar.Archivable=false
local head=new("Part");head.Name="Head";head.Size=vec(2,1,1);head.CFrame=cf(0,5,0);head.Parent=avatar
local torso=new("Part");torso.Name="UpperTorso";torso.Size=vec(2,2,1);torso.CFrame=cf(0,3.5,0);torso.Parent=avatar
player.Character=avatar
local shared={Config="Config",Rules="Rules",CosmeticModels="CosmeticModels",RoundRules="RoundRules",MapRules="MapRules"}; local modules={}; local enum=setmetatable({},{__index=function(t,k) local v=setmetatable({},{__index=function(_,name) return name end}); rawset(t,k,v);return v end})
local remote={OnClientEvent=event(),Sent={}}
function remote:FireServer(action,arg) table.insert(self.Sent,{action,arg}) end
local render=event()
local world=new("Workspace"); function world:GetServerTimeNow() return 1000 end
local clock=10; local walls={}; local rayParams=nil; local focused=nil
function world:Raycast(origin,delta,params) rayParams=params; return walls[delta.X] end
local otherPlayer={Character=new("Model")}
local input={GamepadEnabled=false,InputBegan=event(),GetFocusedTextBox=function() return focused end}
local proximity={PromptShown=event(),PromptHidden=event(),PromptTriggered=event()}
local services={Players={LocalPlayer=player,GetPlayers=function() return {player,otherPlayer} end},ProximityPromptService=proximity,ReplicatedStorage={Shared=shared,FindFirstChild=function() return nil end},UserInputService=input,GuiService={},RunService={RenderStepped=render},TextService={GetTextSize=function(_,value,size,font,bounds) return {X=bounds.X,Y=math.ceil(#value*size*.55/bounds.X)*size*1.2} end}}
local env={Instance={new=new},game={GetService=function(_,name) return assert(services[name],name) end},Enum=enum,Color3={fromRGB=color,new=color},Vector3={new=vec,zero=vec()},CFrame={new=cf,Angles=function() return cf() end,lookAt=function(p) return cf(p) end},Vector2={new=vector,zero=vector(0,0)},UDim2={new=dim2,fromOffset=function(x,y) return dim2(0,x,0,y) end,fromScale=function(x,y) return dim2(x,0,y,0) end},UDim={new=function(s,o) return {Scale=s,Offset=o} end},workspace=world,RaycastParams={new=function() return {} end},os=setmetatable({clock=function() return clock end},{__index=os}),task={spawn=function() end,delay=function() end},script={Parent={UIComponents="UIComponents",TargetController="TargetController",RoundController="RoundController",MinimapController="MinimapController"}},require=function(k) return modules[k] end}
setmetatable(env,{__index=getfenv()})
local function load(name) local f=assert(loadstring(Sources[name],name));setfenv(f,env);local m=f();modules[name]=m;return m end
local C=load("Config");local R=load("Rules");load("RoundRules");load("MapRules");load("CosmeticModels");local K=load("UIComponents");local targets=load("TargetController");local rounds=load("RoundController");load("MinimapController");local U=load("UIController");local inputs=load("InputController")
local audio={Play=function() end,Update=function() end};local effects={Tween=function(_,object,props) for k,v in props do object[k]=v end end,Shake=function() end,Celebrate=function() end}
U:Init(remote,audio,effects)
local profile={RoundRecords={Best={},Medals={},Rounds=0,Daily={Day=-1,Best=0}},Exploration={Services={hideout_1=true}},Cosmetics={Owned={canvas_mint=true,round_specs=true,courier_pack=true,mint_jacket=true},Equipped={Head="canvas_mint",Face="",Back="",Outfit=""}},Cash=100000,Reputation=1000,Starter=8,StarterProgress=0,Identities=2,Upgrades={},Hideout={},Districts={},Collection={},Milestones={},Secrets={},Badges={},Stats={Successes=25,Perfects=10,BestCombo=5,Banked=6000},Settings={Music=.35,Effects=.7,ReducedMotion=false,Shake=true,WeatherEffects=true,MinimapRotate=false,MinimapZoom=2,VehicleCamera=true},Daily={Day=2000,Progress={},Claimed={}},Processing={PendingCards=4,PendingValue=150,Stage="Pressing",Value=200,Cards=5,Ends=1006,Started=992,Duration=14},Contracts={Active="mara_2",Progress={mara_2=1},Claimed={mara_1=true}},Van={Owned=true,Stash={{Id="D1R1",Variant="Foil",Quality=1.1}}}}
for name,def in C.Upgrades do profile.Upgrades[name]=math.floor(def.Max/2) end
for name in C.HideoutUpgrades do profile.Hideout[name]=2 end
for i=1,5 do profile.Districts[tostring(i)]=true end
profile.Collection['D1R1:Standard']=true
local packet={Profile=profile,Loot={{Id="D1R1",Variant="Standard",Quality=1}},Value=24,Heat=40,Chase=false,Immunity=0,Development=true,Combo=2,Gadget={Charges=2,Max=3,Cooldown=0},Weather="Rain",Clock=18.5}
U:UpdateState(packet)
local panels={"Overview","Activities","Map","Pockets","Collection","Equipment","Operations","Hideout","Van","Style Shop","Wardrobe","Districts","Quests","Settings"}
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
local timing={Phase="Action",Lane=2,Kind="Clear",Sequence={1,3,2},RecoveryLeft=1,Hint="Match lane 2",Stage=3,Stages=3,Practice=false,Approach="Bold",Pattern="Bounce",LastGrade="Good",Start=999.5,Duration=1.4,Width=.11,Drift=.1,Center=.55,Token="server-token"}
U:StartTiming(timing); render:Fire(.016)
check(U.TimingLayer.Visible,"timing overlay opens")
check(U.StopButton.Size.Y.Offset>=44,"compact timing button remains touch-friendly")
U:StopTiming()
check(remote.Sent[#remote.Sent][1]=="Stop" and remote.Sent[#remote.Sent][2].Token=="server-token" and remote.Sent[#remote.Sent][2].At==1000 and remote.Sent[#remote.Sent][2].Lane==2,"timing submits only the server token")
U:EndTiming();check(not U.TimingLayer.Visible and U.Timing==nil,"timing cleanup removes the active connection/state")
U:Receive("Reveal",{Loot={Id="D1R1",Variant="Foil",Quality=1.2},Grade="Perfect",Combo=3,Milestone=0})
check(U.Reveal.Visible,"reveal is visible")
U:SkipReveal();check(not U.Reveal.Visible,"reveal can be skipped")
U:Receive("PrestigeInfo",{Token="prestige-token"})
check(string.find(U.DialogText.Text,"queued/active processing",1,true)~=nil,"prestige dialog declares processing reset")
check(string.find(U.DialogText.Text,"van ownership",1,true)~=nil,"prestige dialog declares kept van ownership")
check(not avatar.Archivable,"avatar preview restores the original character clone setting")
check(pg:FindFirstChild("CardCityUI")==U.Gui,"one persistent HUD exists")
U:HideDialog(); U:Close()
check(targets.Find()==nil,"scouting waits for the streamed city and character root")
local root=new("Part");root.Name="HumanoidRootPart";root.CFrame=cf(0,3.5,0);root.Parent=avatar
check(targets.Find()==nil,"no target is invented before the city streams in")
local city=new("Folder");city.Name="CardCity";city.Parent=world
check(targets.Find()==nil,"scanning tolerates an actors folder still streaming in")
local actors=new("Folder");actors.Name="Actors";actors.Parent=city
local function citizen(id,x)
 local model=new("Model");model.Name="Citizen "..id;model:SetAttribute("TargetId",id);model:SetAttribute("TargetAvailable",true)
 local part=new("Part");part.CFrame=cf(x,3.5,0);part.Parent=model;model.PrimaryPart=part;model.Parent=actors;return model
end
local far=citizen("D1N2",9);local near=citizen("D1N1",6);local out=citizen("D1N3",C.InteractDistance+1)
local guard=citizen("guard",1);guard:SetAttribute("TargetId",nil)
local partial=new("Model");partial:SetAttribute("TargetId","D1N4");partial.Parent=actors
check(targets.Find()==near,"fallback finds the closest citizen even with no native prompt instance")
check(targets.Find("D1N2")==far,"native prompt requests retain the citizen they refer to")
check(targets.Find("missing")==nil,"unknown target ids do not create a request")
check(table.find(rayParams.FilterDescendantsInstances,actors)~=nil,"line of sight excludes the citizen's own body")
check(table.find(rayParams.FilterDescendantsInstances,avatar)~=nil and table.find(rayParams.FilterDescendantsInstances,otherPlayer.Character)~=nil,"line of sight excludes all player characters like the server")
near:SetAttribute("TargetAvailable",false);check(targets.Find()==far,"busy or cooling targets are skipped")
near:SetAttribute("TargetAvailable",true);walls[6]={};check(targets.Find()==far,"a closer citizen behind a wall is skipped")
walls[9]={};check(targets.Find()==nil,"fallback cannot select through walls or beyond the server range")
walls={};near.PrimaryPart.CFrame=cf(C.InteractDistance,3.5,0)
check(targets.Find("D1N1")==near,"a citizen at the server's interaction boundary is selectable")
near.PrimaryPart.CFrame=cf(6,3.5,0)
near.Parent=nil;check(targets.Find()==far,"streamed-out citizens leave no stale target reference");near.Parent=actors
root.Parent=nil;check(targets.Find()==nil,"respawn without a character root is safe");root.Parent=avatar
U:UpdateContext();check(U.ScoutButton.Visible and string.find(U.Context.Text,near.Name,1,true)~=nil,"nearby citizen has a visible named Scout action")
check(U.ScoutButton.Size.Y.Offset>=44,"Scout button is a full-size touch target")
inputs.Start(U)
local function scoutCount() local n=0;for _,request in remote.Sent do if request[1]=="Scout" then n+=1 end end;return n end
local n=scoutCount();U.ScoutButton.Activated:Fire()
check(scoutCount()==n+1 and remote.Sent[#remote.Sent][2]=="D1N1","touch Scout submits the closest real target id")
input.InputBegan:Fire({KeyCode=enum.KeyCode.E},false)
check(scoutCount()==n+1,"keyboard and touch firing together cannot duplicate a scout")
clock+=1;input.InputBegan:Fire({KeyCode=enum.KeyCode.E},false)
check(scoutCount()==n+2,"E works when no native prompt is shown")
clock+=1;input.InputBegan:Fire({KeyCode=enum.KeyCode.ButtonX},false)
check(scoutCount()==n+3,"controller X also works without a native prompt")
local prompt=new("ProximityPrompt");prompt:SetAttribute("Action","Target");prompt:SetAttribute("Id","D1N2");prompt.KeyboardKeyCode=enum.KeyCode.E;prompt.GamepadKeyCode=enum.KeyCode.ButtonX;prompt.Enabled=true;prompt.Parent=far.PrimaryPart
clock+=1;proximity.PromptShown:Fire(prompt);input.InputBegan:Fire({KeyCode=enum.KeyCode.E},false)
check(scoutCount()==n+3,"visible native prompts retain ownership of their input key")
proximity.PromptTriggered:Fire(prompt);proximity.PromptTriggered:Fire(prompt)
check(scoutCount()==n+4 and remote.Sent[#remote.Sent][2]=="D1N2","native scouting uses its actual target and shares the duplicate guard")
proximity.PromptHidden:Fire(prompt)
local shop=new("ProximityPrompt");shop:SetAttribute("Action","Shop");shop.KeyboardKeyCode=enum.KeyCode.E;shop.Enabled=true;shop.Parent=city
clock+=1;proximity.PromptShown:Fire(shop);input.InputBegan:Fire({KeyCode=enum.KeyCode.E},false);proximity.PromptTriggered:Fire(shop)
check(scoutCount()==n+4 and U.Current=="Equipment","a shop prompt opens the shop without also scouting a nearby citizen")
U:UpdateContext();check(not U.ScoutButton.Visible,"open City Desk hides the Scout button")
check(not U:RequestScout(),"open menus block scout requests")
U:Close();proximity.PromptHidden:Fire(shop)
clock+=1;input.InputBegan:Fire({KeyCode=enum.KeyCode.E},true);focused={};input.InputBegan:Fire({KeyCode=enum.KeyCode.E},false);focused=nil
check(scoutCount()==n+4,"processed input and typing cannot trigger a scout")
prompt.Parent=nil;proximity.PromptShown:Fire(prompt);input.InputBegan:Fire({KeyCode=enum.KeyCode.E},false)
check(scoutCount()==n+5,"a streamed-out native prompt cannot suppress fallback input")
clock+=1;U.Modal.Visible=true;check(not U:RequestScout(),"scout choices block extra requests");U.Modal.Visible=false
U.Timing={};check(not U:RequestScout(),"an active timing game blocks extra scouts");U.Timing=nil
packet.Vault={};U:UpdateContext();check(not U.ScoutButton.Visible and not U:RequestScout(),"vault runs suppress target scouting");packet.Vault=nil
near:SetAttribute("TargetAvailable",false);far:SetAttribute("TargetAvailable",false);U:UpdateContext()
check(not U.ScoutButton.Visible,"Scout action hides when all nearby citizens are unavailable")
local saved=U.State;U.State=nil;check(not U:RequestScout(),"no request can race profile initialization");U.State=saved
-- New map and round controls execute real production controllers, not copied logic.
U:Close();U:HideDialog();U.Gui.AbsoluteSize={X=390,Y=760}
local map=U.MapController
local mapData={Bounds={MinX=-120,MaxX=1080,MinZ=-195,MaxZ=195},Roads={{X=0,Z=0,Width=240,Depth=36,Kind="Road"}},Buildings={{X=40,Z=-46,Width=32,Depth=32}},Markers={{Id="hideout_1",Kind="Hideout",Label="Workshop",District=1,Position=vec(0,0,0)},{Id="garage_1",Kind="Garage",Label="Garage",District=1,Position=vec(40,0,0)},{Id="style_2",Kind="Style",Label="Style",District=2,Position=vec(240,0,0)}}}
profile.Exploration.Services.garage_1=true;profile.Exploration.Services.style_2=true;profile.Districts["2"]=nil
packet.Navigation={Id="citizen_far",Title="Scout a citizen",Position=vec(1000,3.5,0),Distance=1000}
U:Receive("Map",mapData);map.Small.Area.AbsoluteSize={X=172,Y=172};map:Draw()
check(map.Holder.Visible and #map.Small.Roads==1 and #map.Small.Buildings==1,"minimap draws the actual received road/footprint metadata")
check(map.Small.Goal.Text=="◇" and math.abs(map.Small.Goal.Position.X.Offset-72)<.001,"far objective remains on the correct minimap edge")
for _,record in map.Small.Markers do if record.Data.Id=="style_2" then check(not record.Icon.Visible,"minimap hides locked services") end end
profile.Settings.MinimapRotate=true;root.CFrame.Look=vec(1,0,0);map:Draw()
check(math.abs(map.Small.Roads[1].Frame.Rotation+90)<.001 and math.abs(map.Small.Player.Rotation)<.001,"rotating map keeps the player's arrow upright and rotates geometry correctly")
profile.Settings.MinimapRotate=false;root.CFrame.Look=vec(0,0,-1)
U:Open("Map");map.Full.Area.AbsoluteSize={X=334,Y=300};map:Draw()
check(map.Full.Bounds.Size.X.Offset>0 and map.Full.Bounds.Size.Y.Offset>0,"full map fits its actual world boundary")
check(not map.Holder.Visible,"menu map hides the gameplay minimap")
local pinButton=nil
for _,button in U.Body:GetDescendants() do if button:IsA("TextButton") and button.Text=="Pin destination" then pinButton=button;break end end
check(pinButton~=nil,"discovered services have accessible pin buttons even when icons group together")
pinButton.Activated:Fire();check(remote.Sent[#remote.Sent][1]=="Navigate","service pin submits an id for server validation")
U:Close();profile.Districts["2"]=true
local locked=false;U.PlayerControls={Disable=function()locked=true end,Enable=function()locked=false end}
local readPacket={Phase="Read",Approach="Practice",Stage=1,Stages=2,Sequence={1,3},Start=1000,Duration=1.7,RecoveryLeft=1,Hint="Read 1 then 3",Token="read"}
U:StartTiming(readPacket)
local sent=#remote.Sent;U:StopTiming(1)
check(#remote.Sent==sent and locked,"read preview accepts no hit and suspends character movement")
for _,size in {{X=390,Y=760},{X=844,Y=300},{X=640,Y=280}} do
 U.Gui.AbsoluteSize=size
 local action={Phase="Action",Approach="Careful",Stage=2,Stages=2,Sequence={1,3},Start=999.5,Duration=3,RecoveryLeft=1,Hint="Match lane 3",Token="lane-3",Lane=3,Kind="Switch",Pattern="Reverse",Width=.2,Center=.5,Drift=0,Tool=true}
 U:StartTiming(action)
 for _,button in U.LaneButtons do check(button.Size.Y.Offset>=44 and button.Position.Y.Offset+button.Size.Y.Offset<=U.TimingBox.Size.Y.Offset-52,"lane controls remain full-size and clear of bottom actions / "..size.Y) end
end
U.LaneButtons[3].Activated:Fire();local latest=remote.Sent[#remote.Sent];local after=#remote.Sent
input.InputBegan:Fire({KeyCode=enum.KeyCode.L},false)
check(latest[1]=="Stop" and latest[2].Lane==3 and latest[2].At==1000,"touch lane input sends its actual lane and synchronized input time")
check(#remote.Sent==after,"touch and keyboard cannot submit the same phase twice")
U:EndTiming();check(not locked,"round cleanup restores movement")
local result={Success=true,Reason="Training clear",Mode="Practice",Medal="Gold",Score=340,Best=340,NewBest=true,Stages=3,Perfects=3,Mistakes=0,Seconds=9,Practice=true,Bonus=false,Heat=0,Rep=0,Intake=0,Quality=1}
U:Receive("RoundResult",result)
check(U.ResultLayer.Visible and locked and U.ResultRetry.Visible,"practice result explains performance and offers a fast retry")
U.ResultRetry.Activated:Fire();check(not U.ResultLayer.Visible and not locked and remote.Sent[#remote.Sent][1]=="Practice","retry releases the result and requests a fresh server-owned session")
U:Receive("RoundResult",result);U:Receive("Capture",{Lost=1,Kept=1})
check(not U.ResultLayer.Visible and U.Modal.Visible and not locked,"capture clears results and movement locks before showing its own dialog")
U:HideDialog();U.Gui.AbsoluteSize={X=390,Y=760};near:SetAttribute("TargetAvailable",true);U:UpdateContext()
check(U.ScoutButton.Visible and U.MenuButton.Position.X.Offset==-70 and U.DecoyButton.Position.X.Offset==-68,"portrait actions stay in the middle away from thumbstick and jump")
U.Gui.AbsoluteSize={X=640,Y=280};U:UpdateContext();check(not U.ObjectivePanel.Visible,"compact target actions do not overlap the objective panel")
print("PASS: "..count.." UI component assertions (mocked events/layout sizes; not device or rendering tests)")
