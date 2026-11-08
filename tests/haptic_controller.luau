local now=0; local scheduled={}; local calls={}
local supported=true; local small=true; local large=true; local throwVibration=false; local failSet=false
local service={}
function service:IsVibrationSupported(input) assert(input=="touch"); if throwVibration then error("not supported") end; return supported end
function service:IsMotorSupported(input,motor) assert(input=="touch"); return motor=="small" and small or (motor=="large" and large) end
function service:SetMotor(input,motor,level)
 assert(input=="touch" and (motor=="small" or motor=="large") and level>=0 and level<=1)
 if failSet then error("motor failed") end
 table.insert(calls,{at=now,motor=motor,level=level})
end
local function schedule(delay,fn) table.insert(scheduled,{at=now+delay,fn=fn}) end
local function advance(to)
 while true do
  local index,earliest=nil,math.huge
  for i,event in ipairs(scheduled) do if event.at<=to and event.at<earliest then index=i; earliest=event.at end end
  if not index then break end
  local event=table.remove(scheduled,index); now=event.at; event.fn()
 end
 now=to
end
local h=HapticController.new(service,"touch",{"small","large"},schedule,function() return now end)
assert(not HapticController.play(h,"roll") and #calls==0, "Feedback is opt-in")
HapticController.setEnabled(h,true)
assert(not HapticController.play(h,"other") and #calls==0)
assert(HapticController.play(h,"roll") and #calls==1 and calls[1].level==0.25)
assert(not HapticController.play(h,"collect"),"Cooldown limits repeated signals")
advance(0.11); assert(#calls==2 and calls[2].level==0)
advance(2); assert(HapticController.play(h,"collect"))
advance(2.1); advance(2.2); advance(2.3)
assert(calls[3].level==0.45 and calls[4].level==0 and calls[5].level==0.45 and calls[6].level==0)
advance(4); assert(HapticController.play(h,"rare") and calls[7].level==0.7)
HapticController.setEnabled(h,false); assert(calls[8].level==0)
advance(5); assert(#calls==8, "Old delayed callbacks cannot restart disabled feedback")
HapticController.setEnabled(h,true); supported=false; assert(not HapticController.play(h,"test"))
supported=true; throwVibration=true; assert(not HapticController.play(h,"test")); throwVibration=false
small=false; large=true; advance(6); assert(HapticController.play(h,"test") and calls[#calls].motor=="large")
advance(6.2); assert(calls[#calls].level==0)
advance(8); failSet=true; assert(not HapticController.play(h,"roll")); failSet=false
assert(HapticController.play(h,"roll"),"A failed start must not consume cooldown")
HapticController.setEnabled(h,false); local after=#calls; advance(9); assert(#calls==after)
-- Rollback should not permanently lock feedback, and stale callbacks cannot
-- stop a newer vibration if clocks or scheduled execution are reordered.
HapticController.setEnabled(h,true); now=20; assert(HapticController.play(h,"rare"))
now=10; assert(HapticController.play(h,"roll")); local before=#calls
advance(10.11); assert(#calls==before+1 and calls[#calls].level==0)
advance(21); assert(#calls==before+1)
print("Touch haptics opt-in, patterns, cooldown, fallback, failures and cancellation passed")
