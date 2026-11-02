--!strict
-- Stage 1: a session-only, server-authoritative playable prototype.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remote = Instance.new("RemoteEvent")
remote.Name = "GameAction"
remote.Parent = ReplicatedStorage
local rng = Random.new()
local states = {}
local plots = {}

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
 remote:FireClient(player, {cash=s.cash, pending=math.floor(s.pending), slots=s.slots, parts=s.parts, creatures=s.creatures, rolls=s.rolls, message=message or ""})
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
  if owned(player,plot) then
   local s=states[player]; s.cash += math.floor(s.pending); s.pending %= 1; send(player,"Cash collected!")
  end
 end)
 for n=1,12 do
  local x = ((n-1)%6)*8-20
  local z = math.floor((n-1)/6)*10+1
  local stand=part(folder,"Stand "..n,Vector3.new(6,1,6),center+Vector3.new(x,1,z),Color3.fromRGB(255,205,75))
  plot.stands[n]=stand
  prompt(stand,"Place / remove").Triggered:Connect(function(player)
   if owned(player,plot) then remote:FireClient(player,{open="stand",stand=n}) end
  end)
 end
 return plot
end
for i=1,6 do plots[i]=makePlot(i) end
local function updateStand(s, n)
 local stand=s.plot.stands[n]
 local old=stand:FindFirstChild("Display")
 if old then old:Destroy() end
 for _, creature in ipairs(s.creatures) do
  if creature.stand == n then
   local m=Instance.new("Model"); m.Name="Display"; m.Parent=stand
   local base=stand.Position+Vector3.new(0,1,0)
   local shapes={{"Chest",Vector3.new(2.5,3,1.5),Vector3.new(0,2,0)}, {"Head",Vector3.new(2,2,2),Vector3.new(0,4.5,0)}, {"Arms",Vector3.new(4.5,1,1),Vector3.new(0,2.5,0)}, {"Legs",Vector3.new(2,1.5,1),Vector3.new(0,0.5,0)}}
   for _,shape in ipairs(shapes) do
    local item=creature.components[shape[1]]
    part(m,shape[1],shape[2],base+shape[3],Config.Rarities[item.rarity].color)
   end
   label(stand, creature.name.."\n$"..math.floor(creature.income).."/s",7)
   -- Keep the display label in the model so it is removed with it.
   local gui=stand:FindFirstChildOfClass("BillboardGui"); if gui then gui.Adornee=stand; gui.Parent=m end
   break
  end
 end
end
local function roll(s)
 local eligible={}
 -- Choose an eligible rarity by tier weight, then an archetype within that rarity.
 for r, rarity in ipairs(Config.Rarities) do
  local list={}
  for _, entry in ipairs(Config.Catalog) do if entry.rarity==r and entry.rebirth<=s.rebirth then table.insert(list,entry) end end
  if #list>0 then table.insert(eligible,{list=list, weight=rarity.weight * (1.15 ^ (s.rebirth * (r-1)/7))}) end
 end
 local total=0; for _, tier in ipairs(eligible) do total+=tier.weight end
 local pick=rng:NextNumber(0,total)
 local tier=eligible[#eligible]
 for _, t in ipairs(eligible) do pick-=t.weight; if pick<=0 then tier=t; break end end
 local archetype=tier.list[rng:NextInteger(1,#tier.list)]
 local kind=Config.Types[rng:NextInteger(1,4)]
 return {id=HttpService:GenerateGUID(false), name=archetype.name, kind=kind, rarity=archetype.rarity, income=archetype.income, price=math.max(10,math.floor(archetype.income*5))}
end
local function findById(items, id)
 if type(id) ~= "string" or #id>64 then return nil end
 for i, item in ipairs(items) do if item.id==id then return i,item end end
 return nil
end
remote.OnServerEvent:Connect(function(player, action, value)
 local s=states[player]
 if not s or type(action)~="string" then return end
 local now=os.clock()
 if now-(s.lastAction or 0)<0.15 then return end
 s.lastAction=now
 if action=="roll" and nearby(player,s.plot.lever) then
  if now-(s.lastRoll or 0)<0.35 then return end
  s.lastRoll=now; s.rolls={}
  for _=1,s.slots do table.insert(s.rolls,roll(s)) end
  send(player,"Choose parts to buy, or roll again.")
 elseif action=="buy" and nearby(player,s.plot.lever) then
  local i,item=findById(s.rolls,value)
  if i and s.cash>=item.price and #s.parts<100 then
   s.cash-=item.price; table.insert(s.parts,item); table.remove(s.rolls,i); send(player,"Part purchased!")
  else send(player,"Cannot buy: check cash and inventory space.") end
 elseif action=="upgradeSlots" then
  local cost=Config.SlotCosts[s.slots+1]
  if cost and s.cash>=cost then s.cash-=cost; s.slots+=1; send(player,"Slot unlocked!") else send(player,"Not enough cash, or all slots unlocked.") end
 elseif action=="assemble" and nearby(player,s.plot.pod) and type(value)=="table" then
  local components={}; local seen={}; local sum=0; local highest=0; local dominant=nil
  for _,kind in ipairs(Config.Types) do
   local id=value[kind]; local _,item=findById(s.parts,id)
   if not item or item.kind~=kind or seen[id] then send(player,"Select one owned part of each type."); return end
   seen[id]=true; components[kind]=item; sum+=item.income
   if item.rarity>highest then highest=item.rarity; dominant=item.name end
  end
  for i=#s.parts,1,-1 do if seen[s.parts[i].id] then table.remove(s.parts,i) end end
  table.insert(s.creatures,{id=HttpService:GenerateGUID(false),name=dominant.." Abomination",components=components,income=sum*Config.Rarities[highest].multiplier*0.4,level=1,stand=0})
  send(player,"Assembled! Take it to a stand.")
 elseif action=="stand" and type(value)=="table" then
  local n=value.stand
  if type(n)~="number" or n~=n or n%1~=0 or n<1 or n>12 or not nearby(player,s.plot.stands[n]) then return end
  local _,creature=findById(s.creatures,value.id)
  if not creature then return end
  if creature.stand==n then creature.stand=0
  elseif creature.stand==0 then
   for _, c in ipairs(s.creatures) do if c.stand==n then send(player,"This stand is occupied."); return end end
   creature.stand=n
  else send(player,"Remove this creature from its current stand first."); return end
  updateStand(s,n); send(player,"Stand updated.")
 elseif action=="collect" then
  s.cash+=math.floor(s.pending); s.pending%=1; send(player,"Cash collected!")
 end
end)
local function join(player)
 local plot=nil
 for _,p in ipairs(plots) do if not p.owner then plot=p; break end end
 if not plot then player:Kick("This server has no free plots. Please join another server."); return end
 plot.owner=player; plot.sign.Text=player.DisplayName.."'s plot"
 states[player]={cash=200,pending=0,slots=1,rebirth=0,parts={},creatures={},rolls={},plot=plot}
 player.CharacterAdded:Connect(function(character)
  local root=character:WaitForChild("HumanoidRootPart",10)
  if root and states[player] then character:PivotTo(CFrame.new(plot.lever.Position+Vector3.new(0,4,10))) end
 end)
 send(player,"Welcome! Start by rolling at your station.")
end
Players.PlayerAdded:Connect(join)
Players.PlayerRemoving:Connect(function(player)
 local s=states[player]; if not s then return end
 for n=1,12 do
  for _,c in ipairs(s.creatures) do if c.stand==n then c.stand=0 end end
  updateStand(s,n)
 end
 s.plot.owner=nil; s.plot.sign.Text="Unclaimed plot"; s.plot.bankLabel.Text="Bank: $0"; states[player]=nil
end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(join,player) end
task.spawn(function()
 while true do
  task.wait(1)
  for player,s in pairs(states) do
   for _,creature in ipairs(s.creatures) do if creature.stand>0 then s.pending+=creature.income end end
   s.plot.bankLabel.Text="Bank: $"..math.floor(s.pending)
   remote:FireClient(player, {tick=true, cash=s.cash, pending=math.floor(s.pending)})
  end
 end
end)
