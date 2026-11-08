--!strict
-- Deterministic layout data; no Instances or random state are required.
local WorldPlan={}
WorldPlan.Size=2500
WorldPlan.PlotRadius=350
WorldPlan.PlotSize=120
WorldPlan.TreasureRadius=625
WorldPlan.DaySeconds=24*60
WorldPlan.RiverTrail={x=-885,z=-150}
function WorldPlan.plot(index)
 local angle=(index-1)*math.pi*2/6
 return {x=math.cos(angle)*WorldPlan.PlotRadius,z=math.sin(angle)*WorldPlan.PlotRadius}
end
function WorldPlan.treasure(spot,total)
 local angle=(spot-1)*math.pi*2/total
 return {x=math.cos(angle)*WorldPlan.TreasureRadius,z=math.sin(angle)*WorldPlan.TreasureRadius}
end
-- Surface-water rectangles join the existing lake without entering the six
-- plot areas or the treasure ring. They are visual, not swimming terrain.
function WorldPlan.waterBodies()
 return {
  {name="Decorative lake",x=-800,z=350,width=180,length=260},
  {name="River reach",x=-800,z=110,width=32,length=220},
  {name="River bend",x=-875,z=-16,width=150,length=32},
  {name="River reach",x=-950,z=-166,width=32,length=268},
  {name="River bend",x=-1000,z=-316,width=100,length=32},
  {name="River reach",x=-1050,z=-566,width=32,length=468},
 }
end
function WorldPlan.bridges()
 return {{x=-950,z=-150},{x=-1050,z=-600}}
end
function WorldPlan.nearWater(x,z,margin)
 margin=margin or 0
 for _,water in ipairs(WorldPlan.waterBodies()) do
  if math.abs(x-water.x)<=water.width/2+margin and math.abs(z-water.z)<=water.length/2+margin then return true end
 end
 return false
end
function WorldPlan.nearBridge(x,z,margin)
 margin=margin or 0
 for _,bridge in ipairs(WorldPlan.bridges()) do
  if math.abs(x-bridge.x)<=32+margin and math.abs(z-bridge.z)<=10+margin then return true end
 end
 return false
end
function WorldPlan.scenery()
 local items={}
 -- Rings stay outside plots and treasure spawn points; decorative objects do not collide.
 for ring=1,2 do
  local radius=ring==1 and 780 or 1040
  local count=ring==1 and 24 or 32
  for i=1,count do
   local angle=(i-1)*math.pi*2/count+(ring==2 and 0.07 or 0)
   local x,z=math.cos(angle)*radius,math.sin(angle)*radius
   if not WorldPlan.nearWater(x,z,16) and not WorldPlan.nearBridge(x,z,16) then
    table.insert(items,{kind=i%3==0 and "rock" or "tree",x=x,z=z,variant=(i+ring)%4,style=i%4==0 and "pine" or (i%4==1 and "birch" or "broadleaf")})
   end
  end
 end
 return items
end
function WorldPlan.flowers()
 local items={}
 -- Sparse, non-colliding flowers, away from water and the crossings.
 for i=1,32 do
  local angle=(i-1)*math.pi*2/32+0.11
  local radius=i%2==0 and 720 or 925
  local x,z=math.cos(angle)*radius,math.sin(angle)*radius
  if not WorldPlan.nearWater(x,z,8) and not WorldPlan.nearBridge(x,z,12) then
   table.insert(items,{x=x,z=z,variant=i%3})
  end
 end
 return items
end
function WorldPlan.clockTime(epoch)
 return ((epoch%WorldPlan.DaySeconds)/WorldPlan.DaySeconds*24+6)%24
end
return WorldPlan
