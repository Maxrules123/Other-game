--!strict
local Players=game:GetService("Players")
local Input=game:GetService("UserInputService")
local GuiService=game:GetService("GuiService")
local RunService=game:GetService("RunService")
local Shared=game:GetService("ReplicatedStorage").Shared
local C=require(Shared.Config)
local R=require(Shared.Rules)
local K=require(script.Parent.UIComponents)
local CosmeticModels=require(Shared.CosmeticModels)
local P=K.Color
local U: any={State=nil,Current=nil,Signature="",Timing=nil,GearTab=1,CollectionFilter=0,NoticeId=0,RevealId=0}
function U:Send(action: string,arg: any?) self.Remote:FireServer(action,arg) end
function U:Focus(item: GuiObject?) if Input.GamepadEnabled then GuiService.SelectedObject=item end end
function U:Button(parent: Instance,title: string,area: UDim2,pos: UDim2?,callback: ()->(),color: Color3?): TextButton
 return K.button(parent,title,area,pos,function() self.Audio:Play("Click"); callback() end,color)
end
function U:Init(remote: RemoteEvent,audio: any,effects: any)
 self.Remote=remote; self.Audio=audio; self.Effects=effects
 local pg=Players.LocalPlayer:WaitForChild("PlayerGui"); local old=pg:FindFirstChild("CardCityUI"); if old then old:Destroy() end
 local gui=Instance.new("ScreenGui"); gui.Name="CardCityUI"; gui.ResetOnSpawn=false; gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets; gui.DisplayOrder=15; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=pg; self.Gui=gui
 local root=K.frame(gui,UDim2.new(1,-24,1,-20),UDim2.fromOffset(12,10)); root.BackgroundTransparency=1; self.Root=root
 local max=Instance.new("UISizeConstraint"); max.MaxSize=Vector2.new(1240,2000); max.Parent=root; root.AnchorPoint=Vector2.new(0.5,0); root.Position=UDim2.new(0.5,0,0,10)
 local hud=K.frame(root,UDim2.new(1,0,0,86),nil,P.Background); K.round(hud,14); K.border(hud); self.HUD=hud
 K.label(hud,"CARD CITY",14,P.Text,UDim2.new(0.5,-16,0,25),UDim2.fromOffset(14,5)).Font=Enum.Font.GothamBold
 self.WeatherLabel=K.label(hud,"AFTER HOURS",11,P.Muted,UDim2.new(0.5,-14,0,25),UDim2.new(0.5,0,0,5)); self.WeatherLabel.TextXAlignment=Enum.TextXAlignment.Right
 self.Cash=K.label(hud,"$0",21,P.Mint,UDim2.new(0.36,-14,0,40),UDim2.fromOffset(14,32))
 self.Rep=K.label(hud,"0 REP",13,P.Purple,UDim2.new(0.24,0,0,40),UDim2.new(0.36,0,0,32))
 self.Pockets=K.label(hud,"0 / 5 cards",13,P.Text,UDim2.new(0.4,-14,0,40),UDim2.new(0.6,0,0,32)); self.Pockets.TextXAlignment=Enum.TextXAlignment.Right
 self.HeatFill=K.progress(hud,UDim2.new(0,14,1,-9),UDim2.new(1,-28,0,3),0,P.Mint)
 local objective=K.frame(root,UDim2.new(1,0,0,52),UDim2.fromOffset(0,94),P.Panel); K.round(objective); self.Objective=K.label(objective,"Opening your profile…",12,P.Text,UDim2.new(1,-28,1,-8),UDim2.fromOffset(14,4))
 self.Context=K.label(root,"",12,P.Text,UDim2.new(1,-16,0,52),UDim2.new(0,8,1,-172)); self.Context.TextXAlignment=Enum.TextXAlignment.Center
 self.MenuButton=self:Button(root,"OPEN CITY DESK",UDim2.fromOffset(140,48),UDim2.new(0.5,-70,1,-58),function() self:Open("Overview") end,P.Panel); self.MenuButton.TextColor3=P.Text; K.border(self.MenuButton)
 self.DecoyButton=self:Button(root,"DECOY",UDim2.fromOffset(136,44),UDim2.new(0.5,-68,1,-110),function() self:Send("Decoy") end,P.Purple); self.DecoyButton.Visible=false
 local menu=K.frame(root,UDim2.fromScale(1,1),nil,P.Background); K.round(menu,16); K.border(menu); menu.ZIndex=20; menu.Visible=false; menu.Active=true; self.Menu=menu
 self.MenuTitle=K.label(menu,"CITY DESK",23,P.Text,UDim2.new(1,-90,0,58),UDim2.fromOffset(20,5)); self.MenuTitle.Font=Enum.Font.GothamBold
 self.CloseButton=self:Button(menu,"×",UDim2.fromOffset(48,44),UDim2.new(1,-62,0,12),function() self:Close() end,P.Raised)
 local nav=K.scroll(menu,UDim2.new(0,166,1,-84),UDim2.fromOffset(12,76)); K.list(nav,6); self.NavPanel=nav
 self.Nav={}
 for _,name in {"Overview","Pockets","Collection","Equipment","Operations","Hideout","Van","Style Shop","Wardrobe","Districts","Quests","Settings"} do
  local b=self:Button(nav,name,UDim2.new(1,-8,0,44),nil,function() self:Open(name) end,P.Raised); self.Nav[name]=b
 end
 local body=K.scroll(menu,UDim2.new(1,-208,1,-88),UDim2.fromOffset(192,76)); K.list(body,12); self.Body=body
 local pad=Instance.new("UIPadding"); pad.PaddingRight=UDim.new(0,6); pad.PaddingBottom=UDim.new(0,18); pad.Parent=body
 local toast=K.frame(root,UDim2.new(1,-20,0,74),UDim2.fromOffset(10,154),P.Raised); toast.ZIndex=70; K.round(toast); K.border(toast,P.Mint); toast.Visible=false; self.Toast=toast
 self.ToastText=K.label(toast,"",13,P.Text,UDim2.new(1,-28,1,-16),UDim2.fromOffset(14,8))
 self:BuildDialog(); self:BuildTiming(); self:BuildReveal()
 local function resize()
  self.Mobile=gui.AbsoluteSize.X<760
  local layout=self.NavPanel:FindFirstChildOfClass("UIListLayout")
  layout.FillDirection=if self.Mobile then Enum.FillDirection.Horizontal else Enum.FillDirection.Vertical
  self.NavPanel.Size=if self.Mobile then UDim2.new(1,-32,0,48) else UDim2.new(0,166,1,-84)
  self.NavPanel.Position=if self.Mobile then UDim2.fromOffset(16,68) else UDim2.fromOffset(12,76)
  self.NavPanel.AutomaticCanvasSize=if self.Mobile then Enum.AutomaticSize.X else Enum.AutomaticSize.Y
  self.NavPanel.ScrollingDirection=if self.Mobile then Enum.ScrollingDirection.X else Enum.ScrollingDirection.Y
  for _,b in self.Nav do b.Size=if self.Mobile then UDim2.fromOffset(112,44) else UDim2.new(1,-8,0,44) end
  self.Body.Position=if self.Mobile then UDim2.fromOffset(16,126) else UDim2.fromOffset(192,76)
  self.Body.Size=if self.Mobile then UDim2.new(1,-32,1,-138) else UDim2.new(1,-208,1,-88)
  self.DialogScale.Scale=1; self.TimingScale.Scale=1
  self.DialogBox.Size=UDim2.new(1,-28,0,math.clamp(gui.AbsoluteSize.Y-24,220,390))
  local compact=gui.AbsoluteSize.Y<360
  local height=math.clamp(gui.AbsoluteSize.Y-20,220,330)
  self.TimingBox.Size=UDim2.new(1,-28,0,height)
  self.TimingTitle.Position=UDim2.fromOffset(20,if compact then 4 else 10); self.TimingTitle.Size=UDim2.new(1,-40,0,if compact then 34 else 44)
  self.TimingCaption.Position=UDim2.fromOffset(20,if compact then 38 else 55); self.TimingCaption.Size=UDim2.new(1,-40,0,if compact then 30 else 42)
  self.TimingTrack.Position=UDim2.fromOffset(24,if compact then 76 else 113); self.TimingTrack.Size=UDim2.new(1,-48,0,if compact then 28 else 48)
  self.StopButton.Position=UDim2.fromOffset(24,height-104); self.StopButton.Size=UDim2.new(1,-48,0,48)
  self.TimingCancel.Position=UDim2.fromOffset(24,height-52)
  self.Signature=""; self:RenderMenu()
 end
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize); resize()
 remote.OnClientEvent:Connect(function(kind,packet) self:Receive(kind,packet) end)
 self:Send("Ready")
 task.spawn(function() while gui.Parent do task.wait(0.35); if not self.State then self:Send("Ready") end; self:UpdateContext() end end)
end
function U:Close()
 self.Current=nil; self.Menu.Visible=false; self.Signature=""; self:Focus(nil)
end
function U:Open(name: string)
 if self.Timing or self.Modal.Visible then return end
 local aliases={Index="Collection",Upgrades="Equipment",Missions="Quests",Shop="Equipment",Bank="Operations",Garage="Van"}
 name=aliases[name] or name
 if self.Current~=name then self.Body.CanvasPosition=Vector2.zero end
 self.Current=name; self.Menu.Visible=true; self.MenuTitle.Text=string.upper(name); self.Signature=""
 for tab,b in self.Nav do b.BackgroundColor3=if tab==name then P.Mint else P.Raised; b.TextColor3=if tab==name then P.Background else P.Text end
 self:RenderMenu(); self:Focus(self.CloseButton)
end
function U:Row(height: number): Frame local f=K.frame(self.Body,UDim2.new(1,0,0,height),nil,P.Panel); K.round(f); return f end
function U:Note(title: string,value: string?,accent: Color3?): Frame
 local f=self:Row(if value then 94 else 66)
 K.label(f,title,15,accent or P.Text,UDim2.new(1,-28,0,30),UDim2.fromOffset(14,8)).Font=Enum.Font.GothamBold
 if value then K.label(f,value,12,P.Muted,UDim2.new(1,-28,0,46),UDim2.fromOffset(14,38)) end
 return f
end
function U:Action(title: string,subtitle: string,buttonText: string,callback: ()->(),accent: Color3?)
 local bounds=game:GetService("TextService"):GetTextSize(subtitle,12,Enum.Font.GothamMedium,Vector2.new(math.max(180,self.Body.AbsoluteSize.X-28),1000))
 local height=math.max(44,bounds.Y+6)
 local f=self:Row(104+height)
 K.label(f,title,16,accent or P.Text,UDim2.new(1,-28,0,28),UDim2.fromOffset(14,9)).Font=Enum.Font.GothamBold
 K.label(f,subtitle,12,P.Muted,UDim2.new(1,-28,0,height),UDim2.fromOffset(14,38))
 self:Button(f,buttonText,UDim2.new(1,-28,0,44),UDim2.fromOffset(14,48+height),callback,accent or P.Mint)
 return f
end
function U:Notice(message: string,sound: string?)
 self.NoticeId+=1; local id=self.NoticeId; self.ToastText.Text=message; self.Toast.Visible=true; self.Audio:Play(sound or "Click")
 if sound=="Failure" or sound=="Capture" then self.Effects:Shake() end
 task.delay(4.5,function() if self.NoticeId==id then self.Toast.Visible=false end end)
end
function U:BuildDialog()
 local modal=Instance.new("TextButton"); modal.Size=UDim2.fromScale(1,1); modal.BackgroundColor3=Color3.new(); modal.BackgroundTransparency=0.32; modal.Text=""; modal.Modal=true; modal.AutoButtonColor=false; modal.Selectable=false; modal.ZIndex=100; modal.Visible=false; modal.Parent=self.Gui; self.Modal=modal
 local box=K.frame(modal,UDim2.new(1,-28,0,390),UDim2.fromScale(0.5,0.5),P.Background); box.AnchorPoint=Vector2.new(0.5,0.5); self.DialogBox=box; K.round(box,16); K.border(box)
 local max=Instance.new("UISizeConstraint"); max.MaxSize=Vector2.new(560,390); max.Parent=box
 self.DialogScale=Instance.new("UIScale"); self.DialogScale.Parent=box
 self.DialogTitle=K.label(box,"",21,P.Text,UDim2.new(1,-90,0,55),UDim2.fromOffset(20,10)); self.DialogTitle.Font=Enum.Font.GothamBold
 self:Button(box,"×",UDim2.fromOffset(44,44),UDim2.new(1,-58,0,14),function() self:HideDialog() end,P.Raised)
 local scroll=K.scroll(box,UDim2.new(1,-40,1,-145),UDim2.fromOffset(20,71)); self.DialogScroll=scroll
 self.DialogText=K.label(scroll,"",13,P.Muted,UDim2.new(1,-8,0,0)); self.DialogText.AutomaticSize=Enum.AutomaticSize.Y; self.DialogText.TextYAlignment=Enum.TextYAlignment.Top
 self.DialogConfirm=self:Button(box,"Continue",UDim2.new(0.6,-26,0,48),UDim2.new(0,20,1,-64),function() self:ConfirmDialog() end,P.Mint)
 self.DialogCancel=self:Button(box,"Cancel",UDim2.new(0.4,-22,0,48),UDim2.new(0.6,4,1,-64),function() local action=self.DialogCancelAction; self:HideDialog(); if action then action() end end,P.Raised)
end
function U:ShowDialog(title: string,message: string,confirm: string,callback: ()->(),canCancel: boolean?)
 self:Close(); self:SkipReveal(); self.DialogTitle.Text=title; self.DialogText.Text=message; self.DialogConfirm.Text=confirm; self.DialogCallback=callback
 self.DialogCancel.Text="Cancel"; self.DialogCancelAction=nil; self.DialogCancel.BackgroundColor3=P.Raised; self.DialogCancel.TextColor3=P.Text; self.DialogCancel.Visible=canCancel==true
 self.DialogScroll.CanvasPosition=Vector2.zero; self.Modal.Visible=true; self:Focus(self.DialogConfirm)
end
function U:HideDialog() self.Modal.Visible=false; self.DialogCallback=nil; self.DialogCancelAction=nil; self:Focus(nil) end
function U:ConfirmDialog() local fn=self.DialogCallback; self:HideDialog(); if fn then fn() end end
function U:StateKey(): string
 local p=self.State.Profile; local q=p.Processing; local bits={self.Current or "",tostring(self.Mobile),tostring(p.Cash),tostring(p.Reputation),tostring(p.Starter),tostring(p.StarterProgress),tostring(#self.State.Loot),q.Stage,tostring(q.PendingValue),tostring(q.Value),p.Contracts.Active,tostring(p.Van.Owned),tostring(#p.Van.Stash),tostring(self.GearTab),tostring(self.CollectionFilter),tostring(p.Identities)}
 for _,key in C.UpgradeOrder do table.insert(bits,tostring(p.Upgrades[key])) end
 for _,key in C.HideoutOrder do table.insert(bits,tostring(p.Hideout[key])) end
 for _,map in {p.Collection,p.Secrets,p.Contracts.Claimed,p.Contracts.Progress,p.Daily.Progress,p.Daily.Claimed,p.Settings,p.Cosmetics.Owned,p.Cosmetics.Equipped} do
  local items={}; for key,value in map do table.insert(items,tostring(key)..":"..tostring(value)) end; table.sort(items); table.insert(bits,table.concat(items,","))
 end
 for i=1,5 do table.insert(bits,tostring(p.Districts[tostring(i)])) end
 return table.concat(bits,"|")
end
function U:RenderMenu()
 if not self.State or not self.Current then return end
 local key=self:StateKey(); if key==self.Signature then return end; self.Signature=key
 local oldPosition=self.Body.CanvasPosition; local selected=GuiService.SelectedObject; local hadFocus=selected and selected:IsDescendantOf(self.Body)
 for _,child in self.Body:GetChildren() do if child:IsA("GuiObject") then child:Destroy() end end
 self.ProcessClock=nil; self.ProcessFill=nil
 local p=self.State.Profile
 if self.Current=="Overview" then
  self:Note("AFTER HOURS / CITY DESK","Work the streets, secure your haul, and turn fictional cards into Cash through the backroom machines.",P.Mint)
  self:Note("YOUR NEXT MOVE",C.StarterMissions[p.Starter] and C.StarterMissions[p.Starter].Text or "Explore new blocks, meet quest givers, and build your hideout.")
  self:Action("Backroom operations",p.Processing.PendingCards.." cards queued · Machine: "..p.Processing.Stage.." · Stored cards are safe from capture.","Open operations",function() self:Open("Operations") end)
  self:Action("People and stories","Mara, Jax, Wren and Iris have twelve linked contracts across the city.","Open quest journal",function() self:Open("Quests") end,P.Purple)
  self:Note("CAREER",p.Stats.Successes.." cards secured · "..p.Stats.Perfects.." perfect tricks\n$"..K.number(p.Stats.Banked).." processed · Best streak "..p.Stats.BestCombo,P.Gold)
 elseif self.Current=="Pockets" then
  self:Action("UNBANKED / $"..K.number(self.State.Value),#self.State.Loot.." of "..R.capacity(p.Upgrades.Capacity,C).." slots · Capture or death drops half, rounded up.","Deposit at hideout intake",function() self:Send("Bank") end)
  if #self.State.Loot==0 then self:Note("Empty pockets","Scout a nearby citizen or withdraw cards from your van.") else self:Cards(self.State.Loot,false) end
 elseif self.Current=="Collection" then self:Collection()
 elseif self.Current=="Equipment" then self:Equipment()
 elseif self.Current=="Operations" then self:Operations()
 elseif self.Current=="Hideout" then self:Hideout()
 elseif self.Current=="Van" then self:Van()
 elseif self.Current=="Style Shop" then self:Cosmetics(false)
 elseif self.Current=="Wardrobe" then self:Cosmetics(true)
 elseif self.Current=="Districts" then self:Districts()
 elseif self.Current=="Quests" then self:Quests()
 elseif self.Current=="Settings" then self:Settings() end
 self.Body.CanvasPosition=oldPosition
 if hadFocus then self:Focus(self.Body:FindFirstChildWhichIsA("TextButton",true) or self.CloseButton) end
end
function U:Grid(height: number?): Frame
 local f=K.frame(self.Body,UDim2.new(1,0,0,0)); f.BackgroundTransparency=1; f.AutomaticSize=Enum.AutomaticSize.Y
 local grid=Instance.new("UIGridLayout"); grid.CellPadding=UDim2.fromOffset(10,10); grid.CellSize=if self.Mobile then UDim2.new(1,0,0,height or 148) else UDim2.new(0.5,-5,0,height or 148); grid.SortOrder=Enum.SortOrder.LayoutOrder; grid.Parent=f; return f
end
function U:Cards(entries: {any},index: boolean?)
 local grid=self:Grid(); local p=self.State.Profile
 for _,loot in entries do
  local card=C.Cards[loot.Id]; if not card then continue end
  local tile=K.frame(grid,UDim2.fromOffset(200,148),nil,P.Raised); K.round(tile,11)
  local color=C.RarityColors[card.Rarity]; K.border(tile,if loot.Unknown then P.Border else color)
  K.label(tile,if loot.Unknown then "UNDISCOVERED" else string.upper(card.Brand),13,if loot.Unknown then P.Muted else color,UDim2.new(1,-24,0,26),UDim2.fromOffset(12,8)).Font=Enum.Font.GothamBold
  K.label(tile,C.Rarities[card.Rarity].." / "..C.Districts[card.District].Name,11,P.Muted,UDim2.new(1,-24,0,38),UDim2.fromOffset(12,34))
  K.label(tile,if loot.Unknown then "? / Find this fictional collectible" else (loot.Variant or "").."\n"..card.Name,12,P.Text,UDim2.new(1,-24,0,43),UDim2.fromOffset(12,73))
  if not index then
   local multiplier=1; for _,v in C.Variants do if v.Name==loot.Variant then multiplier=v.Multiplier end end
   local amount=R.lootValue(card.Value,multiplier*(loot.Quality or 1)*R.galleryBonus(p,C),p.Upgrades.Terminal,p.Identities,C)
   K.label(tile,"BASE INTAKE $"..K.number(amount).." · QUALITY ×"..string.format("%.2f",loot.Quality or 1),10,P.Mint,UDim2.new(1,-24,0,22),UDim2.fromOffset(12,120))
  else K.label(tile,loot.Variants or "",10,P.Mint,UDim2.new(1,-24,0,24),UDim2.fromOffset(12,118)) end
 end
end
function U:Collection()
 local p=self.State.Profile; local count=0; local total=0; for _ in p.Collection do count+=1 end; for _ in C.Cards do total+=4 end
 self:Note(count.." / "..total.." VARIANTS DISCOVERED","Discoveries survive capture and New Identity. Foil ×1.5 · Glitched ×2.2 · Golden ×3.5.",P.Gold)
 local filters=self:Row(56); local scroll=K.scroll(filters,UDim2.new(1,-16,1,-8),UDim2.fromOffset(8,4),true); K.list(scroll,6,true)
 for i=0,6 do self:Button(scroll,if i==0 then "All cards" else C.Rarities[i],UDim2.fromOffset(102,44),nil,function() self.CollectionFilter=i; self.Signature=""; self:RenderMenu() end,if i==self.CollectionFilter then P.Mint else P.Raised) end
 local entries={}
 for d=1,5 do for r=1,6 do
  local id=string.format("D%dR%d",d,r)
  if C.Cards[id] and (self.CollectionFilter==0 or self.CollectionFilter==r) then
   local known=false; local variants={}
   for _,v in C.Variants do local found=p.Collection[id..":"..v.Name]; known=known or found; table.insert(variants,(if found then "✓ " else "? ")..v.Name) end
   table.insert(entries,{Id=id,Variant=if known then "FICTIONAL COLLECTIBLE" else "",Unknown=not known,Variants=table.concat(variants," / ")})
  end
 end end
 self:Cards(entries,true)
 for _,m in C.Milestones do self:Note(m.Count.." discoveries / $"..m.Cash,if count>=m.Count then "Milestone rewarded automatically." else "Keep exploring and collecting variants.",if count>=m.Count then P.Mint else P.Muted) end
end
function U:Equipment()
 local p=self.State.Profile
 self:Note("BUILD YOUR LOADOUT","Buy inside a hideout. Reputation unlocks tiers and is never spent. Every benefit below is shown before purchase.",P.Mint)
 local tabs=self:Row(56); local flow=K.scroll(tabs,UDim2.new(1,-16,1,-8),UDim2.fromOffset(8,4),true); K.list(flow,8,true)
 for i,group in C.UpgradeGroups do self:Button(flow,group.Name,UDim2.fromOffset(130,44),nil,function() self.GearTab=i; self.Signature=""; self:RenderMenu() end,if self.GearTab==i then P.Mint else P.Raised) end
 for _,name in C.UpgradeGroups[self.GearTab].Tracks do
  local def=C.Upgrades[name]; local level=p.Upgrades[name]; local cost=R.upgradeCost(def.BaseCost,def.Growth,level); local rep=C.UpgradeRep[level+1] or 0
  local f=self:Row(207)
  K.label(f,(if name=="Terminal" then "INTAKE APPRAISAL" else string.upper(name)).." / "..level.." OF "..def.Max,16,P.Text,UDim2.new(1,-28,0,30),UDim2.fromOffset(14,9)).Font=Enum.Font.GothamBold
  K.label(f,def.Description,12,P.Muted,UDim2.new(1,-28,0,36),UDim2.fromOffset(14,42))
  K.label(f,"CURRENT  "..R.upgradeEffect(name,level,C).."\nNEXT  "..(if level>=def.Max then "Maximum tier" else R.upgradeEffect(name,level+1,C)),12,P.Mint,UDim2.new(1,-28,0,52),UDim2.fromOffset(14,81))
  K.progress(f,UDim2.fromOffset(14,140),UDim2.new(1,-28,0,4),level/def.Max,P.Purple)
  self:Button(f,if level>=def.Max then "MAXIMUM TIER" else "$"..K.number(cost).." / "..rep.." REP required",UDim2.new(1,-28,0,44),UDim2.fromOffset(14,153),function() self:Send("Buy",name) end,if p.Cash>=cost and p.Reputation>=rep and level<def.Max then P.Mint else P.Raised)
 end
end
function U:Operations()
 local p=self.State.Profile; local q=p.Processing
 self:Note("THE BACKROOM / FICTIONAL TOKEN WORKS","Cards become imaginary ink tokens, pass through a cartoon rinse, then pay in-game Cash. No real accounts or payment information exist.",P.Purple)
 local f=self:Row(116)
 K.label(f,"CURRENT MACHINE / "..string.upper(q.Stage),15,P.Mint,UDim2.new(1,-28,0,28),UDim2.fromOffset(14,8))
 self.ProcessClock=K.label(f,"",12,P.Muted,UDim2.new(1,-28,0,40),UDim2.fromOffset(14,39))
 self.ProcessFill=K.progress(f,UDim2.fromOffset(14,91),UDim2.new(1,-28,0,6),q.Stage=="Ready" and 1 or 0,P.Mint)
 self:Action("01 / SECURE THE CARDS",q.PendingCards.." cards queued · $"..K.number(q.PendingValue).." base intake value. Deposit before leaving; pockets are not saved.","Deposit pockets at intake",function() self:Send("Bank") end,P.Mint)
 self:Action("02 / IMAGINARY INK PRESS","Starts the queued batch. Its payout is fixed when started; Yield upgrades improve future batches.","Start press / "..R.processSeconds("Press",p.Upgrades.Press,C).."s",function() self:Send("Process","Press") end,P.Purple)
 self:Action("03 / CARTOON RINSE","When pressing finishes, bring the batch to the mint machine. This is an imaginary arcade activity.","Start rinse / "..R.processSeconds("Rinse",p.Upgrades.Rinse,C).."s",function() self:Send("Process","Rinse") end,P.Mint)
 self:Action("04 / PAYOUT PRINTER",q.Cards.." cards in the active batch · $"..K.number(q.Value).." payout. Collected Cash and stored batches are safe from capture.","Claim finished payout",function() self:Send("Process","Claim") end,P.Gold)
end
function U:Hideout()
 local p=self.State.Profile
 self:Note("HIDDEN IN PLAIN SIGHT","Find the alley beside Bubble Repairs. The workshop entrance is behind the closed frontage. Your lounge, supply bench, machines and planning table are inside.",P.Mint)
 self:Action("Practice makes steady","The practice console runs three stages without rewards, Heat or lost cards.","Use nearby practice console",function() self:Send("Practice") end,P.Purple)
 self:Action("Confetti supplies","Restock your unlocked decoys at the supply bench. Charges require Gadgets; the Workshop adds capacity.","Restock at supply bench",function() self:Send("Resupply") end)
 for _,name in C.HideoutOrder do
  local def=C.HideoutUpgrades[name]; local level=p.Hideout[name]; local cost=R.upgradeCost(def.BaseCost,def.Growth,level)
  self:Action(def.Name.." / "..level.." OF "..def.Max,def.Description.." These improvements survive New Identity.",if level>=def.Max then "FULLY IMPROVED" else "Improve / $"..K.number(cost).." / "..def.Rep*(level+1).." REP",function() self:Send("HideoutBuy",name) end,if p.Cash>=cost and level<def.Max then P.Mint else P.Raised)
 end
 self:Action("NEW IDENTITY / "..p.Identities.." EARNED","All districts, starter jobs, $100,000 and 1,000 REP required. Review exactly what resets before confirming.","Review New Identity",function() self:Send("PrestigeInfo") end,P.Gold)
 local found=0; for _ in p.Secrets do found+=1 end
 self:Note("CITY SOUVENIRS / "..found.." OF 15","Each discovery pays once and is permanent. Follow the clues below; back lanes reward exploration.",P.Gold)
 for d=1,5 do for n=1,3 do local id=string.format("S%d_%d",d,n); local def=C.Secrets[id]
  self:Note((if p.Secrets[id] then "✓ " else "? ")..C.Districts[d].Name.." / "..def.Name,if p.Secrets[id] then "Discovered and saved." else def.Hint,if p.Secrets[id] then P.Mint else P.Muted)
 end end
end
function U:Van()
 local p=self.State.Profile
 self:Note("YOUR MOBILE LOCKER",#p.Van.Stash.." / "..(C.Van.BaseSlots+p.Upgrades.VanSlots*C.Van.SlotsPerLevel).." saved card slots. Stashed cards survive capture/rejoin; withdraw to take them back into risk.",P.Mint)
 if not p.Van.Owned then
  self:Action("CRUMB COURIER VAN","Buy at an alley garage. Ownership persists through New Identity; the stash resets when you prestige.","Buy / $"..C.Van.Price.." / "..C.Van.Reputation.." REP",function() self:Send("Van","Purchase") end)
 else
  self:Action("GARAGE / DRIVE","Summon at a garage, then use the driver-seat prompt. WASD, gamepad or touch thumbstick drives; jump exits.","Summon at nearby garage",function() self:Send("Van","Summon") end)
  self:Action("REAR STORAGE","Stand at the rear of your own van. Van Slots adds room; Engine improves capped cruising speed.","Store all pocket cards",function() self:Send("Van","Store") end)
  self:Action("WITHDRAW","Returns as many cards as fit into your pockets. These become unbanked and vulnerable again.","Withdraw cards",function() self:Send("Van","Withdraw") end,P.Purple)
  self:Action("HIDEOUT DOCK","Park beside the external intake on the west wall, then stand between the rear doors and intake.","Deposit van stash into processing",function() self:Send("Van","Deposit") end,P.Gold)
 end
 if #p.Van.Stash>0 then self:Cards(p.Van.Stash,false) end
end
function U:Cosmetics(wardrobe: boolean)
 local p=self.State.Profile
 self:Note(if wardrobe then "YOUR WARDROBE" else "SECOND SHIFT / OUTFITTERS",if wardrobe then "Equip owned styles at a hideout wardrobe. Appearance only; ownership and your outfit survive New Identity." else "Original caps, knitwear, frames, bags and jackets. Buy at an Outfitters register. No gameplay bonuses or random paid crates.",P.Gold)
 if wardrobe then
  local character=Players.LocalPlayer.Character
  if character and character:FindFirstChild("Head") then
   local row=self:Row(248)
   local viewport=Instance.new("ViewportFrame"); viewport.Size=UDim2.new(1,-24,0,188); viewport.Position=UDim2.fromOffset(12,8); viewport.BackgroundColor3=P.Raised; viewport.BorderSizePixel=0; viewport.Ambient=Color3.fromRGB(179,193,208); viewport.LightColor=Color3.fromRGB(255,237,211); viewport.LightDirection=Vector3.new(-1,-1,-1); viewport.ZIndex=row.ZIndex+1; viewport.Parent=row; K.round(viewport,10)
   local world=Instance.new("WorldModel"); world.Parent=viewport
   local wasArchivable=character.Archivable; character.Archivable=true; local copy=character:Clone(); character.Archivable=wasArchivable
   for _,item in copy:GetDescendants() do
    if item:IsA("LuaSourceContainer") or item:IsA("Tool") then item:Destroy()
    elseif item:IsA("BasePart") then item.Anchored=true; item.CanCollide=false end
   end
   local hum=copy:FindFirstChildOfClass("Humanoid"); if hum then hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end
   copy.Parent=world
   local box,size=copy:GetBoundingBox(); local camera=Instance.new("Camera"); camera.FieldOfView=30; camera.CFrame=CFrame.lookAt(box.Position+Vector3.new(0.45,0.05,-1).Unit*math.max(6,size.Magnitude*1.35),box.Position); camera.Parent=viewport; viewport.CurrentCamera=camera
   self:Button(row,"Refresh your look",UDim2.new(1,-24,0,44),UDim2.fromOffset(12,198),function() self.Signature=""; self:RenderMenu() end,P.Raised)
  end
  for _,slot in C.CosmeticSlots do
   local id=p.Cosmetics.Equipped[slot]; local def=C.Cosmetics[id]
   self:Action(slot.." / "..(if def then def.Name else "Original avatar"),"One style per slot. Removing a style restores your original avatar appearance.","Remove "..slot,function() self:Send("CosmeticRemove",slot) end,P.Raised)
  end
 end
 local grid=self:Grid(264); local listed=0
 for _,id in C.CosmeticOrder do
  local def=C.Cosmetics[id]; local owned=p.Cosmetics.Owned[id]; local worn=p.Cosmetics.Equipped[def.Slot]==id
  if wardrobe and not owned then continue end
  listed+=1
  local tile=K.frame(grid,UDim2.fromOffset(220,264),nil,P.Panel); K.round(tile,12); K.border(tile,if worn then P.Mint else P.Border)
  local viewport=Instance.new("ViewportFrame"); viewport.Size=UDim2.new(1,-24,0,114); viewport.Position=UDim2.fromOffset(12,10); viewport.BackgroundColor3=P.Raised; viewport.BorderSizePixel=0; viewport.Ambient=Color3.fromRGB(179,193,208); viewport.LightColor=Color3.fromRGB(255,237,211); viewport.LightDirection=Vector3.new(-1,-1,-1); viewport.ZIndex=tile.ZIndex+1; viewport.Parent=tile; K.round(viewport,9)
  local world=Instance.new("WorldModel"); world.Parent=viewport
  local model=CosmeticModels.build(world,id,CFrame.new(),Vector3.new(2,1.6,1))
  local box,size=model:GetBoundingBox(); local camera=Instance.new("Camera"); camera.FieldOfView=32; camera.CFrame=CFrame.lookAt(box.Position+Vector3.new(0.6,0.3,-1).Unit*math.max(3,size.Magnitude*1.4),box.Position); camera.Parent=viewport; viewport.CurrentCamera=camera
  K.label(tile,def.Name,14,P.Text,UDim2.new(1,-28,0,32),UDim2.fromOffset(14,131)).Font=Enum.Font.GothamBold
  K.label(tile,def.Slot.." / "..(if owned then (if worn then "WEARING" else "OWNED") else "$"..def.Price.." / "..def.Rep.." REP"),11,if owned then P.Mint else P.Muted,UDim2.new(1,-28,0,30),UDim2.fromOffset(14,169))
  self:Button(tile,if wardrobe then (if worn then "WEARING" else "Equip at wardrobe") elseif owned then "OWNED / see wardrobe" else "Purchase at register",UDim2.new(1,-24,0,44),UDim2.fromOffset(12,208),function()
   if wardrobe then self:Send("CosmeticEquip",id) elseif owned then self:Open("Wardrobe") else self:Send("CosmeticBuy",id) end
  end,if worn or (not owned and p.Cash>=def.Price and p.Reputation>=def.Rep) then P.Mint else P.Raised)
 end
 if listed==0 then self:Note("BUILD YOUR STYLE","Visit Second Shift Outfitters to buy your first cosmetic.") end
end
function U:Districts()
 local p=self.State.Profile
 self:Note("A BIGGER CITY / FIVE DISTRICTS","Follow the main avenue east. Perimeter roads circle the blocks; alley entrances lead to hidden workshops. Courier travel requires empty pockets and low Heat.",P.Mint)
 for i,d in C.Districts do
  local open=p.Districts[tostring(i)]
  self:Action(string.format("%02d / %s",i,d.Name),d.Landmark.." · Targets need Sleight "..d.Equipment.."\n"..(if open then "District unlocked" else "$"..K.number(d.Cash).." and "..d.Rep.." REP required"),if open then "Courier / $"..R.travelCost(p.Hideout.Network,i,C) else "Unlock district",function() if open then self:Send("Travel",i) else self:Send("Unlock",i) end end,if open then P.Mint else P.Purple)
 end
end
function U:Quests()
 local p=self.State.Profile; local starter=C.StarterMissions[p.Starter]
 self:Note("YOUR STARTER STORY",if starter then starter.Title.." / "..starter.Text.." ("..p.StarterProgress.." / "..starter.Goal..")" else "Complete. Meet the city's contacts for longer contracts.",P.Mint)
 if self.State.Vault then self:Action("VAULT RUN ACTIVE","Use the exit or leave the run without a reward.","Leave Vault Run",function() self:Send("VaultLeave") end,P.Red) end
 self:Note("STORY CONTRACTS","Talk to the named contact in the courtyard to accept and claim. One story contract is active at a time; completed rewards can be claimed only once.",P.Purple)
 if p.Contracts.Active~="" then self:Action("ACTIVE CONTRACT / "..C.Contracts[p.Contracts.Active].Title,"You can pause this contract and resume later. Saved progress is kept.","Pause active contract",function() self:Send("QuestPause") end,P.Raised) end
 for _,id in C.ContractOrder do
  local def=C.Contracts[id]; local done=p.Contracts.Claimed[id]; local active=p.Contracts.Active==id; local progress=p.Contracts.Progress[id] or 0
  local unlocked=p.Districts[tostring(def.District)] and (not def.Previous or p.Contracts.Claimed[def.Previous])
  local title=def.Speaker.." / "..def.Title
  local description=def.Text.."\n"..progress.." / "..def.Goal.." · $"..def.Cash.." + "..def.Rep.." REP"
  self:Action(title,description,if done then "COMPLETED" elseif not unlocked then "FINISH PREVIOUS / UNLOCK DISTRICT" elseif active and progress>=def.Goal then "Claim with "..def.Speaker elseif active then "IN PROGRESS" else "Accept from "..def.Speaker,function() if not done and unlocked then self:Send(if active then "QuestClaim" else "QuestAccept",id) end end,if done then P.Raised elseif active then P.Mint else P.Purple)
 end
 self:Note("DAILY ODD JOBS","Three jobs rotate at 00:00 UTC. Daily rewards can be claimed once per server-validated date.",P.Gold)
 for _,id in R.dailyIds(p.Daily.Day,#C.DailyPool) do
  local key=tostring(id); local d=C.DailyPool[id]; local progress=p.Daily.Progress[key] or 0
  self:Action(d.Title.." / "..progress.." OF "..d.Goal,d.Kind.." objective · $"..d.Cash.." + "..d.Rep.." REP",if p.Daily.Claimed[key] then "CLAIMED" elseif progress>=d.Goal then "Claim daily reward" else "IN PROGRESS",function() self:Send("Claim",key) end,if progress>=d.Goal then P.Gold else P.Raised)
 end
 self:Action("VAULT RUN","The kiosk is inside the Starter backroom. Bank pockets first; cross the pulsing security course and find the exit.","Start at kiosk / "..C.Vault.Rep.." REP",function() self:Send("Vault") end,P.Gold)
end
function U:Settings()
 local p=self.State.Profile
 for _,key in {"Music","Effects"} do
  local f=self:Row(104); K.label(f,key.." volume / "..math.floor(p.Settings[key]*100).."%",15,P.Text,UDim2.new(1,-28,0,34),UDim2.fromOffset(14,5))
  for i,value in {0,0.35,0.7,1} do self:Button(f,tostring(math.floor(value*100)).."%",UDim2.new(0.25,-10,0,44),UDim2.new((i-1)*0.25,5,0,50),function() self:Send("Setting",{Key=key,Value=value}) end,if p.Settings[key]==value then P.Mint else P.Raised) end
 end
 for _,key in {"ReducedMotion","Shake","WeatherEffects"} do self:Action(key,if key=="WeatherEffects" then "Toggle local rain particles; weather lighting and the server cycle continue." else "Adjust optional screen and camera presentation.",if p.Settings[key] then "ON / toggle" else "OFF / toggle",function() self:Send("Setting",{Key=key,Value=not p.Settings[key]}) end,P.Purple) end
 self:Note("CONTROLS","E / X / tap: interact · Space / A: time a hit · G / R1: decoy · Tab / Y: city desk · B: close · van: WASD / thumbstick, jump to exit.")
 self:Note("FICTIONAL CITY","Original banks, decorative cards, cartoon tokens, imaginary Cash. Audio asset slots are configurable and currently empty.",P.Muted)
end
function U:UpdateState(packet: any)
 local previous=self.State; self.State=packet; local p=packet.Profile
 self.Audio:Update(p.Settings); self.Effects.Settings=p.Settings
 if self.CityVisuals then self.CityVisuals.Settings=p.Settings; self.CityVisuals.ProcessStage=p.Processing.Stage end
 if self.HideoutController then self.HideoutController:Update(packet) end
 self.Cash.Text="$"..K.number(p.Cash); self.Rep.Text=K.number(p.Reputation).." REP"; self.Pockets.Text=#packet.Loot.." / "..R.capacity(p.Upgrades.Capacity,C).." CARDS\n$"..K.number(packet.Value).." unbanked"
 if previous and p.Cash>previous.Profile.Cash then self.Cash.TextColor3=P.Gold; self.Effects:Tween(self.Cash,{TextColor3=P.Mint},0.8) end
 self.WeatherLabel.Text=(packet.Weather or "Clear"):upper().." / "..string.format("%02d:%02d",math.floor(packet.Clock or 16),math.floor(((packet.Clock or 16)%1)*60)).." / HEAT "..math.floor(packet.Heat)
 self.Effects:Tween(self.HeatFill,{Size=UDim2.fromScale(packet.Heat/100,1),BackgroundColor3=if packet.Chase then P.Red elseif packet.Heat>=55 then P.Gold else P.Mint},0.25)
 local starter=C.StarterMissions[p.Starter]
 self.Objective.Text=if packet.Chase then "SECURITY PURSUIT / break sight, reach cover, or use a decoy" elseif packet.Vault then "VAULT RUN / "..math.ceil(packet.Vault.Remaining).."s / "..packet.Vault.Stage.." of 5 gates" elseif starter then starter.Title:upper().." / "..starter.Text else "AFTER HOURS / explore, meet contacts, and improve your backroom"
 self.DecoyButton.Text=if packet.Gadget.Cooldown>0 then "DECOY / "..math.ceil(packet.Gadget.Cooldown).."s" else "DECOY / "..packet.Gadget.Charges
 self:RenderMenu()
 local q=p.Processing
 if self.ProcessClock then
  local remaining=math.max(0,q.Ends-workspace:GetServerTimeNow())
  self.ProcessClock.Text=if q.Ends>0 then math.ceil(remaining).."s remaining / batch payout $"..K.number(q.Value) else "Queued: "..q.PendingCards.." cards / "..q.Stage
  if self.ProcessFill then self.ProcessFill.Size=UDim2.fromScale(if q.Ends>0 then 1-remaining/math.max(1,q.Duration or 1) elseif q.Stage=="Ready" or q.Stage=="Pressed" then 1 else 0,1) end
 end
end
function U:UpdateContext()
 if not self.State then return end
 local blocked=self.Current or self.Timing or self.Modal.Visible
 self.MenuButton.Visible=not blocked; self.DecoyButton.Visible=not blocked and self.State.Profile.Upgrades.Gadgets>0 and not self.State.Vault
 if self.HideoutController then self.HideoutController:RefreshSecrets(self.State.Profile) end
 if blocked then self.Context.Text=""; return end
 self.Context.Text=if self.State.Chase then "You carry $"..K.number(self.State.Value).." / banked and stored progress stays safe" elseif #self.State.Loot>0 then "Find the alley backroom to secure cards / van rear doors provide mobile storage" else "Scout a citizen / choose Careful or Bold / clear every timing stage"
end
function U:BuildTiming()
 local layer=K.frame(self.Gui,UDim2.fromScale(1,1),nil,P.Background); layer.BackgroundTransparency=0.35; layer.ZIndex=140; layer.Visible=false; self.TimingLayer=layer
 local box=K.frame(layer,UDim2.new(1,-28,0,330),UDim2.fromScale(0.5,0.5),P.Background); box.AnchorPoint=Vector2.new(0.5,0.5); self.TimingBox=box; K.round(box,18); K.border(box)
 local max=Instance.new("UISizeConstraint"); max.MaxSize=Vector2.new(650,330); max.Parent=box
 self.TimingScale=Instance.new("UIScale"); self.TimingScale.Parent=box
 self.TimingTitle=K.label(box,"",21,P.Text,UDim2.new(1,-40,0,44),UDim2.fromOffset(20,10)); self.TimingTitle.Font=Enum.Font.GothamBold
 self.TimingCaption=K.label(box,"",12,P.Muted,UDim2.new(1,-40,0,42),UDim2.fromOffset(20,55))
 local track=K.frame(box,UDim2.new(1,-48,0,48),UDim2.fromOffset(24,113),P.Raised); self.TimingTrack=track; K.round(track,8)
 self.Zone=K.frame(track,UDim2.fromScale(0.2,1),nil,P.Mint); K.round(self.Zone,6)
 self.Perfect=K.frame(track,UDim2.fromScale(0.05,1),nil,P.Gold); K.round(self.Perfect,4)
 self.Marker=K.frame(track,UDim2.new(0,3,1,16),UDim2.fromOffset(0,-8),P.Text); self.Marker.AnchorPoint=Vector2.new(0.5,0)
 self.StopButton=self:Button(box,"LOCK IN / SPACE / A",UDim2.new(1,-48,0,56),UDim2.fromOffset(24,190),function() self:StopTiming() end,P.Mint)
 self.TimingCancel=self:Button(box,"Abandon trick",UDim2.new(1,-48,0,44),UDim2.fromOffset(24,264),function() self:Send("Cancel"); self:EndTiming() end,P.Raised)
end
function U:StartTiming(packet: any)
 self:Close(); self:SkipReveal(); self:HideDialog(); self:EndTiming(); self.Timing=packet; packet.Submitted=false; self.TimingLayer.Visible=true; self.Toast.Visible=false
 self.TimingTitle.Text=(if packet.Practice then "PRACTICE" else string.upper(packet.Approach)).." / "..packet.Stage.." OF "..packet.Stages
 self.TimingCaption.Text=string.upper(packet.Pattern).." / "..(if packet.Stage>1 then (packet.LastGrade or "Good")..". Follow the drifting zone." else "Mint clears the stage. Gold gives a perfect hit.")
 self.Zone.Size=UDim2.fromScale(packet.Width,1); self.Perfect.Size=UDim2.fromScale(packet.Width*0.4,1)
 self:Focus(self.StopButton)
 self.TimingConnection=RunService.RenderStepped:Connect(function()
  if not self.Timing or self.Timing.Submitted then return end
  local elapsed=workspace:GetServerTimeNow()-packet.Start
  local center=R.zone(elapsed,packet.Duration,packet.Center,packet.Drift,packet.Width)
  self.Marker.Position=UDim2.new(R.cursor(elapsed,packet.Duration,packet.Pattern),0,0,-8)
  self.Zone.Position=UDim2.fromScale(center-packet.Width/2,0); self.Perfect.Position=UDim2.fromScale(center-packet.Width*0.2,0)
  self.StopButton.Text=if elapsed<0 then "GET READY" else "LOCK IN / SPACE / A"
 end)
end
function U:StopTiming()
 if not self.Timing or self.Timing.Submitted or workspace:GetServerTimeNow()<self.Timing.Start then return end
 self.Timing.Submitted=true; self:Send("Stop",self.Timing.Token); self.StopButton.Text="CHECKING"
end
function U:EndTiming() if self.TimingConnection then self.TimingConnection:Disconnect(); self.TimingConnection=nil end; self.Timing=nil; self.TimingLayer.Visible=false; self:Focus(nil) end
function U:BuildReveal()
 local f=K.frame(self.Root,UDim2.new(1,-28,0,178),UDim2.new(0.5,0,1,-68),P.Panel); f.AnchorPoint=Vector2.new(0.5,1); f.ZIndex=80; K.round(f,14); K.border(f)
 local max=Instance.new("UISizeConstraint"); max.MaxSize=Vector2.new(420,178); max.Parent=f; f.Visible=false; self.Reveal=f
 self.RevealHeader=K.label(f,"",11,P.Mint,UDim2.new(1,-28,0,25),UDim2.fromOffset(14,8))
 self.RevealBrand=K.label(f,"",24,P.Text,UDim2.new(1,-28,0,38),UDim2.fromOffset(14,33)); self.RevealBrand.Font=Enum.Font.GothamBold
 self.RevealName=K.label(f,"",12,P.Muted,UDim2.new(1,-28,0,42),UDim2.fromOffset(14,74))
 self:Button(f,"Nice / dismiss",UDim2.new(1,-28,0,44),UDim2.fromOffset(14,124),function() self:SkipReveal() end,P.Raised)
end
function U:SkipReveal() self.RevealId+=1; self.Reveal.Visible=false end
function U:Receive(kind: string,packet: any)
 if kind=="State" then self:UpdateState(packet)
 elseif kind=="Notice" then self:Notice(packet.Text,packet.Sound)
 elseif kind=="Timing" then self:StartTiming(packet)
 elseif kind=="TimingEnd" then self:EndTiming()
 elseif kind=="Scout" then
  local style=C.TargetStyles[packet.Style]; local possible={}; for r,w in C.Districts[packet.District].Weights do if w>0 then table.insert(possible,C.Rarities[r]) end end
  self:ShowDialog(packet.Name.." / "..style.Name,style.Flavor.."\n\n"..packet.Stages.." stages / Sleight "..packet.Requirement.." / Suspicion "..packet.Suspicion.."%\nCards: "..table.concat(possible,", ").."\n\nCAREFUL / "..C.Approaches.Careful.Description.."\n\nBOLD / "..C.Approaches.Bold.Description.."\n\nEvery stage must clear before a card is awarded. Later districts have smaller, faster windows.","Careful",function() self:Send("Begin",{Id=packet.Id,Approach="Careful"}) end,true)
  self.DialogCancel.Text="Bold +20%"; self.DialogCancel.BackgroundColor3=P.Gold; self.DialogCancel.TextColor3=P.Background; self.DialogCancelAction=function() self:Send("Begin",{Id=packet.Id,Approach="Bold"}) end
 elseif kind=="Reveal" then
  self.RevealId+=1; local id=self.RevealId; local card=C.Cards[packet.Loot.Id]; self.Reveal.Visible=true
  self.RevealHeader.Text=string.upper(packet.Grade.." / "..C.Rarities[card.Rarity].." / "..packet.Loot.Variant); self.RevealHeader.TextColor3=C.RarityColors[card.Rarity]
  self.RevealBrand.Text=card.Brand; self.RevealName.Text=card.Name.."\nQuality ×"..string.format("%.2f",packet.Loot.Quality or 1).." / Streak "..packet.Combo
  self.Audio:Play(if card.Rarity>=3 then "Reveal" else "Success")
  local root=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if root then self.Effects:Celebrate(root.Position,C.RarityColors[card.Rarity]) end
  task.delay(3,function() if self.RevealId==id then self:SkipReveal() end end)
  if packet.Milestone>0 then self:Notice("Collection milestone / +$"..packet.Milestone,"Success") end
 elseif kind=="Decoy" then local root=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if root then self.Effects:Celebrate(root.Position,P.Purple) end
 elseif kind=="Capture" then
  self:EndTiming(); self.Audio:Play("Capture"); self.Effects:Shake()
  self:ShowDialog("SECURITY CAUGHT YOU",packet.Lost.." unbanked cards lost; "..packet.Kept.." remain.\n\nCash, stored batches, van stash, upgrades and discoveries stay safe. Your checkpoint provides a "..C.CaptureImmunity.."-second grace period.","Back to the city",function() end,false)
 elseif kind=="PrestigeInfo" then
  self:ShowDialog("NEW IDENTITY","Requires all districts, completed starter jobs, $100,000 and 1,000 REP.\n\nRESETS: Cash, Reputation, normal equipment, district access, pocket cards, van stash, queued/active processing, Heat, streak and starter jobs.\n\nKEEPS: van ownership, home upgrades, collections, souvenirs, career stats, contract progress/claims, daily progress/claims, cosmetics and equipped outfits, settings and identity badges.\n\nEARNS: one badge and +5% permanent card banking value, capped at +50%. Confirmation expires in 30 seconds.","Confirm reset",function() self:Send("Prestige",packet.Token) end,true)
 end
end
return U
