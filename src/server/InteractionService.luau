--!strict
local Shared=game:GetService("ReplicatedStorage").Shared
local C=require(Shared.Config)
local R=require(Shared.Rules)
local Q=require(Shared.RoundRules)
local HttpService=game:GetService("HttpService")
local T: any={}
function T:Init(gameService: any) self.Game=gameService end
function T:Eligible(player: Player,id: string): any
 local G=self.Game;local p=G.Data:Get(player);local s=G.State[player];local target=G.NPC.Targets[id];local root=G:Root(player)
 if not p or not s or not root or not target or not target.Model.PrimaryPart or s.Attempt or s.Vault then return nil end
 local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if hum and hum.SeatPart then G:Notify(player,"Exit your vehicle before scouting.");return nil end
 if target.Reserved or target.Available>os.clock() then G:Notify(player,"That citizen is recovering or busy.");return nil end
 if not p.Districts[tostring(target.District)] then G:Notify(player,"Unlock this district first.");return nil end
 local requirement=C.Districts[target.District].Equipment
 if p.Upgrades.Sleight<requirement then G:Notify(player,"This citizen needs Sleight "..requirement..". Upgrade at the workbench.");return nil end
 if #s.Loot>=R.capacity(p.Upgrades.Capacity,C) then G:Notify(player,"Pockets full. Secure cards at an intake or your van.");return nil end
 if (root.Position-target.Model.PrimaryPart.Position).Magnitude>C.InteractDistance or not G.Security:Visible(root.Position,target.Model.PrimaryPart.Position) then G:Notify(player,"Move closer with a clear path to the citizen.");return nil end
 return target
end
function T:Scout(player: Player,id: string)
 local target=self:Eligible(player,id);if not target then return end
 target.PreviewUntil=os.clock()+12
 local p=self.Game.Data:Get(player);local style=target.Style or "Daydreamer"
 local plan=Q.plan(target.District,style,"Careful",1,p.Upgrades,C,p.Starter==1)
 self.Game.Remote:FireClient(player,"Scout",{Id=id,Name=target.Model.Name or "Citizen",Style=style,District=target.District,Stages=#plan.Phases,Suspicion=math.floor(target.Suspicion),Requirement=C.Districts[target.District].Equipment})
end
function T:Packet(player: Player)
 local G=self.Game;local a=G.State[player].Attempt;if not a then return end
 local p=G.Data:Get(player);local active=a.Active or {}
 local packet={Token=a.Token,Phase=a.Phase,Start=a.Start,Duration=a.Duration,Stage=a.Stage,Stages=#a.Plan.Phases,Approach=a.Mode,Practice=a.Practice,Sequence={},Perfects=a.Perfects,Mistakes=a.Mistakes,RecoveryLeft=math.max(0,1-a.Recoveries),Hint=a.Hint or "",Tool=not a.Practice and not a.ToolUsed and p.Upgrades.Gadgets>0 and (G.State[player].GadgetCharges or 0)>0,Intro=a.Intro,BonusValue=C.Round.BonusValue,Quality=a.Quality}
 for _,phase in a.Plan.Phases do table.insert(packet.Sequence,phase.Lane) end
 for _,key in {"Kind","Lane","Width","Center","Drift","Pattern","Memory","Hazard"} do packet[key]=active[key] end
 G.Remote:FireClient(player,"Timing",packet)
end
function T:Activate(player: Player,phase: any,kind: string?)
 local a=self.Game.State[player].Attempt
 a.Active=phase;for _,key in {"Center","Width","Pattern","Drift","Lane"} do a[key]=phase[key] end;a.Phase=kind or "Action";a.Token=HttpService:GenerateGUID(false);a.Start=workspace:GetServerTimeNow()+C.Round.Lead;a.Duration=phase.Duration
 self:Packet(player)
end
function T:Start(player: Player,target: any?,mode: string)
 local G=self.Game;local p=G.Data:Get(player);local s=G.State[player]
 local practice=target==nil;local district=if target then target.District elseif mode=="DailyDrill" then math.floor(os.time()/86400)%3+1 else 1
 local seed=if mode=="DailyDrill" then math.floor(os.time()/86400)*83+41 else Random.new():NextInteger(1,2147483646)
 local intro=not practice and p.Starter==1
 local style=if target then target.Style or "Daydreamer" else "Commuter"
 local plan=Q.plan(district,style,mode,seed,if mode=="DailyDrill" then {Focus=0,Sleight=0} else p.Upgrades,C,intro)
 if target then target.Reserved=player;target.Model:SetAttribute("TargetAvailable",false);target.Prompt.Enabled=false;p.Stats.Attempts+=1 end
 s.Attempt={Target=if target then target.Id else nil,District=district,Style=style,Mode=mode,Approach=if mode=="Bold" then "Bold" else "Careful",Practice=practice,Intro=intro,Plan=plan,Stage=1,Phase="Read",Active=nil,Token=HttpService:GenerateGUID(false),Start=workspace:GetServerTimeNow(),Duration=plan.ReadSeconds,Began=workspace:GetServerTimeNow(),Perfects=0,Clears=0,Mistakes=0,Recoveries=0,Quality=1,Bonus=false,ToolUsed=false,Hint="Read the route. J/K/L or tap its next lane when the marker reaches mint. Arrows + Space/A also work."}
 self:Packet(player)
end
function T:Begin(player: Player,id: string,approach: string?)
 local target=self:Eligible(player,id);if not target then return end
 local mode=approach or "Careful";if mode~="Careful" and mode~="Bold" then return end
 self:Start(player,target,mode)
end
function T:Practice(player: Player,mode: string?)
 local G=self.Game;local s=G.State[player];local root=G:Root(player)
 if not s or not root or s.Attempt or s.Vault or not G.Data:Get(player) then return end
 if not G:NearStation(player,"Practice") then G:Notify(player,"Use the practice console inside a workshop.");return end
 if mode~=nil and mode~="Practice" and mode~="DailyDrill" then return end
 self:Start(player,nil,mode or "Practice")
end
function T:Context(player: Player,a: any): boolean
 local G=self.Game;local root=G:Root(player);local p=G.Data:Get(player)
 if not root or not p then return false end
 if a.Practice then return G:NearStation(player,"Practice") end
 local target=G.NPC.Targets[a.Target]
 return target~=nil and target.Reserved==player and target.Model.PrimaryPart~=nil and (root.Position-target.Model.PrimaryPart.Position).Magnitude<=C.InteractDistance and G.Security:Visible(root.Position,target.Model.PrimaryPart.Position) and p.Districts[tostring(a.District)] and #G.State[player].Loot<R.capacity(p.Upgrades.Capacity,C)
end
function T:Cancel(player: Player,penalize: boolean?)
 local G=self.Game;local s=G.State[player];if not s or not s.Attempt then return end
 local a=s.Attempt;local target=a.Target and G.NPC.Targets[a.Target]
 s.Attempt=nil -- invalidate the token before cleanup or notifications
 if target and target.Reserved==player then target.Reserved=nil;target.Available=os.clock()+(if penalize then 8 else 2) end
 if penalize and not a.Practice then s.Combo=0;G:Heat(player,C.Stealing.CancelHeat);G:Notify(player,"Route abandoned / +10 Heat. Try another citizen or practice at home.","Failure") end
 G.Remote:FireClient(player,"TimingEnd",{})
end
function T:Next(player: Player,grade: string)
 local a=self.Game.State[player].Attempt
 a.Clears+=1;if grade=="Perfect" then a.Perfects+=1 end
 a.Stage+=1
 if a.Stage<=#a.Plan.Phases then a.Hint=grade.." / follow the next lane";self:Activate(player,a.Plan.Phases[a.Stage]);return end
 if a.Intro or a.Practice then self:Finish(player,true,"Route complete");return end
 a.Phase="Decision";a.Active=nil;a.Token=HttpService:GenerateGUID(false);a.Start=workspace:GetServerTimeNow();a.Duration=C.Round.DecisionSeconds
 a.Hint="SECURE: keep the card. BONUS: +15% quality on clear; a miss keeps 75% quality and adds Heat."
 self:Packet(player)
end
function T:Miss(player: Player,reason: string)
 local G=self.Game;local a=G.State[player].Attempt
 a.Mistakes+=1;a.Hint=reason
 if a.Phase=="Bonus" then a.Quality*=C.Round.BonusFailureQuality;self:Finish(player,true,"Bonus missed / card secured at reduced quality");return end
 if a.Phase=="Recovery" or a.Recoveries>=1 then self:Finish(player,false,reason);return end
 a.Recoveries+=1;a.Quality*=C.Round.RecoveryQuality
 a.Hint=reason.." RECOVER: lane 2 in mint. A clear keeps 80% quality."
 self:Activate(player,Q.recovery(a.Active),"Recovery")
end
function T:Resolve(player: Player,hit: any,expired: boolean?)
 local G=self.Game;local s=G.State[player];local a=s and s.Attempt
 if not a or (a.Phase~="Action" and a.Phase~="Recovery" and a.Phase~="Bonus") then return end
 if not self:Context(player,a) then self:Cancel(player,true);return end
 if expired then self:Miss(player,"Phase timed out. Follow the direction arrow and commit before the timer ends.");return end
 if type(hit)~="table" or hit.Token~=a.Token or type(hit.Lane)~="number" or hit.Lane%1~=0 or hit.Lane<1 or hit.Lane>3 then return end
 local ping=math.clamp(player:GetNetworkPing(),0,C.Round.MaxBackdate)
 if not Q.validTime(hit.At,workspace:GetServerTimeNow(),a.Start,a.Duration,ping,C) then return end
 local grade,reason=Q.grade(hit.At-a.Start,hit.Lane,a.Active)
 if grade=="Miss" then self:Miss(player,reason)
 elseif a.Phase=="Bonus" then a.Bonus=true;a.Quality*=1+C.Round.BonusValue;self:Finish(player,true,"Bonus secured")
 else self:Next(player,if a.Phase=="Recovery" then "Recovered" else grade) end
end
function T:Choice(player: Player,arg: any)
 local s=self.Game.State[player];local a=s and s.Attempt
 if not a or a.Phase~="Decision" or type(arg)~="table" or arg.Token~=a.Token then return end
 if not self:Context(player,a) then self:Cancel(player,true);return end
 if workspace:GetServerTimeNow()>a.Start+a.Duration then self:Finish(player,true,"Safely secured / decision timer ended");return end
 if arg.Choice=="Secure" then self:Finish(player,true,"Safely secured")
 elseif arg.Choice=="Bonus" then self:Activate(player,Q.bonus(a.Plan.Phases[#a.Plan.Phases]),"Bonus") end
end
function T:Tool(player: Player,token: any)
 local G=self.Game;local s=G.State[player];local p=G.Data:Get(player);local a=s and s.Attempt
 if not a or not p or token~=a.Token or a.Practice or a.Phase~="Action" or a.ToolUsed or p.Upgrades.Gadgets<1 or (s.GadgetCharges or 0)<1 or (workspace:GetServerTimeNow()<a.Start or workspace:GetServerTimeNow()>a.Start+a.Duration) then return end
 if not self:Context(player,a) then return end
 a.ToolUsed=true;a.Mistakes+=1;a.Quality*=C.Round.RecoveryQuality;s.GadgetCharges-=1
 self:Next(player,"Tool stabilized")
end
function T:Finish(player: Player,success: boolean,reason: string)
 local G=self.Game;local s=G.State[player];local p=G.Data:Get(player);local a=s and s.Attempt
 if not a or not p then return end
 if success and not self:Context(player,a) then self:Cancel(player,true);return end
 s.Attempt=nil -- payout happens at most once, with no yields in the transaction
 local target=a.Target and G.NPC.Targets[a.Target]
 if target and target.Reserved==player then target.Reserved=nil;target.Available=os.clock()+C.TargetCooldown end
 local stages=#a.Plan.Phases;local medal=Q.medal(success,a.Perfects,stages,a.Mistakes,a.Bonus)
 local score=if success then Q.score(a.Perfects,a.Clears,a.Mistakes,a.Bonus,workspace:GetServerTimeNow()-a.Began) else 0
 local records=p.RoundRecords;local key=a.Mode..":D"..a.District;local best=records.Best[key] or 0
 local newBest=success and score>best;records.Rounds+=1
 if newBest then records.Best[key]=score end
 if (C.MedalRanks[medal] or 0)>(C.MedalRanks[records.Medals[key] or "Retry"] or 0) then records.Medals[key]=medal end
 if a.Mode=="DailyDrill" then local day=math.floor(os.time()/86400);if records.Daily.Day~=day then records.Daily={Day=day,Best=0} end;records.Daily.Best=math.max(records.Daily.Best,score) end
 local result={Success=success,Reason=reason,Mode=a.Mode,Medal=medal,Score=score,Best=records.Best[key] or 0,NewBest=newBest,Stages=stages,Perfects=a.Perfects,Mistakes=a.Mistakes,Bonus=a.Bonus,Practice=a.Practice,Quality=a.Quality,Heat=0,Rep=0,Intake=0,Seconds=workspace:GetServerTimeNow()-a.Began}
 if not a.Practice then
  local heatScale=C.Approaches[a.Approach].Heat*R.heatScale(p.Upgrades.Composure,C)
  result.Heat=((if success then C.Heat.Success else C.Heat.Failure)+a.Mistakes*C.Round.ErrorHeat)*heatScale
  G:Heat(player,result.Heat)
  if not success then s.Combo=0;if target then target.Suspicion=math.min(100,target.Suspicion+35) end
  else
   s.Combo=math.min(C.Stealing.ComboCap,(s.Combo or 0)+1)
   local perfect=a.Perfects==stages and a.Mistakes==0
   local style=C.TargetStyles[a.Style];local approach=C.Approaches[a.Approach]
   local loot=G.Inventory.roll(a.District,perfect,style.Luck*approach.Luck*(1+p.Upgrades.Appraisal*C.Stealing.Appraisal))
   loot.Quality=approach.Value*style.Value*(1+math.max(0,s.Combo-1)*C.Stealing.ComboValue)*a.Quality
   table.insert(s.Loot,loot);result.Milestone=G.Inventory.discover(p,loot);result.Loot=loot;result.Quality=loot.Quality;result.Intake=G.Inventory.value(p,{loot})
   result.Rep=if perfect then 3 else 2;p.Reputation+=result.Rep;p.Stats.Successes+=1;if perfect then p.Stats.Perfects+=1 end;p.Stats.BestCombo=math.max(p.Stats.BestCombo,s.Combo)
   G:Event(player,"success",1);G:Event(player,"collect",1);G:Event(player,"collectD"..a.District,1);if perfect then G:Event(player,"perfect",1) end;G:Event(player,"rarity",C.Cards[loot.Id].Rarity)
  end
  if target and G.NPC.React then G.NPC:React(target.Model.PrimaryPart.Position,if success then "Distracted" else "Alert",22) end
 end
 G.Remote:FireClient(player,"TimingEnd",{});G.Remote:FireClient(player,"RoundResult",result);G:Snapshot(player)
end
function T:Tick(player: Player)
 local s=self.Game.State[player];local a=s and s.Attempt;if not a then return end
 if not self:Context(player,a) then self:Cancel(player,true);return end
 local now=workspace:GetServerTimeNow()
 if a.Phase=="Read" and now>=a.Start+a.Duration then self:Activate(player,a.Plan.Phases[1])
 elseif a.Phase=="Decision" and now>=a.Start+a.Duration then self:Finish(player,true,"Safely secured / decision timer ended")
 elseif a.Phase~="Read" and a.Phase~="Decision" and now>a.Start+a.Duration+C.Round.MaxBackdate+0.1 then self:Resolve(player,nil,true) end
end
return T
