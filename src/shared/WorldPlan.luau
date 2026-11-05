--!strict
-- Deterministic layout data; no Instances or random state are required.
local WorldPlan={}
WorldPlan.Size=2500
WorldPlan.PlotRadius=350
WorldPlan.PlotSize=120
WorldPlan.TreasureRadius=625
WorldPlan.DaySeconds=24*60
function WorldPlan.plot(index)
 local angle=(index-1)*math.pi*2/6
 return {x=math.cos(angle)*WorldPlan.PlotRadius,z=math.sin(angle)*WorldPlan.PlotRadius}
end
function WorldPlan.treasure(spot,total)
 local angle=(spot-1)*math.pi*2/total
 return {x=math.cos(angle)*WorldPlan.TreasureRadius,z=math.sin(angle)*WorldPlan.TreasureRadius}
end
function WorldPlan.scenery()
 local items={}
 -- Rings stay outside plots and treasure spawn points; decorative objects do not collide.
 for ring=1,2 do
  local radius=ring==1 and 780 or 1040
  local count=ring==1 and 24 or 32
  for i=1,count do
   local angle=(i-1)*math.pi*2/count+(ring==2 and 0.07 or 0)
   table.insert(items,{kind=i%3==0 and "rock" or "tree",x=math.cos(angle)*radius,z=math.sin(angle)*radius,variant=(i+ring)%4})
  end
 end
 return items
end
function WorldPlan.clockTime(epoch)
 return ((epoch%WorldPlan.DaySeconds)/WorldPlan.DaySeconds*24+6)%24
end
return WorldPlan
