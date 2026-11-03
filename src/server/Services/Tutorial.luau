--!strict
-- Advances only in response to server-verified gameplay actions.
local Tutorial={}
Tutorial.Bonus=1000
function Tutorial.new() return {step=1} end
local function hasAll(parts)
 local found={}
 for _,item in ipairs(parts) do if item.locked~=true then found[item.kind]=true end end
 return found.Head and found.Chest and found.Arms and found.Legs
end
function Tutorial.advance(tutorial,event,parts)
 local step=tutorial.step
 if step==3 and hasAll(parts) then tutorial.step=4; step=4 end
 if step==1 and event=="roll" then tutorial.step=2
 elseif step==2 and event=="buy" then tutorial.step=3
 elseif step==4 and event=="craft" then tutorial.step=5
 elseif step==5 and event=="place" then tutorial.step=6
 elseif step==6 and event=="collect" then tutorial.step=7; return true end
 if tutorial.step==3 and hasAll(parts) then tutorial.step=4 end
 return false
end
function Tutorial.reconcile(tutorial,parts,creatures,pending)
 if tutorial.step==6 and creatures and type(pending)=="number" and pending<1 then
  local placed=false
  for _,creature in ipairs(creatures) do if creature.stand>0 then placed=true; break end end
  if not placed then tutorial.step=#creatures>0 and 5 or (hasAll(parts) and 4 or 3) end
 end
 if tutorial.step==5 and creatures and #creatures==0 then
  tutorial.step=hasAll(parts) and 4 or 3
 elseif tutorial.step==3 or tutorial.step==4 then
  tutorial.step=hasAll(parts) and 4 or 3
 end
end
return Tutorial
