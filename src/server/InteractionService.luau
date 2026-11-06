--!strict
local Shared=game:GetService("ReplicatedStorage").Shared
local C=require(Shared.Config)
local R=require(Shared.Rules)
local HttpService=game:GetService("HttpService")
local T: any={}
function T:Init(gameService: any) self.Game=gameService end
function T:Eligible(player: Player,id: string): any
 local G=self.Game; local p=G.Data:Get(player); local s=G.State[player]; local target=G.NPC.Targets[id]; local root=G:Root(player)
 if not p or not s or not root or not target or s.Attempt or s.Vault then return nil end
 if target.Reserved or target.Available>os.clock() then G:Notify(player,"That target is recovering or busy."); return nil end
 if not p.Districts[tostring(target.District)] then G:Notify(player,"Unlock this district first."); return nil end
 local requirement=C.Districts[target.District].Equipment
 if p.Upgrades.Sleight<requirement then G:Notify(player,"This target needs Sleight "..requirement..". Upgrade at the hideout."); return nil end
 if #s.Loot>=R.capacity(p.Upgrades.Capacity,C) then G:Notify(player,"Pockets full. Bank at a clubhouse terminal."); return nil end
 if (root.Position-target.Model.PrimaryPart.Position).Magnitude>C.InteractDistance or not G.Security:Visible(root.Position,target.Model.PrimaryPart.Position) then G:Notify(player,"Move closer to the target and scout again."); return nil end
 return target
end
function T:Scout(player: Player,id: string)
 local target=self:Eligible(player,id); if not target then return end
 target.PreviewUntil=os.clock()+8
 local p=self.Game.Data:Get(player); local style=target.Style or "Daydreamer"
 self.Game.Remote:FireClient(player,"Scout",{Id=id,Name=target.Model.Name or "Cartoon tourist",Style=style,District=target.District,Stages=if p.Starter==1 then 1 else R.stageCount(target.District,style,C),Suspicion=math.floor(target.Suspicion),Requirement=C.Districts[target.District].Equipment})
end
function T:SendStage(player: Player)
 local G=self.Game; local p=G.Data:Get(player); local a=G.State[player].Attempt
 local approach=C.Approaches[a.Approach]
 local style=C.TargetStyles[a.Style]
 a.Token=HttpService:GenerateGUID(false)
 a.Start=workspace:GetServerTimeNow()+(if a.Stage==1 then C.InteractionLead else C.Stealing.StageLead)
 local challenge=R.challenge(a.District,a.Stage,p.Upgrades.Sleight,p.Upgrades.Focus,approach,style,C)
 a.Duration=challenge.Duration; a.Width=challenge.Width; a.Pattern=challenge.Pattern
 a.Drift=if a.Stage>1 or a.District>2 then challenge.Drift else 0
 if p.Starter==1 and not a.Practice then a.Duration=2.4; a.Width=0.29; a.Drift=0 end
 a.Center=Random.new():NextNumber(C.Timing.MinCenter,C.Timing.MaxCenter)
 local packet=table.clone(a); packet.Name=if a.Practice then "PRACTICE / NO LOOT OR HEAT" else C.Districts[a.District].Name
 G.Remote:FireClient(player,"Timing",packet)
end
function T:Begin(player: Player,id: string,approach: string?)
 local target=self:Eligible(player,id); if not target then return end
 local G=self.Game; local p=G.Data:Get(player); local s=G.State[player]
 local mode=approach or "Careful"; if not C.Approaches[mode] then return end
 local style=target.Style or "Daydreamer"
 target.Reserved=player
 s.Attempt={Target=id,Approach=mode,Style=style,District=target.District,Stage=1,Stages=if p.Starter==1 then 1 else R.stageCount(target.District,style,C),Perfects=0,Practice=false}
 p.Stats.Attempts+=1
 self:SendStage(player)
end
function T:Practice(player: Player)
 local G=self.Game; local s=G.State[player]
 if not s or s.Attempt or s.Vault or not G.Data:Get(player) then return end
 if not G:NearStation(player,"Practice") then G:Notify(player,"Walk to the gold practice arcade in a clubhouse."); return end
 s.Attempt={Practice=true,Approach="Careful",Style="Commuter",District=1,Stage=1,Stages=3,Perfects=0}
 self:SendStage(player)
end
function T:Cancel(player: Player,penalize: boolean?)
 local G=self.Game; local s=G.State[player]; if not s or not s.Attempt then return end
 local a=s.Attempt; local target=a.Target and G.NPC.Targets[a.Target]
 if target and target.Reserved==player then target.Reserved=nil; target.Available=os.clock()+(if penalize then 8 else 3) end
 if penalize and not a.Practice then s.Combo=0; G:Heat(player,C.Stealing.CancelHeat); G:Notify(player,"Trick abandoned · streak lost, +"..C.Stealing.CancelHeat.." Heat.","Failure") end
 s.Attempt=nil; G.Remote:FireClient(player,"TimingEnd",{})
end
function T:Resolve(player: Player,token: string,expired: boolean?)
 local G=self.Game; local p=G.Data:Get(player); local s=G.State[player]; local root=G:Root(player)
 if not p or not s or not s.Attempt or s.Attempt.Token~=token then return end
 local a=s.Attempt; local target=a.Target and G.NPC.Targets[a.Target]
 if not a.Practice and (not target or target.Reserved~=player) then self:Cancel(player); return end
 local elapsed=workspace:GetServerTimeNow()-a.Start
 if not expired and elapsed < -0.1 then return end
 local grade=if expired then "Miss" else R.stageGrade(elapsed-math.clamp(player:GetNetworkPing(),0,C.LatencyAllowance),a)
 if a.Practice then
  if not G:NearStation(player,"Practice") then grade="Miss" end
 elseif not root or (root.Position-target.Model.PrimaryPart.Position).Magnitude>C.InteractDistance or not G.Security:Visible(root.Position,target.Model.PrimaryPart.Position) or not p.Districts[tostring(a.District)] or #s.Loot>=R.capacity(p.Upgrades.Capacity,C) then grade="Miss" end
 if grade=="Perfect" then a.Perfects+=1 end
 if grade~="Miss" and a.Stage<a.Stages then
  a.Stage+=1; a.LastGrade=grade; self:SendStage(player); return
 end
 s.Attempt=nil; G.Remote:FireClient(player,"TimingEnd",{})
 if a.Practice then G:Notify(player,if grade=="Miss" then "Practice missed. Try again; no Heat or loot lost." else "Practice clear! "..a.Perfects.." / 3 perfect stages. Ready for the city.",if grade=="Miss" then "Failure" else "Success"); return end
 target.Reserved=nil; target.Available=os.clock()+C.TargetCooldown
 local heatScale=C.Approaches[a.Approach].Heat*R.heatScale(p.Upgrades.Composure,C)
 if grade=="Miss" then
  s.Combo=0; G:Heat(player,C.Heat.Failure*heatScale); target.Suspicion=math.min(100,target.Suspicion+45)
  for _,other in G.NPC.Targets do if (other.Origin-target.Origin).Magnitude<22 then other.Suspicion=math.min(100,other.Suspicion+20) end end
  G:Notify(player,"BUSTED TRICK · Stage "..a.Stage.." missed. Streak reset; target alerted.","Failure")
 else
  s.Combo=math.min(C.Stealing.ComboCap,(s.Combo or 0)+1)
  local perfect=a.Perfects==a.Stages
  local style=C.TargetStyles[a.Style]; local approach=C.Approaches[a.Approach]
  local luck=style.Luck*approach.Luck*(1+p.Upgrades.Appraisal*C.Stealing.Appraisal)
  local loot=G.Inventory.roll(target.District,perfect,luck)
  loot.Quality=approach.Value*style.Value*(1+math.max(0,s.Combo-1)*C.Stealing.ComboValue)
  table.insert(s.Loot,loot)
  local milestone=G.Inventory.discover(p,loot)
  p.Reputation+=if perfect then 3 else 2; p.Stats.Successes+=1
  if perfect then p.Stats.Perfects+=1 end
  p.Stats.BestCombo=math.max(p.Stats.BestCombo,s.Combo)
  G:Heat(player,C.Heat.Success*heatScale)
  G:Event(player,"success",1); G:Event(player,"collect",1); G:Event(player,"collectD"..target.District,1); if perfect then G:Event(player,"perfect",1) end; G:Event(player,"rarity",C.Cards[loot.Id].Rarity)
  G.Remote:FireClient(player,"Reveal",{Loot=loot,Grade=if perfect then "Perfect" else "Good",Milestone=milestone,Combo=s.Combo})
 end
 G:Snapshot(player)
end
return T
