--!strict
-- Asset-free decorative skyline and accessible social space. Does not handle
-- displays, ownership, prices or profile data.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Plan=require(ReplicatedStorage.Shared:WaitForChild("HubWorldPlan"))
local Landscape={}
local function part(parent,name,size,position,color,material,solid)
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=position; p.Color=color; p.Material=material
 p.Anchored=true; p.CanCollide=solid
 if not solid then p.CanTouch=false; p.CanQuery=false end
 p.Parent=parent; return p
end
function Landscape.build(world)
 local folder=Instance.new("Folder"); folder.Name="Bazaar surroundings"; folder.Parent=world
 -- These prevent ordinary walking off the square floor, not cheating or flying.
 for side=1,4 do
  local horizontal=side<=2
  local edge=(side==1 or side==3) and -Plan.WallEdge or Plan.WallEdge
  local position=horizontal and Vector3.new(0,10,edge) or Vector3.new(edge,10,0)
  local size=horizontal and Vector3.new(230,20,2) or Vector3.new(2,20,230)
  part(folder,"Perimeter wall",size,position,Color3.fromRGB(47,43,85),Enum.Material.Slate,true)
 end
 local shades={{53,47,94},{42,56,103},{67,40,100}}
 for _,tower in ipairs(Plan.buildings()) do
  local shade=shades[tower.variant+1]
  part(folder,"Skyline tower",Vector3.new(tower.width,tower.height,tower.depth),Vector3.new(tower.x,tower.height/2,tower.z),Color3.fromRGB(shade[1],shade[2],shade[3]),Enum.Material.SmoothPlastic,false)
  for level=1,3 do
   local stripe=part(folder,"Neon tower band",Vector3.new(tower.width+0.2,0.55,tower.depth+0.2),Vector3.new(tower.x,tower.height*level/4,tower.z),Color3.fromRGB(85+level*30,125,255),Enum.Material.Neon,false)
   stripe.Transparency=0.15
  end
 end
 for _,bench in ipairs(Plan.benches()) do
  local base=Vector3.new(bench.x,0,bench.z)
  part(folder,"Lounge bench",Vector3.new(8,0.7,2),base+Vector3.new(0,1.4,0),Color3.fromRGB(133,88,55),Enum.Material.Wood,false)
  part(folder,"Bench back",Vector3.new(8,2,0.4),base+Vector3.new(0,2.4,0.8),Color3.fromRGB(151,102,62),Enum.Material.Wood,false)
  for _,dx in ipairs({-3,3}) do
   part(folder,"Bench leg",Vector3.new(0.7,1.3,1.5),base+Vector3.new(dx,0.65,0),Color3.fromRGB(66,60,80),Enum.Material.Metal,false)
  end
 end
 for _,lamp in ipairs(Plan.lights()) do
  local base=Vector3.new(lamp.x,0,lamp.z)
  part(folder,"Lamp pole",Vector3.new(1,9,1),base+Vector3.new(0,4.5,0),Color3.fromRGB(65,65,105),Enum.Material.Metal,false)
  part(folder,"Lamp glow",Vector3.new(3,1,3),base+Vector3.new(0,9.3,0),Color3.fromRGB(90,220,255),Enum.Material.Neon,false)
 end
 return folder
end
return Landscape
