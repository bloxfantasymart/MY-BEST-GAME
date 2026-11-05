--!strict
-- Asset-free placeholder environment. Scenery is bounded and non-colliding;
-- only the perimeter blocks prevent players leaving the map.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local WorldPlan=require(ReplicatedStorage.Shared:WaitForChild("WorldPlan"))
local Environment={}
local function block(parent,name,size,position,color,material,solid)
 local p=Instance.new("Part")
 p.Name=name; p.Size=size; p.Position=position; p.Color=color; p.Material=material
 p.Anchored=true; p.CanCollide=solid; p.Parent=parent
 return p
end
function Environment.build(world)
 local folder=Instance.new("Folder"); folder.Name="Landscape"; folder.Parent=world
 -- Roblox parts have practical size limits; tile the 2500-stud footprint.
 for _,x in ipairs({-625,625}) do for _,z in ipairs({-625,625}) do
  block(folder,"Grass tile",Vector3.new(1250,1,1250),Vector3.new(x,-0.5,z),Color3.fromRGB(75,185,85),Enum.Material.Grass,true)
 end end
 -- Layered stylized cliff walls, not Smooth Terrain. Non-overlapping groups
 -- keep the playable region inside the ground tiles.
 for side=1,4 do
  for i=1,6 do
   local along=-1000+(i-1)*400
   local height=95+(i%3)*25
   local horizontal=side<=2
   local edge=(side==1 or side==3) and -1225 or 1225
   local pos=horizontal and Vector3.new(along,height/2-0.5,edge) or Vector3.new(edge,height/2-0.5,along)
   local size=horizontal and Vector3.new(410,height,50) or Vector3.new(50,height,410)
   block(folder,"Boundary cliff",size,pos,Color3.fromRGB(91,109,105),Enum.Material.Slate,true)
  end
 end
 for _,item in ipairs(WorldPlan.scenery()) do
  local pos=Vector3.new(item.x,0,item.z)
  if item.kind=="tree" then
   block(folder,"Tree trunk",Vector3.new(2.5,12,2.5),pos+Vector3.new(0,6,0),Color3.fromRGB(105,72,50),Enum.Material.Wood,false)
   local crown=block(folder,"Tree canopy",Vector3.new(12,13,12),pos+Vector3.new(0,15,0),Color3.fromRGB(42+item.variant*7,130+item.variant*10,70),Enum.Material.Grass,false)
   crown.Shape=Enum.PartType.Ball
  else
   local rock=block(folder,"Rock",Vector3.new(8+item.variant*2,5+item.variant,7+item.variant),pos+Vector3.new(0,3,0),Color3.fromRGB(105,115,125),Enum.Material.Slate,false)
   rock.Shape=Enum.PartType.Ball
  end
 end
 -- A decorative lake away from plots and footpaths. It is not swim-ready terrain.
 local lake=block(folder,"Decorative lake",Vector3.new(180,0.3,260),Vector3.new(-800,0.06,350),Color3.fromRGB(65,165,215),Enum.Material.Glass,false)
 lake.Transparency=0.35
 return folder
end
function Environment.configureLighting()
 if not Lighting:FindFirstChild("LandscapeAtmosphere") then
  local atmosphere=Instance.new("Atmosphere"); atmosphere.Name="LandscapeAtmosphere"
  atmosphere.Density=0.25; atmosphere.Haze=1; atmosphere.Parent=Lighting
 end
 if not Lighting:FindFirstChild("LandscapeBloom") then
  local bloom=Instance.new("BloomEffect"); bloom.Name="LandscapeBloom"
  bloom.Intensity=0.3; bloom.Threshold=1; bloom.Size=24; bloom.Parent=Lighting
 end
end
function Environment.clock(epoch)
 Lighting.ClockTime=WorldPlan.clockTime(epoch)
end
return Environment
