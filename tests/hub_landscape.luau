local vector={}
vector.__add=function(a,b) return setmetatable({X=a.X+b.X,Y=a.Y+b.Y,Z=a.Z+b.Z},vector) end
local Vector3={new=function(x,y,z) return setmetatable({X=x,Y=y,Z=z},vector) end}
local Color3={fromRGB=function(r,g,b) return {r=r,g=g,b=b} end}
local Enum={Material={Slate="Slate",SmoothPlastic="SmoothPlastic",Neon="Neon",Wood="Wood",Metal="Metal"}}
local meta={__index=function(t,k) return t.props[k] end,__newindex=function(t,k,v) t.props[k]=v; if k=="Parent" and v then table.insert(v.children,t) end end}
local Instance={new=function(class) return setmetatable({props={},children={},class=class},meta) end}
-- INSERT_LANDSCAPE
local buildings=Plan.buildings(); assert(#buildings==20 and #Plan.benches()==2 and #Plan.lights()==4)
for _,tower in ipairs(buildings) do
 assert(math.abs(tower.x)+tower.width/2<=Plan.FloorHalf and math.abs(tower.z)+tower.depth/2<=Plan.FloorHalf)
 assert(tower.height>=30 and tower.height<=60 and tower.variant>=0 and tower.variant<=2)
 -- Visual skyline must remain well clear of the center and booth counters.
 assert(math.sqrt(tower.x^2+tower.z^2)>=100)
 for i=1,15 do
  local angle=(i-1)*2*math.pi/15
  local x,z=math.cos(angle)*80,math.sin(angle)*80
  assert(math.abs(tower.x-x)>(tower.width+19)/2 or math.abs(tower.z-z)>(tower.depth+7)/2)
 end
end
for _,bench in ipairs(Plan.benches()) do
 assert(math.abs(bench.x)>9 and bench.z>5, "Clear the spawn and return portal")
end
local world=Instance.new("Folder"); local folder=Landscape.build(world); assert(folder.Name=="Bazaar surroundings")
local counts={}
for _,item in ipairs(folder.children) do
 counts[item.Name]=(counts[item.Name] or 0)+1
 assert(item.Anchored and item.Size.X<=2048 and item.Size.Y<=2048 and item.Size.Z<=2048)
 if item.Name=="Perimeter wall" then assert(item.CanCollide) else assert(not item.CanCollide and item.CanTouch==false and item.CanQuery==false) end
end
assert(counts["Perimeter wall"]==4 and counts["Skyline tower"]==20 and counts["Neon tower band"]==60)
assert(counts["Lounge bench"]==2 and counts["Bench back"]==2 and counts["Bench leg"]==4)
assert(counts["Lamp pole"]==4 and counts["Lamp glow"]==4)
print("Hub skyline placement, safe clearances, bounded walls and non-colliding decorations passed")
