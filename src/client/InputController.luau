--!strict
local UserInputService=game:GetService("UserInputService")
local ProximityPromptService=game:GetService("ProximityPromptService")
local I={}
function I.Start(ui: any)
 ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt)
  if ui.Timing or ui.Modal.Visible then return end
  local action=prompt:GetAttribute("Action"); local id=prompt:GetAttribute("Id")
  if action=="Target" then ui:Send("Begin",id)
  elseif action=="Bank" then ui:Send("Bank")
  elseif action=="Shop" then ui:Open("Upgrades")
  elseif action=="Missions" then ui:Open("Missions")
  elseif action=="Districts" then ui:Open("Districts")
  elseif action=="Vault" then ui:Send("Vault") end
 end)
 UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
  if UserInputService:GetFocusedTextBox() then return end
  local key=input.KeyCode
  if ui.Timing and (key==Enum.KeyCode.Space or key==Enum.KeyCode.ButtonA) then ui:StopTiming(); return end
  if key==Enum.KeyCode.ButtonB or (key==Enum.KeyCode.Escape and not processed) then
   if ui.Timing then ui:Send("Cancel"); ui:EndTiming()
   elseif ui.Modal.Visible and ui.DialogCancel.Visible then ui:HideDialog()
   elseif ui.Current then ui:Close() end
  elseif not processed and (key==Enum.KeyCode.Tab or key==Enum.KeyCode.ButtonY) then ui:Open("Pockets") end
 end)
end
return I
