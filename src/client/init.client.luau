--!strict
local remote=game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Game") :: RemoteEvent
local audio=require(script.AudioController)
local effects=require(script.EffectsController)
local ui=require(script.UIController)
ui.HideoutController=require(script.HideoutController)
audio:Init()
ui:Init(remote,audio,effects)
require(script.InputController).Start(ui)
