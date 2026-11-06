--!strict
local Players=game:GetService("Players")
local GuiService=game:GetService("GuiService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local C=require(ReplicatedStorage.Shared.Config)
local R=require(ReplicatedStorage.Shared.Rules)
local P=C.Palette
local U: any={State=nil,Current=nil,Timing=nil,MenuSignature="",NoticeId=0,RevealId=0}
local function round(object: Instance, radius: number?)
 local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,radius or 12); corner.Parent=object
end
local function stroke(object: Instance, color: Color3?)
 local border=Instance.new("UIStroke"); border.Color=color or Color3.fromRGB(64,67,88); border.Thickness=1; border.Parent=object
end
local function frame(parent: Instance, name: string, size: UDim2, position: UDim2?, color: Color3?): Frame
 local f=Instance.new("Frame"); f.Name=name; f.Size=size; f.Position=position or UDim2.new(); f.BackgroundColor3=color or P.Panel; f.BorderSizePixel=0; f.Parent=parent
 return f
end
local function text(parent: Instance, value: string, size: number, color: Color3?, area: UDim2?, position: UDim2?): TextLabel
 local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=value; t.TextColor3=color or P.White; t.TextSize=size; t.Font=Enum.Font.GothamMedium; t.TextXAlignment=Enum.TextXAlignment.Left; t.TextYAlignment=Enum.TextYAlignment.Center; t.TextWrapped=true; t.Size=area or UDim2.new(1,0,0,28); t.Position=position or UDim2.new(); t.Parent=parent
 return t
end
local function button(parent: Instance, title: string, size: UDim2, position: UDim2?, callback: ()->(), color: Color3?): TextButton
 local b=Instance.new("TextButton"); b.Size=size; b.Position=position or UDim2.new(); b.BackgroundColor3=color or P.Purple; b.TextColor3=P.Charcoal; b.Text=title; b.TextSize=14; b.Font=Enum.Font.GothamBold; b.AutoButtonColor=true; b.Selectable=true; b.Parent=parent; round(b,9)
 b.Activated:Connect(function() if U.Audio then U.Audio:Play("Click") end; callback() end)
 return b
end
local function list(parent: Instance, padding: number?)
 local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,padding or 10); layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Parent=parent
 return layout
end
local function comma(n: number): string
 local s=tostring(math.floor(n)); local result=s:reverse():gsub("(%d%d%d)","%1,"):reverse(); return result:gsub("^,","")
end
function U:Send(action: string, arg: any?) self.Remote:FireServer(action,arg) end
function U:Focus(object: GuiObject?)
 if UserInputService.GamepadEnabled then GuiService.SelectedObject=object end
end
function U:Init(remote: RemoteEvent, audio: any, effects: any)
 self.Remote=remote; self.Audio=audio; self.Effects=effects
 local playerGui=Players.LocalPlayer:WaitForChild("PlayerGui")
 local old=playerGui:FindFirstChild("CardCityUI"); if old then old:Destroy() end
 local gui=Instance.new("ScreenGui"); gui.Name="CardCityUI"; gui.ResetOnSpawn=false; gui.DisplayOrder=10; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets; gui.Parent=playerGui; self.Gui=gui
 local root=frame(gui,"Safe layout",UDim2.new(1,-24,1,-20),UDim2.fromOffset(12,10)); root.BackgroundTransparency=1; self.Root=root
 local max=Instance.new("UISizeConstraint"); max.MaxSize=Vector2.new(1120,2000); max.Parent=root; root.AnchorPoint=Vector2.new(0.5,0); root.Position=UDim2.new(0.5,0,0,10)
 local hud=frame(root,"HUD",UDim2.new(1,0,0,122),nil,P.Charcoal); round(hud); stroke(hud)
 text(hud,"CC / CARD CITY",13,P.Mint,UDim2.new(0.6,-16,0,25),UDim2.fromOffset(12,6))
 self.Mode=text(hud,"CONNECTING",10,P.Muted,UDim2.new(0.4,-12,0,25),UDim2.new(0.6,0,0,6)); self.Mode.TextXAlignment=Enum.TextXAlignment.Right
 self.Cash=text(hud,"$0",22,P.Gold,UDim2.new(0.35,-10,0,36),UDim2.fromOffset(12,30))
 self.Rep=text(hud,"0 REP",14,P.Purple,UDim2.new(0.25,0,0,36),UDim2.new(0.35,0,0,30))
 self.Pockets=text(hud,"0 / 5\n$0 carried",12,P.White,UDim2.new(0.4,-12,0,36),UDim2.new(0.6,0,0,30)); self.Pockets.TextXAlignment=Enum.TextXAlignment.Right
 self.HeatText=text(hud,"HEAT 0 / 100 · COOL",10,P.Mint,UDim2.new(1,-24,0,20),UDim2.fromOffset(12,68))
 local track=frame(hud,"Heat track",UDim2.new(1,-24,0,6),UDim2.fromOffset(12,91),P.Panel); round(track,3)
 self.HeatFill=frame(track,"Heat",UDim2.fromScale(0,1),nil,P.Mint); round(self.HeatFill,3)
 self.Immunity=text(hud,"",10,P.Muted,UDim2.new(1,-24,0,16),UDim2.fromOffset(12,100))
 local objective=frame(root,"Current objective",UDim2.new(1,0,0,56),UDim2.fromOffset(0,130),P.Panel); round(objective)
 self.Objective=text(objective,"Opening your save safely…",12,P.White,UDim2.new(1,-24,1,-10),UDim2.fromOffset(12,5))
 self.Context=text(root,"",12,P.White,UDim2.new(1,0,0,64),UDim2.new(0,0,1,-128)); self.Context.TextXAlignment=Enum.TextXAlignment.Center
 local nav=Instance.new("ScrollingFrame"); nav.Name="Navigation"; nav.Size=UDim2.new(1,0,0,54); nav.Position=UDim2.new(0,0,1,-58); nav.BackgroundColor3=P.Charcoal; nav.BorderSizePixel=0; nav.ScrollBarThickness=3; nav.AutomaticCanvasSize=Enum.AutomaticSize.X; nav.CanvasSize=UDim2.new(); nav.ScrollingDirection=Enum.ScrollingDirection.X; nav.Parent=root; round(nav)
 local navList=list(nav,6); navList.FillDirection=Enum.FillDirection.Horizontal; navList.VerticalAlignment=Enum.VerticalAlignment.Center
 local navPad=Instance.new("UIPadding"); navPad.PaddingLeft=UDim.new(0,6); navPad.PaddingRight=UDim.new(0,6); navPad.Parent=nav
 local tabs={"Pockets","Index","Upgrades","Hideout","Districts","Missions","Settings"}
 self.Nav={}
 for _,name in tabs do self.Nav[name]=button(nav,name,UDim2.fromOffset(106,44),nil,function() self:Open(name) end,P.Panel); self.Nav[name].TextColor3=P.White end
 local menu=frame(root,"Menu",UDim2.new(1,0,1,-254),UDim2.fromOffset(0,194),P.Charcoal); round(menu); stroke(menu); menu.Visible=false; self.Menu=menu
 self.MenuTitle=text(menu,"POCKETS",18,P.White,UDim2.new(1,-74,0,48),UDim2.fromOffset(16,0))
 self.CloseButton=button(menu,"X",UDim2.fromOffset(44,44),UDim2.new(1,-50,0,3),function() self:Close() end,P.Panel); self.CloseButton.TextColor3=P.White
 local body=Instance.new("ScrollingFrame"); body.Name="Content"; body.Size=UDim2.new(1,-24,1,-58); body.Position=UDim2.fromOffset(12,52); body.BackgroundTransparency=1; body.BorderSizePixel=0; body.ScrollBarThickness=4; body.ScrollBarImageColor3=P.Purple; body.AutomaticCanvasSize=Enum.AutomaticSize.Y; body.CanvasSize=UDim2.new(); body.Parent=menu; self.Body=body
 list(body,10)
 local pad=Instance.new("UIPadding"); pad.PaddingRight=UDim.new(0,7); pad.PaddingBottom=UDim.new(0,12); pad.Parent=body
 local toast=frame(root,"Notice",UDim2.new(1,-16,0,70),UDim2.new(0,8,0,192),P.Panel); round(toast); stroke(toast,P.Mint); toast.Visible=false; toast.ZIndex=20; self.Toast=toast
 self.ToastText=text(toast,"",13,P.White,UDim2.new(1,-24,1,-16),UDim2.fromOffset(12,8)); self.ToastText.ZIndex=21
 -- A modal owns input while open; its backdrop prevents accidental world clicks.
 local modal=Instance.new("TextButton"); modal.Name="Modal backdrop"; modal.Size=UDim2.fromScale(1,1); modal.BackgroundColor3=Color3.new(); modal.BackgroundTransparency=0.35; modal.Text=""; modal.AutoButtonColor=false; modal.Modal=true; modal.Selectable=false; modal.ZIndex=30; modal.Visible=false; modal.Parent=gui; self.Modal=modal
 local dialog=frame(modal,"Dialog",UDim2.new(1,-36,0,310),UDim2.fromScale(0.5,0.5),P.Charcoal); dialog.AnchorPoint=Vector2.new(0.5,0.5); dialog.ZIndex=31; round(dialog,18); stroke(dialog,P.Purple)
 local constraint=Instance.new("UISizeConstraint"); constraint.MaxSize=Vector2.new(520,310); constraint.Parent=dialog; self.Dialog=dialog
 self.DialogTitle=text(dialog,"",20,P.Gold,UDim2.new(1,-78,0,48),UDim2.fromOffset(16,12)); self.DialogTitle.ZIndex=32
 local dismiss=button(dialog,"X",UDim2.fromOffset(44,44),UDim2.new(1,-54,0,8),function() self:HideDialog() end,P.Panel); dismiss.TextColor3=P.White; dismiss.ZIndex=32
 local dialogScroll=Instance.new("ScrollingFrame"); dialogScroll.Name="Explanation"; dialogScroll.BackgroundTransparency=1; dialogScroll.BorderSizePixel=0; dialogScroll.Size=UDim2.new(1,-32,1,-142); dialogScroll.Position=UDim2.fromOffset(16,64); dialogScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; dialogScroll.CanvasSize=UDim2.new(); dialogScroll.ScrollBarThickness=4; dialogScroll.ZIndex=32; dialogScroll.Parent=dialog
 self.DialogScroll=dialogScroll
 self.DialogText=text(dialogScroll,"",13,P.White,UDim2.new(1,-10,0,0)); self.DialogText.AutomaticSize=Enum.AutomaticSize.Y; self.DialogText.TextYAlignment=Enum.TextYAlignment.Top; self.DialogText.ZIndex=32
 self.DialogConfirm=button(dialog,"Continue",UDim2.new(0.6,-22,0,48),UDim2.new(0,16,1,-64),function() self:ConfirmDialog() end,P.Mint); self.DialogConfirm.ZIndex=32
 self.DialogCancel=button(dialog,"Cancel",UDim2.new(0.4,-14,0,48),UDim2.new(0.6,0,1,-64),function() local action=self.DialogCancelAction; self:HideDialog(); if action then action() end end,P.Panel); self.DialogCancel.TextColor3=P.White; self.DialogCancel.ZIndex=32
 self:BuildTiming()
 self:BuildReveal()
 self.DecoyButton=button(root,"DECOY / G",UDim2.fromOffset(114,44),UDim2.new(1,-114,1,-180),function() self:Send("Decoy") end,P.Purple)
 self.DecoyButton.Visible=false
 local dialogScale=Instance.new("UIScale"); dialogScale.Parent=dialog
 local timingScale=Instance.new("UIScale"); timingScale.Parent=self.TimingLayer:FindFirstChild("Timing card")
 local function resize()
  local compact=gui.AbsoluteSize.Y<520
  self.Menu.Position=if compact then UDim2.new() else UDim2.fromOffset(0,194)
  self.Menu.Size=if compact then UDim2.new(1,0,1,-64) else UDim2.new(1,0,1,-254)
  dialogScale.Scale=math.min(1,math.max(0.6,(gui.AbsoluteSize.Y-16)/310))
  timingScale.Scale=math.min(1,math.max(0.6,(gui.AbsoluteSize.Y-16)/292))
 end
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize); resize()
 remote.OnClientEvent:Connect(function(kind,packet) self:Receive(kind,packet) end)
 self:Send("Ready")
 task.spawn(function()
  while gui.Parent do
   task.wait(0.3)
   if not self.State then self:Send("Ready") end
   self:UpdateContext()
  end
 end)
end
function U:Notice(message: string, sound: string?)
 self.NoticeId+=1; local id=self.NoticeId
 self.ToastText.Text=message; self.Toast.Visible=true; self.Audio:Play(sound or "Click")
 if sound=="Failure" or sound=="Capture" then self.Effects:Shake() end
 task.delay(4,function() if self.NoticeId==id then self.Toast.Visible=false end end)
end
function U:ShowDialog(title: string, message: string, confirm: string, callback: ()->(), canCancel: boolean?)
 self:Close(); self:SkipReveal()
 self.DialogCancel.Text="Cancel"; self.DialogCancelAction=nil; self.DialogCancel.BackgroundColor3=P.Panel; self.DialogCancel.TextColor3=P.White
 self.DialogTitle.Text=title; self.DialogText.Text=message; self.DialogConfirm.Text=confirm; self.DialogCancel.Visible=canCancel==true
 self.DialogScroll.CanvasPosition=Vector2.zero
 self.DialogCallback=callback; self.Modal.Visible=true; self:Focus(self.DialogConfirm)
end
function U:HideDialog()
 self.Modal.Visible=false; self.DialogCallback=nil; self.DialogCancelAction=nil; self:Focus(nil)
end
function U:ConfirmDialog()
 local callback=self.DialogCallback; self:HideDialog(); if callback then callback() end
end
function U:Close()
 self.Current=nil; self.Menu.Visible=false; self.MenuSignature=""
 for _,b in self.Nav do b.BackgroundColor3=P.Panel end
 self:Focus(nil)
end
function U:Open(name: string)
 if self.Timing or self.Modal.Visible then return end
 if self.Current==name then self:Close(); return end
 self.Current=name; self.Menu.Visible=true; self.MenuTitle.Text=string.upper(name); self.MenuSignature=""
 for key,b in self.Nav do b.BackgroundColor3=if key==name then P.Purple else P.Panel end
 self.Audio:Play("Click"); self:RenderMenu(); self:Focus(self.CloseButton)
end
function U:Row(height: number): Frame
 local row=frame(self.Body,"Row",UDim2.new(1,0,0,height),nil,P.Panel); round(row,10)
 return row
end
function U:Note(message: string, color: Color3?): Frame
 local row=self:Row(66); text(row,message,12,color or P.Muted,UDim2.new(1,-24,1,-12),UDim2.fromOffset(12,6)); return row
end
function U:Signature(): string
 if not self.State then return "" end
 local p=self.State.Profile
 local bits={tostring(p.Cash),tostring(p.Reputation),tostring(p.Starter),tostring(p.StarterProgress),tostring(#self.State.Loot),tostring(p.Daily.Day),tostring(p.Identities),tostring(self.State.Vault~=nil)}
 for _,name in C.UpgradeOrder do table.insert(bits,tostring(p.Upgrades[name])) end
 for _,name in C.HideoutOrder do table.insert(bits,tostring(p.Hideout[name])) end
 local secrets=0; for _ in p.Secrets do secrets+=1 end; table.insert(bits,tostring(secrets))
 table.insert(bits,tostring(p.Stats.Successes)); table.insert(bits,tostring(p.Stats.BestCombo))
 for i=1,5 do table.insert(bits,tostring(p.Districts[tostring(i)])) end
 local count=0; for _ in p.Collection do count+=1 end; table.insert(bits,tostring(count))
 for i=1,#C.DailyPool do table.insert(bits,tostring(p.Daily.Progress[tostring(i)])); table.insert(bits,tostring(p.Daily.Claimed[tostring(i)])) end
 for _,key in {"Music","Effects","ReducedMotion","Shake"} do table.insert(bits,tostring(p.Settings[key])) end
 return table.concat(bits,"|")
end
function U:RenderMenu()
 if not self.Current or not self.State then return end
 local signature=self:Signature()..self.Current
 if signature==self.MenuSignature then return end
 self.MenuSignature=signature
 local position=self.Body.CanvasPosition
 local selected=GuiService.SelectedObject
 local hadFocus=selected and selected:IsDescendantOf(self.Body)
 for _,child in self.Body:GetChildren() do if child:IsA("GuiObject") then child:Destroy() end end
 local p=self.State.Profile
 if self.Current=="Pockets" then
  self:Note("UNBANKED · Capture removes "..math.floor(C.CaptureFraction*100).."% of carried cards (rounded up). Discoveries always stay in your Index.")
  local row=self:Row(68)
  text(row,#self.State.Loot.." / "..R.capacity(p.Upgrades.Capacity,C).." cards · $"..comma(self.State.Value),16,P.Gold,UDim2.new(1,-24,0,28),UDim2.fromOffset(12,4))
  button(row,"Bank at hideout",UDim2.new(1,-24,0,32),UDim2.fromOffset(12,32),function() self:Send("Bank") end,P.Mint)
  if #self.State.Loot==0 then self:Note("Your pockets are empty. Look for cartoon tourists near Crumb Mart.") end
  for _,loot in self.State.Loot do
   local multiplier=1
   for _,variant in C.Variants do if variant.Name==loot.Variant then multiplier=variant.Multiplier end end
   local amount=R.lootValue(C.Cards[loot.Id].Value,multiplier*(loot.Quality or 1)*R.galleryBonus(p,C),p.Upgrades.Terminal,p.Identities,C)
   self:CardRow(loot.Id,loot.Variant.." ×"..multiplier.." / Quality ×"..string.format("%.2f",loot.Quality or 1).." / Bank $"..comma(amount),true)
  end
 elseif self.Current=="Index" then
  local total=0; local count=0
  for _ in C.Cards do total+=#C.Variants end
  for _ in p.Collection do count+=1 end
  self:Note("CARD INDEX · "..count.." / "..total.." variants discovered. Permanent across captures and New Identity. Milestones pay automatically.",P.Mint)
  for _,milestone in C.Milestones do self:Note(milestone.Count.." discoveries → $"..milestone.Cash..(if count>=milestone.Count then " · CLAIMED" else ""),P.Gold) end
  for district=1,5 do
   for rarity=1,6 do
    local id=string.format("D%dR%d",district,rarity)
    if not C.Cards[id] then continue end
    local discovered=false; local variants={}
    for _,variant in C.Variants do
     local seen=p.Collection[id..":"..variant.Name]
     if seen then discovered=true end
     table.insert(variants,(if seen then "✓ " else "? ")..variant.Name.." ×"..variant.Multiplier)
    end
    self:CardRow(id,table.concat(variants,"  /  "),discovered)
   end
  end
 elseif self.Current=="Upgrades" then
  self:Note("Buy upgrades inside any mint hideout. Cash is spent; Reputation is kept. Sleight unlocks tougher targets. New Identity bank bonus: +"..math.floor((R.identityBonus(p.Identities,C)-1)*100+0.5).."%.")
  for _,name in C.UpgradeOrder do
   local def=C.Upgrades[name]; local level=p.Upgrades[name]; local price=R.upgradeCost(def.BaseCost,def.Growth,level)
   local row=self:Row(202)
   text(row,(if name=="Terminal" then "HIDEOUT TERMINAL" else string.upper(name)).." · "..level.." / "..def.Max,15,P.White,UDim2.new(1,-24,0,30),UDim2.fromOffset(12,6))
   local rep=C.UpgradeRep[level+1] or 0
   local rank=C.UpgradeRanks[math.clamp(math.ceil(math.max(1,level)/2),1,#C.UpgradeRanks)]
   text(row,rank.." · "..def.Description,12,P.Muted,UDim2.new(1,-24,0,42),UDim2.fromOffset(12,36))
   text(row,"NOW / "..R.upgradeEffect(name,level,C).."\nNEXT / "..(if level>=def.Max then "Fully upgraded" else R.upgradeEffect(name,level+1,C)).."\nRequires "..rep.." REP (kept)",11,P.Mint,UDim2.new(1,-24,0,64),UDim2.fromOffset(12,82))
   local rail=frame(row,"Upgrade progress",UDim2.new(1,-24,0,4),UDim2.fromOffset(12,149),P.Charcoal); round(rail,2)
   frame(rail,"Progress",UDim2.fromScale(level/def.Max,1),nil,P.Purple)
   button(row,if level>=def.Max then "MAX LEVEL" else "Upgrade · $"..comma(price),UDim2.new(1,-24,0,44),UDim2.fromOffset(12,158),function() self:Send("Buy",name) end,if p.Cash>=price and p.Reputation>=rep and level<def.Max then P.Mint else P.Muted)
  end
  local row=self:Row(112)
  text(row,"NEW IDENTITY · "..p.Identities.." earned",15,P.Gold,UDim2.new(1,-24,0,30),UDim2.fromOffset(12,6))
  text(row,"All districts + all starter jobs + $100,000 + 1,000 REP",11,P.Muted,UDim2.new(1,-24,0,26),UDim2.fromOffset(12,34))
  button(row,"Review New Identity",UDim2.new(1,-24,0,40),UDim2.fromOffset(12,64),function() self:Send("PrestigeInfo") end,P.Gold)
 elseif self.Current=="Hideout" then
  self:RenderHideout()
 elseif self.Current=="Districts" then
  self:Note("One connected city. Travel east along the road. Unlocks spend Cash and require Reputation; your Reputation remains yours.")
  for i,d in C.Districts do
   local row=self:Row(144)
   text(row,string.format("%02d / %s",i,string.upper(d.Name)),15,d.Color,UDim2.new(1,-24,0,34),UDim2.fromOffset(12,4))
   text(row,"$"..comma(d.Cash).." + "..d.Rep.." REP · Targets need Sleight "..d.Equipment.."\n"..d.Landmark,12,P.Muted,UDim2.new(1,-24,0,48),UDim2.fromOffset(12,40))
   button(row,if p.Districts[tostring(i)] then "DISTRICT OPEN" else "Unlock · $"..comma(d.Cash),UDim2.new(1,-24,0,44),UDim2.fromOffset(12,92),function() self:Send("Unlock",i) end,if p.Districts[tostring(i)] then P.Muted else P.Purple)
  end
 elseif self.Current=="Missions" then
  if self.State.Vault then
   local leave=self:Row(58)
   button(leave,"Leave Vault Run",UDim2.new(1,-16,0,44),UDim2.fromOffset(8,7),function() self:Send("VaultLeave") end,P.Danger)
  end
  local job=C.StarterMissions[p.Starter]
  if job then self:Note("CURRENT JOB · "..job.Title.."\n"..job.Text.." ("..math.min(p.StarterProgress,job.Goal).."/"..job.Goal..")",P.Mint) else self:Note("Starter jobs complete. Explore the city, finish dailies, or prepare a New Identity.",P.Mint) end
  self:Note("DAILY ODD JOBS · Three jobs rotate at 00:00 UTC. Rewards are claimed once per day on the server.",P.Gold)
  for _,id in R.dailyIds(p.Daily.Day,#C.DailyPool) do
   local key=tostring(id); local d=C.DailyPool[id]; local progress=p.Daily.Progress[key] or 0
   local row=self:Row(130)
   text(row,d.Title.." · "..progress.." / "..d.Goal,16,P.White,UDim2.new(1,-24,0,34),UDim2.fromOffset(12,4))
   text(row,"$"..d.Cash.." + "..d.Rep.." REP · "..d.Kind,12,P.Muted,UDim2.new(1,-24,0,32),UDim2.fromOffset(12,38))
   button(row,if p.Daily.Claimed[key] then "CLAIMED" elseif progress>=d.Goal then "Claim reward" else "IN PROGRESS",UDim2.new(1,-24,0,44),UDim2.fromOffset(12,76),function() self:Send("Claim",key) end,if not p.Daily.Claimed[key] and progress>=d.Goal then P.Mint else P.Muted)
  end
  local row=self:Row(136)
  text(row,"VAULT RUN · "..C.Vault.Rep.." REP required",15,P.Gold,UDim2.new(1,-24,0,32),UDim2.fromOffset(12,4))
  text(row,"Use the purple kiosk in Starter Street. Bank pockets first. Dodge pulsing beams, grab the card, exit in 65s.",12,P.Muted,UDim2.new(1,-24,0,48),UDim2.fromOffset(12,38))
  button(row,"Start at kiosk",UDim2.new(1,-24,0,40),UDim2.fromOffset(12,88),function() self:Send("Vault") end,P.Gold)
 elseif self.Current=="Settings" then
  self:Note("FICTIONAL FUN ONLY · Decorative cards, invented banks, imaginary currency. No real payment information is used.",P.Mint)
  for _,key in {"Music","Effects"} do
   local row=self:Row(104)
   text(row,key.." volume · "..math.floor(p.Settings[key]*100+0.5).."%",15,P.White,UDim2.new(1,-24,0,40),UDim2.fromOffset(12,4))
   for i,value in {0,0.35,0.7,1} do
    button(row,tostring(math.floor(value*100+0.5)).."%",UDim2.new(0.25,-9,0,44),UDim2.new((i-1)*0.25,7,0,50),function() self:Send("Setting",{Key=key,Value=value}) end,if math.abs(p.Settings[key]-value)<0.01 then P.Mint else P.Muted)
   end
  end
  for _,key in {"ReducedMotion","Shake"} do
   local row=self:Row(98)
   local title=if key=="ReducedMotion" then "Reduced motion" else "Camera shake"
   text(row,title,15,P.White,UDim2.new(1,-24,0,34),UDim2.fromOffset(12,4))
   button(row,if p.Settings[key] then "ON · toggle" else "OFF · toggle",UDim2.new(1,-24,0,44),UDim2.fromOffset(12,44),function() self:Send("Setting",{Key=key,Value=not p.Settings[key]}) end,P.Purple)
  end
  self:Note("CONTROLS · E / X / tap: interact. Space / A / tap: stop timing. Tab / Y: menus. G / R1: decoy. Escape / B: close. Use the bottom tabs for every panel.")
  self:Note("Audio slots are ready; permitted sound assets have not been configured. UI feedback remains visual.")
  self:Note("Identity badges: "..p.Identities..". Collection discoveries, identity badges, settings, milestone claims, daily progress, clubhouse upgrades, city secrets, and career statistics survive New Identity.",P.Gold)
 end
 self.Body.CanvasPosition=position
 if hadFocus then
  local nextButton=self.Body:FindFirstChildWhichIsA("TextButton",true)
  self:Focus(nextButton or self.CloseButton)
 end
end
function U:CardRow(id: string, variant: string, discovered: boolean)
 local card=C.Cards[id]; if not card then return end
 local row=self:Row(116); stroke(row,if discovered then C.RarityColors[card.Rarity] else P.Muted)
 local color=if discovered then C.RarityColors[card.Rarity] else P.Muted
 text(row,if discovered then card.Brand.." / "..C.Rarities[card.Rarity] else "? UNDISCOVERED / "..C.Rarities[card.Rarity],14,color,UDim2.new(1,-24,0,28),UDim2.fromOffset(12,6))
 text(row,if discovered then card.Name else C.Districts[card.District].Name.." · silhouette",11,P.White,UDim2.new(1,-24,0,28),UDim2.fromOffset(12,32))
 text(row,variant,11,P.Muted,UDim2.new(1,-24,0,40),UDim2.fromOffset(12,62))
end
function U:UpdateState(packet: any)
 local previous=self.State
 self.State=packet; local p=packet.Profile
 self.Audio:Update(p.Settings); self.Effects.Settings=p.Settings
 self.Mode.Text=if packet.Development then "STUDIO TEST DATA" else "CARD CITY / LIVE"
 self.Cash.Text="$"..comma(p.Cash); self.Rep.Text=comma(p.Reputation).." REP"
 if previous and p.Cash>previous.Profile.Cash then
  self.Cash.TextColor3=P.Mint; self.Effects:Tween(self.Cash,{TextColor3=P.Gold},0.6)
 end
 self.Pockets.Text=#packet.Loot.." / "..R.capacity(p.Upgrades.Capacity,C).." cards\n$"..comma(packet.Value).." carried"
 local heat=math.floor(packet.Heat)
 local color=if heat>=55 then P.Danger elseif heat>=25 then P.Gold else P.Mint
 self.HeatText.Text="HEAT "..heat.." / 100 · "..(if packet.Chase then "CHASE! BREAK SIGHT" elseif heat>=55 then "SECURITY ALERT" elseif heat>=25 then "GETTING WARM" else "COOL")
 self.HeatText.TextColor3=color
 self.Effects:Tween(self.HeatFill,{Size=UDim2.fromScale(packet.Heat/100,1),BackgroundColor3=color},0.25)
 self.Immunity.Text=(if packet.Immunity>0 then "Grace "..math.ceil(packet.Immunity).."s / " else "").."STREAK "..packet.Combo.." / "..C.Stealing.ComboCap.." · DECOYS "..packet.Gadget.Charges.." / "..packet.Gadget.Max
 self.DecoyButton.Text=if packet.Gadget.Cooldown>0 then "DECOY "..math.ceil(packet.Gadget.Cooldown).."s" else "DECOY / "..packet.Gadget.Charges
 if self.HideoutController then self.HideoutController:Update(packet) end
 if packet.Vault then self.Objective.Text="VAULT RUN · "..math.ceil(packet.Vault.Remaining).."s · "..packet.Vault.Stage.." / 5 gates\n"..(if packet.Vault.Collected then "Gold card secured. Reach the mint exit!" else "Wait for faded beams → collect the gold card → exit")
 else
  local job=C.StarterMissions[p.Starter]
  if job then self.Objective.Text="NEXT / "..job.Title.." · "..p.StarterProgress.." / "..job.Goal.."\n"..job.Text
  elseif #packet.Loot>0 then self.Objective.Text="NEXT / Bank $"..comma(packet.Value).." at a mint hideout, or risk another target."
  else self.Objective.Text="NEXT / Explore, collect, complete daily jobs. Your next big score is around the corner." end
 end
 self:RenderMenu()
end
function U:UpdateContext()
 if self.State then self.DecoyButton.Visible=self.State.Profile.Upgrades.Gadgets>0 and not self.Current and not self.Timing and not self.Modal.Visible and not self.State.Vault end
 if self.HideoutController and self.State then self.HideoutController:RefreshSecrets(self.State.Profile) end
 if not self.State or self.Current or self.Timing or self.Modal.Visible then self.Context.Text=""; return end
 if self.State.Vault then self.Context.Text="Beams bright = WAIT · Beams faded = GO · Missions to leave"; return end
 local char=Players.LocalPlayer.Character; local root=char and char:FindFirstChild("HumanoidRootPart")
 local city=workspace:FindFirstChild("CardCity"); local actors=city and city:FindFirstChild("Actors")
 if not root or not actors then self.Context.Text=""; return end
 local closest=nil; local distance=16
 for _,model in actors:GetChildren() do
  if model:IsA("Model") and model.PrimaryPart and model:GetAttribute("TargetId") then
   local d=(model.PrimaryPart.Position-root.Position).Magnitude
   if d<distance then closest=model; distance=d end
  end
 end
 if closest then
  local id=closest:GetAttribute("TargetId"); local district=tonumber(string.match(id,"D(%d+)")) or 1
  local need=C.Districts[district].Equipment
  local sleight=self.State.Profile.Upgrades.Sleight
  local style=closest:GetAttribute("Style") or "Daydreamer"
  local duration=(C.Timing.BaseDuration-district*C.Timing.DistrictSpeed)*(1-sleight*C.Timing.SleightSpeed)
  self.Context.Text=string.format("DIFFICULTY %d · %.1fs/stage · SUSPICION %d%%\n%s",district,duration,closest:GetAttribute("Suspicion") or 0,if sleight>=need then C.TargetStyles[style].Name.." · SCOUT / CHOOSE APPROACH" else "EQUIPMENT TOO LOW · Need Sleight "..need)
 else self.Context.Text=if #self.State.Loot>0 then "Mint hideout = bank cards + recover Heat" else "Find a tourist near the colorful sidewalks" end
end
function U:BuildTiming()
 local layer=frame(self.Gui,"Timing layer",UDim2.fromScale(1,1),nil,P.Charcoal); layer.BackgroundTransparency=0.5; layer.Visible=false; layer.ZIndex=40; self.TimingLayer=layer
 local box=frame(layer,"Timing card",UDim2.new(1,-32,0,292),UDim2.fromScale(0.5,0.52),P.Charcoal); box.AnchorPoint=Vector2.new(0.5,0.5); box.ZIndex=41; round(box,18); stroke(box,P.Purple)
 local constraint=Instance.new("UISizeConstraint"); constraint.MaxSize=Vector2.new(600,292); constraint.Parent=box
 local t=text(box,"POCKET TRICK",20,P.Mint,UDim2.new(1,-32,0,34),UDim2.fromOffset(16,12)); t.ZIndex=42; self.TimingTitle=t
 self.TimingCaption=text(box,"Stop the marker inside the mint zone.",13,P.Muted,UDim2.new(1,-32,0,40),UDim2.fromOffset(16,51)); self.TimingCaption.ZIndex=42
 local track=frame(box,"Track",UDim2.new(1,-40,0,44),UDim2.fromOffset(20,104),P.Panel); round(track,8); track.ZIndex=42
 self.Zone=frame(track,"Success zone",UDim2.fromScale(0.2,1),nil,P.Mint); self.Zone.BackgroundTransparency=0.2; self.Zone.ZIndex=43; round(self.Zone,6)
 local mark=text(self.Zone,"GOOD",12,P.Charcoal,UDim2.fromScale(1,1)); mark.TextXAlignment=Enum.TextXAlignment.Center; mark.ZIndex=44
 self.Perfect=frame(track,"Perfect center",UDim2.fromScale(0.04,1),nil,P.Gold); self.Perfect.ZIndex=44; self.Perfect.BackgroundTransparency=0.35
 self.Marker=frame(track,"Moving marker",UDim2.new(0,4,1,12),UDim2.fromOffset(0,-6),P.White); self.Marker.ZIndex=45; self.Marker.AnchorPoint=Vector2.new(0.5,0)
 self.StopButton=button(box,"STOP · SPACE / A",UDim2.new(1,-40,0,56),UDim2.fromOffset(20,170),function() self:StopTiming() end,P.Mint); self.StopButton.ZIndex=42
 local cancel=button(box,"Cancel",UDim2.new(1,-40,0,40),UDim2.fromOffset(20,236),function() self:Send("Cancel"); self:EndTiming() end,P.Panel); cancel.TextColor3=P.Muted; cancel.ZIndex=42
end
function U:StartTiming(packet: any)
 self:Close(); self:SkipReveal(); self:HideDialog(); self.Toast.Visible=false
 self:EndTiming(); self.Timing=packet; self.Timing.Submitted=false
 self.TimingLayer.Visible=true
 self.TimingTitle.Text=(if packet.Practice then "PRACTICE" else string.upper(packet.Approach).." TRICK").." / "..packet.Stage.." OF "..packet.Stages
 self.TimingCaption.Text=string.upper(packet.Pattern).." · "..(if packet.Stage==1 then "Mint = good. Gold = perfect. Clear every stage." else (packet.LastGrade or "Good").."! Now follow the drifting mint zone.")
 if packet.Stage>1 then self.Audio:Play("Success") end
 self.Zone.Size=UDim2.fromScale(packet.Width,1); self.Zone.Position=UDim2.fromScale(packet.Center-packet.Width/2,0)
 self.Perfect.Size=UDim2.fromScale(packet.Width*0.4,1); self.Perfect.Position=UDim2.fromScale(packet.Center-packet.Width*0.2,0)
 self:Focus(self.StopButton)
 self.TimingConnection=RunService.RenderStepped:Connect(function()
  if not self.Timing or self.Timing.Submitted then return end
  local elapsed=workspace:GetServerTimeNow()-packet.Start
  self.Marker.Position=UDim2.new(R.cursor(elapsed,packet.Duration,packet.Pattern),0,0,-6)
  local center=R.zone(elapsed,packet.Duration,packet.Center,packet.Drift,packet.Width)
  self.Zone.Position=UDim2.fromScale(center-packet.Width/2,0)
  self.Perfect.Position=UDim2.fromScale(center-packet.Width*0.2,0)
  self.StopButton.Text=if elapsed<0 then "GET READY…" else "STOP · SPACE / A"
  if elapsed>packet.Duration+0.4 then self.TimingCaption.Text="Waiting for server result…" end
 end)
end
function U:StopTiming()
 if not self.Timing or self.Timing.Submitted or workspace:GetServerTimeNow()<self.Timing.Start then return end
 self.Timing.Submitted=true; self:Send("Stop",self.Timing.Token); self.StopButton.Text="CHECKING…"
end
function U:EndTiming()
 if self.TimingConnection then self.TimingConnection:Disconnect(); self.TimingConnection=nil end
 self.Timing=nil; self.TimingLayer.Visible=false; self:Focus(nil)
end
function U:BuildReveal()
 local card=frame(self.Root,"Card reveal",UDim2.new(1,-24,0,194),UDim2.new(0.5,0,1,-72),P.Panel); card.AnchorPoint=Vector2.new(0.5,1); card.ZIndex=25; card.Visible=false; round(card,16); stroke(card,P.Gold)
 local max=Instance.new("UISizeConstraint"); max.MaxSize=Vector2.new(450,194); max.Parent=card; self.Reveal=card
 self.RevealHeader=text(card,"PERFECT / COMMON",12,P.Mint,UDim2.new(1,-28,0,30),UDim2.fromOffset(14,6)); self.RevealHeader.ZIndex=26
 self.RevealBrand=text(card,"Crumb Bank",24,P.Gold,UDim2.new(1,-28,0,38),UDim2.fromOffset(14,36)); self.RevealBrand.ZIndex=26
 self.RevealName=text(card,"Pocket Crumbs",12,P.White,UDim2.new(1,-28,0,38),UDim2.fromOffset(14,78)); self.RevealName.ZIndex=26
 local decorative=text(card,"◈   FICTIONAL COLLECTIBLE   /   CCSS",10,P.Muted,UDim2.new(1,-28,0,24),UDim2.fromOffset(14,117)); decorative.ZIndex=26
 local skip=button(card,"Nice! / Skip",UDim2.new(1,-28,0,40),UDim2.fromOffset(14,146),function() self:SkipReveal() end,P.Mint); skip.ZIndex=26
end
function U:SkipReveal() self.RevealId+=1; self.Reveal.Visible=false end
function U:ShowReveal(packet: any)
 self.RevealId+=1; local id=self.RevealId
 local card=C.Cards[packet.Loot.Id]
 self.Reveal.Visible=true; self.RevealHeader.Text=string.upper(packet.Grade.." / "..C.Rarities[card.Rarity].." / "..packet.Loot.Variant)
 self.RevealHeader.TextColor3=C.RarityColors[card.Rarity]; self.RevealBrand.Text=card.Brand; self.RevealName.Text=card.Name.."\nQuality ×"..string.format("%.2f",packet.Loot.Quality or 1).." · Streak "..(packet.Combo or 0)
 self.Reveal.BackgroundColor3=if packet.Loot.Variant=="Golden" then Color3.fromRGB(65,53,31) elseif packet.Loot.Variant=="Glitched" then Color3.fromRGB(50,30,70) elseif packet.Loot.Variant=="Foil" then Color3.fromRGB(30,57,65) else P.Panel
 self.Audio:Play(if card.Rarity>=3 then "Reveal" else "Success")
 local root=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
 if root then self.Effects:Celebrate(root.Position,C.RarityColors[card.Rarity]) end
 if not self.Effects.Settings.ReducedMotion then self.Reveal.Position=UDim2.new(0.5,0,1,-54); self.Effects:Tween(self.Reveal,{Position=UDim2.new(0.5,0,1,-72)},0.25) end
 if packet.Milestone>0 then self:Notice("Collection milestone · +$"..packet.Milestone,"Success") end
 task.delay(3,function() if self.RevealId==id then self:SkipReveal() end end)
end
function U:RenderHideout()
 local p=self.State.Profile; local discoveries=0; local found=0
 for _ in p.Collection do discoveries+=1 end
 for _ in p.Secrets do found+=1 end
 self:Note("CRUMB CLUB · Your clubhouse improvements survive New Identity. Your gallery and decorations are personal; other players keep their own progress.",P.Mint)
 self:Note("CAREER · "..p.Stats.Successes.." cards secured · "..p.Stats.Perfects.." perfect tricks · Best streak "..p.Stats.BestCombo.."\n$"..comma(p.Stats.Banked).." banked · "..found.." / 15 secrets · "..discoveries.." card discoveries",P.Gold)
 local tools=self:Row(160)
 text(tools,"PRACTICE & SUPPLIES",16,P.White,UDim2.new(1,-24,0,30),UDim2.fromOffset(12,4))
 text(tools,"Use the practice arcade for three risk-free timing stages. The mint bench refills decoys; use G / R1 / DECOY outside.",12,P.Muted,UDim2.new(1,-24,0,44),UDim2.fromOffset(12,34))
 button(tools,"Practice at arcade",UDim2.new(0.5,-16,0,54),UDim2.fromOffset(12,92),function() self:Send("Practice") end,P.Gold)
 button(tools,"Restock at bench",UDim2.new(0.5,-16,0,54),UDim2.new(0.5,4,0,92),function() self:Send("Resupply") end,P.Mint)
 for _,name in C.HideoutOrder do
  local def=C.HideoutUpgrades[name]; local level=p.Hideout[name]; local price=R.upgradeCost(def.BaseCost,def.Growth,level)
  local row=self:Row(160)
  text(row,def.Name.." · "..level.." / "..def.Max,15,P.Mint,UDim2.new(1,-24,0,30),UDim2.fromOffset(12,5))
  text(row,def.Description.."\nRequires "..def.Rep*(level+1).." REP · Permanent through prestige",12,P.Muted,UDim2.new(1,-24,0,66),UDim2.fromOffset(12,37))
  button(row,if level>=def.Max then "ROOM COMPLETE" else "Improve · $"..comma(price),UDim2.new(1,-24,0,44),UDim2.fromOffset(12,108),function() self:Send("HideoutBuy",name) end,if level<def.Max and p.Cash>=price and p.Reputation>=def.Rep*(level+1) then P.Purple else P.Muted)
 end
 self:Note("COURIER ROUTES · Use the route board at the back of any clubhouse. Bank all cards, lose security, and cool below 20 Heat. Only unlocked districts are available.",P.Gold)
 for i,d in C.Districts do
  local required=math.max(1,math.ceil((i-1)/2)); local fare=R.travelCost(p.Hideout.Network,i,C)
  local row=self:Row(104)
  text(row,d.Name.." · Network "..required,14,d.Color,UDim2.new(1,-24,0,36),UDim2.fromOffset(12,4))
  button(row,if p.Districts[tostring(i)] then "Book courier · $"..fare else "DISTRICT LOCKED",UDim2.new(1,-24,0,48),UDim2.fromOffset(12,47),function() self:Send("Travel",i) end,if p.Hideout.Network>=required and p.Districts[tostring(i)] then P.Mint else P.Muted)
 end
 self:Note("CITY JOURNAL · Fifteen hidden souvenirs, three in every district. Each pays once and remains discovered through New Identity.",P.Mint)
 for district=1,5 do for n=1,3 do
  local id=string.format("S%d_%d",district,n); local def=C.Secrets[id]
  self:Note((if p.Secrets[id] then "✓ DISCOVERED · " else "? ")..C.Districts[district].Name.." / "..def.Name.."\n"..(if p.Secrets[id] then "Saved to your clubhouse journal." else def.Hint.." $"..def.Cash.." + "..def.Rep.." REP"),if p.Secrets[id] then P.Mint else P.Muted)
 end end
end
function U:Receive(kind: string, packet: any)
 if kind=="State" then self:UpdateState(packet)
 elseif kind=="Scout" then
  local style=C.TargetStyles[packet.Style]; local rarities={}
  for i,weight in C.Districts[packet.District].Weights do if weight>0 then table.insert(rarities,C.Rarities[i]) end end
  self:ShowDialog(packet.Name.." / "..style.Name,style.Flavor.."\n\n"..C.Districts[packet.District].Name.." · "..packet.Stages.." timing stages · Sleight "..packet.Requirement.." · Suspicion "..packet.Suspicion.."%\nPossible cards: "..table.concat(rarities,", ").."\n\nCAREFUL / "..C.Approaches.Careful.Description.."\n\nBOLD / "..C.Approaches.Bold.Description.."\n\nOne card is awarded only after every stage. Leaving or canceling a live trick loses your streak.","Careful",function() self:Send("Begin",{Id=packet.Id,Approach="Careful"}) end,true)
  self.DialogCancel.Text="Bold +20%"; self.DialogCancel.BackgroundColor3=P.Gold; self.DialogCancel.TextColor3=P.Charcoal
  self.DialogCancelAction=function() self:Send("Begin",{Id=packet.Id,Approach="Bold"}) end
 elseif kind=="Decoy" then
  local char=Players.LocalPlayer.Character; local root=char and char:FindFirstChild("HumanoidRootPart")
  if root then self.Effects:Celebrate(root.Position,P.Purple) end
 elseif kind=="Notice" then self:Notice(packet.Text,packet.Sound)
 elseif kind=="Timing" then self:StartTiming(packet)
 elseif kind=="TimingEnd" then self:EndTiming()
 elseif kind=="Reveal" then self:ShowReveal(packet)
 elseif kind=="Capture" then
  self:EndTiming(); self.Audio:Play("Capture"); self.Effects:Shake()
  self:ShowDialog(if packet.Died then "POCKETS DROPPED ON RESPAWN" else "BUSTED BY CARDBOARD SECURITY",packet.Lost.." unbanked cards lost ("..math.floor(packet.Fraction*100).."%, rounded up). "..packet.Kept.." remain in your pockets.\n\nYour Cash, upgrades, discoveries, and missions are safe. Respawning or capture returns you to a hideout with "..C.CaptureImmunity.." seconds of protection.","Back to the sidewalks",function() end,false)
 elseif kind=="PrestigeInfo" then
  self:ShowDialog("NEW IDENTITY", "Requires all districts, all starter jobs, $100,000 and 1,000 REP.\n\nRESETS: all Cash, Reputation, upgrades, district access, carried cards, Heat, and starter jobs.\n\nKEEPS: card discoveries, cosmetics/identity badges, settings, milestone claims, daily progress/claims, clubhouse upgrades, city secrets, and career statistics.\n\nEARNS: identity badge and +5% bank value, capped at +50%. Confirmation expires in 30 seconds.","Confirm reset",function() self:Send("Prestige",packet.Token) end,true)
 end
end
return U
