local vmeta={}
vmeta.__add=function(a,b) return setmetatable({X=a.X+b.X,Y=a.Y+b.Y,Z=a.Z+b.Z},vmeta) end
local Vector3={new=function(x,y,z) return setmetatable({X=x,Y=y,Z=z},vmeta) end}
local Color3={fromRGB=function(r,g,b) return {r=r,g=g,b=b} end}
local Enum={Material={Grass="Grass",Slate="Slate",Wood="Wood",Glass="Glass"},PartType={Ball="Ball"}}
local methods={}
function methods:FindFirstChild(name) for _,child in ipairs(self.children) do if child.Name==name then return child end end end
local meta={__index=function(t,k) return methods[k] or t.props[k] end,__newindex=function(t,k,v)
 t.props[k]=v; if k=="Parent" and v then table.insert(v.children,t) end
end}
local Instance={new=function(class) return setmetatable({props={},children={},class=class},meta) end}
local Lighting=Instance.new("Lighting")
-- INSERT_ENVIRONMENT
local world=Instance.new("Folder")
local result=Environment.build(world); assert(result.Name=="Landscape")
local counts={}
for _,item in ipairs(result.children) do
 counts[item.Name]=(counts[item.Name] or 0)+1
 if item.class=="Part" then
  assert(item.Anchored and item.Size.X<=2048 and item.Size.Y<=2048 and item.Size.Z<=2048)
  if item.Name=="Grass tile" or item.Name=="Boundary cliff" or item.Name=="Bridge deck" then assert(item.CanCollide)
  else assert(not item.CanCollide) end
  if item.Name=="Decorative lake" or item.Name=="River reach" or item.Name=="River bend" or item.Name=="Bridge plank" or item.Name=="Bridge rail" or item.Name=="Bridge post" or item.Name=="Flower stem" or item.Name=="Wildflower" then
   assert(item.CanTouch==false and item.CanQuery==false)
  end
 end
end
local trees,rocks,pines=0,0,0
for _,item in ipairs(WorldPlan.scenery()) do if item.kind=="tree" then trees+=1; if item.style=="pine" then pines+=1 end else rocks+=1 end end
assert(counts["Grass tile"]==4 and counts["Boundary cliff"]==24 and counts["Tree trunk"]==trees and counts["Tree canopy"]==trees and counts.Rock==rocks and counts["Pine canopy"]==2*pines)
assert(counts["Decorative lake"]==1 and counts["River reach"]==3 and counts["River bend"]==2)
assert(counts["Bridge deck"]==2 and counts["Bridge plank"]==16 and counts["Bridge rail"]==4 and counts["Bridge post"]==12)
assert(counts["Flower stem"]==#WorldPlan.flowers() and counts.Wildflower==#WorldPlan.flowers())
Environment.configureLighting(); Environment.configureLighting()
assert(#Lighting.children==2 and Lighting:FindFirstChild("LandscapeAtmosphere") and Lighting:FindFirstChild("LandscapeBloom"))
Environment.clock(360); assert(Lighting.ClockTime==12)
print("Landscape geometry counts, collision policy and lighting configuration passed (mocked Roblox)")
