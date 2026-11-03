--!strict
-- Procedural, asset-free decoration. These objects never decide gameplay outcomes.
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local Config=require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local VisualStyle=require(script.Parent.VisualStyle)
local Visuals={}
Visuals.levelTier=VisualStyle.levelTier
Visuals.compositeRarity=VisualStyle.compositeRarity
local function block(parent,name,size,position,color,material)
 local p=Instance.new("Part")
 p.Name=name; p.Size=size; p.Position=position; p.Color=color; p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true; p.CanCollide=false; p.Parent=parent
 return p
end
local function billboard(part,text,height,width)
 local gui=Instance.new("BillboardGui"); gui.Name="Caption"; gui.Size=UDim2.fromOffset(width or 150,55)
 gui.StudsOffset=Vector3.new(0,height,0); gui.AlwaysOnTop=true; gui.Parent=part
 local caption=Instance.new("TextLabel"); caption.Size=UDim2.fromScale(1,1); caption.BackgroundTransparency=1
 caption.Text=text; caption.TextColor3=Color3.new(1,1,1); caption.TextStrokeTransparency=0
 caption.TextScaled=true; caption.Font=Enum.Font.GothamBold; caption.Parent=gui
 return caption
end
local function colorFor(item)
 if item.mutation=="Golden" then return Color3.fromRGB(255,205,30) end
 if item.mutation=="Void" then return Color3.fromRGB(70,20,100) end
 if item.mutation=="Glitched" then return Color3.fromRGB(255,75,220) end
 return Config.Rarities[item.rarity].color
end
local function style(piece,item)
 if item.mutation=="Shiny" or item.mutation=="Golden" then piece.Material=Enum.Material.Metal; piece.Reflectance=0.2 end
 if item.mutation=="Void" or item.mutation=="Glitched" then piece.Material=Enum.Material.Neon end
 if item.mutation=="Glitched" then piece:SetAttribute("Rainbow",true) end
end
function Visuals.decoratePlot(plot,folder,center)
 -- Stations are deliberately non-collidable so the prompt blocks remain accessible.
 local neon=Color3.fromRGB(100,255,245)
 block(folder,"Pod floor",Vector3.new(10,0.4,7),plot.pod.Position+Vector3.new(0,-3.4,0),neon,Enum.Material.Neon)
 local glass=block(folder,"Pod window",Vector3.new(7,5.5,0.25),plot.pod.Position+Vector3.new(0,0,2.65),Color3.fromRGB(125,240,255),Enum.Material.Glass)
 glass.Transparency=0.55
 for i=1,4 do
  local x=(i-2.5)*1.8
  block(folder,"Receptor "..i,Vector3.new(1.3,0.3,1.3),plot.pod.Position+Vector3.new(x,-3.1,3.5),Color3.fromRGB(160,255,255),Enum.Material.Neon)
 end
 block(folder,"ATM screen",Vector3.new(5,2,0.3),plot.atm.Position+Vector3.new(0,0.3,2.6),Color3.fromRGB(20,70,60),Enum.Material.Neon)
 local handle=block(folder,"Lever handle",Vector3.new(0.55,4,0.55),plot.lever.Position+Vector3.new(-5,1.4,0),Color3.fromRGB(230,230,240),Enum.Material.Metal)
 local knob=block(folder,"Lever knob",Vector3.new(1.3,1.3,1.3),handle.Position+Vector3.new(0,2.2,0),Color3.fromRGB(255,200,50),Enum.Material.Neon)
 knob.Shape=Enum.PartType.Ball
 plot.handle=handle; plot.knob=knob; plot.handleRest=handle.CFrame; plot.knobRest=knob.CFrame
 local trays=Instance.new("Folder"); trays.Name="RollTrays"; trays.Parent=folder; plot.trays=trays
 -- The panel sits above the station instead of taking room away from the stands.
 for i=1,9 do
  local x=((i-1)%3-1)*2.1
  local y=math.floor((i-1)/3)*2.1
  local tray=block(trays,"Tray"..i,Vector3.new(1.8,1.8,0.35),plot.lever.Position+Vector3.new(x,y+0.8,2.75),Color3.fromRGB(50,55,80))
  tray:SetAttribute("TrayIndex",i)
 end
 for _,stand in ipairs(plot.stands) do
  block(stand,"Neon rim",Vector3.new(6.2,0.15,6.2),stand.Position+Vector3.new(0,0.52,0),Color3.fromRGB(255,238,135),Enum.Material.Neon)
 end
 -- A few bold plot edge accents help distinguish areas from the grass.
 plot.boundaries={}
 for _,x in ipairs({-26,26}) do
  table.insert(plot.boundaries,block(folder,"Boundary",Vector3.new(0.35,0.35,54),center+Vector3.new(x,0.8,0),neon,Enum.Material.Neon))
 end
end
function Visuals.applyTheme(plot,theme)
 plot.floor.Color=theme.floor
 plot.floor.Material=Enum.Material[theme.material]
 for _,boundary in ipairs(plot.boundaries) do boundary.Color=theme.trim end
end
function Visuals.applyRewardCosmetics(plot,extras)
 if plot.handle then
  plot.handle.Color=extras.goldenLever and Color3.fromRGB(255,215,60) or Color3.fromRGB(230,230,240)
  plot.handle.Material=Enum.Material.Metal
 end
 local folder=plot.floor.Parent
 local statue=folder:FindFirstChild("SigmaStatue")
 if not extras.sigmaStatue then if statue then statue:Destroy() end; return end
 if statue then return end
 statue=Instance.new("Folder"); statue.Name="SigmaStatue"; statue.Parent=folder
 local base=plot.atm.Position+Vector3.new(0,0,-5)
 block(statue,"Pedestal",Vector3.new(4,1,4),base+Vector3.new(0,-1,0),Color3.fromRGB(210,165,30),Enum.Material.Metal)
 block(statue,"StatueBody",Vector3.new(2,3,1.5),base+Vector3.new(0,1,0),Color3.fromRGB(245,205,55),Enum.Material.Metal)
 local head=block(statue,"StatueHead",Vector3.new(2,2,2),base+Vector3.new(0,3.5,0),Color3.fromRGB(255,230,85),Enum.Material.Metal)
 billboard(head,"SIGMA STATUE\n+50% INCOME",2,150)
end
function Visuals.autoCollector(plot,enabled)
 local folder=plot.floor.Parent
 local drone=folder:FindFirstChild("AutoCollectorDrone")
 if not enabled then if drone then drone:Destroy() end; return end
 if drone then return end
 drone=Instance.new("Folder"); drone.Name="AutoCollectorDrone"; drone.Parent=folder
 local base=plot.atm.Position+Vector3.new(0,6,0)
 local body=block(drone,"Body",Vector3.new(3,1.2,2),base,Color3.fromRGB(65,75,100),Enum.Material.Metal)
 block(drone,"Eye",Vector3.new(1.2,0.4,0.1),base+Vector3.new(0,0,1.05),Color3.fromRGB(80,255,210),Enum.Material.Neon)
 for _,x in ipairs({-2,2}) do
  block(drone,"Rotor",Vector3.new(1.8,0.2,1.8),base+Vector3.new(x,0.5,0),Color3.fromRGB(70,230,215),Enum.Material.Neon)
 end
 billboard(body,"AUTO-COLLECT",1.7,130)
end
function Visuals.pull(plot)
 if not plot.handle or not plot.handle.Parent then return end
 local info=TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,true)
 TweenService:Create(plot.handle,info,{CFrame=plot.handleRest*CFrame.Angles(math.rad(35),0,0)}):Play()
 TweenService:Create(plot.knob,info,{CFrame=plot.knobRest*CFrame.new(0,-0.6,1.1)}):Play()
end
function Visuals.showRolls(plot,rolls,slots)
 for i=1,9 do
  local tray=plot.trays:FindFirstChild("Tray"..i)
  local old=tray:FindFirstChild("Preview"); if old then old:Destroy() end
  local oldCaption=tray:FindFirstChild("Caption"); if oldCaption then oldCaption:Destroy() end
  local item=rolls[i]
  tray.Color=i<=slots and Color3.fromRGB(85,100,125) or Color3.fromRGB(40,42,55)
  if item then
   local shape=item.kind=="Head" and Vector3.new(1,1,1) or item.kind=="Chest" and Vector3.new(1.2,1.3,0.7) or item.kind=="Arms" and Vector3.new(1.5,0.5,0.5) or Vector3.new(0.8,1.3,0.6)
   local preview=block(tray,"Preview",shape,tray.Position+Vector3.new(0,0,0.65),colorFor(item))
   if item.kind=="Head" then preview.Shape=Enum.PartType.Ball end
   style(preview,item)
   -- Full offer details remain in the roll menu; small tray labels show rarity and price.
   billboard(tray,Config.Rarities[item.rarity].name.."  $"..item.price,1.15,100)
  end
 end
end
function Visuals.collect(plot)
 for i=1,6 do
  local coin=block(plot.atm,"Coin",Vector3.new(0.8,0.8,0.25),plot.atm.Position+Vector3.new(0,2.5,0),Color3.fromRGB(255,217,40),Enum.Material.Neon)
  local angle=i*math.pi/3
  TweenService:Create(coin,TweenInfo.new(0.7,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=coin.Position+Vector3.new(math.cos(angle)*3,3+math.sin(angle),math.sin(angle)*3),Transparency=1}):Play()
  Debris:AddItem(coin,0.8)
 end
end
local accents={
 Color3.fromRGB(255,181,65),Color3.fromRGB(95,215,255),Color3.fromRGB(255,100,160),Color3.fromRGB(145,255,155),
 Color3.fromRGB(195,145,255),Color3.fromRGB(255,225,110),Color3.fromRGB(100,245,220),Color3.fromRGB(235,150,105),
}
local function detail(model,name,size,base,offset,color,material)
 return block(model,name,size,base+offset,color,material)
end
function Visuals.makeCreature(model,base,creature)
 local headStyle=VisualStyle.resolve(creature.components.Head.name)
 local chestStyle=VisualStyle.resolve(creature.components.Chest.name)
 local armsStyle=VisualStyle.resolve(creature.components.Arms.name)
 local legsStyle=VisualStyle.resolve(creature.components.Legs.name)
 local tier=VisualStyle.levelTier(creature.level)
 local shapes={
  {"Chest",Vector3.new(2.5,3,1.5),Vector3.new(0,2,0)},
  {"Head",Vector3.new(2,2,2),Vector3.new(0,4.5,0)},
  {"Arms",Vector3.new(4.5,1,1),Vector3.new(0,2.5,0)},
  {"Legs",Vector3.new(2,1.5,1),Vector3.new(0,0.5,0)},
 }
 for _,shape in ipairs(shapes) do
  local item=creature.components[shape[1]]
  local piece=block(model,shape[1],shape[2],base+shape[3],colorFor(item))
  style(piece,item)
  if item.mutation=="Shiny" or item.mutation=="Golden" then
   local sparkle=Instance.new("Sparkles"); sparkle.SparkleColor=item.mutation=="Golden" and Color3.fromRGB(255,220,60) or Color3.fromRGB(210,250,255); sparkle.Parent=piece
  elseif item.mutation=="Void" then
   local fire=Instance.new("Fire"); fire.Color=Color3.fromRGB(135,65,255); fire.SecondaryColor=Color3.fromRGB(30,0,50); fire.Heat=0; fire.Size=3; fire.Parent=piece
  end
 end
 -- Front-facing eyes, pupils and mouth are separate primitives, with a stable expression.
 local eyeColor=tier>=2 and accents[headStyle.palette] or Color3.fromRGB(245,245,245)
 local eyeMaterial=tier>=2 and Enum.Material.Neon or Enum.Material.SmoothPlastic
 for _,x in ipairs({-0.45,0.45}) do
  detail(model,"Eye",Vector3.new(0.4,headStyle.face==2 and 0.18 or 0.38,0.12),base,Vector3.new(x,4.62,-1.06),eyeColor,eyeMaterial)
  detail(model,"Pupil",Vector3.new(0.12,0.15,0.07),base,Vector3.new(x,4.62,-1.14),Color3.fromRGB(25,25,35))
 end
 detail(model,"Mouth",Vector3.new(headStyle.face==3 and 0.8 or 0.5,headStyle.face==4 and 0.25 or 0.12,0.1),base,Vector3.new(0,4.05,-1.06),Color3.fromRGB(40,30,45))
 local headColor=accents[headStyle.palette]
 if headStyle.headwear==1 then
  for _,x in ipairs({-0.95,0.95}) do detail(model,"Head ring",Vector3.new(0.18,0.2,2.2),base,Vector3.new(x,5.55,0),headColor,Enum.Material.Metal) end
  for _,z in ipairs({-1,1}) do detail(model,"Head ring",Vector3.new(2.1,0.2,0.18),base,Vector3.new(0,5.55,z),headColor,Enum.Material.Metal) end
 elseif headStyle.headwear==2 then
  detail(model,"Antenna",Vector3.new(0.15,0.9,0.15),base,Vector3.new(0,5.95,0),headColor,Enum.Material.Metal)
  local tip=detail(model,"Antenna tip",Vector3.new(0.35,0.35,0.35),base,Vector3.new(0,6.45,0),headColor,Enum.Material.Neon); tip.Shape=Enum.PartType.Ball
 elseif headStyle.headwear==3 then
  detail(model,"Visor",Vector3.new(1.7,0.35,0.18),base,Vector3.new(0,5.12,-1.12),headColor,Enum.Material.Neon)
  detail(model,"Headband",Vector3.new(2.1,0.2,2.1),base,Vector3.new(0,5.45,0),headColor,Enum.Material.Metal)
 elseif headStyle.headwear==4 then
  for _,x in ipairs({-0.75,0.75}) do detail(model,"Horn",Vector3.new(0.28,0.75,0.28),base,Vector3.new(x,5.85,0),headColor,Enum.Material.Metal) end
 elseif headStyle.headwear==5 then
  detail(model,"Crown band",Vector3.new(2.1,0.22,2.1),base,Vector3.new(0,5.55,0),headColor,Enum.Material.Metal)
  for _,x in ipairs({-0.7,0,0.7}) do detail(model,"Crown point",Vector3.new(0.2,0.5,0.2),base,Vector3.new(x,5.9,-0.85),headColor,Enum.Material.Neon) end
 else
  detail(model,"Cap brim",Vector3.new(2.2,0.18,2.4),base,Vector3.new(0,5.5,-0.15),headColor,Enum.Material.Metal)
  detail(model,"Cap top",Vector3.new(1.6,0.45,1.6),base,Vector3.new(0,5.8,0),headColor,Enum.Material.Metal)
 end
 local chestColor=accents[chestStyle.palette]
 detail(model,"Chest plate",Vector3.new(1.7,1.25,0.12),base,Vector3.new(0,2.15,-0.82),chestColor,Enum.Material.Metal)
 local badgeWidth=chestStyle.chest%2==0 and 0.9 or 0.45
 detail(model,"Chest insignia",Vector3.new(badgeWidth,0.25,0.1),base,Vector3.new(0,2.2,-0.91),Color3.fromRGB(245,245,255),Enum.Material.Neon)
 for _,x in ipairs({-2.05,2.05}) do
  detail(model,"Hand",Vector3.new(0.55,0.75,0.9),base,Vector3.new(x,2.5,0),accents[armsStyle.palette],armsStyle.limbs%2==0 and Enum.Material.Metal or Enum.Material.SmoothPlastic)
 end
 for _,x in ipairs({-0.5,0.5}) do
  detail(model,"Foot",Vector3.new(0.8,0.35,1.3),base,Vector3.new(x,0.15,-0.1),accents[legsStyle.palette],legsStyle.limbs%2==0 and Enum.Material.Metal or Enum.Material.SmoothPlastic)
 end
 if tier>=3 then
  detail(model,"Prestige halo",Vector3.new(2.8,0.12,2.8),base,Vector3.new(0,6.65,0),Config.Rarities[VisualStyle.compositeRarity(creature)].color,Enum.Material.Neon).Transparency=0.4
 end
 if creature.ascended then
  local crown=detail(model,"Ascension crown",Vector3.new(3.4,0.25,3.4),base,Vector3.new(0,7.05,0),Color3.fromRGB(255,220,50),Enum.Material.Neon)
  crown.Transparency=0.15
  for _,x in ipairs({-1,0,1}) do
   detail(model,"Ascension point",Vector3.new(0.25,0.55,0.25),base,Vector3.new(x,7.4,-1.35),Color3.fromRGB(255,235,100),Enum.Material.Neon)
  end
 end
end
return Visuals
