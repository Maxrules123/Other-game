--!strict
local Players=game:GetService("Players")
local C=require(game:GetService("ReplicatedStorage").Shared.Config)
local T={}
function T.Find(id: string?): Model?
 local character=Players.LocalPlayer.Character
 local root=character and character:FindFirstChild("HumanoidRootPart")
 local city=workspace:FindFirstChild("CardCity"); local actors=city and city:FindFirstChild("Actors")
 if not root or not root:IsA("BasePart") or not actors then return nil end
 local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
 local filter: {Instance}={actors}
 for _,player in Players:GetPlayers() do if player.Character then table.insert(filter,player.Character) end end
 params.FilterDescendantsInstances=filter
 local nearest: Model?=nil; local distance=C.InteractDistance
 -- Resolve streamed instances on every scan; never keep a stale target reference.
 for _,model in actors:GetChildren() do
  if not model:IsA("Model") or not model.PrimaryPart or model:GetAttribute("TargetAvailable")==false then continue end
  local targetId=model:GetAttribute("TargetId")
  if type(targetId)~="string" or (id and targetId~=id) then continue end
  local delta=model.PrimaryPart.Position-root.Position
  if delta.Magnitude<=distance and workspace:Raycast(root.Position,delta,params)==nil then nearest=model; distance=delta.Magnitude end
 end
 return nearest
end
function T.Request(ui: any,id: string?): boolean
 if not ui.State or ui.Current or ui.Timing or ui.Modal.Visible or ui.State.Vault then return false end
 local now=os.clock()
 -- Native prompts, E/X and the touch button share one request path.
 if ui.LastScoutAt and now-ui.LastScoutAt<0.5 then return false end
 local target=T.Find(id); if not target then return false end
 ui.LastScoutAt=now
 ui:Send("Scout",target:GetAttribute("TargetId"))
 return true
end
return T
