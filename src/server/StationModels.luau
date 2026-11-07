--!strict
-- Original, consistently scaled workshop equipment. No embedded asset scripts.
local F=require(script.Parent.ModelFactory)
local C=require(game:GetService("ReplicatedStorage").Shared.Config)
local P=C.Palette
local S={}
function S.build(parent: Instance,cf: CFrame,kind: string,name: string): BasePart
 local m=F.model(parent,name.." / workstation")
 local steel=Color3.fromRGB(67,79,83);local enamel=Color3.fromRGB(91,123,113);local oak=Color3.fromRGB(135,105,77)
 local collision={}
 local function p(n: string,size: Vector3,off: CFrame,col: Color3,mat: Enum.Material?,solid: boolean?): Part
  local item=F.part(m,n,size,cf*off,col,mat or Enum.Material.Metal);item.CanCollide=solid==true;item.CanTouch=false
  if solid then table.insert(collision,item) end;return item
 end
 local function screen(off: CFrame,title: string)
  p("Monitor housing",Vector3.new(3.7,2.4,.35),off,steel)
  F.sign(m,cf*off*CFrame.new(0,0,-.2),Vector3.new(3.3,1.9,.06),title,P.Mint)
  p("Monitor stand",Vector3.new(.3,1,.3),off*CFrame.new(0,-1.3,.1),steel)
  p("Keyboard",Vector3.new(3,.15,1.05),CFrame.new(0,3.2,-.8),P.Panel)
  for row=1,3 do for key=1,8 do p("Keycap",Vector3.new(.24,.06,.18),CFrame.new(-1.3+key*.3,3.32,-1.3+row*.25),P.Muted) end end
 end
 local front=2
 if kind=="Bank" then
  p("Secure steel cabinet",Vector3.new(6.6,6,2.8),CFrame.new(0,3,0),steel,nil,true)
  for _,side in {-1,1} do p("Inset secure door",Vector3.new(3,5.5,.18),CFrame.new(side*1.6,3,-1.5),enamel);p("Safe handle",Vector3.new(.16,1.3,.28),CFrame.new(side*.45,3,-1.7),P.Gold) end
  p("Intake slot",Vector3.new(2.9,.22,.16),CFrame.new(0,4.6,-1.7),P.Charcoal)
  p("Intake status lamp",Vector3.new(.4,.18,.1),CFrame.new(2.4,5.4,-1.65),P.Mint,Enum.Material.Neon)
  F.sign(m,cf*CFrame.new(0,6.45,-1.3),Vector3.new(5.2,.65,.12),"CARD INTAKE",P.White)
 elseif kind=="Payout" then
  p("Printer stand",Vector3.new(6,2.3,3),CFrame.new(0,1.15,0),steel,nil,true)
  p("Printer enclosure",Vector3.new(5.7,2.7,2.8),CFrame.new(0,3.6,0),enamel,nil,true)
  p("Paper output slot",Vector3.new(3.4,.28,.18),CFrame.new(0,3.1,-1.48),P.Charcoal)
  p("Paper tray",Vector3.new(4,.12,1.6),CFrame.new(0,2.8,-1.9),steel)
  for n=1,3 do p("Invented token receipts",Vector3.new(2.8,.04,1.1),CFrame.new(0,2.9+n*.04,-1.8),Color3.fromRGB(205,202,172)) end
  F.sign(m,cf*CFrame.new(0,4.2,-1.45),Vector3.new(3.5,.6,.08),"PAYOUT",P.Mint)
 elseif kind=="Shop" or kind=="Resupply" then
  p("Workbench top",Vector3.new(7.4,.4,3.6),CFrame.new(0,3,0),oak,Enum.Material.WoodPlanks,true)
  for _,x in {-3,3} do p("Workbench trestle",Vector3.new(.3,3,3),CFrame.new(x,1.5,0),steel,nil,true) end
  p("Lower tool shelf",Vector3.new(6.3,.2,2.8),CFrame.new(0,1,0),steel)
  if kind=="Shop" then
   p("Perforated tool board",Vector3.new(7,3.6,.2),CFrame.new(0,5.2,1.4),steel)
   for n=-2,2 do
    p("Tool shaft",Vector3.new(.12,1.5,.12),CFrame.new(n*1.1,5,1.15),P.Muted)
    p("Tool grip",Vector3.new(.25,.65,.25),CFrame.new(n*1.1,4.4,1.15),if n%2==0 then enamel else oak)
    p("Spanner head",Vector3.new(.5,.3,.12),CFrame.new(n*1.1,5.8,1.15),P.Muted)
   end
   p("Bench vice",Vector3.new(1.3,.8,1),CFrame.new(2.3,3.6,-.5),enamel)
   F.sign(m,cf*CFrame.new(0,7.3,1.2),Vector3.new(5.5,.65,.1),"FIELD EQUIPMENT",P.White)
  else
   p("Supply case",Vector3.new(5.5,1.5,2.3),CFrame.new(0,3.95,.2),enamel)
   for n=1,4 do local tube=p("Decoy canister",Vector3.new(.65,1.1,.65),CFrame.new(-2+n*.85,5.1,.2),if n%2==0 then P.Gold else P.Mint);tube.Shape=Enum.PartType.Cylinder end
   F.sign(m,cf*CFrame.new(0,4.1,-1.05),Vector3.new(4,.65,.1),"DECOY SUPPLIES",P.White)
  end
 elseif kind=="Practice" or kind=="Missions" or kind=="Vault" then
  p("Console desk",Vector3.new(5,.35,3.4),CFrame.new(0,3,0),oak,Enum.Material.WoodPlanks,true)
  for _,side in {-1,1} do p("Console leg",Vector3.new(.35,3,2.8),CFrame.new(side*2,1.5,0),steel,nil,true) end
  screen(CFrame.new(0,5,.4),if kind=="Practice" then "ROUTE TRAINER" elseif kind=="Vault" then "VAULT / 90 REP" else "CONTRACT DESK")
  if kind=="Practice" then for lane=1,3 do F.sign(m,cf*CFrame.new(-1.8+lane*.9,3.4,-1.3),Vector3.new(.6,.4,.08),tostring(lane),P.Mint) end end
  p("Cable conduit",Vector3.new(.1,3,.1),CFrame.new(1.7,1.5,1.3),P.Charcoal)
 elseif kind=="Hideout" then
  p("Route board backing",Vector3.new(6.5,4.8,.3),CFrame.new(0,4,0),oak,Enum.Material.WoodPlanks,true);front=.65
  for _,x in {-2.7,2.7} do p("Board support",Vector3.new(.2,4,.3),CFrame.new(x,2,.1),steel) end
  p("Map sheet",Vector3.new(5.8,3.7,.08),CFrame.new(0,4,-.22),Color3.fromRGB(187,190,177))
  p("Map avenue",Vector3.new(5.2,.07,.04),CFrame.new(0,4,-.29),steel)
  for n=-2,2 do p("Route district",Vector3.new(.15,.8,.07),CFrame.new(n,4,-.32),enamel);p("Pinned destination",Vector3.new(.18,.18,.1),CFrame.new(n,4.55,-.35),P.Gold) end
  F.sign(m,cf*CFrame.new(0,6.8,-.1),Vector3.new(5.5,.65,.1),"COURIER ROUTES",P.White)
 elseif kind=="Garage" then
  p("Intercom pedestal",Vector3.new(.4,3,.4),CFrame.new(0,1.5,0),steel,nil,true)
  p("Intercom enclosure",Vector3.new(2.6,2.8,.8),CFrame.new(0,4,0),enamel,nil,true);front=.8
  F.sign(m,cf*CFrame.new(0,4.8,-.46),Vector3.new(2.2,.6,.08),"COURIER",P.White)
  for n=1,4 do p("Speaker grille",Vector3.new(1,.06,.04),CFrame.new(-.35,3.5+n*.14,-.45),P.Panel) end
  p("Call button",Vector3.new(.35,.35,.12),CFrame.new(.8,3.7,-.5),P.Mint,Enum.Material.Neon)
 elseif kind=="Index" then
  p("Display cabinet",Vector3.new(3.8,5.7,1.4),CFrame.new(0,2.85,0),oak,Enum.Material.WoodPlanks,true);front=1
  for y=1,3 do for x=1,2 do p("Framed collectible",Vector3.new(1.1,.8,.08),CFrame.new(-1.6+x,1+y*1.1,-.78),C.RarityColors[y+x]) end end
  local glass=p("Display glass",Vector3.new(3.4,5.2,.08),CFrame.new(0,2.85,-.86),P.Muted,Enum.Material.Glass);glass.Transparency=.65
  F.sign(m,cf*CFrame.new(0,6.1,-.8),Vector3.new(3.8,.6,.1),"COLLECTION",P.White)
 end
 local handle=p("Interaction point",Vector3.new(.5,.5,.5),CFrame.new(0,3.3,-front),P.Mint);handle.Transparency=1;handle.CanQuery=false;m.PrimaryPart=handle
 return handle
end
return S
