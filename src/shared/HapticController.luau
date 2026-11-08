--!strict
-- Client-only, opt-in touch feedback. The service, scheduler and clock are
-- injected for testing; failures never affect gameplay or inventory.
local HapticController={}
local patterns={
 roll={{0,0.25},{0.10,0}},
 collect={{0,0.45},{0.10,0},{0.20,0.45},{0.30,0}},
 rare={{0,0.7},{0.55,0}},
 test={{0,0.35},{0.12,0}},
}
local Cooldown=2
local function motorOff(self)
 local motor=self.activeMotor
 self.activeMotor=nil
 if motor then pcall(function() self.service:SetMotor(self.input,motor,0) end) end
end
function HapticController.new(service,input,motors,schedule,clock)
 return {service=service,input=input,motors=motors,schedule=schedule,clock=clock,enabled=false,generation=0,last=nil,activeMotor=nil}
end
function HapticController.setEnabled(self,value)
 self.enabled=value==true
 if not self.enabled then self.generation+=1; motorOff(self) end
end
local function findMotor(self)
 local ok,supported=pcall(function() return self.service:IsVibrationSupported(self.input) end)
 if not ok or not supported then return nil end
 for _,motor in ipairs(self.motors) do
  local check,available=pcall(function() return self.service:IsMotorSupported(self.input,motor) end)
  if check and available then return motor end
 end
 return nil
end
function HapticController.play(self,name)
 local pattern=patterns[name]
 if not self.enabled then return false,"disabled" end
 if not pattern then return false,"unknown" end
 local now=self.clock()
 if type(now)~="number" or now~=now or now==math.huge or now==-math.huge then return false,"clock" end
 if self.last and now>=self.last and now-self.last<Cooldown then return false,"cooldown" end
 local motor=findMotor(self)
 if not motor then return false,"unsupported" end
 self.generation+=1; local generation=self.generation
 motorOff(self)
 local ok=pcall(function() self.service:SetMotor(self.input,motor,pattern[1][2]) end)
 if not ok then return false,"unsupported" end
 self.activeMotor=motor; self.last=now
 for i=2,#pattern do
  local step=pattern[i]; local isLast=i==#pattern
  self.schedule(step[1],function()
   if self.enabled and self.generation==generation then
    local applied=pcall(function() self.service:SetMotor(self.input,motor,step[2]) end)
    if not applied then self.generation+=1; motorOff(self)
    elseif isLast and step[2]==0 then self.activeMotor=nil end
   end
  end)
 end
 return true
end
return HapticController
