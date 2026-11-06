--!strict
local Input=game:GetService("UserInputService")
local Proximity=game:GetService("ProximityPromptService")
local Players=game:GetService("Players")
local I={}
function I.Start(ui: any)
 Proximity.PromptTriggered:Connect(function(prompt: ProximityPrompt)
  if ui.Timing or ui.Modal.Visible then return end
  local action=prompt:GetAttribute("Action"); local id=prompt:GetAttribute("Id")
  if action=="Target" then ui:Send("Scout",id)
  elseif action=="Bank" then ui:Open("Operations"); ui:Send("Bank")
  elseif action=="Press" then ui:Open("Operations"); ui:Send("Process","Press")
  elseif action=="Rinse" then ui:Open("Operations"); ui:Send("Process","Rinse")
  elseif action=="Payout" then ui:Open("Operations"); ui:Send("Process","Claim")
  elseif action=="Shop" then ui:Open("Equipment")
  elseif action=="Missions" or action=="Quest" then ui:Open("Quests")
  elseif action=="Districts" then ui:Open("Districts")
  elseif action=="Hideout" then ui:Open("Hideout")
  elseif action=="Index" then ui:Open("Collection")
  elseif action=="Practice" then ui:Send("Practice")
  elseif action=="Resupply" then ui:Send("Resupply")
  elseif action=="Secret" then ui:Send("Secret",id)
  elseif action=="CosmeticShop" then ui:Open("Style Shop")
  elseif action=="Wardrobe" then ui:Open("Wardrobe")
  elseif action=="Garage" then ui:Open("Van")
  elseif action=="Van" then if prompt:GetAttribute("OwnerId")==Players.LocalPlayer.UserId then ui:Open("Van") else ui:Notice("That van belongs to another player.") end
  elseif action=="DriveVan" then ui:Send("Van","Enter")
  elseif action=="Deliver" then ui:Send("Van","Deliver")
  elseif action=="Vault" then ui:Send("Vault") end
 end)
 Input.InputBegan:Connect(function(input: InputObject,processed: boolean)
  if Input:GetFocusedTextBox() then return end
  local key=input.KeyCode
  if ui.Timing and (key==Enum.KeyCode.Space or key==Enum.KeyCode.ButtonA) then ui:StopTiming(); return end
  if not processed and not ui.Modal.Visible and (key==Enum.KeyCode.G or key==Enum.KeyCode.ButtonR1) then ui:Send("Decoy"); return end
  if key==Enum.KeyCode.ButtonB or (key==Enum.KeyCode.Escape and not processed) then
   if ui.Timing then ui:Send("Cancel"); ui:EndTiming() elseif ui.Modal.Visible then ui:HideDialog() elseif ui.Current then ui:Close() end
  elseif not processed and (key==Enum.KeyCode.Tab or key==Enum.KeyCode.ButtonY) then if ui.Current then ui:Close() else ui:Open("Overview") end end
 end)
 task.spawn(function()
  local controls=nil
  local ok,result=pcall(function() return require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls() end)
  if ok then controls=result end
  local remote=game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("VanControl") :: RemoteEvent
  while ui.Gui.Parent do
   task.wait(0.1)
   local char=Players.LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
   local seat=hum and hum.SeatPart
   if seat and seat.Name=="DriverSeat" and controls then
    local movement=if ui.Current or ui.Modal.Visible or ui.Timing then Vector3.zero else controls:GetMoveVector()
    remote:FireServer(math.clamp(-movement.Z,-1,1),math.clamp(movement.X,-1,1))
   end
  end
 end)
end
return I
