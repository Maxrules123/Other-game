--!strict
local C=require(game:GetService("ReplicatedStorage").Shared.Config)
local Models=require(game:GetService("ReplicatedStorage").Shared.CosmeticModels)
local S: any={}
function S:Init(gameService: any) self.Game=gameService end
function S:Apply(player: Player)
 local p=self.Game.Data:Get(player); local char=player.Character
 if not p or not char or not char:FindFirstChild("Head") then return end
 local old=char:FindFirstChild("CityCosmetics"); if old then old:Destroy() end
 local folder=Instance.new("Folder"); folder.Name="CityCosmetics"; folder.Parent=char
 for _,accessory in char:GetChildren() do
  if accessory:IsA("Accessory") then
   local handle=accessory:FindFirstChild("Handle")
   if handle and handle:IsA("BasePart") then
    local headSlot=p.Cosmetics.Equipped.Head~="" and (handle:FindFirstChild("HatAttachment") or handle:FindFirstChild("HairAttachment"))
    local faceSlot=p.Cosmetics.Equipped.Face~="" and (handle:FindFirstChild("FaceFrontAttachment") or handle:FindFirstChild("FaceCenterAttachment"))
    local backSlot=p.Cosmetics.Equipped.Back~="" and handle:FindFirstChild("BodyBackAttachment")
    local upperClothing=p.Cosmetics.Equipped.Outfit~="" and (accessory.AccessoryType==Enum.AccessoryType.Jacket or accessory.AccessoryType==Enum.AccessoryType.Shirt or accessory.AccessoryType==Enum.AccessoryType.Sweater)
    local hide=headSlot or faceSlot or backSlot or upperClothing
    for _,part in accessory:GetDescendants() do if part:IsA("BasePart") then
     if hide then if part:GetAttribute("CityOriginalTransparency")==nil then part:SetAttribute("CityOriginalTransparency",part.Transparency) end; part.Transparency=1
     elseif part:GetAttribute("CityOriginalTransparency")~=nil then part.Transparency=part:GetAttribute("CityOriginalTransparency"); part:SetAttribute("CityOriginalTransparency",nil) end
    end end
   end
  end
 end
 for _,slot in C.CosmeticSlots do
  local id=p.Cosmetics.Equipped[slot]; local def=C.Cosmetics[id]
  if not def or not p.Cosmetics.Owned[id] then continue end
  local anchor=if slot=="Head" or slot=="Face" then char.Head else char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
  if not anchor or not anchor:IsA("BasePart") then continue end
  local cf=anchor.CFrame*(if slot=="Head" then CFrame.new(0,anchor.Size.Y/2+0.02,0) elseif slot=="Face" then CFrame.new(0,0,-anchor.Size.Z/2-0.1) elseif slot=="Back" then CFrame.new(0,0,anchor.Size.Z/2+0.35) else CFrame.new())
  local m=Models.build(folder,id,cf,anchor.Size)
  for _,item in m:GetDescendants() do if item:IsA("BasePart") then
   item.Anchored=false; item.CanCollide=false; item.CanTouch=false; item.CanQuery=false; item.Massless=true
   local weld=Instance.new("WeldConstraint"); weld.Part0=anchor; weld.Part1=item; weld.Parent=item
  end end
 end
end
function S:Act(player: Player,action: string,id: string)
 local G=self.Game; local p=G.Data:Get(player); local s=G.State[player]
 if not p or not s or s.Attempt or s.Vault then return end
 if action=="Buy" then
  local def=C.Cosmetics[id]
  if not def or p.Cosmetics.Owned[id] then return end
  if not G:NearStation(player,"CosmeticShop") then G:Notify(player,"Visit Second Shift Outfitters on Starter Street."); return end
  if p.Cash<def.Price or p.Reputation<def.Rep then G:Notify(player,"Requires $"..def.Price.." and "..def.Rep.." REP (kept)."); return end
  p.Cash-=def.Price; p.Cosmetics.Owned[id]=true; G:Notify(player,"OWNED / "..def.Name..". Equip it at your hideout wardrobe.","Success")
 elseif action=="Equip" then
  local def=C.Cosmetics[id]
  if not def or not p.Cosmetics.Owned[id] then return end
  if not G:NearStation(player,"Wardrobe") then G:Notify(player,"Use the wardrobe in a hidden workshop."); return end
  p.Cosmetics.Equipped[def.Slot]=id; self:Apply(player)
  G:Notify(player,"WEARING / "..def.Name,"Success")
 elseif action=="Unequip" then
  if not table.find(C.CosmeticSlots,id) or not G:NearStation(player,"Wardrobe") then return end
  p.Cosmetics.Equipped[id]=""; self:Apply(player)
 end
end
return S
