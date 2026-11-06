--!strict
local PathfindingService=game:GetService("PathfindingService")
local C=require(game:GetService("ReplicatedStorage").Shared.Config)
local S: any={ ActivePaths=0 }
function S:Init(gameService: any) self.Game=gameService end
function S:Visible(origin: Vector3, destination: Vector3): boolean
 local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
 local filter: {Instance}={self.Game.NPC.Folder}
 for player in self.Game.State do if player.Character then table.insert(filter,player.Character) end end
 params.FilterDescendantsInstances=filter
 return workspace:Raycast(origin,destination-origin,params)==nil
end
function S:Move(guard: any, destination: Vector3, speed: number, dt: number)
 local root=guard.Model.PrimaryPart
 local delta=destination-root.Position; delta=Vector3.new(delta.X,0,delta.Z)
 if delta.Magnitude<0.5 then return end
 local step=delta.Unit*math.min(delta.Magnitude,speed*dt)
 if self:Visible(root.Position,root.Position+step*1.5) then
  local pos=root.Position+step
  guard.Model:PivotTo(CFrame.lookAt(pos,pos+delta.Unit))
 end
end
function S:Path(guard: any, destination: Vector3, now: number)
 if now-guard.LastPath<2 or guard.Computing or self.ActivePaths>=2 then return end
 guard.LastPath=now; guard.Computing=true; self.ActivePaths+=1
 local target=guard.Target
 task.spawn(function()
  local ok,path=pcall(function()
   local p=PathfindingService:CreatePath({AgentRadius=2,AgentHeight=6,AgentCanJump=false,WaypointSpacing=5})
   p:ComputeAsync(guard.Model.PrimaryPart.Position,destination)
   return p
  end)
  if guard.Target==target and ok and path.Status==Enum.PathStatus.Success then
   guard.Waypoints=path:GetWaypoints(); guard.Waypoint=2
  end
  guard.Computing=false; self.ActivePaths-=1
 end)
end
function S:Tick(now: number, dt: number)
 local G=self.Game
 for _,guard in G.NPC.Guards do
  local root=guard.Model.PrimaryPart
  local d=C.Districts[guard.District]
  local target=guard.Target
  local state=if target then G.State[target] else nil
  local character=if target then target.Character else nil
  local hrp=if character then character:FindFirstChild("HumanoidRootPart") else nil
  if target and (not state or not hrp or not G.Data:Get(target) or state.Vault or G.World:InsideSafe(hrp.Position) or state.Immunity>now or state.Heat<15) then guard.Target=nil; guard.Waypoints=nil; target=nil end
  if not target then
   for player,s in G.State do
    local pRoot=G:Root(player)
    if G.Data:Get(player) and pRoot and not s.Vault and s.Immunity<now and s.Heat>=C.Heat.ChaseAt and not G.World:InsideSafe(pRoot.Position) then
     local delta=pRoot.Position-root.Position
     local attentive=d.Detection*(0.75+s.Heat/200)
     if delta.Magnitude<attentive and delta.Magnitude>0 and root.CFrame.LookVector:Dot(delta.Unit)>0.25 and self:Visible(root.Position,pRoot.Position) then
      guard.Target=player; guard.LastSeen=now; guard.SeenPosition=pRoot.Position; guard.Waypoints=nil
      s.Chase=true; G:Notify(player,"Security spotted you! Break sight or reach a mint hideout.","Alert")
      break
     end
    end
   end
   target=guard.Target; state=if target then G.State[target] else nil; hrp=if target then G:Root(target) else nil
  end
  if target and state and hrp then
   guard.State="Chase"
   local visible=self:Visible(root.Position,hrp.Position) and (hrp.Position-root.Position).Magnitude<d.Detection*1.8
   if visible then guard.LastSeen=now; guard.SeenPosition=hrp.Position end
   if now-guard.LastSeen>6 then guard.Target=nil; guard.Waypoints=nil; guard.State="Search"
   elseif visible and (hrp.Position-root.Position).Magnitude<3.8 then
    G:Capture(target); guard.Target=nil; guard.Waypoints=nil
   else
    local destination=guard.SeenPosition
    if visible then self:Move(guard,destination,d.GuardSpeed,dt) else
     self:Path(guard,destination,now)
     local wp=guard.Waypoints and guard.Waypoints[guard.Waypoint]
     if wp then
      self:Move(guard,wp.Position,d.GuardSpeed,dt)
      if (root.Position-wp.Position).Magnitude<3 then guard.Waypoint+=1 end
     else self:Move(guard,destination,d.GuardSpeed*0.7,dt) end
    end
   end
  else
   guard.State="Patrol"
   local destination=guard.Origin+Vector3.new(math.sin(now*0.13+guard.Phase)*25,0,math.cos(now*0.13+guard.Phase)*5)
   self:Move(guard,destination,7,dt)
  end
  guard.Model.PrimaryPart.Status.Text.Text=if guard.Target then "SECURITY · CHASING\nBreak line of sight!" else "SECURITY · "..guard.State.."\nNot interested in cool customers"
  guard.Model.PrimaryPart.Status.Text.TextColor3=if guard.Target then C.Palette.Danger else C.Palette.Gold
 end
 for player,state_ in G.State do
  if state_.Chase then
   local chased=false
   for _,guard in G.NPC.Guards do if guard.Target==player then chased=true; break end end
   if not chased then state_.Chase=false; G:Event(player,"escape",1); G:Notify(player,"Tail lost. Take a breath.","Success") end
  end
 end
end
return S
