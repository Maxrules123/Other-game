--!strict
local C=require(game:GetService("ReplicatedStorage").Shared.Config)
local V: any={ Slots={} }
function V:Init(gameService: any) self.Game=gameService end
function V:Start(player: Player)
 local G=self.Game; local p=G.Data:Get(player); local s=G.State[player]; local root=G:Root(player)
 if not p or not s or not root or s.Vault then return end
 if (root.Position-Vector3.new(-63,3,37)).Magnitude>14 then G:Notify(player,"Use the purple Vault Run kiosk in Starter Street."); return end
 if p.Reputation<C.Vault.Rep then G:Notify(player,"Vault Run needs "..C.Vault.Rep.." Reputation."); return end
 if s.VaultCooldown>os.clock() then G:Notify(player,"Vault cooling down. Try again shortly."); return end
 if #s.Loot>0 then G:Notify(player,"Bank your carried cards before entering the vault."); return end
 local slot=nil
 for i=1,C.Vault.MaxSlots do if not self.Slots[i] then slot=i; break end end
 if not slot then G:Notify(player,"All vault rooms are busy. Try shortly."); return end
 G:CancelInteraction(player)
 self.Slots[slot]=player
 local origin=Vector3.new(0,100,300+slot*45)
 local folder=Instance.new("Model"); folder.Name="PrivateVault_"..player.UserId; folder.ModelStreamingMode=Enum.ModelStreamingMode.Atomic; folder.Parent=workspace
 local part=G.World.Part
 part(folder,"Vault floor",Vector3.new(120,2,24),CFrame.new(origin+Vector3.new(55,-2,0)),C.Palette.Panel)
 for side=-1,1,2 do part(folder,"Vault wall",Vector3.new(120,12,1),CFrame.new(origin+Vector3.new(55,4,side*12)),C.Palette.Charcoal) end
 part(folder,"Vault ceiling",Vector3.new(120,1,24),CFrame.new(origin+Vector3.new(55,11,0)),C.Palette.Charcoal)
 for side=-1,1,2 do part(folder,"Vault end",Vector3.new(1,12,24),CFrame.new(origin+Vector3.new(55+side*60,4,0)),C.Palette.Charcoal) end
 local hazards={}
 for i=1,5 do
  local x=12+i*13
  local beam=part(folder,"Pulsing cartoon security",Vector3.new(1,10,23),CFrame.new(origin+Vector3.new(x,4,0)),C.Palette.Danger,Enum.Material.Neon)
  beam.CanCollide=false
  local sign=part(folder,"Timing indicator",Vector3.new(7,2,0.5),CFrame.new(origin+Vector3.new(x-3,7,-11))*CFrame.Angles(0,math.pi,0),C.Palette.Panel)
  G.World.Label(sign,"WAIT / GO",C.Palette.Mint)
  table.insert(hazards,beam)
 end
 local card=part(folder,"Vault card",Vector3.new(4,2.5,0.3),CFrame.new(origin+Vector3.new(90,3,0)),C.Palette.Gold,Enum.Material.Neon)
 local exit=part(folder,"Exit pad",Vector3.new(8,0.4,20),CFrame.new(origin+Vector3.new(108,-0.7,0)),C.Palette.Mint)
 G.World.Label(exit,"EXIT")
 s.Vault={Slot=slot,Folder=folder,Origin=origin,Return=root.CFrame,Ends=os.clock()+C.Vault.Duration,Hazards=hazards,Card=card,Collected=false,Stage=0,LastX=0}
 s.VaultCooldown=os.clock()+C.Vault.Cooldown
 root.CFrame=CFrame.new(origin+Vector3.new(0,3,0)); s.LastPosition=root.Position; s.Immunity=os.clock()+C.Vault.Duration+5
 G:Notify(player,"VAULT RUN · Cross when beams fade. Grab the gold card, then reach the exit. Jumping cannot bypass beams.","Alert")
end
function V:Finish(player: Player, success: boolean, reason: string?)
 local G=self.Game; local s=G.State[player]; if not s or not s.Vault then return end
 local v=s.Vault; s.Vault=nil
 self.Slots[v.Slot]=nil; v.Folder:Destroy()
 local root=G:Root(player)
 if root then root.CFrame=v.Return; s.LastPosition=root.Position end
 s.Immunity=os.clock()+C.CaptureImmunity
 local profile=G.Data:Get(player)
 if success and profile then
  profile.Cash+=C.Vault.Reward; profile.Reputation+=20; G:Event(player,"vault",1)
  local loot={Id="D5R5",Variant="Golden"}; G.Inventory.discover(profile,loot)
  G:Notify(player,"VAULT CLEAR · +$"..C.Vault.Reward.." +20 REP · Golden Royal Treat indexed!","Bank")
 else G:Notify(player,reason or "Vault ended. Your saved progress is safe.","Failure") end
end
function V:Tick(now: number)
 for player,s in self.Game.State do
  if not s.Vault then continue end
  local v=s.Vault; local root=self.Game:Root(player)
  if not root or now>=v.Ends then self:Finish(player,false,"Vault timer expired. Replay at the kiosk."); continue end
  local pos=root.Position-v.Origin
  if pos.Y < -5 or math.abs(pos.Z)>13 or pos.X < -6 or pos.X>115 then self:Finish(player,false,"You left the vault course."); continue end
  local failed=false
  for i,beam in v.Hazards do
   local active=(now+i*0.6)%4<2.2
   beam.Transparency=if active then 0.12 else 0.92
   local x=12+i*13
   local crossed=v.LastX<x and pos.X>=x
   if active and (math.abs(pos.X-x)<2 or crossed) then self:Finish(player,false,"Cartoon alarm! Wait for faded beams and try again."); failed=true; break end
   if crossed then
    if i>v.Stage+1 then self:Finish(player,false,"Cross each security gate in order."); failed=true; break end
    v.Stage=math.max(v.Stage,i)
   end
  end
  if failed then continue end
  v.LastX=pos.X
  if pos.X>87 and v.Stage==5 and not v.Collected then v.Collected=true; v.Card.Transparency=1; self.Game:Notify(player,"Vault card collected. Reach the mint exit!","Reveal") end
  if pos.X>104 and v.Collected then self:Finish(player,true) end
 end
end
return V
