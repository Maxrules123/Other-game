--!strict
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Shared=game:GetService("ReplicatedStorage").Shared
local C=require(Shared.Config)
local M=require(Shared.MapRules)
local K=require(script.Parent.UIComponents)
local P=K.Color
local H: any={Data=nil,State=nil,Views={}}
local symbols={Hideout="H",Garage="G",Style="S",Contact="C",Vault="V",Delivery="D",Press="P",Rinse="R",Payout="$",Gear="E",Practice="T"}
function H:View(parent: Instance,full: boolean): any
 local area=K.frame(parent,if full then UDim2.new(1,0,0,340) else UDim2.fromScale(1,1),nil,P.Background);area.ClipsDescendants=true;K.round(area,10);K.border(area)
 local view={Area=area,Roads={},Buildings={},Markers={},Full=full}
 if self.Data then
  for _,road in self.Data.Roads do local f=K.frame(area,UDim2.new(),nil,if road.Kind=="Alley" then P.Raised else P.Border);f.AnchorPoint=Vector2.new(.5,.5);table.insert(view.Roads,{Frame=f,Data=road}) end
  for _,building in self.Data.Buildings do local f=K.frame(area,UDim2.new(),nil,Color3.fromRGB(37,49,51));f.AnchorPoint=Vector2.new(.5,.5);table.insert(view.Buildings,{Frame=f,Data=building}) end
  local bounds=K.frame(area,UDim2.new(),nil,P.Background);bounds.BackgroundTransparency=1;bounds.AnchorPoint=Vector2.new(.5,.5);K.border(bounds,P.Muted);view.Bounds=bounds
  for _,marker in self.Data.Markers do
   local icon=if full then K.button(area,symbols[marker.Kind] or "·",UDim2.fromOffset(44,44),nil,function() self.UI:Send("Navigate",marker.Id) end,P.Raised) else K.label(area,symbols[marker.Kind] or "·",12,P.Mint,UDim2.fromOffset(18,18))
   icon.AnchorPoint=Vector2.new(.5,.5);icon.TextXAlignment=Enum.TextXAlignment.Center;icon.ZIndex=12;table.insert(view.Markers,{Icon=icon,Data=marker})
  end
 end
 view.Goal=K.label(area,"◆",19,P.Gold,UDim2.fromOffset(24,24));view.Goal.AnchorPoint=Vector2.new(.5,.5);view.Goal.TextXAlignment=Enum.TextXAlignment.Center;view.Goal.ZIndex=15
 view.Player=K.label(area,"▲",18,P.Text,UDim2.fromOffset(24,24));view.Player.AnchorPoint=Vector2.new(.5,.5);view.Player.TextXAlignment=Enum.TextXAlignment.Center;view.Player.ZIndex=16
 local north=K.label(area,"N",11,P.Muted,UDim2.fromOffset(16,16),UDim2.fromOffset(6,4));north.ZIndex=17;view.North=north
 local priority={Hideout=8,Contact=7,Style=6,Garage=5,Delivery=4,Vault=3}
 table.sort(view.Markers,function(a,b) local pa=priority[a.Data.Kind] or 1;local pb=priority[b.Data.Kind] or 1;return if pa==pb then a.Data.Id<b.Data.Id else pa>pb end)
 table.insert(self.Views,view);return view
end
function H:Init(ui: any)
 self.UI=ui;self.Views={}
 local holder=K.frame(ui.Root,UDim2.fromOffset(180,224),UDim2.new(1,-180,0,76),P.Background);K.round(holder,11);K.border(holder);self.Holder=holder
 local canvas=K.frame(holder,UDim2.new(1,-8,1,-48),UDim2.fromOffset(4,4),P.Background);self.Canvas=canvas
 self.Small=self:View(canvas,false)
 self.Hint=K.label(holder,"MAP / syncing streets",10,P.Muted,UDim2.new(1,-50,0,42),UDim2.new(0,7,1,-44))
 self.Open=ui:Button(holder,"M",UDim2.fromOffset(44,44),UDim2.new(1,-44,1,-44),function() ui:Open("Map") end,P.Raised)
 local elapsed=0
 self.Connection=RunService.RenderStepped:Connect(function(dt)
  if not ui.Gui.Parent then self.Connection:Disconnect();return end
  elapsed+=dt;if elapsed<.1 then return end;elapsed=0;self:Draw()
 end)
end
function H:SetData(data: any)
 self.Data=data
 for _,view in self.Views do view.Area:Destroy() end;self.Views={};self.Full=nil
 self.Small=self:View(self.Canvas,false)
 self.UI.Signature="";if self.UI.Current=="Map" then self.UI:RenderMenu() end
end
function H:ReceiveState(state: any) self.State=state end
function H:Resize()
 local small=self.UI.Gui.AbsoluteSize.X<760 or self.UI.Gui.AbsoluteSize.Y<430
 local width=if small then 132 else 180
 self.Holder.Size=UDim2.fromOffset(width,width+44);self.Holder.Position=UDim2.new(1,-width,0,76)
end
function H:MountFull(parent: Instance)
 self.UI:Note("CITY MAP","H workshop · G garage · S style shop · C contact · V vault · D delivery · ◆ objective. Tap a discovered service to pin it. Markers give direction and distance, not a driving route.",P.Mint)
 if not self.Data then self.UI:Note("Receiving street layout","The map uses the same roads and building footprints that generate this city.");return end
 local row=self.UI:Row(358);self.Full=self:View(row,true);self.Full.Area.Size=UDim2.new(1,-16,1,-16);self.Full.Area.Position=UDim2.fromOffset(8,8)
 self.UI:Action("NAVIGATION",if self.State and self.State.Navigation then self.State.Navigation.Title else "Choose a discovered service or follow your current objective.","Clear pin / follow objective",function() self.UI:Send("Navigate","") end)
 self.UI:Action("MINIMAP ZOOM","Zoom changes the local map's visible area. Mission destinations outside the square remain marked on its edge.","Cycle zoom",function() local settings=self.State.Profile.Settings;self.UI:Send("Setting",{Key="MinimapZoom",Value=settings.MinimapZoom%3+1}) end,P.Raised)
 local known={}
 for _,marker in self.Data.Markers do if self.State.Profile.Exploration.Services[marker.Id] and self.State.Profile.Districts[tostring(marker.District)] then table.insert(known,marker) end end
 table.sort(known,function(a,b) return if a.District==b.District then a.Label<b.Label else a.District<b.District end)
 self.UI:Note("DISCOVERED SERVICES","Use the list when nearby map icons group together. Explore a service to add it here.")
 for _,marker in known do self.UI:Action(C.Districts[marker.District].Name.." / "..marker.Label,marker.Kind.." service", "Pin destination",function() self.UI:Send("Navigate",marker.Id) end,P.Raised) end
 self:Draw()
end
function H:Draw()
 if not self.State then return end
 local ui=self.UI;self.Holder.Visible=not ui.Current and not ui.Timing and not ui.Modal.Visible and not ui.ResultLayer.Visible and not self.State.Vault
 local character=Players.LocalPlayer.Character;local root=character and character:FindFirstChild("HumanoidRootPart")
 if not root or not self.Data then return end
 local p=self.State.Profile;local goal=self.State.Navigation
 self.Hint.Text=if goal then string.format("%s\n%d studs",goal.Title,math.floor((root.Position-goal.Position).Magnitude+.5)) else "M / city map"
 for i=#self.Views,1,-1 do
  local view=self.Views[i]
  if not view.Area.Parent then table.remove(self.Views,i);continue end
  if (not view.Full and not self.Holder.Visible) or (view.Full and ui.Current~="Map") then continue end
  local size=view.Area.AbsoluteSize;local width=math.max(40,size.X);local height=math.max(40,size.Y)
  local bounds=self.Data.Bounds
  local center=if view.Full then Vector3.new((bounds.MinX+bounds.MaxX)/2,0,(bounds.MinZ+bounds.MaxZ)/2) else root.Position
  local scale=if view.Full then math.max((bounds.MaxX-bounds.MinX)/math.max(32,width-44),(bounds.MaxZ-bounds.MinZ)/math.max(32,height-44)) else ({1.25,2.2,3.6})[p.Settings.MinimapZoom]
  local rotation=if not view.Full and p.Settings.MinimapRotate then M.bearing(root.CFrame.LookVector) else 0
  local function place(frame: GuiObject,position: Vector3,clip: boolean?): boolean
   local x,y=M.project(position,center,rotation,scale);local edge=false
   if clip then x,y,edge=M.clip(x,y,math.min(width,height)/2,14) end
   frame.Position=UDim2.new(.5,x,.5,y);return edge
  end
  for _,entries in {view.Roads,view.Buildings} do for _,record in entries do
   local d=record.Data;place(record.Frame,Vector3.new(d.X,0,d.Z));record.Frame.Size=UDim2.fromOffset(math.max(1,d.Width/scale),math.max(1,d.Depth/scale));record.Frame.Rotation=-math.deg(rotation)
  end end
  if view.Bounds then place(view.Bounds,Vector3.new((bounds.MinX+bounds.MaxX)/2,0,0));view.Bounds.Size=UDim2.fromOffset((bounds.MaxX-bounds.MinX)/scale,(bounds.MaxZ-bounds.MinZ)/scale);view.Bounds.Rotation=-math.deg(rotation) end
  local occupied={};local spacing=if view.Full then 44 else 17
  for _,record in view.Markers do
   local visible=M.visible(record.Data,p,goal) and not (goal and goal.Id==record.Data.Id)
   if visible then
    local x,y=M.project(record.Data.Position,center,rotation,scale)
    visible=math.abs(x)<width/2-8 and math.abs(y)<height/2-8
    for _,point in occupied do if math.abs(point.X-x)<spacing and math.abs(point.Y-y)<spacing then visible=false;break end end
    if visible then table.insert(occupied,{X=x,Y=y});place(record.Icon,record.Data.Position);record.Icon.Rotation=0 end
   end
   record.Icon.Visible=visible
  end
  view.Goal.Visible=goal~=nil
  if goal then local edge=place(view.Goal,goal.Position,not view.Full);view.Goal.Text=if edge then "◇" else "◆" end
  place(view.Player,root.Position);view.Player.Rotation=math.deg(M.bearing(root.CFrame.LookVector)-rotation)
  view.North.Text=if rotation==0 then "N" else "↑";view.North.Rotation=-math.deg(rotation)
 end
end
return H
