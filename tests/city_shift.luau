--!nocheck
-- Execute real round, navigation and driving modules at mocked engine boundaries.
local assertions=0
local function check(ok,message) assert(ok,message);assertions+=1 end
local function close(a,b,message) check(math.abs(a-b)<1e-6,message) end
local now=1000;local day=22000;local ping=0;local serial=0;local modules={}
local vector={};vector.__index=function(t,k) if k=="Magnitude" then return math.sqrt(t.X*t.X+t.Y*t.Y+t.Z*t.Z) end;return vector[k] end
local function vec(x,y,z) return setmetatable({X=x,Y=y,Z=z},vector) end
vector.__sub=function(a,b)return vec(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
vector.__add=function(a,b)return vec(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
local cfMeta={};cfMeta.__index=cfMeta;cfMeta.__mul=function(a,b)return setmetatable({Position=a.Position+b.Position,UpVector=vec(0,1,0)},cfMeta)end
local function cf(x,y,z)return setmetatable({Position=vec(x,y,z),UpVector=vec(0,1,0)},cfMeta)end
local shared={Config="Config",Rules="Rules",RoundRules="RoundRules",MapRules="MapRules",VehicleRules="VehicleRules"}
local allOccupied=false;local firstOccupied=false
local world={GetServerTimeNow=function()return now end,GetPartBoundsInBox=function(_,frame) return if allOccupied or (firstOccupied and frame.Position.Z==0) then {{CanCollide=true}} else {} end}
local enum=setmetatable({},{__index=function()return setmetatable({},{__index=function(_,key)return key end})end})
local services={ReplicatedStorage={Shared=shared},Players={GetPlayers=function()return {}end},HttpService={GenerateGUID=function()serial+=1;return "round-"..serial end}}
local env={game={GetService=function(_,key)return assert(services[key],key)end},script={Parent={ModelFactory="ModelFactory"}},Enum=enum,Vector3={new=vec,zero=vec(0,0,0)},CFrame={new=cf},OverlapParams={new=function()return {}end},workspace=world,Color3={fromRGB=function(...)return {...}end},os={clock=function()return now end,time=function()return day*86400 end},Random={new=function()return {NextInteger=function()serial+=1;return 157+serial*17 end}end},require=function(key)return modules[key]end}
setmetatable(env,{__index=getfenv()})
local function load(name)local fn=assert(loadstring(Sources[name],name));setfenv(fn,env);local result=fn();modules[name]=result;return result end
local C=load("Config");local R=load("Rules");local Q=load("RoundRules");local M=load("MapRules");local Driving=load("VehicleRules");local T=load("InteractionService");local Nav=load("NavigationService");local Vault=load("VaultService");modules.ModelFactory={};local Vehicles=load("VehicleService")
local patterns=0
for district=1,5 do for _,mode in {"Careful","Bold","Practice","DailyDrill"} do for seed=1,60 do
 local plan=Q.plan(district,"VIP",mode,seed*673,{Focus=8,Sleight=8},C,false);local last=0
 for _,phase in plan.Phases do
  check(phase.Lane>=1 and phase.Lane<=3 and phase.Lane~=last,"generated route changes valid lanes");last=phase.Lane
  local attainable=false
  for sample=1,500 do if Q.grade(phase.Duration*sample/501,phase.Lane,phase)=="Perfect" then attainable=true;break end end
  check(attainable,"every generated phase has an attainable perfect interval")
  check(phase.Width>=.12 and phase.Width<=.34 and phase.Duration>=2.4,"gear leaves bounded precision and a fair response time")
 end
 patterns+=1
end end end
check(Q.plan(1,"Daydreamer","Careful",5,{},C,true).Phases[1].Lane==2,"intro teaches the middle lane first")
check(Q.plan(4,"VIP","Bold",5,{},C,false).Phases[2].Memory,"later high-stakes rounds add memory pressure")
check(not Q.plan(1,"Daydreamer","Careful",5,{},C,false).Phases[2].Memory,"beginner rounds keep their cues visible")
local p={UserId=1,Parent=true,GetNetworkPing=function()return ping end};local other={UserId=2,Parent=true,GetNetworkPing=function()return 0 end}
local profile;local s;local root={Position=vec(0,3,0),CFrame=cf(0,3,0)};local hasRoot=true;local visible=true;local nearPractice=true;local nearGarage=true
local target={Id="D1N1",District=1,Style="Commuter",Available=0,Reserved=nil,Suspicion=0,Prompt={Enabled=true},Model={Name="Pip",PrimaryPart={Position=vec(0,3,0)},SetAttribute=function()end}}
local G={State={},NPC={Targets={D1N1=target},Guards={},Folder={},React=function()end},Remote={Events={}},Data={},Inventory={},World={VanSpawns={[1]=cf(0,2,0)},DistrictAt=function()return 1 end}}
function G.Remote:FireClient(player,kind,packet)table.insert(self.Events,{Kind=kind,Packet=packet})end
function G.Data:Get(player)return if player==p or player==other then profile else nil end
function G:Root()return if hasRoot then root else nil end
function G:Notify(_,message)self.LastNotice=message end
function G:NearStation(_,kind)return if kind=="Practice" then nearPractice else nearGarage end
function G:Heat(_,amount)s.Heat+=amount end
function G:Event(_,kind,amount)self.Events=self.Events or {};self.Events[kind]=(self.Events[kind] or 0)+amount end
function G:Snapshot()end
G.Security={Visible=function()return visible end}
G.Inventory.roll=function()return {Id="D1R1",Variant="Standard"}end
G.Inventory.discover=function()return 0 end
G.Inventory.value=function(_,loot)return math.floor(24*(loot[1].Quality or 1))end
local function fresh()
 now+=100;ping=0;hasRoot=true;visible=true;nearPractice=true;nearGarage=true;root.Position=vec(0,3,0);allOccupied=false;firstOccupied=false
 profile={Starter=8,Cash=100,Reputation=30,Upgrades={Focus=1,Sleight=1,Capacity=0,Composure=0,Gadgets=1,Appraisal=0,Engine=0,VanSlots=0},Districts={["1"]=true},Stats={Attempts=0,Successes=0,Perfects=0,BestCombo=0},RoundRecords={Best={},Medals={},Rounds=0,Daily={Day=-1,Best=0}},Exploration={Services={hideout_1=true}},Contracts={Active="",Progress={},Claimed={}},Processing={PendingCards=0,Stage="Idle"},Van={Owned=true,Stash={}}}
 s={Loot={},Heat=0,Combo=0,GadgetCharges=2,VanReady=0};G.State={[p]=s,[other]={Loot={},Heat=0}};G.Remote.Events={};G.Events={};G.LastNotice=nil
 target.Reserved=nil;target.Available=0;target.Suspicion=0;Vehicles.Vehicles={}
 T:Init(G);Nav:Init(G);Vault:Init(G);Vehicles.Game=G
end
local function result()for i=#G.Remote.Events,1,-1 do if G.Remote.Events[i].Kind=="RoundResult" then return G.Remote.Events[i].Packet end end end
local function read()local a=s.Attempt;now=a.Start+a.Duration;T:Tick(p)end
local function hit()
 local a=s.Attempt;local elapsed
 for sample=1,999 do local e=a.Duration*sample/1000;if Q.grade(e,a.Active.Lane,a.Active)=="Perfect" then elapsed=e;break end end
 assert(elapsed,"fixture must be solvable");local at=a.Start+elapsed;now=at+ping
 local packet={Token=a.Token,Lane=a.Active.Lane,At=at};T:Resolve(p,packet);return packet
end
local function primary()
 local limit=0
 while s.Attempt and s.Attempt.Phase~="Decision" do limit+=1;assert(limit<15,"round progression bounded");if s.Attempt.Phase=="Read" then read()else hit()end end
end
local function secure()T:Choice(p,{Token=s.Attempt.Token,Choice="Secure"})end
fresh();T:Begin(p,"D1N1","Careful");local original=s.Attempt
check(original.Phase=="Read" and #s.Loot==0,"round begins with a readable preview and no payout")
T:Begin(p,"D1N1","Bold");T:Begin(other,"D1N1","Careful");check(s.Attempt==original and not G.State[other].Attempt,"repeated/multiplayer starts cannot duplicate a reserved session")
read();local token=s.Attempt.Token;local start=s.Attempt.Start
T:Resolve(p,{Token=token,Lane=2,At=start-1});T:Resolve(p,{Token=token,Lane=2,At=start+5});T:Resolve(p,{Token=token,Lane=0/0,At=now})
check(s.Attempt.Token==token,"early, future and nonfinite input cannot advance a session")
local old=hit();local nextToken=s.Attempt.Token;T:Resolve(p,old);check(s.Attempt.Token==nextToken and #s.Loot==0,"consumed phase tokens cannot advance twice or give partial loot")
primary();check(#s.Loot==0 and s.Attempt.Phase=="Decision","full route discloses a secure-versus-bonus decision before payout")
local decision=s.Attempt.Token;secure();check(#s.Loot==1 and result().Success,"secure awards one card after a full route")
T:Choice(p,{Token=decision,Choice="Secure"});T:Finish(p,true,"replay");check(#s.Loot==1 and profile.Stats.Successes==1,"replayed choices and finalization cannot pay twice")
check(result().Medal=="Gold" and result().NewBest and profile.RoundRecords.Best["Careful:D1"]>0,"perfect clears produce medals and saved personal bests")
fresh();T:Begin(p,"D1N1","Bold");primary();T:Choice(p,{Token=s.Attempt.Token,Choice="Bonus"});check(s.Attempt.Phase=="Bonus","bonus is a distinct optional phase");hit()
close(s.Loot[1].Quality,1.2*C.TargetStyles.Commuter.Value*1.15,"bonus adds only the disclosed quality multiplier")
check(result().Medal=="Platinum","all-perfect bonus route can earn platinum")
fresh();T:Begin(p,"D1N1","Careful");primary();T:Choice(p,{Token=s.Attempt.Token,Choice="Bonus"});now=s.Attempt.Start+s.Attempt.Duration+.6;T:Tick(p)
check(#s.Loot==1 and result().Success and result().Mistakes==1,"bonus failure keeps exactly one card and records its cost")
close(s.Loot[1].Quality,C.TargetStyles.Commuter.Value*.75,"bonus failure applies the disclosed 75% quality")
fresh();T:Begin(p,"D1N1","Careful");read();local a=s.Attempt;now=a.Start+a.Duration*.5;T:Resolve(p,{Token=a.Token,Lane=a.Active.Lane%3+1,At=now})
check(s.Attempt.Phase=="Recovery" and s.Attempt.Recoveries==1,"first wrong lane offers one readable stabilize phase")
hit();primary();secure();close(s.Loot[1].Quality,C.TargetStyles.Commuter.Value*.8,"recovery preserves a reduced-quality card")
check(result().Medal=="Bronze","recovered routes cannot claim a flawless medal")
fresh();T:Begin(p,"D1N1","Careful");read();now=s.Attempt.Start+s.Attempt.Duration+.6;T:Tick(p);now=s.Attempt.Start+s.Attempt.Duration+.6;T:Tick(p)
check(not s.Attempt and #s.Loot==0 and not result().Success,"failed recovery ends the route with no loot")
fresh();T:Begin(p,"D1N1","Careful");read();now=s.Attempt.Start;local tool=s.Attempt.Token;T:Tool(p,tool);T:Tool(p,tool)
check(s.GadgetCharges==1 and s.Attempt.ToolUsed,"one server-owned decoy charge can stabilize once per round")
primary();secure();check(result().Mistakes==1 and result().Quality<1,"a tool has a disclosed quality and medal cost")
fresh();T:Begin(p,"D1N1","Careful");read();now=s.Attempt.Start+s.Attempt.Duration+.01;T:Tool(p,s.Attempt.Token);check(s.GadgetCharges==2,"a tool cannot revive an expired phase")
fresh();ping=.2;T:Begin(p,"D1N1","Careful");read();hit();check(s.Attempt.Stage==2,"bounded input timestamps preserve valid hits at 200ms latency")
local a2=s.Attempt;local at=a2.Start+a2.Duration*.5;now=at+2;T:Resolve(p,{Token=a2.Token,Lane=a2.Active.Lane,At=at});check(s.Attempt.Token==a2.Token,"excessive backdating cannot manufacture a hit")
fresh();T:Begin(p,"D1N1","Careful");primary();now=s.Attempt.Start+s.Attempt.Duration+.1;T:Choice(p,{Token=s.Attempt.Token,Choice="Bonus"});check(not s.Attempt and #s.Loot==1 and not result().Bonus,"expired bonus choices fall back to secure")
fresh();T:Begin(p,"D1N1","Careful");visible=false;T:Tick(p);check(not s.Attempt and not target.Reserved and #s.Loot==0,"a new obstruction cancels and releases the session")
fresh();T:Begin(p,"D1N1","Careful");hasRoot=false;T:Tick(p);check(not s.Attempt and not target.Reserved,"missing/dead character cleanup releases the citizen")
fresh();T:Practice(p,"Practice");primary();check(not s.Attempt and #s.Loot==0 and s.Heat==0 and profile.Cash==100,"practice records performance without changing cash, loot or Heat")
T:Practice(p,"Practice");check(s.Attempt~=nil,"practice supports an immediate fresh retry");T:Cancel(p)
nearPractice=false;T:Practice(p,"DailyDrill");check(not s.Attempt,"training remains tied to a real console")
fresh();T:Practice(p,"DailyDrill");local dailyPlan=s.Attempt.Plan;T:Cancel(p);profile.Upgrades.Focus=8;profile.Upgrades.Sleight=8;T:Practice(p,"DailyDrill")
for i,phase in dailyPlan.Phases do local repeatPhase=s.Attempt.Plan.Phases[i];check(phase.Lane==repeatPhase.Lane and phase.Width==repeatPhase.Width and phase.Duration==repeatPhase.Duration,"daily route and fixed gear are repeatable")end
primary();check(profile.RoundRecords.Daily.Day==day and profile.RoundRecords.Daily.Best>0,"daily drill saves a date-scoped best")
for _,bearing in {0,math.pi/2,math.pi,-math.pi/2,.73} do for _,position in {vec(-120,0,-195),vec(1080,0,195),vec(74,0,-22)} do
 local x,y=M.project(position,vec(45,0,-5),bearing,2.2);local wx,wz=M.unproject(x,y,vec(45,0,-5),bearing,2.2);close(wx,position.X,"map projection roundtrip x");close(wz,position.Z,"map projection roundtrip z")
end end
local x,y=M.project(vec(10,0,0),vec(0,0,0),math.pi/2,1);close(x,0,"east-facing map keeps forward centered");close(y,-10,"east-facing map puts forward above player")
local ex,ey,edge=M.clip(100,50,50,10);check(edge and ex==40 and ey==20,"off-map objectives clamp to the correct edge bearing")
fresh();G.World.Map={Markers={{Id="hideout_1",Kind="Hideout",Label="Workshop",Position=vec(0,3,0),District=1},{Id="garage_1",Kind="Garage",Label="Garage",Position=vec(40,3,0),District=1},{Id="style_2",Kind="Style",Label="Style",Position=vec(200,3,0),District=2},{Id="contact_Mara",Kind="Contact",Label="Mara",Position=vec(70,3,0),District=1},{Id="rinse_1",Kind="Rinse",Label="Rinse",Position=vec(0,3,0),District=1}}}
check(not M.visible(G.World.Map.Markers[3],profile,{Id="style_2"}),"locked services stay hidden even from a forged client goal")
Nav:Pin(p,"garage_1");check(not s.NavPin,"unknown services cannot be pinned by guessing ids")
root.Position=vec(40,3,0);Nav:Discover(p,now);root.Position=vec(0,3,0);Nav:Pin(p,"garage_1");check(Nav:Resolve(p).Id=="garage_1","discovered services create actual destination pins")
root.Position=vec(40,3,0);Nav:Resolve(p);check(not s.NavPin,"arrival clears the obsolete navigation pin")
root.Position=vec(0,3,0);profile.Contracts.Active="mara_1";profile.Contracts.Progress.mara_1=3
check(Nav:Resolve(p).Id=="contact_Mara","finished contracts navigate back to their giver")
profile.Contracts.Active="";profile.Starter=2;profile.Processing.Stage="Pressed";check(Nav:Resolve(p).Id=="rinse_1","processing objectives navigate to the next actual machine")
local speed,yaw,angle=Driving.step(0,1,0,18,.1,C);close(speed,.8,"van accelerates gradually")
speed=Driving.step(10,-1,0,18,.1,C);check(speed>0 and speed<10,"reverse input brakes before changing direction")
speed=0;for _=1,100 do speed=Driving.step(speed,-1,0,18,.1,C)end;close(speed,-7.2,"reverse speed is bounded separately")
local _,forwardYaw=Driving.step(8,1,1,18,0,C);local _,reverseYaw=Driving.step(-8,-1,1,18,0,C);check(forwardYaw>0 and reverseYaw<0,"steering reverses predictably while backing up")
local _,_,lowAngle=Driving.step(3,1,1,18,0,C);local _,_,highAngle=Driving.step(18,1,1,18,0,C);check(highAngle<lowAngle,"wheel angle reduces at speed")
fresh();firstOccupied=true;check(Vehicles:SpawnPoint(1,nil).Position.Z==20,"occupied garage bay selects a separate clear spawn")
allOccupied=true;check(Vehicles:SpawnPoint(1,nil)==nil,"full garage rejects spawning inside another object")
local previous={Model={},Seat={Occupant=nil}};Vehicles.Vehicles[p]=previous;Vehicles:Act(p,"Summon");check(Vehicles.Vehicles[p]==previous,"failed respawn preserves the player's existing van")
fresh();s.Vault={Slot=1,Folder={Destroy=function()end},Return=cf(0,3,0),Began=now-20,Stage=5};Vault.Slots[1]=p
Vault:Finish(p,true);local cash=profile.Cash;Vault:Finish(p,true)
check(cash==100+C.Vault.Reward and profile.Cash==cash,"vault completion uses a one-time payout")
check(result().Mode=="Vault" and result().Cash==C.Vault.Reward and profile.RoundRecords.Best["Vault:D1"]>0,"vault shares the result and personal-best system")
print("PASS: "..assertions.." City Shift assertions / "..patterns.." generated round cases (mocked engine boundaries)")
