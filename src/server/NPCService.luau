--!strict
local C = require(game:GetService("ReplicatedStorage").Shared.Config)
local N: any = { Targets = {}, Guards = {} }
function N:Actor(parent: Instance, name: string, position: Vector3, color: Color3): Model
 local model=Instance.new("Model"); model.Name=name; model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local function body(name_: string,size: Vector3,offset: Vector3,c: Color3): Part
  local p=Instance.new("Part"); p.Name=name_; p.Size=size; p.CFrame=CFrame.new(position+offset); p.Color=c; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.Parent=model
  return p
 end
 local root=body("Root",Vector3.new(2,2,1),Vector3.new(0,3,0),color); model.PrimaryPart=root
 local head=body("Head",Vector3.new(1.6,1.6,1.6),Vector3.new(0,4.8,0),Color3.fromRGB(243,207,169)); head.Shape=Enum.PartType.Ball
 body("Left arm",Vector3.new(0.65,2,0.7),Vector3.new(-1.4,3,0),color)
 body("Right arm",Vector3.new(0.65,2,0.7),Vector3.new(1.4,3,0),color)
 body("Left shoe",Vector3.new(0.85,1.8,1),Vector3.new(-0.55,1.1,0),C.Palette.Charcoal)
 body("Right shoe",Vector3.new(0.85,1.8,1),Vector3.new(0.55,1.1,0),C.Palette.Charcoal)
 for _,side in {-1,1} do body("Eye",Vector3.new(0.15,0.2,0.12),Vector3.new(side*0.3,4.9,-0.76),C.Palette.Charcoal) end
 body("Cartoon smile",Vector3.new(0.45,0.1,0.1),Vector3.new(0,4.45,-0.74),C.Palette.Charcoal)
 local gui=Instance.new("BillboardGui"); gui.Name="Status"; gui.Size=UDim2.fromOffset(260,92); gui.StudsOffset=Vector3.new(0,4,0); gui.MaxDistance=48; gui.AlwaysOnTop=false; gui.Parent=root
 local label=Instance.new("TextLabel"); label.Name="Text"; label.Size=UDim2.fromScale(1,1); label.BackgroundColor3=C.Palette.Charcoal; label.BackgroundTransparency=0.18; label.TextColor3=C.Palette.White; label.Font=Enum.Font.GothamBold; label.TextSize=12; label.TextWrapped=true; label.Parent=gui
 local round=Instance.new("UICorner"); round.CornerRadius=UDim.new(0,8); round.Parent=label
 model.Parent=parent
 return model
end
function N:Build(world: any)
 local folder=Instance.new("Folder"); folder.Name="Actors"; folder.Parent=world.Root; self.Folder=folder
 for _,spawn in world.Targets do
  local d=C.Districts[spawn.District]
  local style=spawn.Style or "Daydreamer"
  local names={"Pip Crumble", "Mina Mints", "Duke Noodles", "Bea Banana", "Gus Goblin", "Lady Raccoon", "Mo Moon", "Vee Void", "Finn Foil"}
  local number=tonumber(string.match(spawn.Id,"N(%d+)")) or 1
  local model=self:Actor(folder,names[number] or "Pocket Tourist",spawn.Position,d.Color:Lerp(C.Palette.Purple,number*0.035))
  model:SetAttribute("Style",style)
  local accessory=Instance.new("Part"); accessory.Name=if style=="VIP" then "Fancy hat" else "Cartoon backpack"; accessory.Anchored=true; accessory.CanCollide=false; accessory.Size=if style=="VIP" then Vector3.new(2,1.1,2) else Vector3.new(1.5,1.8,0.6); accessory.CFrame=model.PrimaryPart.CFrame*CFrame.new(0,if style=="VIP" then 3 else 0,if style=="VIP" then 0 else 0.8); accessory.Color=if style=="Collector" then C.Palette.Gold else C.Palette.Panel; accessory.Parent=model
  model:SetAttribute("TargetId",spawn.Id)
  local prompt=Instance.new("ProximityPrompt"); prompt.ActionText="Scout cartoon target"; prompt.ObjectText=d.Name.." target"; prompt.KeyboardKeyCode=Enum.KeyCode.E; prompt.GamepadKeyCode=Enum.KeyCode.ButtonX; prompt.MaxActivationDistance=11; prompt.RequiresLineOfSight=true; prompt:SetAttribute("Action","Target"); prompt:SetAttribute("Id",spawn.Id); prompt.Parent=model.PrimaryPart
  self.Targets[spawn.Id]={Id=spawn.Id, District=spawn.District, Model=model, Prompt=prompt, Origin=spawn.Position+Vector3.new(0,3,0), Available=0, Reserved=nil, Suspicion=0, Phase=math.random()*6, State="Walking", Style=style, Route=spawn.Route, Waypoint=1, PauseUntil=0}
 end
 for _,spawn in world.Guards do
  local model=self:Actor(folder,"Cardboard Security",spawn.Position,C.Palette.Panel)
  local hat=Instance.new("Part"); hat.Name="Security cap"; hat.Size=Vector3.new(2,0.6,2); hat.CFrame=model.PrimaryPart.CFrame*CFrame.new(0,2.6,0); hat.Anchored=true; hat.CanCollide=false; hat.Color=C.Palette.Gold; hat.Parent=model
  table.insert(self.Guards,{Model=model,District=spawn.District,Origin=spawn.Position+Vector3.new(0,3,0),Target=nil,State="Patrol",LastSeen=0,LastPath=0,Waypoints=nil,Waypoint=1,Phase=math.random()*6, BackLane=spawn.BackLane})
 end
end
function N:Tick(now: number, dt: number)
 for _,target in self.Targets do
  target.Suspicion=math.max(0,target.Suspicion-dt*4)
  local busy=target.Reserved~=nil or target.Available>now
  target.Prompt.Enabled=not busy
  target.Model:SetAttribute("Suspicion",math.floor(target.Suspicion))
  if not busy and target.Route and now>=target.PauseUntil and now>=(target.PreviewUntil or 0) then
   local root=target.Model.PrimaryPart
   local destination=target.Route[target.Waypoint]
   local delta=destination-root.Position
   if delta.Magnitude<0.4 then
    target.Waypoint=target.Waypoint%#target.Route+1; target.PauseUntil=now+1.5+(target.Phase%2); target.State="Pausing"
   else
    local speed=C.TargetStyles[target.Style].Speed
    local position=root.Position+delta.Unit*math.min(delta.Magnitude,speed*dt)
    target.Model:PivotTo(CFrame.lookAt(position,position+delta.Unit)); target.State="Walking"
   end
  elseif not busy then target.State="Pausing" end
  local root=target.Model.PrimaryPart
  local swing=if target.State=="Walking" and not busy then math.sin(now*6+target.Phase)*0.3 else 0
  for _,side in {-1,1} do
   local shoe=target.Model:FindFirstChild(if side<0 then "Left shoe" else "Right shoe")
   local arm=target.Model:FindFirstChild(if side<0 then "Left arm" else "Right arm")
   if shoe then shoe.CFrame=root.CFrame*CFrame.new(side*0.55,-1.9,0)*CFrame.Angles(side*swing,0,0) end
   if arm then arm.CFrame=root.CFrame*CFrame.new(side*1.4,0,0)*CFrame.Angles(-side*swing,0,0) end
  end
  local d=C.Districts[target.District]
  local possible={}
  for r,w in d.Weights do if w>0 then table.insert(possible,C.Rarities[r]) end end
  local state=if target.Reserved then "BUSY" elseif target.Available>now then "RECOVERING" elseif target.Suspicion>40 then "SUSPICIOUS" else string.upper(target.State)
  target.Model.PrimaryPart.Color=d.Color:Lerp(C.Palette.Danger,math.clamp(target.Suspicion/150,0,0.5))
  target.Model.PrimaryPart.Status.Text.Text=string.format("%s / %s · %s\n%s\nSleight %d+ · Suspicion %d%%",target.Model.Name,C.TargetStyles[target.Style].Name,state,table.concat(possible," / "),d.Equipment,math.floor(target.Suspicion))
 end
end
return N
