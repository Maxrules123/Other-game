--!strict
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local K=require(script.Parent.UIComponents)
local Shared=game:GetService("ReplicatedStorage").Shared
local Q=require(Shared.RoundRules)
local C=require(Shared.Config)
local P=K.Color
local H={}
function H.Controls(ui: any,locked: boolean)
 if ui.PlayerControls then if locked then ui.PlayerControls:Disable() else ui.PlayerControls:Enable() end end
end
function H.Build(ui: any)
 local layer=K.frame(ui.Gui,UDim2.fromScale(1,1),nil,P.Background);layer.BackgroundTransparency=0.18;layer.ZIndex=140;layer.Visible=false;ui.TimingLayer=layer
 local box=K.frame(layer,UDim2.new(1,-24,0,410),UDim2.fromScale(0.5,0.5),P.Background);box.AnchorPoint=Vector2.new(.5,.5);ui.TimingBox=box;K.round(box,16);K.border(box)
 local max=Instance.new("UISizeConstraint");max.MaxSize=Vector2.new(680,410);max.Parent=box
 ui.TimingScale=Instance.new("UIScale");ui.TimingScale.Parent=box
 ui.TimingTitle=K.label(box,"",19,P.Text,UDim2.new(1,-36,0,28),UDim2.fromOffset(18,8));ui.TimingTitle.Font=Enum.Font.GothamBold
 ui.RouteLabel=K.label(box,"",21,P.Mint,UDim2.new(1,-36,0,32),UDim2.fromOffset(18,48));ui.RouteLabel.Font=Enum.Font.GothamBold
 ui.TimingCaption=K.label(box,"",12,P.Muted,UDim2.new(1,-36,0,54),UDim2.fromOffset(18,86))
 ui.RoundProgress=K.progress(box,UDim2.fromOffset(18,146),UDim2.new(1,-36,0,4),0,P.Mint)
 local track=K.frame(box,UDim2.new(1,-36,0,40),UDim2.fromOffset(18,159),P.Raised);ui.TimingTrack=track;K.round(track,7)
 ui.Hazard=K.frame(track,UDim2.fromScale(.09,1),nil,P.Red);K.round(ui.Hazard,6)
 ui.Zone=K.frame(track,UDim2.fromScale(.2,1),nil,P.Mint);K.round(ui.Zone,6)
 ui.Perfect=K.frame(track,UDim2.fromScale(.06,1),nil,P.Gold);K.round(ui.Perfect,4)
 ui.Marker=K.frame(track,UDim2.new(0,4,1,12),UDim2.fromOffset(0,-6),P.Text);ui.Marker.AnchorPoint=Vector2.new(.5,0)
 ui.LaneButtons={}
 for lane=1,3 do
  local b=ui:Button(box,"",UDim2.new(1/3,-16,0,48),UDim2.new((lane-1)/3,12,0,221),function() H.Submit(ui,lane) end,P.Raised);ui.LaneButtons[lane]=b
 end
 ui.StopButton=ui.LaneButtons[2]
 ui.RoundFeedback=K.label(box,"",12,P.Gold,UDim2.new(1,-36,0,26),UDim2.fromOffset(18,277))
 ui.RoundTool=ui:Button(box,"USE DECOY / T / Y",UDim2.new(.6,-24,0,44),UDim2.new(0,18,1,-52),function() if ui.Timing then ui:Send("RoundTool",ui.Timing.Token) end end,P.Raised)
 ui.TimingCancel=ui:Button(box,"ABANDON / B",UDim2.new(.4,-24,0,44),UDim2.new(.6,6,1,-52),function() ui:Send("Cancel");ui:EndTiming() end,P.Raised)
 local result=K.frame(ui.Gui,UDim2.fromScale(1,1),nil,P.Background);result.BackgroundTransparency=.18;result.ZIndex=145;result.Visible=false;ui.ResultLayer=result
 local rb=K.frame(result,UDim2.new(1,-24,1,-24),UDim2.fromScale(.5,.5),P.Background);rb.AnchorPoint=Vector2.new(.5,.5);K.round(rb,16);K.border(rb)
 local rmax=Instance.new("UISizeConstraint");rmax.MaxSize=Vector2.new(600,500);rmax.Parent=rb
 ui.ResultTitle=K.label(rb,"",23,P.Mint,UDim2.new(1,-36,0,42),UDim2.fromOffset(18,8));ui.ResultTitle.Font=Enum.Font.GothamBold
 local scroll=K.scroll(rb,UDim2.new(1,-36,1,-120),UDim2.fromOffset(18,58));ui.ResultScroll=scroll
 ui.ResultText=K.label(scroll,"",14,P.Text,UDim2.new(1,-8,0,0));ui.ResultText.AutomaticSize=Enum.AutomaticSize.Y;ui.ResultText.TextYAlignment=Enum.TextYAlignment.Top
 ui.ResultClose=ui:Button(rb,"BACK TO CITY",UDim2.new(.5,-24,0,48),UDim2.new(0,18,1,-58),function() H.CloseResult(ui) end,P.Raised)
 ui.ResultRetry=ui:Button(rb,"RETRY PRACTICE",UDim2.new(.5,-24,0,48),UDim2.new(.5,6,1,-58),function() local mode=ui.LastRoundMode;H.CloseResult(ui);ui:Send("Practice",mode) end,P.Mint)
 task.spawn(function()
  local ok,controls=pcall(function() return require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls() end)
  if ok then ui.PlayerControls=controls end
 end)
end
function H.Resize(ui: any)
 local height=math.clamp(ui.Gui.AbsoluteSize.Y-24,252,410);local compact=height<340
 ui.TimingBox.Size=UDim2.new(1,-24,0,height)
 ui.TimingTitle.Position=UDim2.fromOffset(18,6);ui.TimingTitle.Size=UDim2.new(1,-36,0,28)
 ui.RouteLabel.Position=UDim2.fromOffset(18,if compact then 36 else 48)
 ui.TimingCaption.Position=UDim2.fromOffset(18,if compact then 68 else 86);ui.TimingCaption.Size=UDim2.new(1,-36,0,if compact then 36 else 54)
 ui.RoundProgress.Parent.Position=UDim2.fromOffset(18,if compact then 107 else 146)
 ui.TimingTrack.Position=UDim2.fromOffset(18,if compact then 117 else 159);ui.TimingTrack.Size=UDim2.new(1,-36,0,if compact then 26 else 40)
 for lane,b in ui.LaneButtons do b.Position=UDim2.new((lane-1)/3,12,0,if compact then 148 else 221);b.Size=UDim2.new(1/3,-16,0,48) end
 ui.RoundFeedback.Visible=not compact;ui.RoundFeedback.Position=UDim2.fromOffset(18,277)
 ui.TimingCancel.Position=UDim2.new(.6,6,1,-52)
end
function H.Start(ui: any,packet: any)
 ui:Close();ui:SkipReveal();ui:HideDialog();ui:EndTiming();H.CloseResult(ui)
 ui.Timing=packet;packet.Submitted=false;ui.SelectedLane=2;ui.TimingLayer.Visible=true;ui.Toast.Visible=false;H.Controls(ui,true)
 H.Resize(ui)
 ui.TimingTitle.Text=C.Modes[packet.Approach].Name:upper().." / "..math.min(packet.Stage,packet.Stages).." OF "..packet.Stages
 ui.RoundProgress.Size=UDim2.fromScale(math.clamp((packet.Stage-1)/packet.Stages,0,1),1)
 local route={};for i,lane in packet.Sequence do table.insert(route,(if i==packet.Stage then "["..lane.."]" else tostring(lane))) end
 ui.RouteLabel.Text=if packet.Phase=="Read" then "READ  "..table.concat(route," → ") elseif packet.Memory then "MEMORY / follow the route you read" elseif packet.Phase=="Decision" then "CARD READY / secure or take a risk" else packet.Kind:upper().." / LANE "..packet.Lane.." / "..packet.Pattern:upper()
 ui.TimingCaption.Text=packet.Hint
 ui.RoundTool.Visible=packet.Tool and packet.Phase=="Action"
 ui.TimingTrack.Visible=packet.Phase~="Read" and packet.Phase~="Decision"
 ui.Hazard.Visible=packet.Hazard==true
 ui.RoundFeedback.Text="Gold = perfect · Mint = clear · Recovery remaining: "..packet.RecoveryLeft
 for lane,b in ui.LaneButtons do
  b.Visible=packet.Phase~="Read" and (packet.Phase~="Decision" or lane~=2)
  b.Text=if packet.Phase=="Decision" then (if lane==1 then "SECURE / J" else "+15% BONUS / L") else tostring(lane).." / "..({"J","K","L"})[lane]
  b.BackgroundColor3=if packet.Phase=="Decision" then (if lane==1 then P.Mint else P.Gold) elseif lane==ui.SelectedLane then P.Mint else P.Raised
  b.TextColor3=if b.BackgroundColor3==P.Raised then P.Text else P.Background
 end
 if packet.Phase~="Read" then ui:Focus(if packet.Phase=="Decision" then ui.LaneButtons[1] else ui.LaneButtons[2]) end
 ui.TimingConnection=RunService.RenderStepped:Connect(function()
  if ui.Timing~=packet or packet.Submitted then return end
  local elapsed=workspace:GetServerTimeNow()-packet.Start
  if packet.Phase=="Read" then ui.RoundFeedback.Text="Begin in "..string.format("%.1fs",math.max(0,packet.Duration-elapsed));return end
  if packet.Phase=="Decision" then ui.RoundFeedback.Text="Secures automatically in "..math.ceil(math.max(0,packet.Duration-elapsed)).."s";return end
  local center=Q.center(elapsed,packet)
  ui.Zone.Size=UDim2.fromScale(packet.Width,1);ui.Zone.Position=UDim2.fromScale(center-packet.Width/2,0)
  ui.Perfect.Size=UDim2.fromScale(packet.Width*.4,1);ui.Perfect.Position=UDim2.fromScale(center-packet.Width*.2,0)
  ui.Marker.Position=UDim2.new(Q.cursor(elapsed,packet),0,0,-6)
  ui.Hazard.Position=UDim2.fromScale(if center>.5 then .1 else .81,0)
  if elapsed<0 then ui.RoundFeedback.Text="READY / "..string.format("%.1f",-elapsed) else ui.RoundFeedback.Text="J K L / tap lane · arrows select + Space/A · "..string.format("%.1fs",math.max(0,packet.Duration-elapsed)) end
 end)
end
function H.Select(ui: any,direction: number)
 if not ui.Timing or ui.Timing.Phase=="Read" then return end
 ui.SelectedLane=(ui.SelectedLane-1+direction)%3+1
 for lane,b in ui.LaneButtons do if ui.Timing.Phase~="Decision" then b.BackgroundColor3=if lane==ui.SelectedLane then P.Mint else P.Raised;b.TextColor3=if lane==ui.SelectedLane then P.Background else P.Text end end
 ui:Focus(ui.LaneButtons[ui.SelectedLane])
end
function H.Submit(ui: any,lane: number?)
 local p=ui.Timing;if not p or p.Submitted or p.Phase=="Read" then return end
 lane=lane or ui.SelectedLane or 2
 if p.Phase=="Decision" then
  if lane==2 then lane=1 end
  p.Submitted=true;ui:Send("RoundChoice",{Token=p.Token,Choice=if lane==1 then "Secure" else "Bonus"});return
 end
 local now=workspace:GetServerTimeNow();if now<p.Start or now>p.Start+p.Duration then return end
 p.Submitted=true
 local grade=Q.grade(now-p.Start,lane,p)
 ui.RoundFeedback.Text=if grade=="Miss" then "INPUT RECEIVED / checking recovery" else grade:upper().." / input received"
 ui.Marker.BackgroundColor3=if grade=="Perfect" then P.Gold elseif grade=="Good" then P.Mint else P.Red
 ui.Audio:Play(if grade=="Miss" then "Failure" else "Success")
 ui:Send("Stop",{Token=p.Token,Lane=lane,At=now})
end
function H.End(ui: any)
 if ui.TimingConnection then ui.TimingConnection:Disconnect();ui.TimingConnection=nil end
 ui.Timing=nil;ui.TimingLayer.Visible=false;H.Controls(ui,false);ui:Focus(nil)
end
function H.Result(ui: any,p: any)
 ui:EndTiming();ui:Close();ui:HideDialog();ui.ResultLayer.Visible=true;ui.LastRoundMode=p.Mode;ui.ResultScroll.CanvasPosition=Vector2.zero;H.Controls(ui,true)
 ui.ResultTitle.Text=p.Medal:upper().." / "..(if p.Success then "ROUTE COMPLETE" else "TRY ANOTHER ROUTE")
 ui.ResultTitle.TextColor3=if p.Success then P.Mint else P.Red
 local lines={p.Reason,"",string.format("%d POINTS  ·  BEST %d%s",p.Score,p.Best,if p.NewBest then " / NEW BEST" else ""),string.format("%d/%d perfect  ·  %d mistakes  ·  %.1fs",p.Perfects,p.Stages,p.Mistakes,p.Seconds),""}
 if p.Loot then
  local card=C.Cards[p.Loot.Id];table.insert(lines,card.Brand.." / "..C.Rarities[card.Rarity].." / "..p.Loot.Variant)
  table.insert(lines,string.format("Card quality ×%.2f  ·  Intake value $%d",p.Quality,p.Intake))
  table.insert(lines,"+"..p.Rep.." REP  ·  +"..math.floor(p.Heat+.5).." Heat")
  table.insert(lines,"Cash arrives after you secure, press, rinse and claim this card at home.")
 elseif p.Mode=="Vault" then table.insert(lines,if p.Success then "Vault payout +$"..p.Cash.." / +20 REP / Golden Royal Treat discovery" else "No vault payout. Banked progress is safe; replay after the kiosk cooldown.")
 elseif p.Practice then table.insert(lines,"Training keeps your medal and best score. No Cash, cards or Heat are changed.")
 else table.insert(lines,"No card awarded. +"..math.floor(p.Heat+.5).." Heat. Saved money and stored batches stay safe.") end
 table.insert(lines,"");table.insert(lines,if p.Bonus then "BONUS CLEARED / +15% round quality" elseif p.Mistakes>0 then "Recovered mistakes reduce quality; use workshop practice for a quick retry." else "Try Bold for changing lanes, reversed patterns and memory routes in harder districts.")
 ui.ResultText.Text=table.concat(lines,"\n");ui.ResultRetry.Visible=p.Practice;ui.ResultClose.Text=if p.Practice then "BACK TO WORKSHOP" else "BACK TO CITY"
 ui:Focus(if p.Practice then ui.ResultRetry else ui.ResultClose);ui.Audio:Play(if p.Success then "Success" else "Failure")
end
function H.CloseResult(ui: any)
 if ui.ResultLayer then ui.ResultLayer.Visible=false end;H.Controls(ui,false);ui:Focus(nil)
end
return H
