--!strict
-- Showcase-only hub. No currency or inventory is transferred by this place.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local PhysicsService=game:GetService("PhysicsService")
local TeleportService=game:GetService("TeleportService")
local CollectionService=game:GetService("CollectionService")
local Config=require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local DataService=require(script.Parent.Services.DataService)
local Visuals=require(script.Parent.Services.Visuals)
local BoothLogic=require(script.Parent.BoothLogic)
local HubLandscape=require(script.Parent.HubLandscape)
local ShowcaseView=require(script.Parent.Services.ShowcaseView)
local Titles=require(script.Parent.Services.Titles)
local ShutdownGate=require(script.Parent.Services.ShutdownGate)
local InteractionGate=require(script.Parent.Services.InteractionGate)
local Proximity=require(script.Parent.Services.Proximity)
local remote=Instance.new("RemoteEvent"); remote.Name="HubAction"; remote.Parent=ReplicatedStorage
local profiles={}
local joinGate=ShutdownGate.new()
local booths={}
local world=Instance.new("Folder"); world.Name="TradingBazaar"; world.Parent=workspace
local function block(parent,name,size,position,color,material)
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=position; p.Anchored=true
 p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.Parent=parent; return p
end
local function caption(parent,text,offset)
 local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromOffset(200,55); gui.StudsOffset=Vector3.new(0,offset,0); gui.AlwaysOnTop=true; gui.Parent=parent
 local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(1,1); t.TextScaled=true; t.BackgroundTransparency=1; t.Font=Enum.Font.GothamBold
 t.TextColor3=Color3.new(1,1,1); t.TextStrokeTransparency=0; t.Text=text; t.Parent=gui; return t
end
local function prompt(parent,text)
 local p=Instance.new("ProximityPrompt"); p.ActionText=text; p.ObjectText=parent.Name; p.MaxActivationDistance=12; p.Parent=parent; return p
end
local function nearby(player,part)
 return Proximity.isAliveNear(player.Character,part,20)
end
block(world,"Bazaar floor",Vector3.new(230,1,230),Vector3.new(0,-0.5,0),Color3.fromRGB(43,35,80))
HubLandscape.build(world)
local center=block(world,"Town square",Vector3.new(42,0.5,42),Vector3.new(0,0.3,0),Color3.fromRGB(100,70,170),Enum.Material.Neon)
center.CanCollide=true
local spawn=Instance.new("SpawnLocation"); spawn.Size=Vector3.new(10,1,10); spawn.Position=Vector3.new(0,1,0); spawn.Neutral=true; spawn.Parent=world
local portal=block(world,"Return portal",Vector3.new(10,10,2),Vector3.new(0,5,-19),Color3.fromRGB(60,225,240),Enum.Material.Neon)
caption(portal,"RETURN TO GAME",7)
local function text(player,message) remote:FireClient(player,{message=message}) end
local function travel(player)
 local s=profiles[player]
 if not s or joinGate.closed or not DataService.isHealthy(player.UserId) or not nearby(player,portal) then return end
 if not InteractionGate.allow(s,"prompt",os.clock()) then return end
 local id=Config.PlaceIds.Main
 if type(id)~="number" or id<=0 or id%1~=0 then text(player,"Return portal is not configured. See the setup guide."); return end
 if os.clock()-(s.lastPortal or -20)<10 then return end
 s.lastPortal=os.clock()
 local ok,err=pcall(function() TeleportService:TeleportAsync(id,{player}) end)
 if not ok then warn("Return teleport failed: "..tostring(err)); text(player,"Could not return. Please try again.") end
end
prompt(portal,"Return to game").Triggered:Connect(travel)
TeleportService.TeleportInitFailed:Connect(function(player, _result, message, placeId)
 if placeId==Config.PlaceIds.Main and profiles[player] then warn("Teleport init failed: "..message); text(player,"Travel failed. Please try again.") end
end)

-- Players do not collide with one another. The hub contains no tools or damage system.
pcall(function() PhysicsService:RegisterCollisionGroup("HubPlayers") end)
PhysicsService:CollisionGroupSetCollidable("HubPlayers","HubPlayers",false)
local function noCharacterCollision(character)
 local function apply(child) if child:IsA("BasePart") then child.CollisionGroup="HubPlayers" end end
 for _,child in ipairs(character:GetDescendants()) do apply(child) end
 character.DescendantAdded:Connect(apply)
end
local function findCreature(profile,id)
 if type(id)~="string" or #id>64 then return nil end
 for _,c in ipairs(profile.creatures) do if c.id==id then return c end end
 return nil
end
local function refreshBooth(booth)
 for _,child in ipairs(booth.displays:GetChildren()) do child:Destroy() end
 booth.sign.Text=booth.owner and (booth.owner.DisplayName.."'s showcase") or ("BOOTH "..booth.index.." — UNCLAIMED")
 local userId=booth.owner and booth.owner.UserId
 booth.avatar.Image=(type(userId)=="number" and userId>0) and ("rbxthumb://type=AvatarHeadShot&id="..userId.."&w=150&h=150") or ""
 booth.avatar.Visible=booth.owner~=nil and booth.avatar.Image~=""
 if not booth.owner then return end
 local ownerSession=profiles[booth.owner]
 if not ownerSession then return end
 for i,id in ipairs(booth.listings) do
  local creature=findCreature(ownerSession.profile,id)
  if creature then
   local base=booth.counter.Position+Vector3.new((i-2.5)*4,1.8,0)
   local model=Instance.new("Model"); model.Name="Showcase"; model.Parent=booth.displays
   Visuals.makeCreature(model,base,creature)
   local anchor=block(model,"CaptionAnchor",Vector3.new(0.1,0.1,0.1),base+Vector3.new(0,7.5,0),Color3.new(1,1,1)); anchor.Transparency=1; anchor.CanCollide=false
   local rarity=Config.Rarities[Visuals.compositeRarity(creature)]
   local title=caption(anchor,(creature.ascended and "ASCENDED " or "")..creature.name.." ["..rarity.name.."]\nLv."..creature.level.." | $"..math.floor(Config.Income(creature)).."/s",1)
   title.TextColor3=rarity.color; title.TextStrokeTransparency=0
   CollectionService:AddTag(model,"BrainrotDisplay")
  end
 end
end
local function openBooth(player,booth,fromPrompt)
 local own=booth.owner==player
 local listings={}
 local session=booth.owner and profiles[booth.owner]
 if session then
  for _,id in ipairs(booth.listings) do
   local c=findCreature(session.profile,id)
   if c then
    table.insert(listings,ShowcaseView.describe(c,Config.Rarities,Config.Income,own))
   end
  end
 end
 local inventory={}
 if own and profiles[player] then
  for _,c in ipairs(profiles[player].profile.creatures) do
   table.insert(inventory,ShowcaseView.describe(c,Config.Rarities,Config.Income,true))
  end
 end
 remote:FireClient(player,{open=true,fromPrompt=fromPrompt==true,booth=booth.index,owner=booth.owner and booth.owner.DisplayName or "Unclaimed",own=own,listings=listings,inventory=inventory})
end
for i=1,15 do
 local angle=(i-1)*2*math.pi/15
 local centerPos=Vector3.new(math.cos(angle)*80,0,math.sin(angle)*80)
 local folder=Instance.new("Folder"); folder.Name="Booth"..i; folder.Parent=world
 local counter=block(folder,"Booth "..i,Vector3.new(19,3,7),centerPos+Vector3.new(0,1.5,0),Color3.fromRGB(85,55,155))
 local roof=block(folder,"Neon canopy",Vector3.new(20,0.5,8),centerPos+Vector3.new(0,9,0),Color3.fromRGB(255,100,190),Enum.Material.Neon); roof.CanCollide=false
 local displays=Instance.new("Folder"); displays.Name="Displays"; displays.Parent=folder
 local avatarGui=Instance.new("BillboardGui"); avatarGui.Name="OwnerAvatar"; avatarGui.Size=UDim2.fromOffset(72,72)
 avatarGui.StudsOffset=Vector3.new(0,6,0); avatarGui.AlwaysOnTop=true; avatarGui.MaxDistance=120; avatarGui.Parent=roof
 local avatar=Instance.new("ImageLabel"); avatar.Size=UDim2.fromScale(1,1); avatar.BackgroundTransparency=1; avatar.Visible=false; avatar.Parent=avatarGui
 local booth={index=i,counter=counter,sign=caption(roof,"BOOTH "..i.." — UNCLAIMED",2),avatar=avatar,displays=displays,owner=nil,listings={}}
 booths[i]=booth
 prompt(counter,"Claim / inspect").Triggered:Connect(function(player)
  local s=profiles[player]
  if not s or joinGate.closed or not DataService.isHealthy(player.UserId) or not nearby(player,counter) then return end
  if not InteractionGate.allow(s,"prompt",os.clock()) then return end
  if not booth.owner then
   local ok,reason=BoothLogic.claim(booth,player,s)
   if not ok then text(player,reason); return end
   refreshBooth(booth)
  end
  openBooth(player,booth,true)
 end)
end
remote.OnServerEvent:Connect(function(player,action,payload)
 local s=profiles[player]
 if not s or joinGate.closed or not DataService.isHealthy(player.UserId) or type(action)~="string" or #action>30 then return end
 local now=os.clock()
 if not InteractionGate.allow(s,"remote",now) then return end
 if type(payload)~="table" then return end
 if action=="directory" then
  local requestId=payload.requestId
  if type(requestId)~="number" or requestId~=requestId or requestId%1~=0 or requestId<1 or requestId>2147483647 then return end
  remote:FireClient(player,{directory=true,requestId=requestId,booths=BoothLogic.directory(booths,player)})
  return
 elseif action=="visitBooth" or action=="visitPortal" then
  local destination=portal
  if action=="visitBooth" then
   if not BoothLogic.validIndex(payload.booth,#booths) then return end
   destination=booths[payload.booth].counter
  end
  local character=player.Character
  local root=character and character:FindFirstChild("HumanoidRootPart")
  local humanoid=character and character:FindFirstChildOfClass("Humanoid")
  local allowed,reason=BoothLogic.allowTravel(s,now,root~=nil and humanoid~=nil and humanoid.Health>0)
  if not allowed then text(player,reason); return end
  character:PivotTo(CFrame.new(destination.Position+Vector3.new(0,4,8)))
  text(player,"Travelled to "..destination.Name..". Use its prompt to interact.")
  return
 end
 local index=payload.booth
 if not BoothLogic.validIndex(index,#booths) then return end
 local booth=booths[index]
 if not nearby(player,booth.counter) then text(player,"Move closer to the booth."); return end
 if action=="refresh" then openBooth(player,booth); return end
 if booth.owner~=player then return end
 if action=="release" then
  BoothLogic.release(booth,player,s); refreshBooth(booth); remote:FireClient(player,{close=true,booth=booth.index,message="Booth released."}); return
 elseif action=="add" then
  local ok,reason=BoothLogic.add(booth,player,s,payload.id)
  if not ok then text(player,reason); return end
 elseif action=="remove" then
  local ok,reason=BoothLogic.remove(booth,player,payload.id)
  if not ok then text(player,reason); return end
 else return end
 refreshBooth(booth); openBooth(player,booth)
end)
local function releaseBooth(s)
 if not s.booth then return end
 local booth=booths[s.booth]; BoothLogic.release(booth,booth.owner,s); refreshBooth(booth)
end
local function joinImpl(player,context)
 local function titleWhenReady(character)
  local head=character:WaitForChild("Head",10)
  local session=profiles[player]
  if head and session and player.Character==character then Titles.apply(character,session.profile.rebirth,session.profile.extras) end
 end
 player.CharacterAdded:Connect(function(character) noCharacterCollision(character); task.spawn(titleWhenReady,character) end)
 if player.Character then noCharacterCollision(player.Character) end
 local profile=DataService.load(player.UserId)
 if not profile then if player.Parent then player:Kick("Could not load your profile safely. Please retry after the previous session closes.") end; return end
 context.data=profile
 if not player.Parent or joinGate.closed then
  if not DataService.save(player.UserId,profile,true) then warn("Failed to release hub profile after interrupted join: "..player.UserId) end
  context.data=nil
  return
 end
 profiles[player]={profile=profile,booth=nil}; context.data=nil
 if player.Character then task.spawn(titleWhenReady,player.Character) end
 text(player,"Claim a booth to display creatures. Trading is not enabled yet.")
end
local function join(player)
 if profiles[player] then return end
 local started,reason=ShutdownGate.begin(joinGate,player.UserId,player)
 if not started then
  -- A duplicate callback for the same Player is harmless, but a different
  -- connection must not remain stranded or overlap a pending save/load.
  if player.Parent and (reason=="departing" or (reason=="joining" and joinGate.joiningOwners[player.UserId]~=player)) then
   player:Kick("Your previous session is still closing. Please wait a moment and rejoin.")
  end
  return
 end
 local context={}
 local ok,err=pcall(joinImpl,player,context)
 if not ok then
  warn("Hub join failed for "..player.UserId..": "..tostring(err))
  if not profiles[player] and context.data then
   local savedOk,saved=pcall(DataService.save,player.UserId,context.data,true)
   if not savedOk or not saved then warn("Failed to release hub profile after join error: "..player.UserId) end
  end
  if player.Parent then player:Kick("Could not join safely. Please try again.") end
 end
 ShutdownGate.finish(joinGate,player.UserId)
end
Players.PlayerAdded:Connect(join)
Players.PlayerRemoving:Connect(function(player)
 local s=profiles[player]; if not s or not ShutdownGate.beginDeparture(joinGate,player.UserId) then return end
 profiles[player]=nil
 local ok,err=pcall(function()
  local released,releaseErr=pcall(releaseBooth,s)
  if not released then warn("Failed to clear hub booth for "..player.UserId..": "..tostring(releaseErr)) end
  if not DataService.save(player.UserId,s.profile,true) then warn("Failed to release hub profile for "..player.UserId) end
 end)
 ShutdownGate.finishDeparture(joinGate,player.UserId)
 if not ok then warn("Hub departure failed for "..player.UserId..": "..tostring(err)) end
end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(join,player) end
task.spawn(function()
 while true do
  task.wait(45)
  if joinGate.closed then break end
  for player,s in pairs(profiles) do
   task.spawn(function()
    if profiles[player]==s and not DataService.save(player.UserId,s.profile,false) then warn("Hub lease renewal failed for "..player.UserId) end
   end)
  end
 end
end)
task.spawn(function()
 while true do task.wait(2); for player in pairs(profiles) do if not DataService.isHealthy(player.UserId) then player:Kick("Data session expired. Please rejoin.") end end end
end)
game:BindToClose(function()
 ShutdownGate.close(joinGate)
 local remaining=0
 for player,s in pairs(profiles) do
  profiles[player]=nil; remaining+=1
  task.spawn(function()
   local ok,saved=pcall(DataService.save,player.UserId,s.profile,true)
   if not ok or not saved then warn("Hub shutdown save failed: "..player.UserId) end
   remaining-=1
  end)
 end
 local deadline=os.clock()+25
 while not ShutdownGate.drained(joinGate,remaining) and os.clock()<deadline do task.wait(0.1) end
 if not ShutdownGate.drained(joinGate,remaining) then warn("Hub shutdown deadline reached with saves, departures or joins still pending.") end
end)
