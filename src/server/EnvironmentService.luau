--!strict
local Lighting=game:GetService("Lighting")
local C=require(game:GetService("ReplicatedStorage").Shared.Config)
local E: any={Next=0,Started=0,State="Clear",Previous="Clear",Clock=16,TransitionAt=0}
local transitions={Clear={{"Overcast",5},{"Fog",1}},Overcast={{"Rain",4},{"Clear",3},{"Fog",1}},Rain={{"Overcast",5},{"Fog",1}},Fog={{"Clear",3},{"Overcast",3}}}
function E:Choose(): string
 local choices=transitions[self.State]; local total=0; for _,entry in choices do total+=entry[2] end
 local roll=self.Rng:NextNumber(0,total)
 for _,entry in choices do roll-=entry[2]; if roll<=0 then return entry[1] end end
 return choices[#choices][1]
end
function E:Start()
 self.Rng=Random.new(); self.Streetlights={}; self.Windows={}
 for _,item in workspace.CardCity:GetDescendants() do
  if item:IsA("PointLight") and string.find(item.Parent.Name,"Streetlight") then table.insert(self.Streetlights,item) end
  if item:IsA("BasePart") and (item.Name=="Upper window" or item.Name=="Sash window" or item.Name=="Rowhouse window") then table.insert(self.Windows,{Part=item,Color=item.Color}) end
 end
 local materialService=game:GetService("MaterialService")
 for name,definition in C.MaterialAssets do
  if definition.ColorMap and definition.ColorMap~="" then
   local variant=Instance.new("MaterialVariant"); variant.Name="AfterHours_"..name; variant.BaseMaterial=Enum.Material[name]; variant.StudsPerTile=8
   for _,key in {"ColorMap","NormalMap","RoughnessMap","MetalnessMap"} do if definition[key] and definition[key]~="" then variant[key]=definition[key] end end
   variant.Parent=materialService; materialService:SetBaseMaterialOverride(Enum.Material[name],variant.Name)
  end
 end
 self.Started=os.time(); self.TransitionAt=self.Started-C.Weather.Transition; self.Next=os.time()+C.Weather.Duration
 workspace:SetAttribute("Weather",self.State); workspace:SetAttribute("WeatherNext",self.Next)
 local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere"); atmosphere.Name="CityAtmosphere"; atmosphere.Parent=Lighting; self.Atmosphere=atmosphere
 local bloom=Lighting:FindFirstChild("CityBloom") or Instance.new("BloomEffect"); bloom.Name="CityBloom"; bloom.Intensity=0.12; bloom.Size=20; bloom.Threshold=1.6; bloom.Parent=Lighting
 local correction=Lighting:FindFirstChild("CityGrade") or Instance.new("ColorCorrectionEffect"); correction.Name="CityGrade"; correction.Contrast=0.08; correction.Saturation=-0.06; correction.Parent=Lighting; self.Grade=correction
 local clouds=workspace.Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds"); clouds.Name="CityClouds"; clouds.Parent=workspace.Terrain; self.Clouds=clouds
 self:Tick()
end
function E:Tick()
 local now=os.time()
 if now>=self.Next then
  self.Previous=self.State; self.State=self:Choose(); self.TransitionAt=now; self.Next=now+C.Weather.Duration+self.Rng:NextInteger(-60,60)
  workspace:SetAttribute("Weather",self.State); workspace:SetAttribute("WeatherNext",self.Next)
 end
 local alpha=math.clamp((now-self.TransitionAt)/C.Weather.Transition,0,1)
 local previous=C.Weather.Profiles[self.Previous]; local profile=C.Weather.Profiles[self.State]
 local function blend(key: string): number return previous[key]+(profile[key]-previous[key])*alpha end
 local rain=(if previous.Rain then 1 else 0)+((if profile.Rain then 1 else 0)-(if previous.Rain then 1 else 0))*alpha
 self.Clock=(16+(now-self.Started)/C.Weather.DaySeconds*24)%24
 local daylight=math.clamp(math.cos((self.Clock-12)/24*math.pi*2)*0.8+0.2,0,1)
 Lighting.ClockTime=self.Clock; Lighting.Brightness=blend("Brightness")*(0.5+0.5*daylight)
 Lighting.Ambient=Color3.fromRGB(52,61,80):Lerp(Color3.fromRGB(112,112,122),daylight)
 Lighting.OutdoorAmbient=Color3.fromRGB(63,77,99):Lerp(Color3.fromRGB(143,153,166),daylight)
 self.Atmosphere.Density=blend("Density"); self.Atmosphere.Haze=blend("Haze"); self.Atmosphere.Color=Color3.fromRGB(100,119,151):Lerp(Color3.fromRGB(191,203,224),daylight)
 self.Clouds.Cover=blend("Clouds"); self.Clouds.Density=0.6; self.Clouds.Color=Color3.fromRGB(224,230,239):Lerp(Color3.fromRGB(132,143,165),rain)
 self.Grade.TintColor=Color3.fromRGB(220,230,255):Lerp(Color3.fromRGB(255,246,231),daylight)
 for _,light in self.Streetlights do if light.Parent then light.Enabled=daylight<0.35 or rain>0.3 end end
 for _,window in self.Windows do if window.Part.Parent then window.Part.Material=if daylight<0.35 then Enum.Material.Neon else Enum.Material.Glass; window.Part.Color=if daylight<0.35 then Color3.fromRGB(218,195,150) else window.Color end end
 workspace.GlobalWind=Vector3.new(4+rain*10,0,math.sin(now*0.025)*3)
 workspace:SetAttribute("CityClock",self.Clock); workspace:SetAttribute("RainIntensity",rain)
end
return E
