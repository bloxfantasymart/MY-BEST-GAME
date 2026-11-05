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
local scenery=WorldPlan.scenery(); assert(#scenery==56)
for _,p in ipairs(scenery) do
 assert((p.kind=="tree" or p.kind=="rock") and math.abs(p.x)<1150 and math.abs(p.z)<1150)
 assert(distance(p,{x=0,z=0})>=779)
 for _,plot in ipairs(plots) do assert(distance(p,plot)>150) end
end
assert(WorldPlan.clockTime(0)==6 and WorldPlan.clockTime(360)==12 and WorldPlan.clockTime(720)==18 and WorldPlan.clockTime(1080)==0)
assert(WorldPlan.clockTime(1440)==6 and WorldPlan.clockTime(-1440)==6)
for i=0,1440 do local value=WorldPlan.clockTime(i); assert(value>=0 and value<24) end
print("World footprint, six separated plots, treasure locations, scenery and day cycle passed")
