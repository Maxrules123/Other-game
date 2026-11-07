--!strict
local remote=game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Game") :: RemoteEvent
local audio=require(script.AudioController)
local effects=require(script.EffectsController)
local ui=require(script.UIController)
ui.HideoutController=require(script.HideoutController)
local cityVisuals=require(script.CityVisualController)
ui.CityVisuals=cityVisuals
cityVisuals:Init()
audio:Init()
ui:Init(remote,audio,effects)
require(script.InputController).Start(ui)

require(script.VehicleController).Init(ui)
