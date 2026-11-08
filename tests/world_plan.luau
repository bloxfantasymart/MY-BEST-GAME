local function distance(a,b) return math.sqrt((a.x-b.x)^2+(a.z-b.z)^2) end
assert(WorldPlan.Size==2500 and WorldPlan.PlotSize==120 and WorldPlan.PlotRadius==350)
local plots={}
for i=1,6 do
 local p=WorldPlan.plot(i); plots[i]=p
 assert(math.abs(distance(p,{x=0,z=0})-350)<1e-8)
 assert(math.abs(p.x)+60<WorldPlan.Size/2 and math.abs(p.z)+60<WorldPlan.Size/2)
 for j=1,i-1 do assert(distance(p,plots[j])>WorldPlan.PlotSize*math.sqrt(2)) end
end
local treasure={}
for i=1,32 do
 local p=WorldPlan.treasure(i,32)
 assert(math.abs(distance(p,{x=0,z=0})-625)<1e-8)
 for _,plot in ipairs(plots) do assert(distance(p,plot)>120) end
 for _,old in ipairs(treasure) do assert(distance(p,old)>100) end
 table.insert(treasure,p)
end
local water=WorldPlan.waterBodies(); assert(#water==6)
for i,body in ipairs(water) do
 assert(body.width>0 and body.length>0 and math.abs(body.x)+body.width/2<WorldPlan.Size/2 and math.abs(body.z)+body.length/2<WorldPlan.Size/2)
 -- Closest point on the rectangle to the center must clear the treasure ring.
 local dx=math.max(0,math.abs(body.x)-body.width/2)
 local dz=math.max(0,math.abs(body.z)-body.length/2)
 assert(math.sqrt(dx*dx+dz*dz)>WorldPlan.TreasureRadius+20)
 if i>1 then
  local previous=water[i-1]
  assert(math.abs(body.x-previous.x)<=(body.width+previous.width)/2 and math.abs(body.z-previous.z)<=(body.length+previous.length)/2, "Water reaches must join")
 end
end
local bridges=WorldPlan.bridges(); assert(#bridges==2)
for _,bridge in ipairs(bridges) do
 assert(WorldPlan.nearWater(bridge.x,bridge.z) and not WorldPlan.nearWater(bridge.x-32,bridge.z) and not WorldPlan.nearWater(bridge.x+32,bridge.z))
 assert(math.abs(bridge.x)+32<WorldPlan.Size/2 and math.abs(bridge.z)+10<WorldPlan.Size/2)
end
local trail=WorldPlan.RiverTrail
assert(not WorldPlan.nearWater(trail.x,trail.z,5) and not WorldPlan.nearBridge(trail.x,trail.z,5))
assert(distance(trail,bridges[1])<80 and distance(trail,{x=0,z=0})>WorldPlan.TreasureRadius+20)
local scenery=WorldPlan.scenery(); assert(#scenery>=45 and #scenery<=56)
for _,p in ipairs(scenery) do
 assert((p.kind=="tree" or p.kind=="rock") and math.abs(p.x)<1150 and math.abs(p.z)<1150)
 assert(distance(p,{x=0,z=0})>=779)
 assert(not WorldPlan.nearWater(p.x,p.z,16) and not WorldPlan.nearBridge(p.x,p.z,16))
 for _,plot in ipairs(plots) do assert(distance(p,plot)>150) end
end
local flowers=WorldPlan.flowers(); assert(#flowers>=20 and #flowers<=32)
for _,flower in ipairs(flowers) do
 assert(not WorldPlan.nearWater(flower.x,flower.z,8) and not WorldPlan.nearBridge(flower.x,flower.z,12))
 assert(distance(flower,{x=0,z=0})>=719 and flower.variant>=0 and flower.variant<=2)
 for _,plot in ipairs(plots) do assert(distance(flower,plot)>150) end
end
assert(WorldPlan.clockTime(0)==6 and WorldPlan.clockTime(360)==12 and WorldPlan.clockTime(720)==18 and WorldPlan.clockTime(1080)==0)
assert(WorldPlan.clockTime(1440)==6 and WorldPlan.clockTime(-1440)==6)
for i=0,1440 do local value=WorldPlan.clockTime(i); assert(value>=0 and value<24) end
print("World footprint, six separated plots, treasure locations, scenery and day cycle passed")
