--!strict
-- Server-authoritative prototype and progression.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local DataService = require(script.Parent:WaitForChild("Services"):WaitForChild("DataService"))
local Visuals = require(script.Parent:WaitForChild("Services"):WaitForChild("Visuals"))
local Progression = require(script.Parent.Services.Progression)
local LiveEvents = require(script.Parent.Services.LiveEvents)
local PassService = require(script.Parent.Services.PassService)
local Inventory = require(script.Parent.Services.Inventory)
local Tutorial = require(script.Parent.Services.Tutorial)
local Titles = require(script.Parent.Services.Titles)
local Fusion = require(script.Parent.Services.Fusion)
local PlotEconomy = require(script.Parent.Services.PlotEconomy)
local SessionGifts = require(script.Parent.Services.SessionGifts)
local AdminService = require(script.Parent.Services.AdminService)
local RewardExtras = require(script.Parent.Services.RewardExtras)
local QuestRewards = require(script.Parent.Services.QuestRewards)
local MysteryBoxes = require(script.Parent.Services.MysteryBoxes)
local Season = require(script.Parent.Services.Season)
local AutoCollector = require(script.Parent.Services.AutoCollector)
local AutoRoll = require(script.Parent.Services.AutoRoll)
local Blueprints = require(script.Parent.Services.Blueprints)
local Crafting = require(script.Parent.Services.Crafting)
local ShutdownGate = require(script.Parent.Services.ShutdownGate)
local RollOdds = require(script.Parent.Services.RollOdds)
local Rebirth = require(script.Parent.Services.Rebirth)
local LevelUpgrade = require(script.Parent.Services.LevelUpgrade)
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local SeasonRewards = require(ReplicatedStorage.Shared:WaitForChild("SeasonRewards"))
local remote = Instance.new("RemoteEvent")
remote.Name = "GameAction"
remote.Parent = ReplicatedStorage
local rng = Random.new()
local states = {}
local joinGate = ShutdownGate.new()
local plots = {}
local adminEvent=nil
local function currentEvent()
 local event=LiveEvents.at(os.time())
 if adminEvent and os.clock()>=adminEvent.expires then adminEvent=nil end
 if adminEvent then LiveEvents.applyOverride(event,adminEvent.name) end
 return event
end
local function activeEvents()
 local event=currentEvent()
 return event.frenzy,event.eclipse,event.sigma,event.storm,event.weekend
end
local function eventText()
 local text=LiveEvents.text(LiveEvents.at(os.time()))
 if adminEvent and os.clock()<adminEvent.expires then text..=" | Admin "..adminEvent.name.." "..math.ceil(adminEvent.expires-os.clock()).."s" end
 return text
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
local hubPortal=part(world,"Trading hub portal",Vector3.new(10,10,2),Vector3.new(0,5,-22),Color3.fromRGB(150,65,255),Enum.Material.Neon)
label(hubPortal,"TRADING HUB",7)
local forge=part(world,"Fusion forge",Vector3.new(7,4,7),Vector3.new(0,2.5,20),Color3.fromRGB(255,170,40),Enum.Material.Metal)
label(forge,"FUSION FORGE\nREBIRTH 15+",5)
local cashBoard=part(world,"Server cash leaderboard",Vector3.new(13,9,1),Vector3.new(-22,5,10),Color3.fromRGB(25,35,75))
local rebirthBoard=part(world,"Server rebirth leaderboard",Vector3.new(13,9,1),Vector3.new(22,5,10),Color3.fromRGB(70,30,105))
local cashCaption=label(cashBoard,"SERVER CASH",6); cashCaption.Parent.Size=UDim2.fromOffset(250,180)
local rebirthCaption=label(rebirthBoard,"SERVER REBIRTHS",6); rebirthCaption.Parent.Size=UDim2.fromOffset(250,180)

local function partCapacity(s)
 return PassService.capacity(s.passes,s.backpackUpgrades,SeasonRewards.bonusSlots(s.season.claimed))
end
local settleIncome
local function incomeSummary(s,rates,event)
 return PlotEconomy.summary(rates or PlotEconomy.rates(s.creatures,Config.Income),event or currentEvent(),PassService.owned(s.passes,"VIP"),s.extras.sigmaStatue)
end
local function send(player, message, effect)
 local s = states[player]
 if not s then return end
 Progression.refresh(s.progress,os.time())
 local stats=player:FindFirstChild("leaderstats")
 if stats then stats.Cash.Value=s.cash; stats.Rebirths.Value=s.rebirth end
 remote:FireClient(player, {cash=s.cash, pending=math.floor(s.pending), slots=s.slots, standsUnlocked=s.standsUnlocked, plotIndex=s.plot.index, tutorial=s.tutorial, theme=s.theme, isAdmin=AdminService.authorized(Config.AdminUserIds,player.UserId), passes=s.passes, partCapacity=partCapacity(s), offlineReport=s.offlineReport, backpackUpgrades=s.backpackUpgrades, rareBlueprints=s.rareBlueprints, autoRolling=s.autoRolling, autoCollect=s.autoCollector.enabled, income=incomeSummary(s), autoRun=s.autoRun, rebirth=s.rebirth, target=Config.RebirthTarget(s.rebirth), rebirthCost=Config.RebirthCost(s.rebirth), event=eventText(), eventFlags=currentEvent(), serverDay=Progression.day(os.time()), giftElapsed=math.floor(os.clock()-s.sessionStarted), giftClaims=s.giftClaims, luckRemaining=math.max(0,s.luckUntil-os.time()), tripleLuckRemaining=math.max(0,s.tripleLuckUntil-os.time()), extras=s.extras, season=s.season, rollRemaining=math.max(0,math.ceil((s.offerExpires or 0)-os.clock())), progress=s.progress, quests=Progression.quests(s.progress), parts=s.parts, creatures=s.creatures, rolls=s.rolls, message=message or "", effect=effect})
end
local function owned(player, plot)
 return not joinGate.closed and plot.owner == player and states[player] ~= nil and DataService.isHealthy(player.UserId)
end
local function nearby(player, p)
 local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 return root and (root.Position - p.Position).Magnitude <= 20
end
prompt(forge,"Open fusion forge").Triggered:Connect(function(player)
 local s=states[player]
 if s and not joinGate.closed and DataService.isHealthy(player.UserId) and nearby(player,forge) then remote:FireClient(player,{open="forge"}) end
end)
local function collect(player,s)
 if settleIncome then settleIncome(s,os.clock(),currentEvent()) end
 local amount=math.floor(s.pending)
 if amount<=0 then send(player,"No cash ready to collect yet."); return end
 s.cash+=amount; s.pending-=amount
 Progression.increment(s.progress,"collected",amount,os.time())
 local completed=Tutorial.advance(s.tutorial,"collect",s.parts)
 if completed then s.cash+=Tutorial.Bonus end
 if os.clock()-(s.lastCollectEffect or -10)>1 then s.lastCollectEffect=os.clock(); Visuals.collect(s.plot) end
 send(player,"Collected $"..amount.."!"..(completed and " Tutorial complete: +$"..Tutorial.Bonus.."!" or ""),"collect")
end
local function goToHub(player)
 local s=states[player]
 if not s or joinGate.closed or not DataService.isHealthy(player.UserId) or not nearby(player,hubPortal) then return end
 local id=Config.PlaceIds.TradingHub
 if type(id)~="number" or id<=0 or id%1~=0 then send(player,"Trading hub is not configured yet. See the setup guide."); return end
 if os.clock()-(s.lastPortal or -20)<10 then return end
 s.lastPortal=os.clock()
 local ok,err=pcall(function() TeleportService:TeleportAsync(id,{player}) end)
 if not ok then warn("Trading hub teleport failed: "..tostring(err)); send(player,"Could not travel to the hub. Please try again.") end
end
prompt(hubPortal,"Visit trading hub").Triggered:Connect(goToHub)
TeleportService.TeleportInitFailed:Connect(function(player, _result, message, placeId)
 if placeId==Config.PlaceIds.TradingHub and states[player] then warn("Teleport init failed: "..message); send(player,"Travel failed. Please try again.") end
end)

local function makePlot(i)
 local angle = (i-1)*math.pi*2/6
 local center = Vector3.new(math.cos(angle)*105, 0, math.sin(angle)*105)
 local folder = Instance.new("Folder")
 folder.Name = "Plot"..i
 folder.Parent = world
 local floor=part(folder,"Plot",Vector3.new(54,1,54),center,Color3.fromRGB(59,120,190))
 local path = part(folder,"Path",Vector3.new(12,0.4,70),center/2+Vector3.new(0,0.25,0),Color3.fromRGB(220,213,180))
 path.CFrame = CFrame.lookAt(path.Position, center)
 local sign = part(folder,"Sign",Vector3.new(5,5,1),center+Vector3.new(0,3,22),Color3.fromRGB(255,192,65))
 local plot = {index=i, floor=floor, owner=nil, sign=label(sign,"Unclaimed plot",4), stands={}}
 plot.lever = part(folder,"Roll station",Vector3.new(8,5,5),center+Vector3.new(-18,3,-16),Color3.fromRGB(250,91,105))
 plot.pod = part(folder,"Assembly pod",Vector3.new(8,7,5),center+Vector3.new(0,4,-16),Color3.fromRGB(124,75,225))
 plot.atm = part(folder,"Cash ATM",Vector3.new(8,4,5),center+Vector3.new(18,2.5,-16),Color3.fromRGB(48,205,115))
 label(plot.lever,"ROLL",4); label(plot.pod,"ASSEMBLE",5); plot.bankLabel = label(plot.atm,"Bank: $0",4)
 prompt(plot.lever,"Roll").Triggered:Connect(function(player)
  if owned(player,plot) and nearby(player,plot.lever) then remote:FireClient(player,{open="roll"}) end
 end)
 prompt(plot.pod,"Open assembly").Triggered:Connect(function(player)
  if owned(player,plot) and nearby(player,plot.pod) then remote:FireClient(player,{open="assemble"}) end
 end)
 prompt(plot.atm,"Collect").Triggered:Connect(function(player)
  if owned(player,plot) and nearby(player,plot.atm) then collect(player,states[player]) end
 end)
 local pad=part(folder,"Collect pad",Vector3.new(7,0.5,4),plot.atm.Position+Vector3.new(0,-1.7,5),Color3.fromRGB(80,255,140),Enum.Material.Neon)
 pad.Touched:Connect(function(hit)
  local player=Players:GetPlayerFromCharacter(hit.Parent)
  if not player or not owned(player,plot) or not nearby(player,pad) then return end
  local s=states[player]
  if os.clock()-(s.lastPadTouch or -10)<1 then return end
  s.lastPadTouch=os.clock()
  if s.pending>=1 then collect(player,s) end
 end)
 for n=1,24 do
  local x = ((n-1)%6)*8-20
  local z = math.floor((n-1)/6)*8-5
  local stand=part(folder,"Stand "..n,Vector3.new(6,1,6),center+Vector3.new(x,1,z),Color3.fromRGB(255,205,75))
  plot.stands[n]=stand
  prompt(stand,"Place / remove").Triggered:Connect(function(player)
   if owned(player,plot) and nearby(player,stand) then
    if n <= states[player].standsUnlocked then remote:FireClient(player,{open="stand",stand=n}) else send(player,"This stand is locked. Upgrade stands from the menu.") end
   end
  end)
 end
 Visuals.decoratePlot(plot,folder,center)
 return plot
end
for i=1,6 do plots[i]=makePlot(i) end
local function updateStand(s, n, rates)
 local stand=s.plot.stands[n]
 local old=stand:FindFirstChild("Display")
 if not rates then
  rates=PlotEconomy.rates(s.creatures,Config.Income)
  if s.extras.sigmaStatue then for key,value in pairs(rates) do rates[key]=value*1.5 end end
 end
 stand.Color = n<=s.standsUnlocked and Color3.fromRGB(255,205,75) or Color3.fromRGB(90,95,110)
 local rim=stand:FindFirstChild("Neon rim")
 if rim then rim.Color=n<=s.standsUnlocked and Color3.fromRGB(255,238,135) or Color3.fromRGB(70,75,90) end
 local selected=nil
 for _,creature in ipairs(s.creatures) do if creature.stand==n then selected=creature; break end end
 if old and selected and old:GetAttribute("CreatureId")==selected.id and old:GetAttribute("VisualTier")==Visuals.levelTier(selected.level) then
  local caption=old:FindFirstChild("TextLabel",true)
  if caption then caption.Text=(selected.ascended and "ASCENDED " or "")..selected.name.." ["..Config.Rarities[Visuals.compositeRarity(selected)].name.."] Lv."..selected.level.."\n$"..math.floor(rates[n] or 0).."/s" end
  return
 end
 if old then old:Destroy() end
 if not selected then return end
 local model=Instance.new("Model"); model.Name="Display"; model:SetAttribute("CreatureId",selected.id); model:SetAttribute("VisualTier",Visuals.levelTier(selected.level)); model.Parent=stand
 Visuals.makeCreature(model,stand.Position+Vector3.new(0,1,0),selected)
 local rarity=Config.Rarities[Visuals.compositeRarity(selected)]
 local caption=label(stand,(selected.ascended and "ASCENDED " or "")..selected.name.." ["..rarity.name.."] Lv."..selected.level.."\n$"..math.floor(rates[n] or 0).."/s",9)
 caption.TextColor3=rarity.color; caption.TextStrokeTransparency=0
 caption.Parent.Adornee=stand; caption.Parent.Parent=model
 CollectionService:AddTag(model,"BrainrotDisplay")
end
local function refreshStands(s)
 local rates=PlotEconomy.rates(s.creatures,Config.Income)
 if s.extras.sigmaStatue then for key,value in pairs(rates) do rates[key]=value*1.5 end end
 for n=1,24 do updateStand(s,n,rates) end
end
-- Settle before changing stands, levels or persistent multipliers. The prior
-- observed event applies to the elapsed interval; transitions are approximate
-- to the next checkpoint, since event boundaries can fall between ticks.
settleIncome=function(s,now,event)
 local elapsed=math.max(0,now-s.lastIncomeClock)
 s.lastIncomeClock=now
 local earned,leveled=PlotEconomy.advance(s.creatures,elapsed,Config.Income,s.incomeEvent,PassService.owned(s.passes,"VIP"),s.extras.sigmaStatue)
 s.incomeEvent=event
 s.pending+=earned
 if leveled then
  s.incomeDirty=true
  if not joinGate.closed and states[s.player]==s then refreshStands(s) end
 end
end
local function rollContext(s)
 local now=os.time(); local event=currentEvent()
 local modifiers={frenzy=event.frenzy,weekend=event.weekend,luckPass=PassService.owned(s.passes,"Luck"),
  luck2=s.luckUntil>now,luck3=s.tripleLuckUntil>now,goldenLever=s.extras.goldenLever}
 local tiers,total,factor=RollOdds.build(Config.Rarities,Config.Catalog,s.rebirth,modifiers)
 return tiers,total,factor,event,modifiers,now
end
local function roll(s)
 local eligible,total,_,event=rollContext(s)
 local pick=rng:NextNumber(0,total)
 local tier=eligible[#eligible]
 for _, t in ipairs(eligible) do pick-=t.weight; if pick<=0 then tier=t; break end end
 local archetype=tier.list[rng:NextInteger(1,#tier.list)]
 local kind=Config.Types[rng:NextInteger(1,4)]
 local mutationRoll=rng:NextInteger(1,10000)
 local mutation=Config.Mutations[1]
 for _,m in ipairs(Config.Mutations) do mutationRoll-=m.weight; if mutationRoll<=0 then mutation=m; break end end
 return {rarityChance=tier.weight/total, mutation=mutation.name, mutationMultiplier=mutation.multiplier,id=HttpService:GenerateGUID(false), name=archetype.name, kind=kind, rarity=archetype.rarity, income=archetype.income, price=math.max(1,math.floor(math.max(10,archetype.income*5)*(event.eclipse and 0.5 or 1)))}
end
local lastAnnouncement=-10
local function rollBatch(s)
 s.rolls={}
 s.offerExpires=os.clock()+60
 for _=1,s.slots do table.insert(s.rolls,roll(s)) end
 Progression.increment(s.progress,"rolls",s.slots,os.time())
 Season.recordRolls(s.season,s.slots)
 Tutorial.advance(s.tutorial,"roll",s.parts)
 local best=nil
 for _,item in ipairs(s.rolls) do if item.rarity>=6 and (not best or item.rarity>best.rarity) then best=item end end
 if best and os.clock()-lastAnnouncement>=5 then
  lastAnnouncement=os.clock()
  remote:FireAllClients({announcement=s.player.DisplayName.." rolled "..best.name.." "..best.kind.." ["..Config.Rarities[best.rarity].name.."]! (offer, not a purchase)"})
 end
 Visuals.showRolls(s.plot,s.rolls,s.slots); Visuals.pull(s.plot)
 remote:FireClient(s.player,{effectOnly="roll"})
end
local function makeGiftPart(rarity)
 local eligible={}
 for _,entry in ipairs(Config.Catalog) do if entry.rarity==rarity then table.insert(eligible,entry) end end
 if #eligible==0 then return nil end
 local entry=eligible[rng:NextInteger(1,#eligible)]
 return {id=HttpService:GenerateGUID(false),name=entry.name,kind=Config.Types[rng:NextInteger(1,#Config.Types)],rarity=entry.rarity,income=entry.income,price=math.max(10,math.floor(entry.income*5)),mutation="Standard",mutationMultiplier=1}
end
local function chooseGiftRarity(minRarity)
 local choices={}; local total=0
 for rarity=minRarity,#Config.Rarities do
  local available=false
  for _,entry in ipairs(Config.Catalog) do if entry.rarity==rarity then available=true; break end end
  if available then total+=Config.Rarities[rarity].weight; table.insert(choices,rarity) end
 end
 if total<=0 then return nil end
 local pick=rng:NextNumber(0,total)
 for _,rarity in ipairs(choices) do pick-=Config.Rarities[rarity].weight; if pick<=0 then return rarity end end
 return choices[#choices]
end
local function expireOffers(s,now)
 if SessionGifts.offersExpired(s.offerExpires,now,#s.rolls) then
  s.rolls={}; s.offerExpires=0; Visuals.showRolls(s.plot,s.rolls,s.slots); return true
 end
 return false
end
local function findById(items, id)
 if type(id) ~= "string" or #id>64 then return nil end
 for i, item in ipairs(items) do if item.id==id then return i,item end end
 return nil
end
local function refreshPass(player,s,key)
 if s.passes[key]=="disabled" or s.passes[key]=="invalid" then return end
 local now=os.clock()
 if now-(s.passLastRefresh[key] or -20)<10 then return end
 s.passLastRefresh[key]=now
 s.passVersion[key]=(s.passVersion[key] or 0)+1
 local version=s.passVersion[key]
 task.spawn(function()
  local result=PassService.lookup(player.UserId,Config.GamePasses[key])
  if joinGate.closed or states[player]~=s or s.passVersion[key]~=version then return end
  if key=="VIP" then settleIncome(s,os.clock(),currentEvent()) end
  -- A failed service lookup must never erase an ownership already confirmed this session.
  if s.passes[key]~="owned" then s.passes[key]=result end
  if key=="KeepSlots" and result=="owned" then s.keepSlotsEntitled=true end
  if result=="unknown" then warn("Unable to verify gamepass "..key.." for "..player.UserId) end
  send(player)
 end)
end
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
 local s=states[player]
 if not s or joinGate.closed or not purchased then return end
 for _,key in ipairs(Config.PassOrder) do
  if Config.GamePasses[key]==passId and s.passes[key]~="disabled" and s.passes[key]~="invalid" then
   -- Roblox's server-side purchase-finished event is authoritative; invalidate stale queries.
   if key=="VIP" then settleIncome(s,os.clock(),currentEvent()) end
   s.passVersion[key]=(s.passVersion[key] or 0)+1; s.passes[key]="owned"
   if key=="KeepSlots" then s.keepSlotsEntitled=true end
   send(player,"Gamepass unlocked: "..key.."!"); return
  end
 end
end)
local function adminSnapshot(admin,targetId)
 if not AdminService.authorized(Config.AdminUserIds,admin.UserId) then return end
 local players={}
 for player,s in pairs(states) do
  table.insert(players,{id=player.UserId,name=player.DisplayName,cash=s.cash,rebirth=s.rebirth,slots=s.slots,partCount=#s.parts,creatureCount=#s.creatures})
 end
 table.sort(players,function(a,b) return a.id<b.id end)
 local inspected=nil
 local parsed=AdminService.plan(Config.AdminUserIds,admin.UserId,{command="inspect",target=targetId},#Config.Catalog)
 if parsed then
  local target=Players:GetPlayerByUserId(parsed.target)
  local s=target and states[target]
  if s then
   local parts={}; local creatures={}
   for _,item in ipairs(s.parts) do table.insert(parts,(item.mutation or "Standard").." "..item.name.." "..item.kind) end
   for _,item in ipairs(s.creatures) do table.insert(creatures,(item.ascended and "ASCENDED " or "")..item.name.." Lv."..item.level.." Stand "..item.stand) end
   inspected={id=target.UserId,name=target.DisplayName,cash=s.cash,rebirth=s.rebirth,slots=s.slots,parts=parts,creatures=creatures}
  end
 end
 remote:FireClient(admin,{adminSnapshot=true,players=players,inspected=inspected})
end
local function runAdmin(admin,payload)
 local plan,reason=AdminService.plan(Config.AdminUserIds,admin.UserId,payload,#Config.Catalog)
 if not plan then send(admin,reason); return end
 if plan.command=="event" then
  local at=os.clock(); local before=currentEvent()
  for player,session in pairs(states) do if DataService.isHealthy(player.UserId) then settleIncome(session,at,before) end end
  adminEvent={name=plan.event,expires=os.clock()+120}
  local after=currentEvent(); for _,session in pairs(states) do session.incomeEvent=after end
  warn("[Admin] "..admin.UserId.." triggered "..plan.event.." for 120 seconds")
  send(admin,"Server event started for 120 seconds."); adminSnapshot(admin); return
 end
 local target=Players:GetPlayerByUserId(plan.target)
 local ts=target and states[target]
 if not ts or not DataService.isHealthy(target.UserId) then send(admin,"Target is not online with a healthy profile."); return end
 if plan.command=="grantCash" then ts.cash+=plan.amount
 elseif plan.command=="setCash" then ts.cash=plan.amount
 elseif plan.command=="setRebirth" then
  ts.rebirth=plan.amount; ts.autoRolling=false; ts.rolls={}; ts.offerExpires=0
  if ts.rebirth<AutoCollector.RequiredRebirth then
   AutoCollector.set(ts.autoCollector,false,ts.rebirth,os.clock()); Visuals.autoCollector(ts.plot,false)
  end
  for _,theme in ipairs(Config.Themes) do
   if theme.id==ts.theme and ts.rebirth<theme.rebirth then ts.theme="Classic"; Visuals.applyTheme(ts.plot,Config.Themes[1]); break end
  end
  Titles.apply(target.Character,ts.rebirth,ts.extras); Visuals.showRolls(ts.plot,ts.rolls,ts.slots)
 elseif plan.command=="grantPart" then
  if #ts.parts>=partCapacity(ts) then send(admin,"Target's part inventory is full."); return end
  local entry=Config.Catalog[plan.index]
  table.insert(ts.parts,{id=HttpService:GenerateGUID(false),name=entry.name,kind=plan.kind,rarity=entry.rarity,income=entry.income,price=math.max(10,math.floor(entry.income*5)),mutation="Standard",mutationMultiplier=1})
 elseif plan.command~="kick" then send(admin,"Unsupported admin action."); return end
 warn("[Admin] "..admin.UserId.." used "..plan.command.." on "..target.UserId..(plan.amount and (" amount="..plan.amount) or "")..(plan.index and (" catalog="..plan.index.." kind="..plan.kind) or ""))
 if plan.command=="kick" then target:Kick("Removed from this server by an administrator.")
 else send(target,"An administrator updated your profile in this server.") end
 if states[admin] then send(admin,"Admin action completed."); adminSnapshot(admin,plan.target) end
end
remote.OnServerEvent:Connect(function(player, action, value)
 local s=states[player]
 if not s or joinGate.closed or type(action)~="string" or #action>40 then return end
 if not DataService.isHealthy(player.UserId) then player:Kick("Your data session could not be renewed. Please rejoin."); return end
 local now=os.clock()
 if expireOffers(s,now) then
  send(player,"Unpurchased roll offers expired after 60 seconds.")
  if action=="buy" or action=="buyWithVoucher" or action=="skip" then return end
 end
 if now<(s.blockUntil or 0) then return end
 if now-(s.windowStart or 0)>=1 then s.windowStart=now; s.requestCount=0 end
 s.requestCount=(s.requestCount or 0)+1
 if s.requestCount>15 then s.blockUntil=now+5; return end
 if now-(s.lastAction or 0)<0.15 then return end
 s.lastAction=now
 settleIncome(s,now,currentEvent())
 if action=="adminOpen" then
  if AdminService.authorized(Config.AdminUserIds,player.UserId) then adminSnapshot(player,value) end
 elseif action=="adminAction" then
  if AdminService.authorized(Config.AdminUserIds,player.UserId) then runAdmin(player,value) end
 elseif action=="sync" then send(player)
 elseif action=="requestEvents" then
  local epoch=os.time(); local schedule=LiveEvents.forecast(epoch)
  currentEvent() -- clear an expired override before reporting it
  if adminEvent then schedule.override={name=adminEvent.name,remaining=math.max(0,math.ceil(adminEvent.expires-os.clock()))} end
  remote:FireClient(player,{eventSchedule=true,schedule=schedule})
 elseif action=="requestOdds" then
  local tiers,total,factor,event,modifiers,now=rollContext(s)
  remote:FireClient(player,{oddsSnapshot=true,odds={tiers=RollOdds.disclose(tiers,total,#Config.Rarities),rebirth=s.rebirth,nonCommonFactor=factor,modifiers=modifiers,eclipse=event.eclipse==true,at=now}})
 elseif action=="roll" and nearby(player,s.plot.lever) then
  if now-(s.lastRoll or 0)<0.35 then return end
  s.lastRoll=now; s.autoRolling=false; rollBatch(s)
  send(player,"Choose parts to buy, or roll again.")
 elseif (action=="buy" or action=="buyWithVoucher") and nearby(player,s.plot.lever) then
  if s.autoRolling then send(player,"Stop auto-roll before buying manually."); return end
  local i,item=findById(s.rolls,value)
  local voucher=action=="buyWithVoucher"
  if i and #s.parts<partCapacity(s) and ((voucher and s.extras.rollVouchers>0) or (not voucher and s.cash>=item.price)) then
   if voucher then s.extras.rollVouchers-=1 else s.cash-=item.price end
   table.insert(s.parts,item); Tutorial.advance(s.tutorial,"buy",s.parts); table.remove(s.rolls,i)
   if #s.rolls==0 then s.offerExpires=0 end
   Visuals.showRolls(s.plot,s.rolls,s.slots); send(player,voucher and "Part claimed with a voucher!" or "Part purchased!",item.rarity>=4 and "rare" or "buy")
  else send(player,"Cannot buy: check cash, vouchers and inventory space.") end
 elseif action=="buyPass" and type(value)=="string" and #value<=30 then
  local status=s.passes[value]
  if status=="notOwned" then
   if now-(s.lastPassPrompt or -20)<8 then send(player,"Please wait before opening another purchase prompt."); return end
   s.lastPassPrompt=now
   local ok,err=PassService.prompt(player,Config.GamePasses[value])
   if not ok then warn("Gamepass prompt failed: "..tostring(err)); send(player,"Purchase prompt unavailable. Please try again.") end
  elseif status=="owned" then send(player,"You already own that gamepass.")
  elseif status=="unknown" then refreshPass(player,s,value); send(player,"Checking ownership. Please try again shortly.")
  else send(player,"This gamepass is not configured correctly.") end
 elseif action=="refreshPasses" then
  for _,key in ipairs(Config.PassOrder) do refreshPass(player,s,key) end
  send(player,"Checking gamepass ownership...")
 elseif action=="claimGift" then
  local gift,reason=SessionGifts.find(Config.SessionGifts,s.giftClaims,value,os.clock()-s.sessionStarted)
  if not gift then send(player,reason); return end
  if gift.kind=="cash" then s.cash+=gift.value
  elseif gift.kind=="luck" then s.luckUntil=math.max(s.luckUntil,os.time())+gift.duration
  elseif gift.kind=="vouchers" then
   if s.extras.rollVouchers+gift.value>RewardExtras.MaxVouchers then send(player,"Use some vouchers before claiming."); return end
   s.extras.rollVouchers+=gift.value
  elseif gift.kind=="blueprint" then
   if s.rareBlueprints>=Blueprints.MaxOwned then send(player,"Use a blueprint before claiming another."); return end
   s.rareBlueprints+=1
  elseif gift.kind=="crown" then
   if s.extras.ohioCrown then s.cash+=100000 else s.extras.ohioCrown=true; Titles.apply(player.Character,s.rebirth,s.extras) end
  elseif gift.kind=="part" or gift.kind=="partPlus" then
   if #s.parts>=partCapacity(s) then send(player,"Free inventory space before claiming this gift."); return end
   local rarity=gift.kind=="part" and gift.rarity or chooseGiftRarity(gift.minRarity)
   local item=rarity and makeGiftPart(rarity)
   if not item then send(player,"This gift is unavailable. Please try again later."); return end
   table.insert(s.parts,item)
  else send(player,"This gift is not implemented."); return end
  s.giftClaims[gift.id]=true
  send(player,"Session gift claimed: "..gift.label..(gift.kind=="crown" and " (or $100,000 if already owned)" or "").."!")
 elseif action=="dailyReward" then
  local epoch=os.time(); local day=Progression.nextDaily(s.progress,epoch)
  if not day then send(player,"Daily reward already claimed. Come back after UTC midnight."); return end
  local reward,reason=RewardExtras.daily(s.extras,day)
  if not reward then send(player,reason); return end
  Progression.claimDaily(s.progress,epoch); s.cash+=reward.cash
  Visuals.applyRewardCosmetics(s.plot,s.extras); refreshStands(s)
  send(player,"Day "..day.." reward: "..reward.message.."!")
 elseif action=="useLuckPotion" then
  if s.extras.luckPotions<1 then send(player,"No 3x luck potions available."); return end
  s.extras.luckPotions-=1; s.tripleLuckUntil=math.max(s.tripleLuckUntil,os.time())+900
  send(player,"3x luck potion activated for 15 minutes.")
 elseif action=="useDoubleLuckPotion" then
  if s.extras.doubleLuckPotions<1 then send(player,"No 2x luck potions available."); return end
  s.extras.doubleLuckPotions-=1; s.luckUntil=math.max(s.luckUntil,os.time())+600
  send(player,"2x luck potion activated for 10 minutes.")
 elseif action=="openUncommonBox" then
  local item,reason=MysteryBoxes.open(s.extras,s.parts,s.creatures,s.rolls,partCapacity(s),function() return makeGiftPart(2) end)
  if not item then send(player,reason); return end
  Tutorial.advance(s.tutorial,"sync",s.parts)
  send(player,"Uncommon Mystery Box: "..item.name.." "..item.kind.."!")
 elseif action=="openStandardBox" then
  local item,reason=MysteryBoxes.openStandard(s.extras,s.parts,s.creatures,s.rolls,partCapacity(s),function()
   return makeGiftPart(MysteryBoxes.standardRarity(rng:NextInteger(1,100)))
  end)
  if not item then send(player,reason); return end
  Tutorial.advance(s.tutorial,"sync",s.parts)
  send(player,"Standard Roll Crate: "..item.name.." "..item.kind.."!")
 elseif action=="claimQuest" then
  if type(value)~="table" then send(player,"Review the current daily objectives first."); return end
  local quest,reason=QuestRewards.claimReviewed(s.progress,s.extras,value.key,value.day,os.time())
  if not quest then send(player,reason); return end
  s.cash+=quest.reward; Season.addXP(s.season,quest.xp)
  send(player,"Quest completed: "..quest.rewardLabel.." and "..quest.xp.." season XP!")
 elseif action=="claimSeason" then
  local reward,reason=Season.claim(s.season,s.extras,RewardExtras.MaxPotions,RewardExtras.MaxVouchers,RewardExtras.MaxBoxes)
  if not reward then send(player,reason); return end
  if reward.kind=="cash" then s.cash+=reward.amount end
  send(player,"Free season tier "..s.season.claimed..": "..reward.label.."!")
 elseif action=="claimRepeatRolls" then
  local success,reason=Season.claimRepeat(s.season,s.extras,RewardExtras.MaxVouchers)
  send(player,success and "Repeatable roll objective: one free-part voucher!" or reason)
 elseif action=="teleport" then
  local destinations={lever=s.plot.lever,pod=s.plot.pod,atm=s.plot.atm,portal=hubPortal,forge=forge}
  local destination=type(value)=="string" and destinations[value] or nil
  if destination and now-(s.lastTeleport or -10)>=3 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
   s.lastTeleport=now; player.Character:PivotTo(CFrame.new(destination.Position+Vector3.new(0,4,8))); send(player,"Teleported to "..destination.Name..".")
  end
 elseif action=="skip" and nearby(player,s.plot.lever) then
  if s.autoRolling then send(player,"Stop auto-roll before skipping manually."); return end
  local i=findById(s.rolls,value)
  if i then table.remove(s.rolls,i); if #s.rolls==0 then s.offerExpires=0 end; Visuals.showRolls(s.plot,s.rolls,s.slots); send(player,"Offer skipped.") end
 elseif action=="discardOffers" and nearby(player,s.plot.lever) then
  if s.autoRolling then send(player,"Stop auto-roll before discarding offers."); return end
  if #s.rolls>0 then s.rolls={}; s.offerExpires=0; Visuals.showRolls(s.plot,s.rolls,s.slots); send(player,"All unpurchased offers discarded.") end
 elseif action=="autoRoll" then
  if value==false then s.autoRolling=false; send(player,"Auto-roll stopped.")
  elseif s.autoRolling then send(player,"Stop auto-roll before changing its settings.")
  elseif not PassService.canAuto(s.passes,s.rebirth) then send(player,"Auto-roll unlocks at rebirth 5 or with the AutoRoll pass.")
  elseif not nearby(player,s.plot.lever) then send(player,"Move closer to your roll station.")
  elseif #s.rolls>0 then send(player,"Buy, skip or discard existing offers before starting auto-roll.")
  else
   local config,reason=AutoRoll.validate(value)
   if not config then send(player,reason); return end
   s.autoRun={config=config,remaining=config.maxSpend,batches=0,bought=0,skipped=0,spent=0}
   s.autoRolling=true; s.nextAuto=now; send(player,"Auto-roll started. Stay near your station; limits apply only to automated buys.")
  end
 elseif action=="setAutoCollect" then
  local ok,reason=AutoCollector.set(s.autoCollector,value,s.rebirth,now)
  if ok then Visuals.autoCollector(s.plot,s.autoCollector.enabled); send(player,s.autoCollector.enabled and "Auto-collector enabled; it collects every 10 seconds while online." or "Auto-collector disabled.")
  else send(player,reason) end
 elseif action=="theme" and type(value)=="string" and #value<=20 then
  for _,theme in ipairs(Config.Themes) do
   if theme.id==value then
    if s.rebirth<theme.rebirth then send(player,"This theme requires rebirth "..theme.rebirth..".")
    else s.theme=theme.id; Visuals.applyTheme(s.plot,theme); send(player,"Plot theme changed to "..theme.name..".") end
    break
   end
  end
 elseif action=="upgradeStands" then
  local nextStand=s.standsUnlocked+1
  local cost=Config.StandCosts[nextStand-12]
  if not cost then send(player,"All 24 stands are unlocked.")
  elseif s.rebirth<nextStand-12 then send(player,"This stand requires rebirth "..(nextStand-12)..".")
  elseif s.cash<cost then send(player,"Not enough cash for this stand.")
  else s.cash-=cost; s.standsUnlocked=nextStand; updateStand(s,nextStand); send(player,"Stand "..nextStand.." unlocked!") end
 elseif action=="setItemLock" and type(value)=="table" then
  local items=value.category=="part" and s.parts or (value.category=="creature" and s.creatures or nil)
  if items and Inventory.setLocked(items,value.id,value.locked) then
   send(player,value.locked and "Item protected from consumption and sale." or "Item protection removed.")
  else send(player,"Invalid item or protection request.") end
 elseif action=="bulkSetItemLock" and type(value)=="table" then
  local count=Inventory.bulkSetLocked(s.parts,s.creatures,value.items,value.locked)
  if not count then send(player,"Batch protection cancelled: selection changed or was invalid.")
  else send(player,(value.locked and "Protected " or "Unprotected ")..count.." selected items.") end
 elseif action=="bulkSaleReview" and type(value)=="table" then
  local requestId=value.requestId
  if type(requestId)~="number" or requestId~=requestId or requestId%1~=0 or requestId<1 or requestId>2147483647 then return end
  s.bulkSaleQuote=nil
  local ok,token=pcall(function() return HttpService:GenerateGUID(false) end)
  local quote,reason
  if ok then quote,reason=Inventory.reviewBulkSale(s.parts,value.rarity,value.standardOnly,os.clock(),token,Config.PartSellValue)
  else reason="Could not create a bulk sale review. Try again." end
  s.bulkSaleQuote=quote
  remote:FireClient(player,{bulkSaleReview=true,requestId=requestId,quote=quote,reason=reason})
 elseif action=="cancelBulkSaleReview" then
  s.bulkSaleQuote=nil
 elseif action=="bulkSaleConfirm" then
  local count,total=Inventory.confirmBulkSale(s,value,os.clock(),Config.PartSellValue)
  if not count then send(player,total); return end
  s.cash+=total; Tutorial.reconcile(s.tutorial,s.parts); send(player,"Sold "..count.." parts for $"..total..".")
 elseif action=="sellPart" then
  local index,item=findById(s.parts,value)
  if index and Inventory.canConsume(item) then table.remove(s.parts,index); Tutorial.reconcile(s.tutorial,s.parts); local amount=Config.PartSellValue(item); s.cash+=amount; send(player,"Part sold for $"..amount..".")
  elseif index then send(player,"Unlock this part before selling.") end
 elseif action=="sellCreature" then
  local index,creature=findById(s.creatures,value)
  if index and creature.stand==0 and Inventory.canConsume(creature) then table.remove(s.creatures,index); local amount=Config.CreatureSellValue(creature); s.cash+=amount; send(player,"Creature sold for $"..amount..".")
  elseif index then send(player,creature.locked and "Unlock this creature before selling." or "Remove the creature from its stand before selling.") end
 elseif action=="upgradeBackpack" then
  local cost=Config.BackpackUpgradeCosts[s.backpackUpgrades+1]
  if not cost then send(player,"All backpack upgrades are unlocked.")
  elseif s.cash<cost then send(player,"Not enough cash for this backpack upgrade.")
  else s.cash-=cost; s.backpackUpgrades+=1; send(player,"Backpack capacity increased by five part slots.") end
 elseif action=="upgradeSlots" then
  local cost=Config.SlotCosts[s.slots+1]
  if cost and s.cash>=cost then s.cash-=cost; s.slots+=1; Visuals.showRolls(s.plot,s.rolls,s.slots); send(player,"Slot unlocked!") else send(player,"Not enough cash, or all slots unlocked.") end
 elseif action=="assemble" and nearby(player,s.plot.pod) and type(value)=="table" then
  local tutorialParts={}; for _,item in ipairs(s.parts) do table.insert(tutorialParts,item) end
  local result,reason=Crafting.execute(s.parts,s.creatures,s.rareBlueprints,value,Config.Rarities,function() return HttpService:GenerateGUID(false) end)
  if not result then send(player,reason); return end
  s.rareBlueprints=result.blueprintCount
  if result.highest>=3 then Progression.increment(s.progress,"rareCrafts",1,os.time()) end
  Season.addXP(s.season,20); Tutorial.advance(s.tutorial,"craft",tutorialParts)
  send(player,result.usedBlueprint and "Rare blueprint used: assembled with +25% base income!" or "Assembled! Take it to a stand.","craft")
 elseif action=="fusion" then
  if not nearby(player,forge) then send(player,"Move closer to the fusion forge."); return end
  local creature,costOrError=Fusion.execute(s.creatures,value,s.rebirth,s.cash,Config.FusionCost,function() return HttpService:GenerateGUID(false) end)
  if not creature then send(player,costOrError)
  else s.cash-=costOrError; send(player,"Fusion complete! Your ascended creature starts at level 1.","craft") end
 elseif action=="stand" and type(value)=="table" then
  local n=value.stand
  if type(n)~="number" or n~=n or n%1~=0 or n<1 or n>s.standsUnlocked or not nearby(player,s.plot.stands[n]) then return end
  local _,creature=findById(s.creatures,value.id)
  if not creature then return end
  if creature.stand==n then creature.stand=0
  elseif creature.stand==0 then
   for _, c in ipairs(s.creatures) do if c.stand==n then send(player,"This stand is occupied."); return end end
   creature.stand=n; Tutorial.advance(s.tutorial,"place",s.parts)
  else send(player,"Remove this creature from its current stand first."); return end
  refreshStands(s); send(player,"Stand updated.")
 elseif action=="level" then
  local creature,costOrReason=LevelUpgrade.execute(s,value,Config.LevelCost)
  if not creature then send(player,costOrReason); return end
  if creature.stand>0 then refreshStands(s) end
  send(player,"Level upgraded for $"..costOrReason.."!")
 elseif action=="rebirthReview" then
  s.rebirthQuote=nil
  local ok,token=pcall(function() return HttpService:GenerateGUID(false) end)
  if not ok then send(player,"Could not create a rebirth review. Try again."); return end
  local quote,reason=Rebirth.review(s,value,PassService.canRebirth(s.passes,s.keepSlotsEntitled),PassService.keepSlots(s.passes,s.keepSlotsEntitled),os.clock(),token,Config.RebirthTarget,Config.RebirthCost)
  if not quote then send(player,reason); return end
  s.rebirthQuote=quote; remote:FireClient(player,{rebirthQuote=quote})
 elseif action=="cancelRebirthReview" then
  s.rebirthQuote=nil; send(player,"Rebirth review cancelled.")
 elseif action=="rebirthConfirm" then
  local index,quote=Rebirth.consume(s,value,PassService.canRebirth(s.passes,s.keepSlotsEntitled),PassService.keepSlots(s.passes,s.keepSlotsEntitled),os.clock(),Config.RebirthTarget,Config.RebirthCost)
  if not index then send(player,quote); return end
  local sacrificed=table.remove(s.creatures,index)
  if sacrificed.stand>0 then refreshStands(s) end
  s.cash=0; if not quote.keepSlots then s.slots=1 end; s.rolls={}; s.offerExpires=0; s.autoRolling=false; s.rebirth+=1; Season.addXP(s.season,100); Titles.apply(player.Character,s.rebirth,s.extras); Visuals.showRolls(s.plot,s.rolls,s.slots)
  send(player,"Rebirth complete! New archetypes unlocked.")
 elseif action=="collect" then
  collect(player,s)
 end
end)
local function profile(s,closing)
 return {version=1,cash=s.cash,pending=s.pending,slots=s.slots,standsUnlocked=s.standsUnlocked,rebirth=s.rebirth,backpackUpgrades=s.backpackUpgrades,rareBlueprints=s.rareBlueprints,autoCollect=s.autoCollector.enabled,parts=s.parts,creatures=s.creatures,progress=s.progress,season=s.season,extras=s.extras,luckUntil=s.luckUntil,tripleLuckUntil=s.tripleLuckUntil,tutorial=s.tutorial,theme=s.theme,keepSlotsEntitled=s.keepSlotsEntitled,lastLogout=closing and os.time() or 0}
end
local function clearPlot(s)
 for n=1,24 do
  local display=s.plot.stands[n]:FindFirstChild("Display")
  if display then display:Destroy() end
 end
 Visuals.showRolls(s.plot,{},1); Visuals.applyTheme(s.plot,Config.Themes[1]); Visuals.applyRewardCosmetics(s.plot,RewardExtras.new()); Visuals.autoCollector(s.plot,false)
 s.plot.owner=nil; s.plot.sign.Text="Unclaimed plot"; s.plot.bankLabel.Text="Bank: $0"
end
local function joinImpl(player,context)
 local plot=nil
 for _,p in ipairs(plots) do if not p.owner then plot=p; break end end
 if not plot then player:Kick("This server has no free plots. Please join another server."); return end
 plot.owner=player; context.plot=plot; plot.sign.Text="Loading "..player.DisplayName.."..."
 local data=DataService.load(player.UserId,function(profileData)
  return Progression.applyOffline(profileData,os.time(),Config.Income,function(creatures,incomeFn)
   return PlotEconomy.total(creatures,incomeFn)*((profileData.extras and profileData.extras.sigmaStatue) and 1.5 or 1)
  end)
 end)
 if not data then
  plot.owner=nil; plot.sign.Text="Unclaimed plot"
  if player.Parent then player:Kick("Could not load your data safely. Please try again later.") end
  return
 end
 context.data=data
 if not player.Parent or joinGate.closed then
  data.lastLogout=os.time()
  if not DataService.save(player.UserId,data,true) then warn("Failed to release profile after interrupted join: "..player.UserId) end
  context.data=nil
  plot.owner=nil; plot.sign.Text="Unclaimed plot"; return
 end
 local s={player=player,passes=PassService.initial(Config.GamePasses,Config.PassOrder),passVersion={},passLastRefresh={},sessionStarted=os.clock(),lastIncomeClock=os.clock(),incomeEvent=currentEvent(),incomeDirty=false,giftClaims={},autoCollector=AutoCollector.new(data.autoCollect,data.rebirth,os.clock()),season=data.season or Season.new(),luckUntil=data.luckUntil or 0,tripleLuckUntil=data.tripleLuckUntil or 0,extras=RewardExtras.normalize(data.extras or RewardExtras.new()),offerExpires=0,keepSlotsEntitled=data.keepSlotsEntitled==true,cash=data.cash,pending=data.pending,slots=data.slots,standsUnlocked=data.standsUnlocked or 12,autoRolling=false,autoRun=nil,backpackUpgrades=data.backpackUpgrades or 0,rareBlueprints=data.rareBlueprints or 0,rebirth=data.rebirth,tutorial=data.tutorial or Tutorial.new(),theme=data.theme or "Classic",progress=data.progress or Progression.new(),parts=data.parts,creatures=data.creatures,rolls={},plot=plot}
 if (data.lastOfflineAward or 0)>0 then
  -- This is informational only: the amount was already credited atomically on acquisition.
  s.offlineReport={amount=data.lastOfflineAward,seconds=data.lastOfflineSeconds,rate=data.lastOfflineRate,capped=data.lastOfflineCapped}
 end
 states[player]=s; context.data=nil; plot.sign.Text=player.DisplayName.."'s plot"
 for _,key in ipairs(Config.PassOrder) do refreshPass(player,s,key) end
 local stats=Instance.new("Folder"); stats.Name="leaderstats"; stats.Parent=player
 local cashStat=Instance.new("NumberValue"); cashStat.Name="Cash"; cashStat.Value=s.cash; cashStat.Parent=stats
 local rebirthStat=Instance.new("IntValue"); rebirthStat.Name="Rebirths"; rebirthStat.Value=s.rebirth; rebirthStat.Parent=stats
 Tutorial.advance(s.tutorial,"sync",s.parts)
 for _,theme in ipairs(Config.Themes) do if theme.id==s.theme then Visuals.applyTheme(s.plot,theme); break end end
 Visuals.applyRewardCosmetics(s.plot,s.extras)
 Visuals.autoCollector(s.plot,s.autoCollector.enabled)
 refreshStands(s)
 Visuals.showRolls(s.plot,s.rolls,s.slots)
 local function teleport(character)
  local root=character:WaitForChild("HumanoidRootPart",10)
  if root and states[player]==s then
   character:PivotTo(CFrame.new(plot.lever.Position+Vector3.new(0,4,10)))
   local head=character:WaitForChild("Head",10)
   if head and states[player]==s and player.Character==character then Titles.apply(character,s.rebirth,s.extras) end
  end
 end
 player.CharacterAdded:Connect(teleport)
 if player.Character then task.spawn(teleport,player.Character) end
 if (data.lastOfflineAward or 0)>0 then send(player,"Welcome back! $"..data.lastOfflineAward.." was added to your bank while away.")
 else send(player,"Welcome! Roll at your station.") end
end
local function join(player)
 if states[player] or not ShutdownGate.begin(joinGate,player.UserId) then return end
 local context={}
 local ok,err=pcall(joinImpl,player,context)
 if not ok then
  warn("Player join failed for "..player.UserId..": "..tostring(err))
  if not states[player] then
   if context.data then
    context.data.lastLogout=os.time()
    local savedOk,saved=pcall(DataService.save,player.UserId,context.data,true)
    if not savedOk or not saved then warn("Failed to release profile after join error: "..player.UserId) end
   end
   if context.plot and context.plot.owner==player then context.plot.owner=nil; context.plot.sign.Text="Unclaimed plot" end
  end
  if player.Parent then player:Kick("Could not join safely. Please try again.") end
 end
 ShutdownGate.finish(joinGate,player.UserId)
end
Players.PlayerAdded:Connect(join)
Players.PlayerRemoving:Connect(function(player)
 local s=states[player]; if not s or not ShutdownGate.beginDeparture(joinGate,player.UserId) then return end
 states[player]=nil
 local ok,err=pcall(function()
  if DataService.isHealthy(player.UserId) then settleIncome(s,os.clock(),currentEvent()) end
  local snapshot=profile(s,true)
  local cleared,clearErr=pcall(clearPlot,s)
  if not cleared then warn("Failed to clear plot for "..player.UserId..": "..tostring(clearErr)) end
  if not DataService.save(player.UserId,snapshot,true) then warn("Failed to save profile for "..player.UserId) end
 end)
 ShutdownGate.finishDeparture(joinGate,player.UserId)
 if not ok then warn("Departure failed for "..player.UserId..": "..tostring(err)) end
end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(join,player) end
task.spawn(function()
 while true do
  task.wait(1)
  if joinGate.closed then break end
  local incomeEvent=currentEvent()
  for player,s in pairs(states) do
   if not DataService.isHealthy(player.UserId) then player:Kick("Data connection lost; please rejoin.")
   else
    local previousDay=s.progress.questDay
    Progression.refresh(s.progress,os.time())
    local changed=previousDay~=s.progress.questDay
    local expired=expireOffers(s,os.clock())
    if expired then changed=true end
    settleIncome(s,os.clock(),incomeEvent)
    if s.incomeDirty then changed=true; s.incomeDirty=false end
    local rates=PlotEconomy.rates(s.creatures,Config.Income)
    if AutoCollector.due(s.autoCollector,s.rebirth,os.clock(),s.pending) then collect(player,s) end
    s.plot.bankLabel.Text="Bank: $"..math.floor(s.pending)
    if changed then send(player,expired and "Unpurchased roll offers expired after 60 seconds." or nil)
    else remote:FireClient(player, {tick=true, cash=s.cash, pending=math.floor(s.pending), event=eventText(), eventFlags=incomeEvent, income=incomeSummary(s,rates,incomeEvent), serverDay=Progression.day(os.time()), giftElapsed=math.floor(os.clock()-s.sessionStarted), luckRemaining=math.max(0,s.luckUntil-os.time()), tripleLuckRemaining=math.max(0,s.tripleLuckUntil-os.time()), rollRemaining=math.max(0,math.ceil((s.offerExpires or 0)-os.clock()))}) end
   end
  end
 end
end)
task.spawn(function()
 while true do
  task.wait(0.5)
  if joinGate.closed then break end
  for player,s in pairs(states) do
   if s.autoRolling and os.clock()>=(s.nextAuto or 0) then
    if not DataService.isHealthy(player.UserId) or not nearby(player,s.plot.lever) then
     s.autoRolling=false; send(player,"Auto-roll stopped: stay near your roll station.")
    elseif not PassService.canAuto(s.passes,s.rebirth) then
     s.autoRolling=false; send(player,"Auto-roll is no longer available.")
    elseif #s.parts>=partCapacity(s) then
     s.autoRolling=false; send(player,"Auto-roll stopped: inventory full.")
    else
     s.nextAuto=os.clock()+2
     rollBatch(s)
     local run=s.autoRun
     local result=AutoRoll.process(s.rolls,s.parts,run.config,s.cash,run.remaining,partCapacity(s))
     s.cash=result.cash; run.remaining=result.remaining; run.batches+=1
     run.bought+=result.bought; run.skipped+=result.skipped; run.spent+=result.spent
     if result.bought>0 then Tutorial.advance(s.tutorial,"buy",s.parts) end
     if #s.rolls==0 then s.offerExpires=0 end
     Visuals.showRolls(s.plot,s.rolls,s.slots)
     local stopped=result.stop
     if not stopped and run.batches>=run.config.maxBatches then stopped="Batch limit reached." end
     if stopped then s.autoRolling=false; send(player,"Auto-roll stopped: "..stopped.." Review remaining offers.")
     else send(player,"Auto-roll is running.") end
    end
   end
  end
 end
end)
task.spawn(function()
 while true do
  local records={}
  for player,s in pairs(states) do table.insert(records,{name=player.DisplayName,cash=s.cash,rebirth=s.rebirth}) end
  table.sort(records,function(a,b) if a.cash==b.cash then return a.name<b.name end; return a.cash>b.cash end)
  local lines={"SERVER CASH"}
  for i,record in ipairs(records) do table.insert(lines,i..". "..record.name.."  $"..math.floor(record.cash)) end
  cashCaption.Text=table.concat(lines,"\n")
  table.sort(records,function(a,b) if a.rebirth==b.rebirth then return a.name<b.name end; return a.rebirth>b.rebirth end)
  lines={"SERVER REBIRTHS"}
  for i,record in ipairs(records) do table.insert(lines,i..". "..record.name.."  "..record.rebirth) end
  rebirthCaption.Text=table.concat(lines,"\n")
  task.wait(10)
 end
end)
-- Storm rewards are created and claimed on the server, once per drop, by its plot owner.
task.spawn(function()
 while true do
  task.wait(10)
  if joinGate.closed then break end
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
      if claimed or joinGate.closed or states[owner]~=s or not DataService.isHealthy(owner.UserId) then return end
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
  if joinGate.closed then break end
  for player,s in pairs(states) do
   task.spawn(function()
    if states[player]==s then
     if DataService.isHealthy(player.UserId) then settleIncome(s,os.clock(),currentEvent()) end
     if not DataService.save(player.UserId,profile(s),false) then warn("Autosave failed for "..player.UserId) end
    end
   end)
  end
 end
end)
game:BindToClose(function()
 ShutdownGate.close(joinGate)
 local remaining=0
 for player,s in pairs(states) do
  if DataService.isHealthy(player.UserId) then settleIncome(s,os.clock(),currentEvent()) end
  states[player]=nil; remaining+=1
  task.spawn(function()
   local ok,saved=pcall(function() return DataService.save(player.UserId,profile(s,true),true) end)
   if not ok or not saved then warn("Shutdown save failed for "..player.UserId) end
   remaining-=1
  end)
 end
 local deadline=os.clock()+25
 while not ShutdownGate.drained(joinGate,remaining) and os.clock()<deadline do task.wait(0.1) end
 if not ShutdownGate.drained(joinGate,remaining) then warn("Shutdown deadline reached with saves, departures or joins still pending.") end
end)
