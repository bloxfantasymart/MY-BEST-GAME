--!strict
-- Procedural, asset-free decoration. These objects never decide gameplay outcomes.
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local Config=require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local Visuals={}
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
 for _,x in ipairs({-26,26}) do
  block(folder,"Boundary",Vector3.new(0.35,0.35,54),center+Vector3.new(x,0.8,0),neon,Enum.Material.Neon)
 end
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
function Visuals.makeCreature(model,base,creature)
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
  if shape[1]=="Head" then
   -- Two neon eyes give the placeholder a readable face without external assets.
   for _,x in ipairs({-0.45,0.45}) do
    local eye=block(model,"Eye",Vector3.new(0.25,0.35,0.1),piece.Position+Vector3.new(x,0.1,-1.03),Color3.fromRGB(255,255,255),Enum.Material.Neon)
    eye.Shape=Enum.PartType.Ball
   end
  end
 end
end
return Visuals
