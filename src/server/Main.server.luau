--!strict
-- Server-authoritative prototype and progression.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local DataService = require(script.Parent:WaitForChild("Services"):WaitForChild("DataService"))
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remote = Instance.new("RemoteEvent")
remote.Name = "GameAction"
remote.Parent = ReplicatedStorage
local rng = Random.new()
local states = {}
local plots = {}
local startedAt=os.clock()
local function activeEvents()
 local elapsed=os.clock()-startedAt
 local frenzy=(elapsed%1800)>=1500
 local cycle=math.floor(elapsed/900)
 local offset=elapsed%900
 local eclipse=cycle>0 and cycle%3==1 and offset<180
 local sigma=cycle>0 and cycle%3==2 and offset<120
 local storm=cycle>0 and cycle%3==0 and offset<120
 return frenzy,eclipse,sigma,storm
end
local function eventText()
 local frenzy,eclipse,sigma,storm=activeEvents()
 local names={}
 if frenzy then table.insert(names,"2x Luck Frenzy") end
 if eclipse then table.insert(names,"50% Eclipse Discount") end
 if sigma then table.insert(names,"3x Sigma Income") end
 if storm then table.insert(names,"Ohio Storm: collect golden drops") end
 return #names>0 and table.concat(names," + ") or "No active event"
end

local function part(parent, name, size, position, color, material)
 local p = Instance.new("Part")
 p.Name, p.Size, p.Position, p.Color = name, size, position, color
 p.Anchored = true
 p.Material = material or Enum.Material.SmoothPlastic
 p.Parent = parent
 return p
end
local function label(parent, text, offset)
 local gui = Instance.new("BillboardGui")
 gui.Size = UDim2.fromOffset(200, 55)
 gui.StudsOffset = Vector3.new(0, offset or 4, 0)
 gui.AlwaysOnTop = true
 gui.Parent = parent
 local t = Instance.new("TextLabel")
 t.Size = UDim2.fromScale(1, 1)
 t.BackgroundTransparency = 1
 t.TextColor3 = Color3.new(1,1,1)
 t.TextStrokeTransparency = 0
 t.TextScaled = true
 t.Font = Enum.Font.GothamBold
 t.Text = text
 t.Parent = gui
 return t
end
local function prompt(p, action)
 local q = Instance.new("ProximityPrompt")
 q.ActionText = action
 q.ObjectText = p.Name
 q.MaxActivationDistance = 12
 q.HoldDuration = 0
 q.Parent = p
 return q
end
local world = Instance.new("Folder")
world.Name = "GeneratedWorld"
world.Parent = workspace
part(world,"Grass",Vector3.new(450,1,450),Vector3.new(0,-0.5,0),Color3.fromRGB(75,185,85),Enum.Material.Grass)
part(world,"Plaza",Vector3.new(65,1,65),Vector3.new(0,0.1,0),Color3.fromRGB(110,105,150))
local spawn = Instance.new("SpawnLocation")
spawn.Size = Vector3.new(12,1,12)
spawn.Position = Vector3.new(0,1,0)
spawn.Neutral = true
spawn.Parent = world

local function send(player, message)
 local s = states[player]
 if not s then return end
 remote:FireClient(player, {cash=s.cash, pending=math.floor(s.pending), slots=s.slots, standsUnlocked=s.standsUnlocked, autoRolling=s.autoRolling, autoRarity=s.autoRarity, rebirth=s.rebirth, target=Config.RebirthTarget(s.rebirth), rebirthCost=Config.RebirthCost(s.rebirth), event=eventText(), parts=s.parts, creatures=s.creatures, rolls=s.rolls, message=message or ""})
end
local function owned(player, plot)
 return plot.owner == player and states[player] ~= nil
end
local function nearby(player, p)
 local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 return root and (root.Position - p.Position).Magnitude <= 20
end
local function makePlot(i)
 local angle = (i-1)*math.pi*2/6
 local center = Vector3.new(math.cos(angle)*105, 0, math.sin(angle)*105)
 local folder = Instance.new("Folder")
 folder.Name = "Plot"..i
 folder.Parent = world
 part(folder,"Plot",Vector3.new(54,1,54),center,Color3.fromRGB(59,120,190))
 local path = part(folder,"Path",Vector3.new(12,0.4,70),center/2+Vector3.new(0,0.25,0),Color3.fromRGB(220,213,180))
 path.CFrame = CFrame.lookAt(path.Position, center)
 local sign = part(folder,"Sign",Vector3.new(5,5,1),center+Vector3.new(0,3,22),Color3.fromRGB(255,192,65))
 local plot = {owner=nil, sign=label(sign,"Unclaimed plot",4), stands={}}
 plot.lever = part(folder,"Roll station",Vector3.new(8,5,5),center+Vector3.new(-18,3,-16),Color3.fromRGB(250,91,105))
 plot.pod = part(folder,"Assembly pod",Vector3.new(8,7,5),center+Vector3.new(0,4,-16),Color3.fromRGB(124,75,225))
 plot.atm = part(folder,"Cash ATM",Vector3.new(8,4,5),center+Vector3.new(18,2.5,-16),Color3.fromRGB(48,205,115))
 label(plot.lever,"ROLL",4); label(plot.pod,"ASSEMBLE",5); plot.bankLabel = label(plot.atm,"Bank: $0",4)
 prompt(plot.lever,"Roll").Triggered:Connect(function(player)
  if owned(player,plot) then remote:FireClient(player,{open="roll"}) end
 end)
 prompt(plot.pod,"Open assembly").Triggered:Connect(function(player)
  if owned(player,plot) then remote:FireClient(player,{open="assemble"}) end
 end)
 prompt(plot.atm,"Collect").Triggered:Connect(function(player)
  if owned(player,plot) and DataService.isHealthy(player.UserId) then
   local s=states[player]; s.cash += math.floor(s.pending); s.pending %= 1; send(player,"Cash collected!")
  end
 end)
 for n=1,24 do
  local x = ((n-1)%6)*8-20
  local z = math.floor((n-1)/6)*8-5
  local stand=part(folder,"Stand "..n,Vector3.new(6,1,6),center+Vector3.new(x,1,z),Color3.fromRGB(255,205,75))
  plot.stands[n]=stand
  prompt(stand,"Place / remove").Triggered:Connect(function(player)
   if owned(player,plot) then
    if n <= states[player].standsUnlocked then remote:FireClient(player,{open="stand",stand=n}) else send(player,"This stand is locked. Upgrade stands from the menu.") end
   end
  end)
 end
 return plot
end
for i=1,6 do plots[i]=makePlot(i) end
local function updateStand(s, n)
 local stand=s.plot.stands[n]
 local old=stand:FindFirstChild("Display")
 if old then old:Destroy() end
 stand.Color = n<=s.standsUnlocked and Color3.fromRGB(255,205,75) or Color3.fromRGB(90,95,110)
 for _, creature in ipairs(s.creatures) do
  if creature.stand == n then
   local m=Instance.new("Model"); m.Name="Display"; m.Parent=stand
   local base=stand.Position+Vector3.new(0,1,0)
   local shapes={{"Chest",Vector3.new(2.5,3,1.5),Vector3.new(0,2,0)}, {"Head",Vector3.new(2,2,2),Vector3.new(0,4.5,0)}, {"Arms",Vector3.new(4.5,1,1),Vector3.new(0,2.5,0)}, {"Legs",Vector3.new(2,1.5,1),Vector3.new(0,0.5,0)}}
   for _,shape in ipairs(shapes) do
    local item=creature.components[shape[1]]
    local color=Config.Rarities[item.rarity].color
    if item.mutation=="Golden" then color=Color3.fromRGB(255,205,30) elseif item.mutation=="Void" then color=Color3.fromRGB(70,20,100) elseif item.mutation=="Glitched" then color=Color3.fromRGB(255,75,220) end
    local piece=part(m,shape[1],shape[2],base+shape[3],color)
    if item.mutation=="Shiny" or item.mutation=="Golden" then piece.Material=Enum.Material.Metal; piece.Reflectance=0.2 end
   end
   label(stand, creature.name.." Lv."..creature.level.."\n$"..math.floor(Config.Income(creature)).."/s",7)
   -- Keep the display label in the model so it is removed with it.
   local gui=stand:FindFirstChildOfClass("BillboardGui"); if gui then gui.Adornee=stand; gui.Parent=m end
   break
  end
 end
end
local function roll(s)
 local eligible={}
 local frenzy,eclipse=activeEvents()
 -- Choose an eligible rarity by tier weight, then an archetype within that rarity.
 for r, rarity in ipairs(Config.Rarities) do
  local list={}
  for _, entry in ipairs(Config.Catalog) do if entry.rarity==r and entry.rebirth<=s.rebirth then table.insert(list,entry) end end
  if #list>0 then table.insert(eligible,{list=list, weight=rarity.weight * (1.15 ^ (s.rebirth * (r-1)/7)) * ((frenzy and r>1) and 2 or 1)}) end
 end
 local total=0; for _, tier in ipairs(eligible) do total+=tier.weight end
 local pick=rng:NextNumber(0,total)
 local tier=eligible[#eligible]
 for _, t in ipairs(eligible) do pick-=t.weight; if pick<=0 then tier=t; break end end
 local archetype=tier.list[rng:NextInteger(1,#tier.list)]
 local kind=Config.Types[rng:NextInteger(1,4)]
 local mutationRoll=rng:NextInteger(1,10000)
 local mutation=Config.Mutations[1]
 for _,m in ipairs(Config.Mutations) do mutationRoll-=m.weight; if mutationRoll<=0 then mutation=m; break end end
 return {mutation=mutation.name, mutationMultiplier=mutation.multiplier,id=HttpService:GenerateGUID(false), name=archetype.name, kind=kind, rarity=archetype.rarity, income=archetype.income, price=math.max(1,math.floor(math.max(10,archetype.income*5)*(eclipse and 0.5 or 1)))}
end
local function rollBatch(s)
 s.rolls={}
 for _=1,s.slots do table.insert(s.rolls,roll(s)) end
end
local function findById(items, id)
 if type(id) ~= "string" or #id>64 then return nil end
 for i, item in ipairs(items) do if item.id==id then return i,item end end
 return nil
end
remote.OnServerEvent:Connect(function(player, action, value)
 local s=states[player]
 if not s or type(action)~="string" then return end
 if not DataService.isHealthy(player.UserId) then player:Kick("Your data session could not be renewed. Please rejoin."); return end
 local now=os.clock()
 if now<(s.blockUntil or 0) then return end
 if now-(s.windowStart or 0)>=1 then s.windowStart=now; s.requestCount=0 end
 s.requestCount=(s.requestCount or 0)+1
 if s.requestCount>15 then s.blockUntil=now+5; return end
 if now-(s.lastAction or 0)<0.15 then return end
 s.lastAction=now
 if action=="sync" then send(player)
 elseif action=="roll" and nearby(player,s.plot.lever) then
  if now-(s.lastRoll or 0)<0.35 then return end
  s.lastRoll=now; s.autoRolling=false; rollBatch(s)
  send(player,"Choose parts to buy, or roll again.")
 elseif action=="buy" and nearby(player,s.plot.lever) then
  local i,item=findById(s.rolls,value)
  if i and s.cash>=item.price and #s.parts<100 then
   s.cash-=item.price; table.insert(s.parts,item); table.remove(s.rolls,i); send(player,"Part purchased!")
  else send(player,"Cannot buy: check cash and inventory space.") end
 elseif action=="teleport" then
  local destinations={lever=s.plot.lever,pod=s.plot.pod,atm=s.plot.atm}
  local destination=type(value)=="string" and destinations[value] or nil
  if destination and now-(s.lastTeleport or -10)>=3 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
   s.lastTeleport=now; player.Character:PivotTo(CFrame.new(destination.Position+Vector3.new(0,4,8))); send(player,"Teleported to "..destination.Name..".")
  end
 elseif action=="autoRoll" then
  if value==false then s.autoRolling=false; send(player,"Auto-roll stopped.")
  elseif type(value)=="number" and value==value and value%1==0 and value>=1 and value<=8 and nearby(player,s.plot.lever) then
   s.autoRarity=value; s.autoRolling=true; s.nextAuto=0; send(player,"Auto-roll started. Stay near your station.")
  end
 elseif action=="upgradeStands" then
  local nextStand=s.standsUnlocked+1
  local cost=Config.StandCosts[nextStand-12]
  if not cost then send(player,"All 24 stands are unlocked.")
  elseif s.rebirth<nextStand-12 then send(player,"This stand requires rebirth "..(nextStand-12)..".")
  elseif s.cash<cost then send(player,"Not enough cash for this stand.")
  else s.cash-=cost; s.standsUnlocked=nextStand; updateStand(s,nextStand); send(player,"Stand "..nextStand.." unlocked!") end
 elseif action=="sellPart" then
  local index,item=findById(s.parts,value)
  if index then table.remove(s.parts,index); local amount=Config.PartSellValue(item); s.cash+=amount; send(player,"Part sold for $"..amount..".") end
 elseif action=="sellCreature" then
  local index,creature=findById(s.creatures,value)
  if index and creature.stand==0 then table.remove(s.creatures,index); local amount=Config.CreatureSellValue(creature); s.cash+=amount; send(player,"Creature sold for $"..amount..".")
  elseif index then send(player,"Remove the creature from its stand before selling.") end
 elseif action=="upgradeSlots" then
  local cost=Config.SlotCosts[s.slots+1]
  if cost and s.cash>=cost then s.cash-=cost; s.slots+=1; send(player,"Slot unlocked!") else send(player,"Not enough cash, or all slots unlocked.") end
 elseif action=="assemble" and nearby(player,s.plot.pod) and type(value)=="table" then
  if #s.creatures>=100 then send(player,"Creature inventory is full (100)."); return end
  local components={}; local seen={}; local sum=0; local highest=0; local dominant=nil; local firstMutation=nil; local harmony=true
  for _,kind in ipairs(Config.Types) do
   local id=value[kind]; local _,item=findById(s.parts,id)
   if not item or item.kind~=kind or seen[id] then send(player,"Select one owned part of each type."); return end
   seen[id]=true; components[kind]=item; sum+=item.income*(item.mutationMultiplier or 1)
   if firstMutation==nil then firstMutation=item.mutation or "Standard" elseif firstMutation~=(item.mutation or "Standard") then harmony=false end
   if item.rarity>highest then highest=item.rarity; dominant=item.name end
  end
  for i=#s.parts,1,-1 do if seen[s.parts[i].id] then table.remove(s.parts,i) end end
  table.insert(s.creatures,{id=HttpService:GenerateGUID(false),name=dominant.." Abomination",components=components,income=sum*Config.Rarities[highest].multiplier*0.4*(harmony and 2 or 1),level=1,exp=0,stand=0})
  send(player,"Assembled! Take it to a stand.")
 elseif action=="stand" and type(value)=="table" then
  local n=value.stand
  if type(n)~="number" or n~=n or n%1~=0 or n<1 or n>s.standsUnlocked or not nearby(player,s.plot.stands[n]) then return end
  local _,creature=findById(s.creatures,value.id)
  if not creature then return end
  if creature.stand==n then creature.stand=0
  elseif creature.stand==0 then
   for _, c in ipairs(s.creatures) do if c.stand==n then send(player,"This stand is occupied."); return end end
   creature.stand=n
  else send(player,"Remove this creature from its current stand first."); return end
  updateStand(s,n); send(player,"Stand updated.")
 elseif action=="level" then
  local _,creature=findById(s.creatures,value)
  if creature and creature.level<1000 then
   local cost=Config.LevelCost(creature)
   if s.cash>=cost then s.cash-=cost; creature.level+=1; if creature.stand>0 then updateStand(s,creature.stand) end; send(player,"Level upgraded!")
   else send(player,"Not enough cash to level up.") end
  end
 elseif action=="rebirth" then
  if s.rebirth>=100 then send(player,"Maximum rebirth reached!"); return end
  local target=Config.RebirthTarget(s.rebirth).." Abomination"
  local index=nil
  for i,c in ipairs(s.creatures) do if c.name==target then index=i; break end end
  if s.cash<Config.RebirthCost(s.rebirth) or not index then send(player,"Rebirth requires the displayed cash and creature."); return end
  local sacrificed=table.remove(s.creatures,index)
  if sacrificed.stand>0 then updateStand(s,sacrificed.stand) end
  s.cash=0; s.slots=1; s.rolls={}; s.autoRolling=false; s.rebirth+=1
  send(player,"Rebirth complete! New archetypes unlocked.")
 elseif action=="collect" then
  s.cash+=math.floor(s.pending); s.pending%=1; send(player,"Cash collected!")
 end
end)
local function profile(s)
 return {version=1,cash=s.cash,pending=s.pending,slots=s.slots,standsUnlocked=s.standsUnlocked,rebirth=s.rebirth,parts=s.parts,creatures=s.creatures}
end
local function clearPlot(s)
 for n=1,24 do
  local display=s.plot.stands[n]:FindFirstChild("Display")
  if display then display:Destroy() end
 end
 s.plot.owner=nil; s.plot.sign.Text="Unclaimed plot"; s.plot.bankLabel.Text="Bank: $0"
end
local function join(player)
 local plot=nil
 for _,p in ipairs(plots) do if not p.owner then plot=p; break end end
 if not plot then player:Kick("This server has no free plots. Please join another server."); return end
 plot.owner=player; plot.sign.Text="Loading "..player.DisplayName.."..."
 local data=DataService.load(player.UserId)
 if not data then
  plot.owner=nil; plot.sign.Text="Unclaimed plot"
  if player.Parent then player:Kick("Could not load your data safely. Please try again later.") end
  return
 end
 if not player.Parent then DataService.save(player.UserId,data,true); plot.owner=nil; plot.sign.Text="Unclaimed plot"; return end
 local s={cash=data.cash,pending=data.pending,slots=data.slots,standsUnlocked=data.standsUnlocked or 12,autoRolling=false,autoRarity=1,rebirth=data.rebirth,parts=data.parts,creatures=data.creatures,rolls={},plot=plot}
 states[player]=s; plot.sign.Text=player.DisplayName.."'s plot"
 for n=1,24 do updateStand(s,n) end
 local function teleport(character)
  local root=character:WaitForChild("HumanoidRootPart",10)
  if root and states[player] then character:PivotTo(CFrame.new(plot.lever.Position+Vector3.new(0,4,10))) end
 end
 player.CharacterAdded:Connect(teleport)
 if player.Character then task.spawn(teleport,player.Character) end
 send(player,"Welcome! Roll at your station.")
end
Players.PlayerAdded:Connect(join)
Players.PlayerRemoving:Connect(function(player)
 local s=states[player]; if not s then return end
 states[player]=nil
 local snapshot=profile(s)
 clearPlot(s)
 if not DataService.save(player.UserId,snapshot,true) then warn("Failed to save profile for "..player.UserId) end
end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(join,player) end
task.spawn(function()
 while true do
  task.wait(1)
  for player,s in pairs(states) do
   if not DataService.isHealthy(player.UserId) then player:Kick("Data connection lost; please rejoin.")
   else
    local changed=false
    for _,creature in ipairs(s.creatures) do
     if creature.stand>0 then
      local _,_,sigma=activeEvents()
      s.pending+=Config.Income(creature)*(sigma and 3 or 1)
      if creature.level<1000 then
       creature.exp=(creature.exp or 0)+1
       if creature.exp>=10 then creature.exp-=10; creature.level+=1; updateStand(s,creature.stand); changed=true end
      else creature.exp=0 end
     end
    end
    s.plot.bankLabel.Text="Bank: $"..math.floor(s.pending)
    if changed then send(player) else remote:FireClient(player, {tick=true, cash=s.cash, pending=math.floor(s.pending), event=eventText()}) end
   end
  end
 end
end)
task.spawn(function()
 while true do
  task.wait(0.5)
  for player,s in pairs(states) do
   if s.autoRolling and os.clock()>=(s.nextAuto or 0) then
    if not DataService.isHealthy(player.UserId) or not nearby(player,s.plot.lever) then
     s.autoRolling=false; send(player,"Auto-roll stopped: stay near your roll station.")
    elseif #s.parts>=100 then
     s.autoRolling=false; send(player,"Auto-roll stopped: inventory full.")
    else
     s.nextAuto=os.clock()+2
     rollBatch(s)
     local stopped=false
     for i=#s.rolls,1,-1 do
      local item=s.rolls[i]
      if item.rarity>=s.autoRarity then
       if s.cash<item.price or #s.parts>=100 then stopped=true; break end
       s.cash-=item.price; table.insert(s.parts,item); table.remove(s.rolls,i)
      end
     end
     if stopped then s.autoRolling=false; send(player,"Auto-roll stopped: not enough cash or inventory space.")
     else send(player,"Auto-roll is running.") end
    end
   end
  end
 end
end)
-- Storm rewards are created and claimed on the server, once per drop, by its plot owner.
task.spawn(function()
 while true do
  task.wait(10)
  local _,_,_,storm=activeEvents()
  if storm then
   for owner,s in pairs(states) do
    if DataService.isHealthy(owner.UserId) then
     local position=s.plot.atm.Position+Vector3.new(rng:NextNumber(-15,15),22,rng:NextNumber(5,25))
     local drop=part(world,"Storm drop",Vector3.new(2.5,2.5,2.5),position,Color3.fromRGB(255,216,40),Enum.Material.Neon)
     drop.Shape=Enum.PartType.Ball; drop.CanCollide=false; drop.Anchored=false
     pcall(function() drop:SetNetworkOwner(nil) end)
     local claimed=false
     drop.Touched:Connect(function(hit)
      if claimed or states[owner]~=s or not DataService.isHealthy(owner.UserId) then return end
      local character=owner.Character
      if character and hit:IsDescendantOf(character) then
       claimed=true; s.cash+=50*(1+s.rebirth); drop:Destroy(); send(owner,"Ohio Storm bonus collected!")
      end
     end)
     Debris:AddItem(drop,8)
    end
   end
  end
 end
end)
task.spawn(function()
 while true do
  task.wait(45)
  for player,s in pairs(states) do
   task.spawn(function()
    if states[player]==s and not DataService.save(player.UserId,profile(s),false) then warn("Autosave failed for "..player.UserId) end
   end)
  end
 end
end)
game:BindToClose(function()
 local remaining=0
 for player,s in pairs(states) do
  states[player]=nil; remaining+=1
  task.spawn(function()
   if not DataService.save(player.UserId,profile(s),true) then warn("Shutdown save failed for "..player.UserId) end
   remaining-=1
  end)
 end
 local deadline=os.clock()+25
 while remaining>0 and os.clock()<deadline do task.wait(0.1) end
end)
