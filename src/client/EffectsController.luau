--!strict
local TweenService=game:GetService("TweenService")
local E: any={Settings={ReducedMotion=false,Shake=true}}
function E:Tween(object: Instance, properties: any, duration: number?)
 local tween=TweenService:Create(object,TweenInfo.new(if self.Settings.ReducedMotion then 0 else duration or 0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),properties)
 tween:Play(); return tween
end
function E:Shake()
 if self.Settings.ReducedMotion or not self.Settings.Shake then return end
 local char=game:GetService("Players").LocalPlayer.Character
 local hum=char and char:FindFirstChildOfClass("Humanoid")
 if hum then hum.CameraOffset=Vector3.new(0.12,0.06,0); self:Tween(hum,{CameraOffset=Vector3.zero},0.2) end
end
function E:Celebrate(position: Vector3, color: Color3)
 if self.Settings.ReducedMotion then return end
 local p=Instance.new("Part"); p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Transparency=1; p.Position=position; p.Parent=workspace
 local emitter=Instance.new("ParticleEmitter"); emitter.Color=ColorSequence.new(color); emitter.Rate=0; emitter.Lifetime=NumberRange.new(0.4,0.8); emitter.Speed=NumberRange.new(4,9); emitter.SpreadAngle=Vector2.new(180,180); emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.15),NumberSequenceKeypoint.new(1,0)}); emitter.Parent=p; emitter:Emit(12)
 game:GetService("Debris"):AddItem(p,1)
end
return E
