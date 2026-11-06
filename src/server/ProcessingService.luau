--!strict
-- Entirely fictional arcade economy: cards -> imaginary ink tokens -> cartoon rinse -> Cash.
-- No real payment details, financial methods, accounts, or external services exist here.
local Shared=game:GetService("ReplicatedStorage").Shared
local C=require(Shared.Config)
local R=require(Shared.Rules)
local B: any={}
function B:Init(gameService: any) self.Game=gameService end
function B:Refresh(profile: any,now: number?)
 local q=profile.Processing; local time=now or os.time()
 if q.Ends>0 and time>=q.Ends then
  if q.Stage=="Pressing" then q.Stage="Pressed" elseif q.Stage=="Rinsing" then q.Stage="Ready" end
  q.Ends=0
 end
end
function B:Deposit(player: Player,fromVan: boolean?)
 local G=self.Game; local p=G.Data:Get(player); local s=G.State[player]
 if not p or not s or s.Vault or s.Attempt or not G:NearStation(player,"Bank") then return end
 local loot=if fromVan then p.Van.Stash else s.Loot
 if #loot==0 then G:Notify(player,"Nothing to deposit. Bring cards in your pockets or van."); return end
 local q=p.Processing
 if q.PendingCards+#loot>C.Processing.QueueCapacity then G:Notify(player,"Intake is full. Finish your current batches first."); return end
 local count=#loot; local value=G.Inventory.value(p,loot)
 q.PendingCards+=count; q.PendingValue+=value
 if not s.CaughtTrip or fromVan then
  for _,entry in loot do if entry.Clean~=false then q.PendingClean+=1 end end
 end
 if fromVan then p.Van.Stash={} else s.Loot={}; s.CaughtTrip=false end
 G:Notify(player,"SECURED · "..count.." cards queued ($"..value.." base value). Start the ink press in Operations.","Bank")
end
function B:Act(player: Player,action: string)
 local G=self.Game; local p=G.Data:Get(player); local s=G.State[player]
 if not p or not s or s.Vault or s.Attempt then return end
 self:Refresh(p)
 local q=p.Processing
 if action=="Press" then
  if not G:NearStation(player,"Press") then G:Notify(player,"Use the purple ink press in the hidden hideout."); return end
  if q.Stage~="Idle" or q.PendingCards<1 then G:Notify(player,"Deposit cards and finish any active batch first."); return end
  q.Value=math.floor(q.PendingValue*(1+p.Upgrades.Yield*C.Processing.YieldPerLevel)); q.Cards=q.PendingCards; q.Clean=q.PendingClean
  q.PendingValue=0; q.PendingCards=0; q.PendingClean=0
  q.Stage="Pressing"; q.Started=os.time(); q.Duration=R.processSeconds("Press",p.Upgrades.Press,C); q.Ends=q.Started+q.Duration
  G:Notify(player,"INK PRESS RUNNING · Your fictional tokens are being made.","Click")
 elseif action=="Rinse" then
  if not G:NearStation(player,"Rinse") then G:Notify(player,"Use the mint cartoon-rinse machine in the hideout."); return end
  if q.Stage~="Pressed" then G:Notify(player,"Let the ink press finish before rinsing its cartoon tokens."); return end
  q.Stage="Rinsing"; q.Started=os.time(); q.Duration=R.processSeconds("Rinse",p.Upgrades.Rinse,C); q.Ends=q.Started+q.Duration
  G:Notify(player,"CARTOON RINSE RUNNING · This machine only cleans imaginary ink.","Click")
 elseif action=="Claim" then
  if not G:NearStation(player,"Payout") then G:Notify(player,"Collect the finished payout at the hideout cash printer."); return end
  if q.Stage~="Ready" then G:Notify(player,"Finish pressing and rinsing before collecting Cash."); return end
  local amount,cards,clean=q.Value,q.Cards,q.Clean
  q.Stage="Idle"; q.Value=0; q.Cards=0; q.Clean=0; q.Ends=0; q.Started=0; q.Duration=0 -- Clear before awarding; no yields.
  p.Cash+=amount; p.Reputation+=cards; p.Stats.Banked+=amount
  G:Event(player,"bank",amount); G:Event(player,"process",1)
  if clean>0 then G:Event(player,"clean",clean) end
  G:Notify(player,"PAYOUT COLLECTED · +$"..amount.." · "..cards.." cards processed.","Bank")
 end
end
return B
