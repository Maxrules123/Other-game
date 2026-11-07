--!strict
local V={}
function V.step(speed: number,throttle: number,steer: number,cap: number,dt: number,c: any): (number,number,number)
 dt=math.clamp(dt,0,.2);cap=math.max(1,cap)
 local desired=throttle*cap*(if throttle<0 then c.Van.ReverseFraction else 1)
 local braking=speed*desired<0 or math.abs(desired)<math.abs(speed)
 local acceleration=if throttle==0 then c.Van.Coast elseif braking then c.Van.Braking else c.Van.Acceleration
 local nextSpeed=speed+math.clamp(desired-speed,-acceleration*dt,acceleration*dt)
 if math.abs(nextSpeed)<.04 and throttle==0 then nextSpeed=0 end
 local angle=steer*c.Van.SteerAngle/(1+math.abs(nextSpeed)/cap*1.2)
 local yawRate=nextSpeed/c.Van.Wheelbase*math.tan(angle)
 return nextSpeed,yawRate,angle
end
return V
