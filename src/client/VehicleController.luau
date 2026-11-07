--!strict
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Input=game:GetService("UserInputService")
local Replicated=game:GetService("ReplicatedStorage")
local C=require(Replicated.Shared.Config)
local K=require(script.Parent.UIComponents)
local P=K.Color
local V={}
function V.Init(ui: any)
 local player=Players.LocalPlayer
 local remote=Replicated:WaitForChild("Network"):WaitForChild("VanControl") :: RemoteEvent
 local holder=K.frame(ui.Root,UDim2.fromOffset(220,100),UDim2.fromOffset(0,76),P.Background);K.round(holder,10);K.border(holder);holder.Visible=false
 local speed=K.label(holder,"",24,P.Mint,UDim2.new(1,-64,0,40),UDim2.fromOffset(10,4));speed.Font=Enum.Font.GothamBold
 local hint=K.label(holder,"",11,P.Muted,UDim2.new(1,-20,0,46),UDim2.fromOffset(10,47))
 ui:Button(holder,"R",UDim2.fromOffset(44,44),UDim2.new(1,-48,0,4),function() ui:Send("Van","Recover") end,P.Raised)
 local lastVan: Model?=nil;local elapsed=0;local entered=0;local previous: any=nil;local engine: Sound?=nil
 local function restore()
  if previous then local cam=previous.Camera;if cam and cam.Parent then cam.CameraType=previous.Type;cam.CameraSubject=previous.Subject;cam.FieldOfView=previous.FOV end;previous=nil end
 end
 local inputConnection=Input.InputBegan:Connect(function(input: InputObject,processed: boolean)
  if not processed and not Input:GetFocusedTextBox() and input.KeyCode==Enum.KeyCode.R and lastVan and not ui.Timing and not ui.Current and not ui.Modal.Visible and not ui.ResultLayer.Visible then ui:Send("Van","Recover") end
 end)
 local connection: RBXScriptConnection
 connection=RunService.RenderStepped:Connect(function(dt)
  if not ui.Gui.Parent then restore();if engine then engine:Destroy() end;inputConnection:Disconnect();connection:Disconnect();return end
  local char=player.Character;local hum=char and char:FindFirstChildOfClass("Humanoid");local seat=hum and hum.SeatPart
  local van=if seat and seat.Name=="DriverSeat" then seat:FindFirstAncestorOfClass("Model") else nil
  if van and van:GetAttribute("OwnerId")~=player.UserId then van=nil end
  local settings=ui.State and ui.State.Profile.Settings
  local blocked=ui.Current or ui.Timing or ui.Modal.Visible or ui.ResultLayer.Visible
  if van~=lastVan then
   restore();if engine then engine:Destroy();engine=nil end
   lastVan=van;entered=os.clock()
   if van and van.PrimaryPart and type(C.Audio.Engine)=="string" and C.Audio.Engine~="" then engine=Instance.new("Sound");engine.SoundId=C.Audio.Engine;engine.Looped=true;engine.RollOffMaxDistance=50;engine.Parent=van.PrimaryPart;engine:Play() end
  end
  holder.Visible=van~=nil and not blocked
  ui.Driving=van~=nil;ui.ObjectivePanel.Visible=van==nil and not ui.HideObjective
  if not van or not van.PrimaryPart or not settings then restore();return end
  local body=van.PrimaryPart;local velocity=body.AssemblyLinearVelocity;local actual=Vector3.new(velocity.X,0,velocity.Z).Magnitude
  holder.Size=UDim2.new(1,if ui.Mobile or ui.Gui.AbsoluteSize.Y<430 then -144 else -192,0,100)
  speed.Text=string.format("%02d studs/s",math.floor(actual+.5))
  hint.Text=if van:GetAttribute("Overturned") then "OVERTURNED / stop and press R to recover" elseif os.clock()-entered<7 then "WASD / thumbstick · S brakes/reverses\nJump exits · R recovers when stopped" else (if van:GetAttribute("Reversing") then "REVERSE" else "COURIER").." / rear doors store cards"
  elapsed+=dt
  if elapsed>=.1 then
   elapsed=0;local controls=ui.PlayerControls
   local movement=if blocked or not controls then Vector3.zero else controls:GetMoveVector()
   remote:FireServer(math.clamp(-movement.Z,-1,1),math.clamp(movement.X,-1,1))
   if engine then engine.Volume=settings.Effects*.22;engine.PlaybackSpeed=.7+math.min(1.2,actual/25) end
  end
  local cam=workspace.CurrentCamera
  if settings.VehicleCamera and cam then
   if previous and previous.Camera~=cam then restore() end
   if not previous then previous={Camera=cam,Type=cam.CameraType,Subject=cam.CameraSubject,FOV=cam.FieldOfView} end
   cam.CameraType=Enum.CameraType.Scriptable
   local target=body.Position+Vector3.new(0,2,0)+body.CFrame.LookVector*3
   local desired=body.Position-body.CFrame.LookVector*15+Vector3.new(0,7,0)
   local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={van,char}
   local hit=workspace:Raycast(target,desired-target,params);if hit then desired=hit.Position+hit.Normal*.7 end
   cam.CFrame=cam.CFrame:Lerp(CFrame.lookAt(desired,target),if settings.ReducedMotion then 1 else 1-math.exp(-dt*7))
   cam.FieldOfView=previous.FOV+(if settings.ReducedMotion then 0 else math.min(4,actual/8))
  else restore() end
 end)
end
return V
