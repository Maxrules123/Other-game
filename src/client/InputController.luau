--!strict
local Input=game:GetService("UserInputService")
local Proximity=game:GetService("ProximityPromptService")
local Players=game:GetService("Players")
local Rounds=require(script.Parent.RoundController)
local I={}
function I.Start(ui: any)
 local shown: {[ProximityPrompt]: boolean}={}
 Proximity.PromptShown:Connect(function(prompt: ProximityPrompt) shown[prompt]=true end)
 Proximity.PromptHidden:Connect(function(prompt: ProximityPrompt) shown[prompt]=nil end)
 Proximity.PromptTriggered:Connect(function(prompt: ProximityPrompt)
  if ui.Timing or ui.Modal.Visible or ui.ResultLayer.Visible then return end
  local action=prompt:GetAttribute("Action"); local id=prompt:GetAttribute("Id")
  if action=="Target" then ui:RequestScout(id)
  elseif action=="Bank" then ui:Open("Operations"); ui:Send("Bank")
  elseif action=="Press" then ui:Open("Operations"); ui:Send("Process","Press")
  elseif action=="Rinse" then ui:Open("Operations"); ui:Send("Process","Rinse")
  elseif action=="Payout" then ui:Open("Operations"); ui:Send("Process","Claim")
  elseif action=="Shop" then ui:Open("Equipment")
  elseif action=="Missions" then ui.ContactFilter=nil;ui:Open("Quests")
  elseif action=="Quest" then ui:Send("Talk",id)
  elseif action=="Districts" then ui:Open("Districts")
  elseif action=="Hideout" then ui:Open("Hideout")
  elseif action=="Index" then ui:Open("Collection")
  elseif action=="Practice" then ui:Open("Activities")
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
  if ui.Timing then
   local lane=if key==Enum.KeyCode.J then 1 elseif key==Enum.KeyCode.K then 2 elseif key==Enum.KeyCode.L then 3 else nil
   if lane then ui:StopTiming(lane);return end
   if key==Enum.KeyCode.Space or key==Enum.KeyCode.ButtonA then ui:StopTiming();return end
   if key==Enum.KeyCode.Left or key==Enum.KeyCode.DPadLeft or key==Enum.KeyCode.ButtonL1 then Rounds.Select(ui,-1);return end
   if key==Enum.KeyCode.Right or key==Enum.KeyCode.DPadRight or key==Enum.KeyCode.ButtonR1 then Rounds.Select(ui,1);return end
   if key==Enum.KeyCode.T or key==Enum.KeyCode.ButtonY then ui:Send("RoundTool",ui.Timing.Token);return end
  end
  if ui.ResultLayer.Visible then
   if key==Enum.KeyCode.ButtonB or key==Enum.KeyCode.Escape then Rounds.CloseResult(ui) end
   return
  end
  if not processed and (key==Enum.KeyCode.E or key==Enum.KeyCode.ButtonX) then
   -- Let a visible native prompt handle its key, especially shops and machines.
   for prompt in shown do if prompt.Parent and prompt.Enabled and (prompt.KeyboardKeyCode==key or prompt.GamepadKeyCode==key) then return end end
   ui:RequestScout(); return
  end
  if not processed and not ui.Modal.Visible and (key==Enum.KeyCode.G or key==Enum.KeyCode.ButtonR1) then ui:Send("Decoy"); return end
  if key==Enum.KeyCode.ButtonB or (key==Enum.KeyCode.Escape and not processed) then
   if ui.Timing then ui:Send("Cancel"); ui:EndTiming() elseif ui.Modal.Visible then ui:HideDialog() elseif ui.Current then ui:Close() end
  elseif not processed and key==Enum.KeyCode.M then if ui.Current=="Map" then ui:Close() else ui:Open("Map") end
  elseif not processed and (key==Enum.KeyCode.Tab or key==Enum.KeyCode.ButtonY) then if ui.Current then ui:Close() else ui:Open("Overview") end end
 end)
end
return I
