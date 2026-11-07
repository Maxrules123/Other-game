--!strict
local C=require(game:GetService("ReplicatedStorage").Shared.Config)
local N={}
function N:Init(gameService: any) self.Game=gameService end
function N:Marker(id: string): any
 for _,marker in self.Game.World.Map.Markers do if marker.Id==id then return marker end end;return nil
end
function N:Discover(player: Player,now: number)
 local G=self.Game;local s=G.State[player];local p=G.Data:Get(player);local root=G:Root(player)
 if not s or not p or not root or now<(s.DiscoverAt or 0) or s.Vault then return end;s.DiscoverAt=now+1.2
 for _,marker in G.World.Map.Markers do
  if p.Districts[tostring(marker.District)] and (root.Position-marker.Position).Magnitude<34 then p.Exploration.Services[marker.Id]=true end
 end
end
function N:Pin(player: Player,id: any)
 local G=self.Game;local s=G.State[player];local p=G.Data:Get(player)
 if not s or not p or type(id)~="string" or #id>40 then return end
 if id=="" then s.NavPin=nil;return end
 local marker=self:Marker(id)
 if marker and p.Districts[tostring(marker.District)] and p.Exploration.Services[id] then s.NavPin=id end
end
function N:Resolve(player: Player): any
 local G=self.Game;local s=G.State[player];local p=G.Data:Get(player);local root=G:Root(player)
 if not s or not p or not root or s.Vault then return nil end
 local function packet(marker: any,title: string?): any
  if not marker then return nil end
  return {Id=marker.Id,Kind=marker.Kind,Title=title or marker.Label,Position=marker.Position,Distance=(root.Position-marker.Position).Magnitude}
 end
 if s.NavPin then
  local marker=self:Marker(s.NavPin)
  if marker and p.Districts[tostring(marker.District)] and (root.Position-marker.Position).Magnitude>9 then return packet(marker,"Pinned / "..marker.Label) end
  s.NavPin=nil
 end
 local district=G.World:DistrictAt(root.Position) or 1
 local active=p.Contracts.Active;local contract=C.Contracts[active]
 local starter=C.StarterMissions[p.Starter]
 local kind=if contract then contract.Kind elseif starter then starter.Kind else "collect"
 if contract and (p.Contracts.Progress[active] or 0)>=contract.Goal then return packet(self:Marker("contact_"..contract.Speaker),"Return to "..contract.Speaker) end
 if kind=="delivery" then return packet(self:Marker("delivery")) end
 if kind=="van" or kind=="drive" then return packet(self:Marker("garage_"..district),if kind=="drive" then "Drive your van / contract distance" else "Buy the courier van") end
 if kind=="upgrade" then return packet(self:Marker("gear_"..district)) end
 if kind=="facility" then return packet(self:Marker("hideout_"..district),"Improve your workshop") end
 if kind=="vault" then return packet(self:Marker("vault")) end
 if kind=="bank" or kind=="process" or kind=="clean" or #s.Loot>=C.Inventory.Base+p.Upgrades.Capacity*C.Inventory.PerLevel then
  local q=p.Processing;local prefix=if q.Stage=="Ready" then "payout" elseif q.Stage=="Pressed" or q.Stage=="Rinsing" then "rinse" elseif q.PendingCards>0 or q.Stage=="Pressing" then "press" else "hideout"
  return packet(self:Marker(prefix.."_"..district))
 end
 if kind=="secret" then return packet(self:Marker("contact_"..contract.Speaker),"Explore the back lanes / ask "..contract.Speaker) end
 local required=tonumber(string.match(kind,"^collectD(%d+)$"))
 if required and not p.Districts[tostring(required)] then return packet(self:Marker("hideout_"..district),"Unlock "..C.Districts[required].Name) end
 local closest=nil;local distance=math.huge
 for id,target in G.NPC.Targets do
  if p.Districts[tostring(target.District)] and p.Upgrades.Sleight>=C.Districts[target.District].Equipment and (not required or target.District==required) and not target.Reserved and target.Available<=os.clock() and target.Model.PrimaryPart then
   local d=(root.Position-target.Model.PrimaryPart.Position).Magnitude
   if d<distance then closest={Id="citizen_"..id,Kind="Citizen",Label="Scout a citizen",Position=target.Model.PrimaryPart.Position};distance=d end
  end
 end
 return packet(closest,if kind=="perfect" then "Perfect a route / nearby citizen" else nil)
end
return N
