--!strict
local SoundService=game:GetService("SoundService")
local C=require(game:GetService("ReplicatedStorage").Shared.Config)
local A: any={Settings={Music=0.35,Effects=0.7},Sounds={}}
function A:Init()
 local folder=Instance.new("Folder"); folder.Name="CardCityAudio"; folder.Parent=SoundService
 for name,id in C.Audio do
  if id~="" then
   local sound=Instance.new("Sound"); sound.Name=name; sound.SoundId=id; sound.Looped=name=="Music"; sound.Volume=if name=="Music" then self.Settings.Music else self.Settings.Effects; sound.Parent=folder
   self.Sounds[name]=sound
  end
 end
 if self.Sounds.Music then self.Sounds.Music:Play() end
end
function A:Update(settings: any)
 self.Settings=settings
 for name,sound in self.Sounds do sound.Volume=if name=="Music" then settings.Music else settings.Effects end
end
function A:Play(name: string)
 local sound=self.Sounds[name]
 if sound then sound.TimePosition=0; sound:Play() end
end
return A
