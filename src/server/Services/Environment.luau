--!strict
-- Asset-free placeholder environment. Scenery is bounded and non-colliding;
-- bridge decks and perimeter blocks are the only additional solid scenery.
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
   local bark=item.style=="birch" and Color3.fromRGB(220,216,194) or Color3.fromRGB(105,72,50)
   local trunk=block(folder,"Tree trunk",Vector3.new(2.5,12,2.5),pos+Vector3.new(0,6,0),bark,Enum.Material.Wood,false)
   trunk.CanTouch=false; trunk.CanQuery=false
   local crown=block(folder,"Tree canopy",Vector3.new(12,13,12),pos+Vector3.new(0,15,0),Color3.fromRGB(42+item.variant*7,130+item.variant*10,70),Enum.Material.Grass,false)
   crown.Shape=Enum.PartType.Ball; crown.CanTouch=false; crown.CanQuery=false
   if item.style=="pine" then
    for level=1,2 do
     local width=12-level*3
     local foliage=block(folder,"Pine canopy",Vector3.new(width,6,width),pos+Vector3.new(0,18+level*3,0),Color3.fromRGB(34,112+level*5,62),Enum.Material.Grass,false)
     foliage.Shape=Enum.PartType.Ball; foliage.CanTouch=false; foliage.CanQuery=false
    end
   end
  else
   local rock=block(folder,"Rock",Vector3.new(8+item.variant*2,5+item.variant,7+item.variant),pos+Vector3.new(0,3,0),Color3.fromRGB(105,115,125),Enum.Material.Slate,false)
   rock.Shape=Enum.PartType.Ball; rock.CanTouch=false; rock.CanQuery=false
  end
 end
 -- A connected surface-water prototype: it is intentionally not swim-ready
 -- terrain. Water and bridge details never interfere with prompts or raycasts.
 for _,water in ipairs(WorldPlan.waterBodies()) do
  local surface=block(folder,water.name,Vector3.new(water.width,0.3,water.length),Vector3.new(water.x,0.06,water.z),Color3.fromRGB(65,165,215),Enum.Material.Glass,false)
  surface.Transparency=0.35; surface.CanTouch=false; surface.CanQuery=false
 end
 for _,bridge in ipairs(WorldPlan.bridges()) do
  local x,z=bridge.x,bridge.z
  block(folder,"Bridge deck",Vector3.new(64,0.7,18),Vector3.new(x,0.35,z),Color3.fromRGB(124,83,51),Enum.Material.Wood,true)
  -- Planks, low rails and posts are visual only; the deck is one walkable part.
  for i=0,7 do
   local plank=block(folder,"Bridge plank",Vector3.new(7.7,0.1,17.5),Vector3.new(x-28+i*8,0.75,z),Color3.fromRGB(164+(i%2)*10,111+(i%2)*6,67),Enum.Material.Wood,false)
   plank.CanTouch=false; plank.CanQuery=false
  end
  for _,side in ipairs({-1,1}) do
   local rail=block(folder,"Bridge rail",Vector3.new(62,0.8,0.8),Vector3.new(x,3,z+side*8.5),Color3.fromRGB(110,72,43),Enum.Material.Wood,false)
   rail.CanTouch=false; rail.CanQuery=false
   for _,dx in ipairs({-29,0,29}) do
    local post=block(folder,"Bridge post",Vector3.new(1,3,1),Vector3.new(x+dx,1.8,z+side*8.5),Color3.fromRGB(110,72,43),Enum.Material.Wood,false)
    post.CanTouch=false; post.CanQuery=false
   end
  end
 end
 for _,flower in ipairs(WorldPlan.flowers()) do
  local stem=block(folder,"Flower stem",Vector3.new(0.3,2,0.3),Vector3.new(flower.x,1,flower.z),Color3.fromRGB(48,139,63),Enum.Material.Grass,false)
  stem.CanTouch=false; stem.CanQuery=false
  local colors={{255,225,75},{255,135,165},{185,155,255}}
  local c=colors[flower.variant+1]
  local bloom=block(folder,"Wildflower",Vector3.new(2,0.8,2),Vector3.new(flower.x,2.1,flower.z),Color3.fromRGB(c[1],c[2],c[3]),Enum.Material.Grass,false)
  bloom.Shape=Enum.PartType.Ball; bloom.CanTouch=false; bloom.CanQuery=false
 end
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
