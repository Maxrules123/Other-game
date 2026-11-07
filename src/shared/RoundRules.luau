--!strict
-- Pure round generation/scoring. The server owns every session and recomputes hits.
local Q={}
function Q.plan(district: number,style: string,mode: string,seed: number,gear: any,c: any,intro: boolean?): any
 local state=math.max(1,math.floor(seed)%2147483647)
 local function random(): number state=(state*48271)%2147483647; return state/2147483647 end
 local bold=mode=="Bold" or mode=="DailyDrill"
 local count=if intro then 1 elseif mode=="Practice" then 3 elseif mode=="DailyDrill" then 4 else math.clamp(1+c.TargetStyles[style].Stages+(if district>=4 then 1 else 0),2,4)
 local phases={};local last=0
 for i=1,count do
  local lane=if intro then 2 else math.floor(random()*3)+1
  if lane==last then lane=lane%3+1 end;last=lane
  local width=math.clamp((c.Round.Width-(district-1)*0.017+(gear.Focus or 0)*0.006)*(if bold then 0.87 else 1.05),0.12,0.34)
  local duration=math.clamp((c.Round.Duration-(district-1)*0.16)*(1+(gear.Sleight or 0)*0.018)*(if bold then 0.92 else 1.08),2.4,4.6)
  local pattern=if i==1 then "Sweep" elseif i%3==2 then "Reverse" else "Bounce"
  table.insert(phases,{Kind=if i==1 then "Lift" elseif i%2==0 then "Switch" else "Clear",Lane=lane,Duration=if intro then 4 else duration,Width=if intro then 0.32 else width,Center=0.34+random()*0.32,Drift=if district>1 and i>1 then math.min(0.065,0.018*district) else 0,Pattern=pattern,Memory=bold and district>=3 and i>1,Hazard=bold or district>=3})
 end
 return {Phases=phases,ReadSeconds=if intro then 2.8 elseif bold and district>=3 then 2.4 else 1.7,Seed=seed}
end
function Q.cursor(elapsed: number,phase: any): number
 local t=math.clamp(elapsed/phase.Duration,0,1)
 if phase.Pattern=="Reverse" then return 1-t elseif phase.Pattern=="Bounce" then return 1-math.abs(1-2*t) end
 return t
end
function Q.center(elapsed: number,phase: any): number
 return math.clamp(phase.Center+math.sin(math.clamp(elapsed/phase.Duration,0,1)*math.pi*2)*(phase.Drift or 0),phase.Width/2,1-phase.Width/2)
end
function Q.grade(elapsed: number,lane: number,phase: any): (string,string)
 if elapsed<0 then return "Miss","Wait for the READY countdown to finish." end
 if elapsed>phase.Duration then return "Miss","The phase timed out. Read the lane, then commit inside the mint zone." end
 if lane~=phase.Lane then return "Miss","Wrong lane. Follow the numbered route shown during READ." end
 local distance=math.abs(Q.cursor(elapsed,phase)-Q.center(elapsed,phase))
 if distance<=phase.Width*0.2 then return "Perfect","Perfect alignment" end
 if distance<=phase.Width*0.5 then return "Good","Clean alignment" end
 return "Miss","Timing missed. Watch the direction arrow and wait for the mint zone."
end
function Q.validTime(at: any,received: number,start: number,duration: number,ping: number,c: any): boolean
 if type(at)~="number" or at~=at or math.abs(at)==math.huge then return false end
 local allowance=math.clamp(ping+0.1,0.12,c.Round.MaxBackdate)
 return at>=start and at<=start+duration and at<=received+0.035 and at>=received-allowance
end
function Q.recovery(phase: any): any
 local r=table.clone(phase);r.Kind="Stabilize";r.Lane=2;r.Pattern="Sweep";r.Width=math.min(0.36,phase.Width+0.09);r.Duration=3.5;r.Drift=0;r.Memory=false;r.Hazard=false;return r
end
function Q.bonus(phase: any): any
 local p=table.clone(phase);p.Kind="Bonus";p.Lane=phase.Lane%3+1;p.Pattern="Bounce";p.Width=math.max(0.12,phase.Width*0.85);p.Memory=false;p.Hazard=true;return p
end
function Q.medal(success: boolean,perfects: number,stages: number,mistakes: number,bonus: boolean): string
 if not success then return "Retry" end
 if mistakes>0 then return "Bronze" elseif perfects>=stages and bonus then return "Platinum" elseif perfects>=stages then return "Gold" end
 return "Silver"
end
function Q.score(perfects: number,clears: number,mistakes: number,bonus: boolean,seconds: number): number
 return math.max(0,perfects*100+math.max(0,clears-perfects)*65+(if bonus then 100 else 0)+math.floor(math.max(0,100-seconds*4))-mistakes*35)
end
return Q
