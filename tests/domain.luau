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
local shared={Config="Config",Rules="Rules"}
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
 Players={},
}
local env={
 Color3={fromRGB=function(r,g,b) return {r,g,b} end},
 Vector3={new=vec},
 Random={new=function() return {NextNumber=function(_,lo,hi) return lo+(hi-lo)*0.5 end} end},
 game={GetService=function(_,name) return services[name] end},
 script={Parent={PlayerDataService="PlayerDataService",WorldService="WorldService",NPCService="NPCService",InventoryService="InventoryService",MissionService="MissionService",SecurityService="SecurityService",VaultService="VaultService"}},
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
local M=load("MissionService")
local I=load("InventoryService")
local D=load("PlayerDataService")
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
local profiles={}
local stateA=player(10); local stateB=player(11)
-- A real default profile from the data loader.
check(D:Load(stateA),"gameplay profile loads")
profile=D:Get(stateA); profiles[stateA]=profile; profiles[stateB]=clone(profile)
G.Data={Get=function(_,p) return profiles[p] end}
G.Remote={Events={},FireClient=function(self,p,kind,packet) table.insert(self.Events,{p,kind,packet}) end}
G.World={Checkpoints={"checkpoint"},SafeZones={vec(0,0,0)},InsideSafe=function() return true end,DistrictAt=function() return 1 end}
G.Security={Visible=function() return true end}
local root={Position=vec(0,3,3),CFrame="start"}
G.Root=function() return root end
G.ApplyMovement=function() end
local target={Id="D1N1",District=1,Model={PrimaryPart={Position=vec(0,3,3)}},Origin=vec(0,3,3),Available=0,Reserved=nil,Suspicion=0}
G.NPC={Targets={D1N1=target},Guards={}}
for _,p in {stateA,stateB} do G.State[p]={Loot={},Heat=0,LastTrouble=0,Immunity=0,Chase=false,VaultCooldown=0,Tokens=16,TokenTime=now} end
G:Begin(stateA,"D1N1")
check(G.State[stateA].Attempt~=nil,"eligible player reserves target")
G:Begin(stateB,"D1N1")
check(G.State[stateB].Attempt==nil,"simultaneous interaction cannot share target")
local a=G.State[stateA].Attempt
now=a.Start+a.Duration*a.Center
G:Resolve(stateA,a.Token)
equal(#G.State[stateA].Loot,1,"valid timing grants exactly one card")
equal(G.State[stateA].Heat,C.Heat.Success,"success adds modest Heat")
check(profile.Starter==2,"first success advances onboarding")
G:Resolve(stateA,a.Token)
equal(#G.State[stateA].Loot,1,"replayed token cannot duplicate reward")
G:Bank(stateA)
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
now=a.Start+a.Duration+2
G:Resolve(stateA,a.Token,true)
equal(#s.Loot,0,"timing timeout grants no loot")
equal(s.Heat,C.Heat.Success+C.Heat.Failure,"miss adds configured Heat")
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
equal(profile.StarterProgress,0,"caught trip does not count for clean mission")
for _=1,5 do table.insert(s.Loot,{Id="D1R1",Variant="Standard"}) end
G:Bank(stateA)
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
print("PASS: "..passed.." domain assertions (mocked engine boundaries; not Studio playtesting)")
