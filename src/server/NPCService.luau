--!strict
local C = require(game:GetService("ReplicatedStorage").Shared.Config)
local F=require(script.Parent.ModelFactory)
local N: any = { Targets = {}, Guards = {} }
function N:Prepare()
 -- Roblox supplies a genuine articulated R15 base; no unknown Toolbox scripts are loaded.
 local ok,rig=pcall(function()
  local description=Instance.new("HumanoidDescription")
  description.BodyTypeScale=0.5; description.ProportionScale=0.3
  description.HeadColor=Color3.fromRGB(218,177,142); description.LeftArmColor=description.HeadColor; description.RightArmColor=description.HeadColor
  description.TorsoColor=C.Palette.Panel; description.LeftLegColor=C.Palette.Charcoal; description.RightLegColor=C.Palette.Charcoal
  return game:GetService("Players"):CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15)
 end)
 if ok then self.AvatarTemplate=rig; rig.Name="CityR15Template"; rig.Parent=nil
 else warn("R15 rig unavailable; using detailed original fallback citizens.") end
end
function N:RigActor(parent: Instance,name: string,position: Vector3,color: Color3): Model
 local model=self.AvatarTemplate:Clone(); model.Name=name; model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local root=model:FindFirstChild("HumanoidRootPart"); model.PrimaryPart=root
 local humanoid=model:FindFirstChildOfClass("Humanoid"); humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None; humanoid.AutoRotate=false; humanoid.WalkSpeed=0
 for _,item in model:GetDescendants() do if item:IsA("BasePart") then item.Anchored=item==root; item.CanCollide=false; item.CanTouch=false; item.Massless=true end end
 root.Transparency=1; model:PivotTo(CFrame.new(position+Vector3.new(0,3.8,0))); model:SetAttribute("R15Citizen",true)
 local torso=model:FindFirstChild("UpperTorso")
 if torso then
  torso.Color=color
  local function detail(name_: string,size: Vector3,offset: CFrame,col: Color3,material: Enum.Material?)
   local p=F.part(model,name_,size,torso.CFrame*offset,col,material or Enum.Material.Fabric); p.Anchored=false; p.CanCollide=false; p.CanTouch=false; p.Massless=true
   local weld=Instance.new("WeldConstraint"); weld.Part0=torso; weld.Part1=p; weld.Parent=p
  end
  detail("Jacket left lapel",Vector3.new(0.27,0.9,0.08),CFrame.new(-0.35,0.1,-0.55)*CFrame.Angles(0,0,-0.15),color:Lerp(C.Palette.White,0.2))
  detail("Jacket right lapel",Vector3.new(0.27,0.9,0.08),CFrame.new(0.35,0.1,-0.55)*CFrame.Angles(0,0,0.15),color:Lerp(C.Palette.White,0.2))
  detail("Shirt collar",Vector3.new(0.55,0.2,0.1),CFrame.new(0,0.65,-0.55),C.Palette.White)
  detail("Tie",Vector3.new(0.12,0.8,0.1),CFrame.new(0,0.1,-0.6),C.Palette.Gold)
  detail("Chest pocket",Vector3.new(0.32,0.24,0.08),CFrame.new(-0.65,-0.1,-0.57),color:Lerp(C.Palette.Charcoal,0.2))
  for n=1,3 do detail("Jacket button",Vector3.new(0.07,0.07,0.08),CFrame.new(0,-0.15-n*0.15,-0.6),C.Palette.Muted,Enum.Material.Metal) end
 end
 local head=model:FindFirstChild("Head")
 if head then
  local face=head:FindFirstChildOfClass("Decal") or Instance.new("Decal"); face.Texture="rbxasset://textures/face.png"; face.Face=Enum.NormalId.Front; face.Parent=head
  local hair=F.part(model,"Original hair cap",Vector3.new(1.6,0.5,1.5),head.CFrame*CFrame.new(0,0.6,0.08),Color3.fromRGB(66,48,45),Enum.Material.SmoothPlastic,Enum.PartType.Ball); hair.Anchored=false; hair.CanCollide=false; hair.Massless=true
  local weld=Instance.new("WeldConstraint"); weld.Part0=head; weld.Part1=hair; weld.Parent=hair
 end
 local gui=Instance.new("BillboardGui"); gui.Name="Status"; gui.Size=UDim2.fromOffset(240,70); gui.StudsOffset=Vector3.new(0,4.2,0); gui.MaxDistance=40; gui.Parent=root
 local label=Instance.new("TextLabel"); label.Name="Text"; label.Size=UDim2.fromScale(1,1); label.BackgroundColor3=C.Palette.Charcoal; label.BackgroundTransparency=0.22; label.TextColor3=C.Palette.White; label.Font=Enum.Font.GothamMedium; label.TextSize=11; label.TextWrapped=true; label.Parent=gui
 local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,8); corner.Parent=label
 local shades={Color3.fromRGB(233,195,160),Color3.fromRGB(204,157,117),Color3.fromRGB(153,106,77),Color3.fromRGB(109,75,57),Color3.fromRGB(224,177,139)}
 local skin=shades[(math.abs(math.floor(position.X+position.Z)*7+#name)%#shades)+1]
 for _,partName in {"Head","LeftHand","RightHand"} do local skinPart=model:FindFirstChild(partName); if skinPart and skinPart:IsA("BasePart") then skinPart.Color=skin end end
 local hand=model:FindFirstChild("RightHand")
 if hand then
  for _,spec in {{"CitizenPhone",Vector3.new(0.35,0.65,0.08),C.Palette.Charcoal,0},{"PhoneScreen",Vector3.new(0.28,0.51,0.02),C.Palette.Mint,-0.055}} do
   local item=F.part(model,spec[1],spec[2],hand.CFrame*CFrame.new(0,-0.1,-0.36+spec[4]),spec[3],Enum.Material.SmoothPlastic); item.Anchored=false; item.CanCollide=false; item.CanQuery=false; item.Massless=true
   local joint=Instance.new("WeldConstraint"); joint.Part0=hand; joint.Part1=item; joint.Parent=item
  end
 end
 for _,spec in {{"Umbrella canopy",Vector3.new(3.6,0.5,3.6),Vector3.new(0.5,3.3,0),Enum.PartType.Ball},{"Umbrella shaft",Vector3.new(0.08,2.8,0.08),Vector3.new(0.5,1.8,0),Enum.PartType.Block}} do
  local item=F.part(model,spec[1],spec[2],root.CFrame*CFrame.new(spec[3]),color,Enum.Material.SmoothPlastic,spec[4]); item.CanCollide=false; item.CanQuery=false
 end
 model.Parent=parent; return model
end
function N:Actor(parent: Instance, name: string, position: Vector3, color: Color3): Model
 if self.AvatarTemplate then return self:RigActor(parent,name,position,color) end
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
  local names={"Pip Crumble", "Mina Mints", "Duke Noodles", "Bea Banana", "Gus Goblin", "Lady Raccoon", "Mo Moon", "Vee Void", "Finn Foil", "Tess Transit", "Noah Notes", "Rae Rain", "Zed Ledger"}
  local number=tonumber(string.match(spawn.Id,"N(%d+)")) or 1
  local model=self:Actor(folder,names[number] or "Pocket Tourist",spawn.Position,d.Color:Lerp(C.Palette.Purple,number*0.035))
  model:SetAttribute("Style",style)
  local accessory=Instance.new("Part"); accessory.Name=if style=="VIP" then "Fancy hat" else "Cartoon backpack"; accessory.Anchored=true; accessory.CanCollide=false; accessory.Size=if style=="VIP" then Vector3.new(2,1.1,2) else Vector3.new(1.5,1.8,0.6); accessory.CFrame=model.PrimaryPart.CFrame*CFrame.new(0,if style=="VIP" then 3 else 0,if style=="VIP" then 0 else 0.8); accessory.Color=if style=="Collector" then C.Palette.Gold else C.Palette.Panel; accessory.Parent=model
  model:SetAttribute("TargetId",spawn.Id)
  local prompt=Instance.new("ProximityPrompt"); prompt.ActionText="Scout cartoon target"; prompt.ObjectText=d.Name.." target"; prompt.KeyboardKeyCode=Enum.KeyCode.E; prompt.GamepadKeyCode=Enum.KeyCode.ButtonX; prompt.MaxActivationDistance=11; prompt.RequiresLineOfSight=true; prompt:SetAttribute("Action","Target"); prompt:SetAttribute("Id",spawn.Id); prompt.Parent=model.PrimaryPart
  self.Targets[spawn.Id]={Id=spawn.Id, District=spawn.District, Model=model, Prompt=prompt, Origin=spawn.Position+Vector3.new(0,3.8,0), Available=0, Reserved=nil, Suspicion=0, Phase=math.random()*6, State="Walking", Style=style, PauseLabel=spawn.PauseLabel or "Window shopping", Route=spawn.Route, Waypoint=1, PauseUntil=0}
 end
 for speaker,position in world.QuestPositions do
  local citizen=self:Actor(folder,speaker,position,C.Palette.Purple)
  citizen.PrimaryPart.Status.Text.Text=speaker.." / STORY CONTRACTS"
  local q=Instance.new("ProximityPrompt"); q.ActionText="Talk to "..speaker; q.ObjectText="City contracts"; q:SetAttribute("Action","Quest"); q:SetAttribute("Id",speaker); q.MaxActivationDistance=11; q.Parent=citizen.PrimaryPart
 end
 for _,spawn in world.Guards do
  local model=self:Actor(folder,"Cardboard Security",spawn.Position,C.Palette.Panel)
  local hat=Instance.new("Part"); hat.Name="Security cap"; hat.Size=Vector3.new(2,0.6,2); hat.CFrame=model.PrimaryPart.CFrame*CFrame.new(0,2.6,0); hat.Anchored=true; hat.CanCollide=false; hat.Color=C.Palette.Gold; hat.Parent=model
  table.insert(self.Guards,{Model=model,District=spawn.District,Origin=spawn.Position+Vector3.new(0,3.8,0),Target=nil,State="Patrol",LastSeen=0,LastPath=0,Waypoints=nil,Waypoint=1,Phase=math.random()*6, BackLane=spawn.BackLane})
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
    target.Waypoint=target.Waypoint%#target.Route+1; target.PauseUntil=now+1.5+(target.Phase%2)+(if workspace:GetAttribute("Weather")=="Rain" then 2 else 0); target.State=target.PauseLabel
   else
    local speed=C.TargetStyles[target.Style].Speed
    local position=root.Position+delta.Unit*math.min(delta.Magnitude,speed*dt)
    target.Model:PivotTo(CFrame.lookAt(position,position+delta.Unit)); target.State="Walking"
   end
  elseif not busy then target.State=target.PauseLabel end
  target.Model:SetAttribute("Activity",if busy then "Talking" else target.State)
  target.Model:SetAttribute("MotionTarget",target.Model.PrimaryPart.CFrame)
  target.Model:SetAttribute("WalkSpeed",if target.State=="Walking" and not busy then C.TargetStyles[target.Style].Speed else 0)
  local d=C.Districts[target.District]
  local possible={}
  for r,w in d.Weights do if w>0 then table.insert(possible,C.Rarities[r]) end end
  local state=if target.Reserved then "BUSY" elseif target.Available>now then "RECOVERING" elseif target.Suspicion>40 then "SUSPICIOUS" else string.upper(target.State)
  local outfit=target.Model:FindFirstChild("UpperTorso") or target.Model.PrimaryPart
  outfit.Color=d.Color:Lerp(C.Palette.Danger,math.clamp(target.Suspicion/150,0,0.5))
  target.Model.PrimaryPart.Status.Text.Text=string.format("%s / %s · %s\n%s\nSleight %d+ · Suspicion %d%%",target.Model.Name,C.TargetStyles[target.Style].Name,state,table.concat(possible," / "),d.Equipment,math.floor(target.Suspicion))
 end
end
return N
