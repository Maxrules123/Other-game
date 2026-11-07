--!strict
local M={}
function M.project(position: any,center: any,bearing: number,studsPerPixel: number): (number,number)
 local x=(position.X-center.X)/studsPerPixel;local z=(position.Z-center.Z)/studsPerPixel
 return x*math.cos(bearing)+z*math.sin(bearing),-x*math.sin(bearing)+z*math.cos(bearing)
end
function M.unproject(x: number,y: number,center: any,bearing: number,studsPerPixel: number): (number,number)
 return center.X+(x*math.cos(bearing)-y*math.sin(bearing))*studsPerPixel,center.Z+(x*math.sin(bearing)+y*math.cos(bearing))*studsPerPixel
end
function M.clip(x: number,y: number,half: number,padding: number): (number,number,boolean)
 local limit=math.max(1,half-padding);local factor=math.max(1,math.abs(x)/limit,math.abs(y)/limit)
 return x/factor,y/factor,factor>1
end
function M.bearing(look: any): number return math.atan2(look.X,-look.Z) end
function M.visible(marker: any,profile: any,goal: any): boolean
 if not profile.Districts[tostring(marker.District)] then return false end
 if goal and goal.Id==marker.Id then return true end
 if marker.Kind=="Press" or marker.Kind=="Rinse" or marker.Kind=="Payout" or marker.Kind=="Gear" or marker.Kind=="Practice" then return false end
 return profile.Exploration.Services[marker.Id]==true
end
return M
