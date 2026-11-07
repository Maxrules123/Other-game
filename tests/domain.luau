--!nocheck
-- check.py prepends the unmodified production modules to Sources.
local passed=0
local function check(condition, message)
 assert(condition,message); passed+=1
end
local function clone(value)
 if type(value)~="table" then return value end
 local c={}; for k,v in value do c[k]=clone(v) end; return c
end
local function equal(a,b,message) check(a==b,message.." ("..tostring(a).." vs "..tostring(b)..")") end
local Vector={}
Vector.__index=function(t,k)
 if k=="Magnitude" then return math.sqrt(t.X*t.X+t.Y*t.Y+t.Z*t.Z) end
 return Vector[k]
end
Vector.__sub=function(a,b) return setmetatable({X=a.X-b.X,Y=a.Y-b.Y,Z=a.Z-b.Z},Vector) end
Vector.__add=function(a,b) return setmetatable({X=a.X+b.X,Y=a.Y+b.Y,Z=a.Z+b.Z},Vector) end
local function vec(x,y,z) return setmetatable({X=x,Y=y,Z=z},Vector) end
local id=0
local shared={Config="Config",Rules="Rules",CosmeticModels="CosmeticModels",RoundRules="RoundRules",VehicleRules="VehicleRules",MapRules="MapRules"}
local Modules={}
local now=1000
local time=1000000
local records={}
local failStore=false
local store={}
function store:UpdateAsync(key,callback)
 if failStore then error("simulated storage outage") end
 local result=callback(clone(records[key]))
 if result~=nil then records[key]=clone(result) end
 return clone(result)
end
local services={
 ReplicatedStorage={Shared=shared,WaitForChild=function() return shared end},
 HttpService={GenerateGUID=function() id+=1; return "token"..id end},
 RunService={IsStudio=function() return false end},
 DataStoreService={GetDataStore=function() return store end},
 Players={}, PathfindingService={},
}
local env={
 Color3={fromRGB=function(r,g,b) return {r,g,b} end},
 Vector3={new=vec},
 Random={new=function() return {NextNumber=function(_,lo,hi) return lo+(hi-lo)*0.5 end,NextInteger=function(_,lo,hi) return math.floor((lo+hi)/2) end} end},
 game={GetService=function(_,name) return services[name] end},
 script={Parent={PlayerDataService="PlayerDataService",WorldService="WorldService",NPCService="NPCService",InventoryService="InventoryService",MissionService="MissionService",SecurityService="SecurityService",VaultService="VaultService",InteractionService="InteractionService",ProcessingService="ProcessingService",VehicleService="VehicleService",ModelFactory="ModelFactory",EnvironmentService="EnvironmentService",TrafficService="TrafficService",CosmeticService="CosmeticService",NavigationService="NavigationService"}},
 workspace={GetServerTimeNow=function() return now end},
 task={wait=function() end},
 os={time=function() return time end,clock=function() return now end},
 require=function(key) return Modules[key] end,
}
setmetatable(env,{__index=getfenv()})
local function load(name)
 local fn=assert(loadstring(Sources[name],name)); setfenv(fn,env)
 local module=fn(); Modules[name]=module; return module
end
local C=load("Config")
local R=load("Rules")
local Q=load("RoundRules");load("VehicleRules");load("MapRules")
load("CosmeticModels")
local M=load("MissionService")
local I=load("InventoryService")
local D=load("PlayerDataService")
local T=load("InteractionService")
local B=load("ProcessingService")
Modules.ModelFactory={}
local VService=load("VehicleService")
local Cos=load("CosmeticService"); Cos.Apply=function(self,p) self.Applied=p end
Modules.NavigationService={Resolve=function() return nil end,Discover=function() end};Modules.EnvironmentService={State="Clear",Clock=16}; Modules.TrafficService={}
local function player(userId)
 return {UserId=userId,Parent=true,GetNetworkPing=function() return 0 end,Kick=function(self,msg) self.Kicked=msg end}
end
local p1,p2=player(1),player(2)
check(D:Load(p1),"new production profile can load")
local profile=D:Get(p1)
equal(profile.Cash,0,"new player starts without Cash")
profile.Cash=321
check(D:Save(p1,false),"profile saves")
equal(records.player_1.Data.Cash,321,"saved progress reaches store")
local rival=player(1)
check(not D:Load(rival),"overlapping session rejected")
check(rival.Kicked~=nil,"overlapping player gets useful message")
check(D:Save(p1,true),"release writes final snapshot and drops lease")
check(D:Load(rival),"released profile can rejoin")
equal(D:Get(rival).Cash,321,"returning player retains Cash")
records.player_2={Data={Schema=999},Lease=nil}
check(not D:Load(p2),"future schema is rejected")
equal(records.player_2.Data.Schema,999,"failed migration never overwrites profile")
failStore=true
local p3=player(3)
check(not D:Load(p3),"load outage is rejected")
check(records.player_3==nil,"load outage does not write defaults")
failStore=false
records.player_1.Lease.Token="different-session"
check(not D:Save(rival,false),"stale writer cannot save")
check(rival.Kicked~=nil,"lost lease closes session")
equal(records.player_1.Data.Cash,321,"stale writer preserves newer data")
local p4=player(4); check(D:Load(p4),"another player can load")
time+=C.LeaseSeconds+1
check(D:Get(p4)==nil,"expired lease blocks gameplay")
check(not D:Save(p4,false),"expired lease cannot overwrite data")
local defs=0
for _,card in C.Cards do check(C.Districts[card.District].Weights[card.Rarity]>0,"every indexed card can drop"); defs+=1 end
equal(defs,22,"catalog contains 22 obtainable card designs")
equal(R.capacity(0,C),5,"starter carrying capacity")
equal(R.capacity(8,C),21,"max carrying capacity")
equal(R.grade(1,2,0.5,0.2),"Perfect","center scores perfect")
equal(R.grade(1.15,2,0.5,0.2),"Good","edge inside window scores good")
equal(R.grade(-0.1,2,0.5,0.2),"Miss","early timing rejected")
equal(R.grade(2.1,2,0.5,0.2),"Miss","late timing rejected")
equal(R.grade(0.2,2,0.5,0.2),"Miss","outside zone rejected")
equal(R.identityBonus(500,C),1.5,"identity reward has permanent cap")
check(not R.canBuy(39,40,0,8),"unaffordable upgrade denied")
check(not R.canBuy(100,1,8,8),"maxed upgrade denied")
equal(R.penalty(5,0.5),3,"odd capture penalty rounds up")
equal(R.lootValue(100,2,2,2,C),246,"variant, terminal, identity value is rounded")
-- Use the real domain methods with engine boundaries replaced by deterministic mocks.
Modules.WorldService={}; Modules.NPCService={}; Modules.SecurityService={}; Modules.VaultService={}
local G=load("GameService")
T:Init(G); B:Init(G); VService.Game=G; Cos:Init(G)
local profiles={}
local stateA=player(10); local stateB=player(11)
-- A real default profile from the data loader.
check(D:Load(stateA),"gameplay profile loads")
profile=D:Get(stateA); profiles[stateA]=profile; profiles[stateB]=clone(profile)
G.Data={Get=function(_,p) return profiles[p] end}
G.Remote={Events={},FireClient=function(self,p,kind,packet) table.insert(self.Events,{p,kind,packet}) end}
G.World={Checkpoints={"checkpoint"},Stations={Bank={vec(0,3,3)},Practice={vec(0,3,3)},Resupply={vec(0,3,3)},Hideout={vec(0,3,3)},Press={vec(0,3,3)},Rinse={vec(0,3,3)},Payout={vec(0,3,3)},Garage={vec(0,3,3)},CosmeticShop={vec(0,3,3)},Wardrobe={vec(0,3,3)}},Secrets={},SecretParts={},SafeZones={vec(0,0,0)},InsideSafe=function() return true end,DistrictAt=function() return 1 end}
G.Security={Visible=function() return true end}
local root={Position=vec(0,3,3),CFrame="start"}
G.Root=function() return root end
G.ApplyMovement=function() end
local target={Id="D1N1",District=1,Model={PrimaryPart={Position=vec(0,3,3)},SetAttribute=function() end},Prompt={Enabled=true},Origin=vec(0,3,3),Available=0,Reserved=nil,Suspicion=0}
G.NPC={Targets={D1N1=target},Guards={},React=function() end}
for _,p in {stateA,stateB} do G.State[p]={Loot={},Heat=0,LastTrouble=0,Immunity=0,Chase=false,VaultCooldown=0,Tokens=16,TokenTime=now} end
T:Scout(stateA,"D1N1")
check(G.Remote.Events[#G.Remote.Events][2]=="Scout","nearby target scouting reaches the client choice dialog")
check(G.State[stateA].Attempt==nil and target.Reserved==nil,"a scout preview alone never reserves a target or awards loot")
G.Security.Visible=function() return false end
check(T:Eligible(stateA,"D1N1")==nil,"server still rejects scouting through walls without native camera occlusion")
T:Begin(stateA,"D1N1","Careful")
check(G.State[stateA].Attempt==nil,"server rechecks world obstruction when the choice is confirmed")
G.Security.Visible=function() return true end
root.Position=vec(C.InteractDistance+1,3,3)
check(T:Eligible(stateA,"D1N1")==nil,"server rejects fallback scouting beyond the interaction radius")
root.Position=vec(C.InteractDistance,3,3)
check(T:Eligible(stateA,"D1N1")==target,"native and fallback scouting share the server distance boundary")
root.Position=vec(0,3,3);target.Reserved=stateB
check(T:Eligible(stateA,"D1N1")==nil,"fallback cannot bypass another player's target reservation")
target.Reserved=nil;target.Available=now+1
check(T:Eligible(stateA,"D1N1")==nil,"fallback cannot bypass the target recovery timer")
target.Available=0
local function finishProcessing()
 B:Act(stateA,"Press")
 if profile.Processing.Ends>0 then time=profile.Processing.Ends+1 end
 B:Refresh(profile)
 B:Act(stateA,"Rinse")
 if profile.Processing.Ends>0 then time=profile.Processing.Ends+1 end
 B:Refresh(profile)
 B:Act(stateA,"Claim")
end
G:Begin(stateA,"D1N1")
now=G.State[stateA].Attempt.Start+G.State[stateA].Attempt.Duration;T:Tick(stateA)
check(G.State[stateA].Attempt~=nil,"eligible player reserves target")
G:Begin(stateB,"D1N1")
check(G.State[stateB].Attempt==nil,"simultaneous interaction cannot share target")
local a=G.State[stateA].Attempt
now=a.Start+a.Duration*a.Center
G:Resolve(stateA,{Token=a.Token,Lane=a.Lane,At=now})
equal(#G.State[stateA].Loot,1,"valid timing grants exactly one card")
equal(G.State[stateA].Heat,C.Heat.Success*C.Approaches.Careful.Heat,"success adds modest Heat")
check(profile.Starter==2,"first success advances onboarding")
G:Resolve(stateA,{Token=a.Token,Lane=a.Lane,At=now})
equal(#G.State[stateA].Loot,1,"replayed token cannot duplicate reward")
G:Bank(stateA)
finishProcessing()
equal(#G.State[stateA].Loot,0,"bank clears pockets")
check(profile.Cash>0,"bank pays Cash")
equal(profile.Starter,3,"bank advances onboarding")
profile.Cash=40
G:Buy(stateA,"Sleight")
equal(profile.Upgrades.Sleight,1,"eligible purchase applies upgrade")
check(profile.Cash>=0,"upgrade cannot make balance negative")
profile.Cash=0
G:Buy(stateA,"Sleight")
equal(profile.Upgrades.Sleight,1,"unaffordable repeat purchase denied")
equal(profile.Cash,0,"failed purchase preserves Cash")
profile.Cash=500; profile.Reputation=0
G:Unlock(stateA,2)
check(not profile.Districts["2"],"district Reputation requirement enforced")
profile.Reputation=30
G:Unlock(stateA,2)
check(profile.Districts["2"],"eligible district unlock succeeds")
equal(profile.Cash,380,"district charges configured price")
equal(profile.Reputation,30,"unlock keeps Reputation")
G:Unlock(stateA,2)
equal(profile.Cash,380,"repeated unlock does not charge twice")
local s=G.State[stateA]
for _=1,R.capacity(profile.Upgrades.Capacity,C) do table.insert(s.Loot,{Id="D1R1",Variant="Standard"}) end
target.Available=0
G:Begin(stateA,"D1N1")
check(s.Attempt==nil,"full carrying inventory blocks interaction")
s.Loot={}; target.Available=0
G:Begin(stateA,"D1N1"); a=s.Attempt
now=a.Start+a.Duration;T:Tick(stateA);a=s.Attempt
now=a.Start+a.Duration+2;G:Resolve(stateA,nil,true)
check(s.Attempt and s.Attempt.Phase=="Recovery","first error offers a bounded recovery phase")
a=s.Attempt;now=a.Start+a.Duration+2;G:Resolve(stateA,nil,true)
equal(#s.Loot,0,"timing timeout grants no loot")
equal(s.Heat,(C.Heat.Success+C.Heat.Failure+2*C.Round.ErrorHeat)*C.Approaches.Careful.Heat,"miss adds configured Heat")
check(target.Suspicion>0,"miss increases target suspicion")
for _=1,5 do table.insert(s.Loot,{Id="D1R1",Variant="Standard"}) end
local banked=profile.Cash
G:Capture(stateA)
equal(#s.Loot,2,"capture removes intended rounded-up half")
equal(profile.Cash,banked,"capture keeps banked Cash")
equal(profile.Upgrades.Sleight,1,"capture keeps upgrades")
check(s.Immunity>now,"capture applies grace period")
G:Capture(stateA)
equal(#s.Loot,2,"grace period prevents repeat capture")
local savedCash=profile.Cash
G:Capture(stateA,true)
equal(#s.Loot,1,"resetting character also drops half of unbanked loot")
equal(profile.Cash,savedCash,"death penalty preserves saved Cash")
profile.Starter=7; profile.StarterProgress=0
s.Loot={}; for _=1,5 do table.insert(s.Loot,{Id="D1R1",Variant="Standard"}) end
G:Bank(stateA)
finishProcessing()
equal(profile.StarterProgress,0,"caught trip does not count for clean mission")
for _=1,5 do table.insert(s.Loot,{Id="D1R1",Variant="Standard"}) end
G:Bank(stateA)
finishProcessing()
equal(profile.Starter,8,"clean trip completes clean objective")
M.rotate(profile)
local daily=M.definitions(profile)[1]
profile.Daily.Progress[daily.Id]=daily.Definition.Goal
local before=profile.Cash
check(M.claim(profile,daily.Id),"completed daily can be claimed")
equal(profile.Cash,before+daily.Definition.Cash,"daily pays exact reward")
check(not M.claim(profile,daily.Id),"daily reward cannot be claimed twice")
check(not M.claim(profile,"999"),"unknown daily reward rejected")
time+=86400
M.rotate(profile)
check(next(profile.Daily.Claimed)==nil,"daily rotation resets claims")
check(next(profile.Daily.Progress)==nil,"daily rotation resets progress")
for i=1,5 do
 I.discover(profile,{Id="D1R1",Variant="test"..i})
end
before=profile.Cash
I.discover(profile,{Id="D1R1",Variant="test5"})
equal(profile.Cash,before,"duplicate discovery cannot pay milestone again")
profile.Cash=C.Prestige.Cash; profile.Reputation=C.Prestige.Reputation
for i=1,5 do profile.Districts[tostring(i)]=true end
profile.Settings.ReducedMotion=true
s.Prestige={Token="confirmed",Ends=now+30}
local collection=profile.Collection; local settings=profile.Settings; local dailyState=profile.Daily
G:Prestige(stateA,"wrong-token")
equal(profile.Cash,C.Prestige.Cash,"invalid prestige token cannot reset data")
G:Prestige(stateA,"confirmed")
equal(profile.Cash,0,"prestige resets Cash")
equal(profile.Reputation,0,"prestige resets Reputation")
equal(profile.Upgrades.Sleight,0,"prestige resets upgrades")
check(profile.Districts["1"] and not profile.Districts["5"],"prestige resets district access")
equal(profile.Starter,1,"prestige resets starter jobs")
equal(#s.Loot,0,"prestige clears carried cards")
equal(s.Heat,0,"prestige resets Heat")
check(profile.Collection==collection,"prestige preserves collection")
check(profile.Settings==settings,"prestige preserves settings")
check(profile.Daily==dailyState,"prestige preserves daily progress and claims")
check(profile.Badges["Identity 1"],"prestige awards identity badge")
equal(profile.Identities,1,"prestige adds exactly one identity")
G:Prestige(stateA,"confirmed")
equal(profile.Identities,1,"prestige token cannot be replayed")
-- Expansion: schema migration, multi-stage scoring, facilities, gadgets and secrets.
local legacy=clone(profile); legacy.Schema=1; legacy.Cash=777; legacy.Hideout=nil; legacy.Secrets=nil; legacy.Stats=nil;legacy.RoundRecords=nil;legacy.Exploration=nil;legacy.Settings.MinimapRotate=nil;legacy.Settings.MinimapZoom=nil;legacy.Settings.VehicleCamera=nil
legacy.Upgrades.Gadgets=nil; legacy.Upgrades.Composure=nil; legacy.Upgrades.Appraisal=nil
records.player_23={Data=legacy}
local migrated=player(23)
check(D:Load(migrated),"version-one save migrates without a reset")
local migratedProfile=D:Get(migrated)
equal(migratedProfile.Cash,777,"migration preserves currency")
equal(migratedProfile.Schema,C.Schema,"migration updates schema")
equal(migratedProfile.Hideout.Network,0,"migration adds facility defaults")
equal(migratedProfile.Upgrades.Gadgets,0,"migration adds new upgrade defaults")
check(next(migratedProfile.Secrets)==nil,"migration adds empty city journal")
check(migratedProfile.RoundRecords.Rounds==0 and next(migratedProfile.RoundRecords.Best)==nil,"migration adds round records without inventing results")
check(migratedProfile.Exploration.Services.hideout_1,"migration discovers only the starter workshop by default")
check(migratedProfile.Settings.MinimapRotate==false and migratedProfile.Settings.MinimapZoom==2 and migratedProfile.Settings.VehicleCamera,"migration adds safe map and camera defaults")
local schema3=clone(legacy);schema3.Schema=3;schema3.Cash=789;schema3.Van={Owned=true,Stash={{Id="D1R1",Variant="Foil"}}};schema3.Processing.Stage="Pressed";schema3.Processing.Value=175;schema3.Cosmetics.Owned.canvas_mint=true
records.player_203={Data=schema3,Revision=1}
local olderPlayer=player(203);check(D:Load(olderPlayer),"schema-3 saved data loads through the real persistence layer")
local older=D:Get(olderPlayer)
check(older.Schema==4 and older.Cash==789 and older.Processing.Stage=="Pressed" and older.Processing.Value==175,"schema-4 migration preserves currency and a pending batch")
check(older.Van.Owned and #older.Van.Stash==1 and older.Cosmetics.Owned.canvas_mint,"schema-4 migration preserves van contents and cosmetics")
for _,pattern in {"Sweep","Reverse","Bounce"} do
 local a_={Duration=2,Center=0.5,Width=0.3,Drift=0,Pattern=pattern}
 local elapsed=if pattern=="Bounce" then 0.5 else 1
 equal(R.stageGrade(elapsed,a_),"Perfect","pattern center hit: "..pattern)
 equal(R.stageGrade(-1,a_),"Miss","negative time denied: "..pattern)
 equal(R.stageGrade(3,a_),"Miss","expired input denied: "..pattern)
end
check(R.zone(0.5,2,0.5,0.1,0.2)>0.5,"later-stage zone actually drifts")
equal(R.stageCount(5,"VIP",C),3,"VIP stage count capped at three")
equal(R.charges(profile,C),0,"gadgets are locked before purchase")
profile.Upgrades.Gadgets=2; profile.Hideout.Workshop=2
equal(R.charges(profile,C),4,"gadget and workshop capacity stack")
profile.Starter=8; profile.Cash=10000; profile.Reputation=1000
profile.Upgrades.Composure=0; s.Immunity=0; s.Heat=0; s.Loot={}; target.Style="VIP"; target.Available=0
local function hitAll()
 while s.Attempt do
  local step=s.Attempt
  if step.Phase=="Read" then now=step.Start+step.Duration;T:Tick(stateA);continue elseif step.Phase=="Decision" then T:Choice(stateA,{Token=step.Token,Choice="Secure"});continue end
  local found=false
  for sample=1,999 do
   local elapsed=step.Duration*sample/1000
   if R.stageGrade(elapsed,step)=="Perfect" then now=step.Start+elapsed; found=true; break end
  end
  check(found,"timing pattern has an attainable perfect zone")
  G:Resolve(stateA,{Token=step.Token,Lane=step.Lane,At=now})
 end
end
G:Begin(stateA,"D1N1","Bold")
now=s.Attempt.Start+s.Attempt.Duration;T:Tick(stateA)
local first=s.Attempt; local oldToken=first.Token
now=first.Start+first.Duration*first.Center
G:Resolve(stateA,{Token=oldToken,Lane=first.Lane,At=now})
equal(#s.Loot,0,"first VIP stage does not award partial loot")
equal(s.Attempt.Stage,2,"successful first stage advances challenge")
local secondToken=s.Attempt.Token
check(secondToken~=oldToken,"each stage has a fresh token")
G:Resolve(stateA,{Token=oldToken,Lane=first.Lane,At=now})
equal(s.Attempt.Token,secondToken,"replayed prior stage cannot advance")
hitAll()
equal(#s.Loot,1,"all stages award exactly one card")
check(s.Loot[1].Quality>1,"bold VIP reward includes explicit value quality")
equal(s.Combo,1,"first complete challenge starts a streak")
check(s.Heat>C.Heat.Success,"bold approach adds more Heat")
target.Available=0; G:Begin(stateA,"D1N1","Careful"); hitAll()
equal(s.Combo,2,"consecutive full challenges grow the streak")
check(s.Loot[2].Quality>1.25,"streak adds capped quality to the reward")
target.Available=0; G:Begin(stateA,"D1N1"); G:CancelInteraction(stateA,true)
equal(s.Combo,0,"live cancellation resets streak")
check(s.Heat>0,"live cancellation is not a free reroll")
equal(R.rarityWeight(0,6,2,C),0,"rarity luck never creates an unavailable card")
equal(R.rarityWeight(74,1,2,C),74,"rarity luck preserves Common baseline weight")
check(R.rarityWeight(1,6,1.3,C)>R.rarityWeight(1,2,1.3,C),"luck favors higher tiers even in districts without Common cards")
local oldAttempts=profile.Stats.Attempts
local oldHeat=s.Heat; local oldLoot=#s.Loot; local oldRep=profile.Reputation
T:Practice(stateA); hitAll()
equal(s.Heat,oldHeat,"practice never adds Heat")
equal(#s.Loot,oldLoot,"practice never awards a card")
equal(profile.Reputation,oldRep,"practice cannot farm Reputation")
equal(profile.Stats.Attempts,oldAttempts,"practice does not alter actual attempt statistics")
local oldLounge=profile.Hideout.Lounge
G:HideoutBuy(stateA,"Lounge")
equal(profile.Hideout.Lounge,oldLounge+1,"facility purchase upgrades the room")
profile.Cash=0; oldLounge=profile.Hideout.Lounge
G:HideoutBuy(stateA,"Lounge")
equal(profile.Hideout.Lounge,oldLounge,"unaffordable facility purchase denied")
equal(profile.Cash,0,"facility purchase cannot make Cash negative")
G:Resupply(stateA)
equal(s.GadgetCharges,4,"supply bench refills configured charge capacity")
G.World.InsideSafe=function() return false end
s.Heat=70; s.GadgetReady=0; now+=50
G:Decoy(stateA)
equal(s.GadgetCharges,3,"decoy consumes exactly one charge")
equal(s.Heat,58,"decoy relieves configured Heat")
check(s.DecoyUntil>now,"decoy temporarily suppresses pursuit")
G:Decoy(stateA)
equal(s.GadgetCharges,3,"decoy cooldown prevents rapid repeat use")
G.World.InsideSafe=function() return true end
G.World.Secrets.S1_1=vec(0,3,3)
local beforeSecret=profile.Cash
G:Secret(stateA,"S1_1")
check(profile.Secrets.S1_1,"nearby valid secret is saved")
equal(profile.Cash,beforeSecret+C.Secrets.S1_1.Cash,"secret pays its exact reward")
G:Secret(stateA,"S1_1")
equal(profile.Cash,beforeSecret+C.Secrets.S1_1.Cash,"secret cannot pay twice")
G.World.Secrets.S5_1=vec(0,3,3); profile.Districts["5"]=nil
G:Secret(stateA,"S5_1")
check(not profile.Secrets.S5_1,"locked-district secret denied")
profile.Cash=1000; profile.Districts["2"]=true; profile.Hideout.Network=1
G.World.Checkpoints[2]="plaza"
s.Loot={}; s.Heat=0; s.Chase=false
local oldCash=profile.Cash
G:Travel(stateA,2)
equal(root.CFrame,"plaza","courier moves player to chosen checkpoint")
equal(profile.Cash,oldCash-R.travelCost(1,2,C),"courier charges exact fare")
now+=5; s.Heat=80; oldCash=profile.Cash
G:Travel(stateA,2)
equal(profile.Cash,oldCash,"hot players cannot use courier travel")
s.Heat=0; s.Loot={{Id="D1R1",Variant="Standard"}}
G:Travel(stateA,2)
equal(profile.Cash,oldCash,"courier cannot extract unbanked loot")
profile.Cash=C.Prestige.Cash; profile.Reputation=C.Prestige.Reputation; profile.Starter=8
for i=1,5 do profile.Districts[tostring(i)]=true end
s.Loot={}; s.Prestige={Token="second-identity",Ends=now+30}
local home=profile.Hideout; local journal=profile.Secrets; local stats=profile.Stats
G:Prestige(stateA,"second-identity")
check(profile.Hideout==home,"New Identity preserves clubhouse upgrades")
check(profile.Secrets==journal,"New Identity preserves city journal")
check(profile.Stats==stats,"New Identity preserves career statistics")
equal(profile.Upgrades.Gadgets,0,"New Identity resets normal gadget upgrades")
equal(s.GadgetCharges,0,"New Identity clears gadget charges")
-- Actual guard state machine: a decoy only releases its owner's pursuit.
local S=load("SecurityService"); S:Init(G)
G.World.InsideSafe=function() return false end
stateA.Character={FindFirstChild=function() return root end,FindFirstChildOfClass=function() return nil end}
local guard={Model={PrimaryPart={Position=vec(0,3,30),CFrame={LookVector={Dot=function() return 1 end}},Status={Text={}}}},District=1,Target=stateA,LastSeen=now,Phase=0,Origin=vec(0,3,30),LastPath=0}
G.NPC.Guards={guard}; s.Heat=90; s.Immunity=0; s.Chase=true; s.DecoyUntil=now+3
G.State[stateB].Heat=0; G.State[stateB].Immunity=0
S.Visible=function() return true end; S.Move=function() end
local escaped=profile.Stats.Escapes
S:Tick(now,0.25)
check(guard.Target==nil,"decoy makes pursuing guard lose intended player")
check(not s.Chase,"decoy resolves the player's chase state")
equal(profile.Stats.Escapes,escaped+1,"a real resolved chase counts exactly one escape")
check(not G.State[stateB].Chase,"cool bystander is not punished by another player's decoy")
now+=4
S:Tick(now,0.25)
check(guard.Target==stateA,"hot player can be detected again after decoy expires")
check(s.Chase,"reacquisition restores chase state")
G.World.InsideSafe=function() return true end
S:Tick(now,0.25)
check(guard.Target==nil,"safe room reliably releases pursuit")
local beforeFar=profile.Cash
G.World.Secrets.S1_2=vec(100,3,3)
G:Secret(stateA,"S1_2")
equal(profile.Cash,beforeFar,"distant secret cannot pay a reward")
check(not profile.Secrets.S1_2,"distant secret cannot be discovered remotely")
-- After Hours: fictional processing pipeline, persistence, contracts and van transactions.
profile.Cash=1000; profile.Starter=8; profile.Reputation=1000; s.Loot={{Id="D1R1",Variant="Standard",Quality=1}}; s.CaughtTrip=false
local beforeDeposit=profile.Cash
G:Bank(stateA)
equal(profile.Cash,beforeDeposit,"deposit secures cards but never pays instant Cash")
equal(profile.Processing.PendingCards,1,"deposit queues exactly one card")
check(profile.Processing.PendingValue>0,"deposit records server-valued inputs")
equal(#s.Loot,0,"deposit removes pocket cards atomically")
B:Act(stateA,"Claim")
equal(profile.Cash,beforeDeposit,"claim before processing cannot pay")
B:Act(stateA,"Rinse")
equal(profile.Processing.Stage,"Idle","rinse cannot bypass the press")
B:Act(stateA,"Press")
equal(profile.Processing.Stage,"Pressing","press starts the batch")
local batch=profile.Processing.Value
B:Act(stateA,"Press")
equal(profile.Processing.Value,batch,"repeated press cannot duplicate or replace batch")
B:Act(stateA,"Claim")
equal(profile.Cash,beforeDeposit,"running batch cannot be collected early")
time=profile.Processing.Ends+1; B:Refresh(profile)
equal(profile.Processing.Stage,"Pressed","offline elapsed timer advances to pressed state")
B:Act(stateA,"Rinse"); equal(profile.Processing.Stage,"Rinsing","rinse starts only after press completes")
time=profile.Processing.Ends+1; B:Refresh(profile)
equal(profile.Processing.Stage,"Ready","rinse completion makes payout ready")
B:Act(stateA,"Claim")
equal(profile.Cash,beforeDeposit+batch,"finished processing pays exact locked batch value")
B:Act(stateA,"Claim")
equal(profile.Cash,beforeDeposit+batch,"processing payout cannot be claimed twice")
equal(profile.Processing.Stage,"Idle","payout clears the completed batch")
profile.Processing.PendingCards=C.Processing.QueueCapacity; s.Loot={{Id="D1R1",Variant="Standard"}}
G:Bank(stateA)
equal(#s.Loot,1,"full processing queue preserves carried cards")
profile.Processing.PendingCards=0; profile.Processing.PendingValue=0; profile.Processing.PendingClean=0
profile.Van.Owned=false
VService:Act(stateA,"Purchase")
check(profile.Van.Owned,"van purchase grants ownership")
local afterVan=profile.Cash
VService:Act(stateA,"Purchase")
equal(profile.Cash,afterVan,"van cannot charge twice for ownership")
VService.Vehicles[stateA]={Model={StashHandle={Position=root.Position}}}
s.Loot={{Id="D1R1",Variant="Standard"},{Id="D1R1",Variant="Standard"}}
VService:Act(stateA,"Store")
equal(#s.Loot,0,"van storage removes exactly the transferred pocket cards")
equal(#profile.Van.Stash,2,"van storage receives cards")
VService:Act(stateA,"Store")
equal(#profile.Van.Stash,2,"repeated storage cannot duplicate cards")
VService:Act(stateA,"Withdraw")
equal(#s.Loot,2,"withdraw returns stored cards")
equal(#profile.Van.Stash,0,"withdraw removes stored copies")
local cap=VService:Capacity(profile)
for _=1,cap do table.insert(profile.Van.Stash,{Id="D1R1",Variant="Standard"}) end
VService:Act(stateA,"Store")
equal(#s.Loot,2,"full van preserves pocket cards")
equal(#profile.Van.Stash,cap,"van capacity is enforced")
profile.Van.Stash={}; VService:Act(stateA,"Store"); VService:Act(stateA,"Deposit")
equal(#profile.Van.Stash,0,"dock deposit clears stored cards")
equal(profile.Processing.PendingCards,2,"dock deposit creates processing inputs")
profile.Contracts.Active=""; profile.Contracts.Claimed={}; profile.Contracts.Progress={}
check(M.accept(profile,"mara_1"),"eligible story contract can be accepted")
check(not M.accept(profile,"jax_1"),"only one story contract may be active")
M.event(profile,"collect",3)
check(M.claimContract(profile,"mara_1"),"completed story contract can be claimed")
check(not M.claimContract(profile,"mara_1"),"story contract reward is one-time")
check(M.accept(profile,"mara_2"),"next story contract requires and accepts previous completion")
profile.Contracts.Active=""
check(not M.accept(profile,"iris_2"),"story prerequisites cannot be skipped")
local easy=R.challenge(1,1,0,0,C.Approaches.Careful,C.TargetStyles.Daydreamer,C)
local hard=R.challenge(5,3,0,0,C.Approaches.Bold,C.TargetStyles.VIP,C)
check(hard.Width<easy.Width,"later district challenge has a smaller window")
check(hard.Duration<easy.Duration,"later district challenge is faster")
check(hard.Drift>easy.Drift,"later challenges drift more")
local geared=R.challenge(5,3,8,8,C.Approaches.Careful,C.TargetStyles.VIP,C)
check(geared.Width<easy.Width,"maximum Focus does not trivialize endgame against starter")
check(hard.Width>=0.085 and geared.Width<=0.36,"timing difficulty bounds enforced")
check(math.abs(R.speedTowards(0,24,7,0.1)-0.7)<0.00001,"traffic accelerates gradually")
check(R.speedTowards(24,0,18,0.1)>0,"normal traffic braking is gradual")
check(R.processSeconds("Press",6,C)<R.processSeconds("Press",0,C),"press upgrade reduces processing time")
check(profile.Processing.PendingCards>0,"queued batch exists before capture")
s.Immunity=0; s.Loot={{Id="D1R1",Variant="Standard"}}; local protected=profile.Processing.PendingValue
G:Capture(stateA)
equal(profile.Processing.PendingValue,protected,"capture cannot debit stored processing inputs")
profile.Cash=1000; profile.Reputation=1000
local cashBeforeStyle=profile.Cash
Cos:Act(stateA,"Buy","canvas_mint")
check(profile.Cosmetics.Owned.canvas_mint,"cosmetic purchase grants ownership")
equal(profile.Cash,cashBeforeStyle-C.Cosmetics.canvas_mint.Price,"cosmetic purchase charges exact catalog price")
Cos:Act(stateA,"Buy","canvas_mint")
equal(profile.Cash,cashBeforeStyle-C.Cosmetics.canvas_mint.Price,"owned cosmetics cannot charge twice")
Cos:Act(stateA,"Equip","night_beanie")
check(profile.Cosmetics.Equipped.Head=="","unowned cosmetic cannot be equipped")
Cos:Act(stateA,"Equip","canvas_mint")
equal(profile.Cosmetics.Equipped.Head,"canvas_mint","wardrobe equips an owned item into its defined slot")
check(Cos.Applied==stateA,"equipping actually reapplies the character appearance")
Cos:Act(stateA,"Unequip","Head")
equal(profile.Cosmetics.Equipped.Head,"","unequipping clears only the requested slot")
profile.Cash=0
Cos:Act(stateA,"Buy","night_beanie")
check(not profile.Cosmetics.Owned.night_beanie,"unaffordable cosmetic denied")
equal(profile.Cash,0,"cosmetic purchase cannot make Cash negative")
local styleOwned=profile.Cosmetics.Owned
profile.Cash=C.Prestige.Cash; profile.Reputation=C.Prestige.Reputation; profile.Starter=8
for i=1,5 do profile.Districts[tostring(i)]=true end
s.Prestige={Token="style-identity",Ends=now+30}
G:Prestige(stateA,"style-identity")
check(profile.Cosmetics.Owned==styleOwned and profile.Cosmetics.Owned.canvas_mint,"New Identity preserves cosmetic ownership")
print("PASS: "..passed.." domain assertions (mocked engine boundaries; not Studio playtesting)")
