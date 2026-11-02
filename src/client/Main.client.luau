--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local Lighting=game:GetService("Lighting")
local Config=require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local AutoFill=require(ReplicatedStorage.Shared:WaitForChild("AutoFill"))
local CraftMath=require(ReplicatedStorage.Shared:WaitForChild("CraftMath"))
local InventoryView=require(ReplicatedStorage.Shared:WaitForChild("InventoryView"))
local remote=ReplicatedStorage:WaitForChild("GameAction")
local player=Players.LocalPlayer
local sounds={}
local function playEffect(name)
 local id=Config.AudioIds[name]
 if type(id)~="number" or id<=0 then return end
 if not sounds[name] then
  local sound=Instance.new("Sound"); sound.Name="Brainrot_"..name; sound.SoundId="rbxassetid://"..id; sound.Volume=0.5; sound.Parent=SoundService; sounds[name]=sound
 end
 sounds[name]:Play()
end
local gui=Instance.new("ScreenGui"); gui.Name="BrainrotUI"; gui.ResetOnSpawn=false; gui.Parent=player:WaitForChild("PlayerGui")
local function round(frame)
 local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,12); corner.Parent=frame
 local stroke=Instance.new("UIStroke"); stroke.Thickness=2; stroke.Color=Color3.fromRGB(28,25,53); stroke.Parent=frame
end
local function button(parent,text,size,pos,color)
 local b=Instance.new("TextButton"); b.Size=size; b.Position=pos; b.BackgroundColor3=color or Color3.fromRGB(105,70,220)
 b.Text=text; b.TextColor3=(b.BackgroundColor3.R*0.299+b.BackgroundColor3.G*0.587+b.BackgroundColor3.B*0.114)>0.68 and Color3.fromRGB(22,24,45) or Color3.new(1,1,1); b.Font=Enum.Font.GothamBold; b.TextSize=16; b.TextWrapped=true; b.Parent=parent; round(b); return b
end
local hud=button(gui,"Loading...",UDim2.new(0.4,0,0,55),UDim2.new(0.02,0,0,8),Color3.fromRGB(38,42,72))
hud.Activated:Connect(function() remote:FireServer("collect") end)
local bag=button(gui,"BACKPACK",UDim2.new(0,120,0,48),UDim2.new(1,-130,0,8))
local slots=button(gui,"UPGRADES",UDim2.new(0,120,0,48),UDim2.new(1,-130,0,62),Color3.fromRGB(230,135,40))

local travel=button(gui,"TRAVEL",UDim2.new(0,120,0,48),UDim2.new(1,-130,0,170),Color3.fromRGB(39,145,180))
local rewards=button(gui,"REWARDS",UDim2.new(0,120,0,48),UDim2.new(1,-130,0,224),Color3.fromRGB(66,155,115))
local rebirth=button(gui,"REBIRTH",UDim2.new(0,120,0,48),UDim2.new(1,-130,0,116),Color3.fromRGB(218,65,135))
local eventLabel=Instance.new("TextLabel"); eventLabel.BackgroundTransparency=1; eventLabel.Size=UDim2.new(1,-155,0,28); eventLabel.Position=UDim2.new(0.02,0,0,98); eventLabel.TextColor3=Color3.fromRGB(255,225,80); eventLabel.TextStrokeTransparency=0; eventLabel.Font=Enum.Font.GothamBold; eventLabel.TextScaled=true; eventLabel.Parent=gui
local notice=Instance.new("TextLabel"); notice.BackgroundTransparency=1; notice.Size=UDim2.new(1,-155,0,30); notice.Position=UDim2.new(0.02,0,0,67); notice.TextColor3=Color3.new(1,1,1); notice.TextStrokeTransparency=0; notice.Font=Enum.Font.GothamBold; notice.TextScaled=true; notice.Parent=gui
local guidance=Instance.new("TextLabel"); guidance.Size=UDim2.new(1,-155,0,42); guidance.Position=UDim2.new(0.02,0,0,130)
guidance.BackgroundColor3=Color3.fromRGB(105,75,30); guidance.TextColor3=Color3.new(1,1,1); guidance.TextWrapped=true
guidance.Font=Enum.Font.GothamBold; guidance.TextSize=14; guidance.Visible=false; guidance.Parent=gui; round(guidance)
local guideHighlight=Instance.new("Highlight"); guideHighlight.Name="TutorialTarget"; guideHighlight.FillColor=Color3.fromRGB(255,220,60)
guideHighlight.OutlineColor=Color3.new(1,1,1); guideHighlight.FillTransparency=0.65; guideHighlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; guideHighlight.Enabled=false; guideHighlight.Parent=workspace
local panel=Instance.new("Frame"); panel.Size=UDim2.new(0.85,0,0.68,0); panel.Position=UDim2.new(0.075,0,0.2,0); panel.BackgroundColor3=Color3.fromRGB(37,39,70); panel.Visible=false; panel.Parent=gui; round(panel)
local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,-70,0,45); title.BackgroundTransparency=1; title.TextColor3=Color3.new(1,1,1); title.Font=Enum.Font.GothamBold; title.TextSize=20; title.Parent=panel
local close=button(panel,"X",UDim2.fromOffset(48,40),UDim2.new(1,-54,0,4),Color3.fromRGB(200,65,85)); close.Activated:Connect(function() panel.Visible=false end)
local list=Instance.new("ScrollingFrame"); list.Size=UDim2.new(1,-20,1,-55); list.Position=UDim2.fromOffset(10,50); list.BackgroundTransparency=1; list.BorderSizePixel=0; list.ScrollBarThickness=7; list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.CanvasSize=UDim2.new(); list.Parent=panel
local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,6); layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Parent=list
local state={cash=0,pending=0,slots=1,standsUnlocked=12,plotIndex=0,tutorial={step=1},theme="Classic",passes={},partCapacity=100,backpackUpgrades=0,rareBlueprints=0,autoRolling=false,autoCollect=false,income={placed=0,normal=0,online=0,offline=0},autoRun=nil,rebirth=0,isAdmin=false,rebirthCost=1000,target="Dirt Boy",parts={},creatures={},rolls={},progress={dailyLastDay=-1,dailyStreak=0,questDay=-1,rolls=0,rareCrafts=0,collected=0,claimed={}},quests={},season={xp=0,claimed=0,rollProgress=0},extras={luckPotions=0,rollVouchers=0,goldenLever=false,sigmaStatue=false,ohioCrown=false},serverDay=0,giftClaims={},giftElapsed=0,luckRemaining=0,rollRemaining=0}
local loaded=false
local mode=""; local stand=0; local chosen={}; local rowOrder=0
local bagTab="All"; local selectedSell=nil; local confirmRebirth=false
local bulkRarity=1; local confirmBulk=nil
local bagQuery=""; local bagDraft=""; local bagProtection="All"; local bagSort="Newest"; local bagPage=1
local forgeIds={}; local forgeConfirm=false; local useBlueprint=false; local craftConfirm=false
local autoRules={"skip","skip","hold","hold","hold","hold","hold","hold"}
local autoMaxSpend="10000"; local autoMaxPrice="1000"; local autoMaxBatches="50"; local autoConfirm=false; local discardConfirm=false
local giftButtons={}
local incomeLabels={}
local catalogOdds=nil; local catalogRarity=0; local catalogUnlockedOnly=false
local catalogQuery=""; local catalogDraft=""; local catalogPage=1
local adminData=nil; local adminTarget=nil; local adminAmount="1000"; local adminCatalog=1; local adminKind=1; local pendingAdmin=nil
local function row(text, callback, color)
 local b=button(list,text,UDim2.new(1,-10,0,50),UDim2.new(),color)
 rowOrder+=1; b.LayoutOrder=rowOrder
 if callback then b.Activated:Connect(callback) end
 return b
end
local function giftText(gift)
 local left=math.max(0,gift.seconds-(state.giftElapsed or 0))
 local status=(state.giftClaims and state.giftClaims[gift.id]) and "CLAIMED" or (left==0 and "CLAIM" or (math.floor(left/60).."m "..(left%60).."s"))
 return gift.label.." — "..status
end
local function updateIncomeLabels()
 local income=state.income or {}
 if incomeLabels.online and incomeLabels.online.Parent then incomeLabels.online.Text=string.format("CURRENT ONLINE RATE: $%.2g/s",income.online or 0) end
 if incomeLabels.normal and incomeLabels.normal.Parent then incomeLabels.normal.Text=string.format("NORMAL RATE: $%.2g/s | PLACED: %d",income.normal or 0,income.placed or 0) end
 if incomeLabels.offline and incomeLabels.offline.Parent then incomeLabels.offline.Text=string.format("OFFLINE RATE: $%.2g/s (25%%; maximum 24h)",income.offline or 0) end
 if incomeLabels.bonuses and incomeLabels.bonuses.Parent then
  incomeLabels.bonuses.Text="ACTIVE: "..(income.statue and "Statue +50% | " or "")..(income.sigma and "Sigma x3 | " or "")..(income.weekend and "Weekend x2 | " or "")..(income.vip and "VIP x1.2" or "")
 end
end
local function refreshTimedLabels()
 if panel.Visible and mode=="rewards" then
  for _,gift in ipairs(Config.SessionGifts) do
   local b=giftButtons[gift.id]
   if b and b.Parent then b.Text=giftText(gift) end
  end
 end
 if panel.Visible and mode=="income" then updateIncomeLabels() end
 if panel.Visible and mode=="roll" then title.Text="ROLL STATION | offers expire in "..(state.rollRemaining or 0).."s" end
end
local function render()
 hud.Text="$"..math.floor(state.cash).."  |  Collect $"..math.floor(state.pending).."  |  R"..(state.rebirth or 0)
 if not panel.Visible then return end
 local previousScroll=list.CanvasPosition
 for _,child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 rowOrder=0; giftButtons={}; incomeLabels={}
 if mode=="roll" then
  title.Text="ROLL STATION | offers expire in "..(state.rollRemaining or 0).."s"
  row("PULL LEVER / REROLL",function() remote:FireServer("roll") end,Color3.fromRGB(220,78,93))
  if state.autoRolling then
   local run=state.autoRun
   row("STOP AUTO-ROLL"..(run and (" | spent $"..run.spent.." / $"..run.config.maxSpend.." | batches "..run.batches.."/"..run.config.maxBatches) or ""),function() remote:FireServer("autoRoll",false) end,Color3.fromRGB(200,65,85))
  elseif state.rebirth<5 and state.passes.AutoRoll~="owned" then
   row("AUTO-ROLL: unlock at rebirth 5 or with pass",nil,Color3.fromRGB(70,75,105))
  else row("CONFIGURE AUTO-ROLL",function() autoConfirm=false; mode="autoSetup"; list.CanvasPosition=Vector2.zero; render() end,Color3.fromRGB(52,170,105)) end
  if not state.autoRolling and #state.rolls>0 then
   row(discardConfirm and "CONFIRM: DISCARD ALL CURRENT OFFERS" or "DISCARD ALL OFFERS (review first)",function()
    if discardConfirm then remote:FireServer("discardOffers"); discardConfirm=false else discardConfirm=true; render() end
   end,Color3.fromRGB(160,75,70))
   if discardConfirm then row("CANCEL DISCARD",function() discardConfirm=false; render() end,Color3.fromRGB(70,75,105)) end
  end
  row("VIEW CATALOG & CURRENT ODDS",function() catalogOdds=nil; mode="catalog"; list.CanvasPosition=Vector2.zero; remote:FireServer("requestOdds"); render() end,Color3.fromRGB(60,120,180))
  for _,item in ipairs(state.rolls) do
   local rarity=Config.Rarities[item.rarity]
   local odds=item.rarityChance and string.format("%.2f%% tier",item.rarityChance*100) or rarity.name
   row("BUY "..(item.mutation or "Standard").." "..item.name.." "..item.kind.." ["..rarity.name..", "..odds.."]  $"..item.price,function() remote:FireServer("buy",item.id) end,rarity.color)
   if state.extras and state.extras.rollVouchers>0 then
    row("FREE PART VOUCHER: "..item.name.." "..item.kind.." ("..state.extras.rollVouchers.." left)",function() remote:FireServer("buyWithVoucher",item.id) end,Color3.fromRGB(60,145,150))
   end
   row("SKIP "..item.name.." "..item.kind,function() remote:FireServer("skip",item.id) end,Color3.fromRGB(70,75,105))
  end
 elseif mode=="autoSetup" then
  title.Text="AUTO-ROLL SETTINGS"
  row("Per rarity: SKIP discards; HOLD stops for review; BUY spends cash. Processed in slot order.",nil,Color3.fromRGB(70,75,105))
  for i,rarity in ipairs(Config.Rarities) do
   row(rarity.name..": "..string.upper(autoRules[i]).." (tap to change)",function()
    autoRules[i]=autoRules[i]=="skip" and "hold" or (autoRules[i]=="hold" and "buy" or "skip"); autoConfirm=false; render()
   end,rarity.color)
  end
  local function numberField(labelText,initial,callback)
   local field=Instance.new("TextBox"); field.Size=UDim2.new(1,-10,0,50); field.BackgroundColor3=Color3.fromRGB(60,65,95); field.TextColor3=Color3.new(1,1,1)
   field.Text=initial; field.PlaceholderText=labelText; field.ClearTextOnFocus=false; field.Font=Enum.Font.GothamBold; field.TextSize=16
   field.Parent=list; rowOrder+=1; field.LayoutOrder=rowOrder; round(field)
   field:GetPropertyChangedSignal("Text"):Connect(function() callback(string.sub(field.Text,1,18)); autoConfirm=false end)
  end
  row("MAX CASH TO SPEND IN THIS RUN",nil,Color3.fromRGB(70,75,105)); numberField("Total cash budget",autoMaxSpend,function(v) autoMaxSpend=v end)
  row("MAX PRICE PER PART",nil,Color3.fromRGB(70,75,105)); numberField("Maximum part price",autoMaxPrice,function(v) autoMaxPrice=v end)
  row("MAX BATCHES (1–1000)",nil,Color3.fromRGB(70,75,105)); numberField("Maximum batches",autoMaxBatches,function(v) autoMaxBatches=v end)
  row("Run uses cash, not vouchers. Limits reset on each run. Existing offers must be cleared first.",nil,Color3.fromRGB(70,75,105))
  row(autoConfirm and "CONFIRM AUTO-ROLL: CASH MAY BE SPENT" or "REVIEW AUTO-ROLL SETTINGS",function()
   if autoConfirm then
    remote:FireServer("autoRoll",{rules=autoRules,maxSpend=tonumber(autoMaxSpend),maxPrice=tonumber(autoMaxPrice),maxBatches=tonumber(autoMaxBatches)})
    autoConfirm=false; discardConfirm=false; mode="roll"; list.CanvasPosition=Vector2.zero; render()
   else autoConfirm=true; render() end
  end,Color3.fromRGB(185,65,85))
  row("BACK TO ROLL STATION",function() autoConfirm=false; mode="roll"; list.CanvasPosition=Vector2.zero; render() end,Color3.fromRGB(70,75,105))
 elseif mode=="catalog" then
  title.Text="CATALOG & ROLL ODDS"
  row("REFRESH SERVER ODDS",function() remote:FireServer("requestOdds") end,Color3.fromRGB(60,120,180))
  if catalogOdds then
   local mods=catalogOdds.modifiers
   row("Snapshot "..os.date("!%H:%M:%S",catalogOdds.at).." UTC | Rebirth "..catalogOdds.rebirth.." | "..(catalogOdds.rebirth==state.rebirth and "current rebirth" or "REBIRTH CHANGED: REFRESH"),nil,Color3.fromRGB(70,75,105))
   local bonuses={}
   if mods.frenzy then table.insert(bonuses,"Frenzy x2") end
   if mods.weekend then table.insert(bonuses,"Weekend x1.5") end
   if mods.luckPass then table.insert(bonuses,"Luck pass x2") end
   if mods.luck2 then table.insert(bonuses,"2x boost") end
   if mods.luck3 then table.insert(bonuses,"3x boost") end
   if mods.goldenLever then table.insert(bonuses,"Golden Lever x1.05") end
   row("Non-Common weight bonuses: "..(#bonuses>0 and table.concat(bonuses,", ") or "none").." | factor x"..string.format("%.2f",catalogOdds.nonCommonFactor),nil,Color3.fromRGB(70,75,105))
   row("Each slot rolls independently. Bonuses change weights, not final percentages; rebirth also changes weights. Refresh when events or boosts change.",nil,Color3.fromRGB(70,75,105))
   for i,rarity in ipairs(Config.Rarities) do
    local item=catalogOdds.tiers[i]
    row(rarity.name..": "..string.format("%.5g%%",item.chance*100).." per slot | "..item.count.." unlocked archetypes",nil,rarity.color)
   end
   local mutations={}
   for _,mutation in ipairs(Config.Mutations) do table.insert(mutations,mutation.name.." "..string.format("%.2f%%",mutation.weight/100)) end
   row("Mutation odds (independent): "..table.concat(mutations,", "),nil,Color3.fromRGB(70,75,105))
  else row("Loading current odds from the server...",nil,Color3.fromRGB(70,75,105)) end
  row("CATALOG: chances below are per archetype, any part or mutation. Gift odds are different.",nil,Color3.fromRGB(70,75,105))
  local search=Instance.new("TextBox"); search.Size=UDim2.new(1,-10,0,50); search.BackgroundColor3=Color3.fromRGB(60,65,95); search.TextColor3=Color3.new(1,1,1)
  search.Text=catalogDraft; search.PlaceholderText="Search archetype name"; search.ClearTextOnFocus=false; search.Font=Enum.Font.GothamBold; search.TextSize=16
  search.Parent=list; rowOrder+=1; search.LayoutOrder=rowOrder; round(search)
  search:GetPropertyChangedSignal("Text"):Connect(function() catalogDraft=string.sub(search.Text,1,80) end)
  row("APPLY SEARCH"..(catalogQuery~="" and (": "..catalogQuery) or ""),function() catalogQuery=catalogDraft; catalogPage=1; render() end,Color3.fromRGB(60,120,180))
  row("RARITY: "..(catalogRarity==0 and "All" or Config.Rarities[catalogRarity].name).." (tap to change)",function() catalogRarity=(catalogRarity+1)%(#Config.Rarities+1); catalogPage=1; render() end,Color3.fromRGB(70,75,105))
  row("SHOW: "..(catalogUnlockedOnly and "Unlocked only" or "All archetypes").." (tap to change)",function() catalogUnlockedOnly=not catalogUnlockedOnly; catalogPage=1; render() end,Color3.fromRGB(70,75,105))
  local entries={}; local query=string.lower(catalogQuery)
  for _,entry in ipairs(Config.Catalog) do
   if (catalogRarity==0 or entry.rarity==catalogRarity) and (not catalogUnlockedOnly or entry.rebirth<=state.rebirth) and (query=="" or string.find(string.lower(entry.name),query,1,true)) then table.insert(entries,entry) end
  end
  local pages=math.max(1,math.ceil(#entries/10)); catalogPage=math.clamp(catalogPage,1,pages)
  row("PAGE "..catalogPage.." / "..pages.." | "..#entries.." archetypes",nil,Color3.fromRGB(70,75,105))
  if catalogPage>1 then row("PREVIOUS PAGE",function() catalogPage-=1; render() end,Color3.fromRGB(60,120,180)) end
  if catalogPage<pages then row("NEXT PAGE",function() catalogPage+=1; render() end,Color3.fromRGB(60,120,180)) end
  for i=(catalogPage-1)*10+1,math.min(catalogPage*10,#entries) do
   local entry=entries[i]; local rarity=Config.Rarities[entry.rarity]
   local unlocked=entry.rebirth<=state.rebirth
   local chance=""
   if catalogOdds and catalogOdds.rebirth==state.rebirth and unlocked then
    local tier=catalogOdds.tiers[entry.rarity]
    if tier.count>0 then chance=" | "..string.format("%.5g%%",tier.chance*100/tier.count).." per slot" end
   end
   local price=math.max(10,math.floor(entry.income*5))
   row(entry.name.." ["..rarity.name.."] | "..(unlocked and "UNLOCKED" or "REBIRTH "..entry.rebirth).." | part base $"..price.." | contribution "..entry.income..chance,nil,rarity.color)
  end
  row("Prices shown are before Eclipse discount. An archetype is selected uniformly within its unlocked rarity tier; each part type is 25%.",nil,Color3.fromRGB(70,75,105))
  row("BACK TO REWARDS",function() mode="rewards"; list.CanvasPosition=Vector2.zero; render() end,Color3.fromRGB(70,75,105))
 elseif mode=="assemble" then
  title.Text="ASSEMBLY: select one of each"
  row("RARE BLUEPRINT: "..(useBlueprint and "ON" or "OFF").." | owned: "..(state.rareBlueprints or 0).." (requires 4 Rare+ parts, +25% base income)",function()
   useBlueprint=not useBlueprint; craftConfirm=false; chosen={}; render()
  end,Color3.fromRGB(125,75,175))
  row("AUTO-FILL BEST eligible part of each type",function()
   craftConfirm=false; chosen=AutoFill.best(state.parts,Config.Rarities,Config.Types,useBlueprint and 3 or 1) or {}
   if not next(chosen) then notice.Text="You need one eligible part of each type to auto-fill." end
   render()
  end,Color3.fromRGB(60,120,180))
  local components={}
  for _,item in ipairs(state.parts) do
   if chosen[item.kind]==item.id and not item.locked then components[item.kind]=item end
  end
  local preview=CraftMath.evaluate(components,Config.Rarities,useBlueprint)
  local ready=preview and #state.creatures<100 and (not useBlueprint or (state.rareBlueprints or 0)>0)
  if preview then
   row("PREVIEW: "..preview.name.." | "..Config.Rarities[preview.highest].name.." | $"..string.format("%.4g",preview.income).."/s at level 1",nil,Color3.fromRGB(60,120,180))
   row(preview.harmony and ("Matching "..preview.mutation.." mutations: 2x harmony bonus") or "Mixed mutations: no harmony bonus",nil,Color3.fromRGB(70,75,105))
   if useBlueprint then row("One blueprint will be consumed for +25% base income.",nil,Color3.fromRGB(125,75,175)) end
  else row("Select one eligible part of each type to preview the creature.",nil,Color3.fromRGB(70,75,105)) end
  if #state.creatures>=100 then row("Creature inventory is full. Free a slot before crafting.",nil,Color3.fromRGB(150,65,65)) end
  if useBlueprint and (state.rareBlueprints or 0)<1 then row("No rare blueprints available. Claim the 25-minute session gift.",nil,Color3.fromRGB(150,65,65)) end
  row(craftConfirm and "CONFIRM: CONSUME FOUR PARTS"..(useBlueprint and " AND ONE BLUEPRINT" or "") or "REVIEW ASSEMBLY",function()
   if not ready then notice.Text="Select four eligible parts and check inventory and blueprint availability."; return end
   if not craftConfirm then craftConfirm=true; render(); return end
   chosen.useBlueprint=useBlueprint; remote:FireServer("assemble",chosen); chosen={}; craftConfirm=false
  end,Color3.fromRGB(52,170,105))
  if craftConfirm then row("CANCEL ASSEMBLY",function() craftConfirm=false; render() end,Color3.fromRGB(70,75,105)) end
  for _,kind in ipairs(Config.Types) do
   local picked=components[kind]
   row(kind..": "..(picked and ((picked.mutation or "Standard").." "..picked.name.." ["..Config.Rarities[picked.rarity].name.."]") or "choose below"),nil,Color3.fromRGB(70,75,105))
   for _,item in ipairs(state.parts) do
    if item.kind==kind and not item.locked and (not useBlueprint or item.rarity>=3) then row((item.mutation or "Standard").." "..item.name.." "..kind..(chosen[kind]==item.id and " ✓" or ""),function() chosen[kind]=item.id; craftConfirm=false; render() end,Config.Rarities[item.rarity].color) end
   end
  end
 elseif mode=="forge" then
  title.Text="FUSION FORGE — REBIRTH 15+"
  row("Fuse 3 unplaced matching creatures, level 10 or above. All parts and mutations must match.",nil,Color3.fromRGB(70,75,105))
  row("The inputs are destroyed. Output starts at level 1 with 5x original base income and boosts adjacent stands.",nil,Color3.fromRGB(70,75,105))
  local first=nil
  for _,creature in ipairs(state.creatures) do if creature.id==forgeIds[1] then first=creature; break end end
  local fee=first and Config.FusionCost(first) or 0
  row("SELECTED "..#forgeIds.."/3 | FEE $"..fee.." | Cash $"..math.floor(state.cash),nil,Color3.fromRGB(70,75,105))
  if first then
   row("RECIPE: "..first.name.." | "..(first.blueprintApplied and "Blueprint boosted" or "No blueprint").." | base $"..string.format("%.4g",first.income).."/s",nil,Color3.fromRGB(70,75,105))
   for _,kind in ipairs(Config.Types) do
    local component=first.components[kind]
    row(kind..": "..component.name.." ["..Config.Rarities[component.rarity].name.."] "..(component.mutation or "Standard").." x"..(component.mutationMultiplier or 1).." | base "..component.income,nil,Color3.fromRGB(70,75,105))
   end
   row("OUTPUT if valid: level 1, $"..string.format("%.4g",first.income*5).."/s base; adjacent stands gain 20%.",nil,Color3.fromRGB(60,120,180))
   row("CLEAR FUSION SELECTION",function() forgeIds={}; forgeConfirm=false; render() end,Color3.fromRGB(70,75,105))
  end
  row(forgeConfirm and "CONFIRM: CONSUME 3 CREATURES AND CASH" or "FUSE SELECTED (review first)",function()
   if #forgeIds~=3 or not first then return end
   if forgeConfirm then remote:FireServer("fusion",forgeIds); forgeIds={}; forgeConfirm=false
   else forgeConfirm=true; render() end
  end,Color3.fromRGB(185,100,35))
  for _,creature in ipairs(state.creatures) do
   if not creature.ascended and not creature.locked then
    local selected=false; for _,id in ipairs(forgeIds) do if id==creature.id then selected=true end end
    local text=(selected and "✓ " or "")..(creature.blueprintApplied and "[BLUEPRINT] " or "")..creature.name.." Lv."..creature.level.." | "..(creature.stand==0 and "Unplaced" or "Stand "..creature.stand).." | base $"..math.floor(creature.income).."/s"
    row(text,function()
     if selected then for i,id in ipairs(forgeIds) do if id==creature.id then table.remove(forgeIds,i); break end end
     elseif #forgeIds<3 then table.insert(forgeIds,creature.id) end
     forgeConfirm=false; render()
    end,selected and Color3.fromRGB(45,150,110) or nil)
   end
  end
 elseif mode=="stand" then
  title.Text="STAND "..stand..": choose a creature"
  for _,c in ipairs(state.creatures) do
   row((c.ascended and "ASCENDED " or "")..c.name.." | $"..math.floor(Config.Income(c)).."/s | "..(c.stand==0 and "Unplaced" or "Stand "..c.stand),function() remote:FireServer("stand",{stand=stand,id=c.id}) end)
  end
 elseif mode=="rebirth" then
  title.Text="REBIRTH "..(state.rebirth or 0).." / 100"
  if state.rebirth>=100 then row("Maximum rebirth reached",nil) else
   row("Cost: $"..state.rebirthCost.." | Sacrifice (unprotected, non-ascended): "..state.target.." Abomination",nil,Color3.fromRGB(70,75,105))
   row("Rebirth resets cash; roll slots reset unless Keep Slots applies. Other items remain. Luck x"..string.format("%.2f",1.15^(state.rebirth+1)),nil,Color3.fromRGB(70,75,105))
   row(confirmRebirth and "CONFIRM: RESET CASH AND SACRIFICE" or "REBIRTH (tap to review)",function()
   if confirmRebirth then remote:FireServer("rebirth"); confirmRebirth=false else confirmRebirth=true; render() end
  end,Color3.fromRGB(220,75,130))
  end
 elseif mode=="upgrades" then
  title.Text="PLOT UPGRADES"
  local slotCost=Config.SlotCosts[state.slots+1]
  row(slotCost and ("Unlock roll slot "..(state.slots+1).." — $"..slotCost) or "All roll slots unlocked",function() remote:FireServer("upgradeSlots") end,Color3.fromRGB(210,130,35))
  local nextStand=state.standsUnlocked+1
  local standCost=Config.StandCosts[nextStand-12]
  row(standCost and ("Unlock stand "..nextStand.." — $"..standCost.."; rebirth "..(nextStand-12)) or "All stands unlocked",function() remote:FireServer("upgradeStands") end,Color3.fromRGB(210,130,35))
  local bagCost=Config.BackpackUpgradeCosts[(state.backpackUpgrades or 0)+1]
  row(bagCost and ("BACKPACK +5 PART SLOTS — $"..bagCost.." ("..(state.backpackUpgrades or 0).."/10)") or "All cash backpack upgrades unlocked",function() remote:FireServer("upgradeBackpack") end,Color3.fromRGB(210,130,35))
  row("PLOT INCOME BREAKDOWN",function() mode="income"; list.CanvasPosition=Vector2.zero; render() end,Color3.fromRGB(60,145,150))
  if state.rebirth<10 then row("AUTO-COLLECTOR DRONE — unlocks at rebirth 10 (free)",nil,Color3.fromRGB(70,75,105))
  else row("AUTO-COLLECTOR: "..(state.autoCollect and "ON" or "OFF").." (every 10 seconds while online)",function() remote:FireServer("setAutoCollect",not state.autoCollect) end,Color3.fromRGB(60,145,150)) end
  row("FUSION FORGE (REBIRTH 15+)",function() remote:FireServer("teleport","forge"); panel.Visible=false end,Color3.fromRGB(175,120,45))
  row("PLOT THEMES",function() mode="themes"; list.CanvasPosition=Vector2.zero; render() end,Color3.fromRGB(60,130,160))
  row("OPEN GAMEPASS SHOP",function() mode="shop"; list.CanvasPosition=Vector2.zero; render() end,Color3.fromRGB(180,65,160))
 elseif mode=="income" then
  title.Text="PLOT INCOME"
  incomeLabels.online=row("",nil,Color3.fromRGB(52,170,105))
  incomeLabels.normal=row("",nil,Color3.fromRGB(70,75,105))
  incomeLabels.offline=row("",nil,Color3.fromRGB(70,75,105))
  incomeLabels.bonuses=row("",nil,Color3.fromRGB(70,75,105))
  row("Normal rate includes level, neighboring ascension boosts and the Sigma Statue. Online rate includes active events and VIP.",nil,Color3.fromRGB(70,75,105))
  row("Offline earnings require a successful departure save and exclude events, VIP and EXP. Rates are estimates; server delays may reduce actual online income.",nil,Color3.fromRGB(70,75,105))
  row("COLLECT PENDING CASH",function() remote:FireServer("collect") end,Color3.fromRGB(52,170,105))
  row("BACK TO UPGRADES",function() mode="upgrades"; list.CanvasPosition=Vector2.zero; render() end,Color3.fromRGB(70,75,105))
  updateIncomeLabels()
 elseif mode=="themes" then
  title.Text="PLOT THEMES"
  row("Cosmetic themes unlock with rebirth and cost no cash.",nil,Color3.fromRGB(70,75,105))
  for _,theme in ipairs(Config.Themes) do
   local status=state.theme==theme.id and "ACTIVE" or (state.rebirth>=theme.rebirth and "SELECT" or "REBIRTH "..theme.rebirth)
   row(theme.name.." — "..status,function() remote:FireServer("theme",theme.id) end,theme.floor)
  end
 elseif mode=="shop" then
  title.Text="GAMEPASS SHOP"
  row("Passes are optional. Roblox shows the price before you confirm.",nil,Color3.fromRGB(70,75,105))
  row("REFRESH OWNERSHIP",function() remote:FireServer("refreshPasses") end,Color3.fromRGB(60,120,180))
  for _,key in ipairs(Config.PassOrder) do
   local status=state.passes[key] or "unknown"
   local detail=status=="owned" and "OWNED" or status=="notOwned" and "TAP TO VIEW" or status=="unknown" and "CHECKING" or "UNAVAILABLE"
   row(key.." — "..Config.PassDescriptions[key].." — "..detail,function() remote:FireServer("buyPass",key) end,Color3.fromRGB(120,75,170))
  end
  row("Developer products and trading are not available yet.",nil,Color3.fromRGB(70,75,105))
 elseif mode=="rewards" then
  title.Text="DAILY REWARDS & QUESTS"
  local p=state.progress
  local available=state.serverDay>p.dailyLastDay
  local nextDay=(p.dailyLastDay==state.serverDay-1) and (p.dailyStreak%7+1) or 1
  row(available and ("CLAIM DAY "..nextDay.." — "..(Config.DailyRewardLabels[nextDay] or "reward")) or "DAILY REWARD CLAIMED — returns at UTC midnight",function() remote:FireServer("dailyReward") end,Color3.fromRGB(52,170,105))
  row("Consecutive UTC days build a 7-day streak; missing a day resets it.",nil,Color3.fromRGB(70,75,105))
  local extras=state.extras or {}
  row("USE 3x LUCK POTION (15 min) — "..(extras.luckPotions or 0).." owned",function() remote:FireServer("useLuckPotion") end,Color3.fromRGB(125,75,175))
  row("Free-part vouchers: "..(extras.rollVouchers or 0).." — use at roll station; rolls are already free.",nil,Color3.fromRGB(70,75,105))
  row("Golden Lever: "..(extras.goldenLever and "unlocked (+5% non-common weight)" or "locked").." | Sigma Statue: "..(extras.sigmaStatue and "unlocked (+50% income)" or "locked"),nil,Color3.fromRGB(70,75,105))
  for _,quest in ipairs(state.quests) do
   local value=p[quest.key] or 0
   local status=p.claimed[quest.key] and "CLAIMED" or (value>=quest.goal and "CLAIM" or "IN PROGRESS")
   row(quest.label.."  "..value.."/"..quest.goal.." | $"..quest.reward.." — "..status,function() remote:FireServer("claimQuest",quest.key) end,Color3.fromRGB(90,80,150))
  end
  row("CATALOG & ROLL ODDS",function() catalogOdds=nil; mode="catalog"; list.CanvasPosition=Vector2.zero; remote:FireServer("requestOdds"); render() end,Color3.fromRGB(60,120,180))
  row("OPEN FREE SEASON TRACK",function() mode="season"; list.CanvasPosition=Vector2.zero; render() end,Color3.fromRGB(120,75,180))
  row("SESSION GIFTS — timers reset when you leave",nil,Color3.fromRGB(70,75,105))
  for _,gift in ipairs(Config.SessionGifts) do
   local b=row(giftText(gift),function() remote:FireServer("claimGift",gift.id) end,Color3.fromRGB(155,105,45))
   giftButtons[gift.id]=b
  end
  local total=0; for i=4,#Config.Rarities do total+=Config.Rarities[i].weight end
  local odds={}; for i=4,#Config.Rarities do table.insert(odds,Config.Rarities[i].name.." "..string.format("%.2f%%",100*Config.Rarities[i].weight/total)) end
  row("60m Epic+ gift tier odds: "..table.concat(odds,", ")..". Standard mutation; any rebirth.",nil,Color3.fromRGB(70,75,105))
  if state.isAdmin then row("DEVELOPER ADMIN",function() pendingAdmin=nil; mode="admin"; list.CanvasPosition=Vector2.zero; remote:FireServer("adminOpen",adminTarget); render() end,Color3.fromRGB(155,65,65)) end
  row("HOW TO PLAY",function() mode="help"; list.CanvasPosition=Vector2.zero; render() end,Color3.fromRGB(60,120,180))
 elseif mode=="season" then
  title.Text="FREE SEASON TRACK"
  local season=state.season or {xp=0,claimed=0,rollProgress=0}
  local unlocked=math.floor(season.xp/100)
  row("Season XP: "..season.xp.." / 5000 | tiers unlocked: "..unlocked.." / 50",nil,Color3.fromRGB(70,75,105))
  row("Earn XP: +1 per part rolled, +20 per assembly, +100 per rebirth; daily quests award 50/75/100.",nil,Color3.fromRGB(70,75,105))
  local nextTier=season.claimed+1
  if nextTier<=50 then
   local desc=nextTier%3==1 and ("$"..(nextTier*1000).." cash") or (nextTier%3==2 and "one 3x luck potion" or "two free-part vouchers")
   row("TIER "..nextTier.." — "..desc.." — "..(nextTier<=unlocked and "CLAIM" or "LOCKED"),function() remote:FireServer("claimSeason") end,Color3.fromRGB(120,75,180))
  else row("All 50 free tiers claimed!",nil,Color3.fromRGB(52,170,105)) end
  row("Repeatable: roll 250 parts for one free-part voucher. Progress: "..season.rollProgress.." (claims: "..math.floor(season.rollProgress/250)..")",function() remote:FireServer("claimRepeatRolls") end,Color3.fromRGB(60,145,150))
  row("Permanent prototype track; no season reset or premium purchase. Free tiers are claimed in order.",nil,Color3.fromRGB(70,75,105))
  row("BACK TO REWARDS",function() mode="rewards"; list.CanvasPosition=Vector2.zero; render() end,Color3.fromRGB(70,75,105))
 elseif mode=="admin" then
  title.Text="DEVELOPER ADMIN — CURRENT SERVER"
  if not state.isAdmin then row("Not authorized.",nil,Color3.fromRGB(150,50,60))
  else
   row("Admin actions affect real profiles. Use only in a private test experience.",nil,Color3.fromRGB(150,65,60))
   row("REFRESH PLAYER LIST",function() remote:FireServer("adminOpen",adminTarget) end,Color3.fromRGB(60,120,180))
   if adminData then
    row("SELECT AN ONLINE PLAYER",nil,Color3.fromRGB(70,75,105))
    for _,entry in ipairs(adminData.players) do
     row(entry.name.." | $"..math.floor(entry.cash).." | Rebirth "..entry.rebirth.." | "..entry.partCount.." parts / "..entry.creatureCount.." creatures",function()
      adminTarget=entry.id; pendingAdmin=nil; remote:FireServer("adminOpen",entry.id)
     end,entry.id==adminTarget and Color3.fromRGB(45,145,110) or nil)
    end
    local inspected=adminData.inspected
    if inspected then
     row("TARGET: "..inspected.name.." | slots "..inspected.slots,nil,Color3.fromRGB(70,75,105))
     local field=Instance.new("TextBox"); field.Size=UDim2.new(1,-10,0,50); field.BackgroundColor3=Color3.fromRGB(60,65,95); field.TextColor3=Color3.new(1,1,1)
     field.Text=adminAmount; field.PlaceholderText="Enter whole-number amount"; field.ClearTextOnFocus=false; field.Font=Enum.Font.GothamBold; field.TextSize=16
     field.Parent=list; rowOrder+=1; field.LayoutOrder=rowOrder; round(field)
     field:GetPropertyChangedSignal("Text"):Connect(function() adminAmount=string.sub(field.Text,1,24) end)
     local function propose(command)
      pendingAdmin={command=command,target=inspected.id,amount=tonumber(adminAmount),index=adminCatalog,kind=Config.Types[adminKind]}; render()
     end
     row("GRANT CASH (amount above)",function() propose("grantCash") end,Color3.fromRGB(140,85,50))
     row("SET CASH (amount above)",function() propose("setCash") end,Color3.fromRGB(140,85,50))
     row("SET REBIRTH 0–100 (amount above)",function() propose("setRebirth") end,Color3.fromRGB(140,85,50))
     row("CATALOG: "..Config.Catalog[adminCatalog].name.." (tap to change)",function() adminCatalog=adminCatalog%#Config.Catalog+1; pendingAdmin=nil; render() end)
     row("PART TYPE: "..Config.Types[adminKind].." (tap to change)",function() adminKind=adminKind%#Config.Types+1; pendingAdmin=nil; render() end)
     row("GRANT STANDARD PART",function() propose("grantPart") end,Color3.fromRGB(140,85,50))
     row("KICK PLAYER FROM THIS SERVER",function() propose("kick") end,Color3.fromRGB(160,55,70))
    end
    row("SERVER EVENT: 120 SECONDS",nil,Color3.fromRGB(70,75,105))
    for _,eventName in ipairs({"Frenzy","Eclipse","Sigma","Storm"}) do
     row("TRIGGER "..eventName,function() pendingAdmin={command="event",event=eventName}; render() end,Color3.fromRGB(125,70,145))
    end
    if pendingAdmin then
     local targetLabel=pendingAdmin.event or ("user ID "..tostring(pendingAdmin.target))
     if pendingAdmin.target then
      for _,entry in ipairs(adminData.players) do if entry.id==pendingAdmin.target then targetLabel=entry.name.." ("..entry.id..")"; break end end
     end
     local detail=pendingAdmin.command.." "..targetLabel
     if pendingAdmin.command=="grantCash" or pendingAdmin.command=="setCash" or pendingAdmin.command=="setRebirth" then detail..=" amount "..tostring(pendingAdmin.amount) end
     if pendingAdmin.command=="grantPart" then detail..=" "..Config.Catalog[pendingAdmin.index].name.." "..pendingAdmin.kind end
     row("CONFIRM: "..detail,function() remote:FireServer("adminAction",pendingAdmin); pendingAdmin=nil; render() end,Color3.fromRGB(185,55,65))
     row("CANCEL ADMIN ACTION",function() pendingAdmin=nil; render() end,Color3.fromRGB(70,75,105))
    end
    if inspected then
     row("PART INVENTORY: "..#inspected.parts,nil,Color3.fromRGB(70,75,105))
     for _,item in ipairs(inspected.parts) do row(item,nil,Color3.fromRGB(60,65,95)) end
     row("CREATURE INVENTORY: "..#inspected.creatures,nil,Color3.fromRGB(70,75,105))
     for _,item in ipairs(inspected.creatures) do row(item,nil,Color3.fromRGB(60,65,95)) end
    end
   else row("Loading player list...",nil,Color3.fromRGB(70,75,105)) end
  end
 elseif mode=="help" then
  title.Text="HOW TO PLAY"
  row("1. At your red roll station, pull the lever and buy one Head, Chest, Arms and Legs.",nil,Color3.fromRGB(70,75,105))
  row("2. Use the purple assembly pod to combine your four owned parts.",nil,Color3.fromRGB(70,75,105))
  row("3. Place your creature on a yellow stand. It earns cash and levels up while placed.",nil,Color3.fromRGB(70,75,105))
  row("4. Step on the green ATM pad or tap the cash counter to collect your earnings.",nil,Color3.fromRGB(70,75,105))
  row("5. Upgrade, then open REBIRTH to see the cash and creature you must sacrifice.",nil,Color3.fromRGB(70,75,105))
  row("Tier odds show the chance of the rarity tier, not an individual part or mutation. Auto-roll spends cash!",nil,Color3.fromRGB(70,75,105))
 elseif mode=="travel" then
  title.Text="TRAVEL AROUND YOUR PLOT"
  row("ROLL STATION",function() remote:FireServer("teleport","lever"); panel.Visible=false end)
  row("ASSEMBLY POD",function() remote:FireServer("teleport","pod"); panel.Visible=false end)
  row("CASH ATM",function() remote:FireServer("teleport","atm"); panel.Visible=false end)
  row("FUSION FORGE",function() remote:FireServer("teleport","forge"); panel.Visible=false end)
  row("TRADING HUB PORTAL",function() remote:FireServer("teleport","portal"); panel.Visible=false end)
 elseif mode=="bag" then
  title.Text="BACKPACK — "..bagTab
  row("TAB: "..bagTab.." (tap to change)",function()
   if bagTab=="All" then bagTab="Body Parts" elseif bagTab=="Body Parts" then bagTab="Brainrots" elseif bagTab=="Brainrots" then bagTab="Boosts" else bagTab="All" end
   selectedSell=nil; confirmBulk=nil; bagPage=1; render()
  end,Color3.fromRGB(70,75,105))
  if bagTab=="Boosts" then
   local extras=state.extras or {}
   row("USE 3x LUCK POTION (15 min) — "..(extras.luckPotions or 0).." owned",function() remote:FireServer("useLuckPotion") end,Color3.fromRGB(125,75,175))
   row("Free-part vouchers: "..(extras.rollVouchers or 0).." | Rare blueprints: "..(state.rareBlueprints or 0).." — use at assembly.",nil,Color3.fromRGB(70,75,105))
  else
   row("Parts "..#state.parts.."/"..state.partCapacity.." | Creatures "..#state.creatures.."/100",nil,Color3.fromRGB(70,75,105))
   local search=Instance.new("TextBox"); search.Size=UDim2.new(1,-10,0,50); search.BackgroundColor3=Color3.fromRGB(60,65,95); search.TextColor3=Color3.new(1,1,1)
   search.Text=bagDraft; search.PlaceholderText="Search names, part types or mutations"; search.ClearTextOnFocus=false; search.Font=Enum.Font.GothamBold; search.TextSize=16
   search.Parent=list; rowOrder+=1; search.LayoutOrder=rowOrder; round(search)
   search:GetPropertyChangedSignal("Text"):Connect(function() bagDraft=string.sub(search.Text,1,80) end)
   row("APPLY SEARCH"..(bagQuery~="" and (": "..bagQuery) or ""),function()
    bagQuery=bagDraft; bagPage=1; selectedSell=nil; confirmBulk=nil; render()
   end,Color3.fromRGB(60,120,180))
   row("PROTECTION: "..bagProtection.." (tap to change)",function()
    if bagProtection=="All" then bagProtection="Protected" elseif bagProtection=="Protected" then bagProtection="Unprotected" else bagProtection="All" end
    bagPage=1; selectedSell=nil; confirmBulk=nil; render()
   end,Color3.fromRGB(70,75,105))
   row("SORT: "..bagSort.." (tap to change)",function()
    if bagSort=="Newest" then bagSort="Rarity" elseif bagSort=="Rarity" then bagSort="Income" elseif bagSort=="Income" then bagSort="Name" else bagSort="Newest" end
    bagPage=1; selectedSell=nil; confirmBulk=nil; render()
   end,Color3.fromRGB(70,75,105))
   if selectedSell then
    row((selectedSell.locked and "UNPROTECT " or "PROTECT ")..selectedSell.name,function()
     remote:FireServer("setItemLock",{category=selectedSell.category,id=selectedSell.id,locked=not selectedSell.locked}); selectedSell=nil; confirmBulk=nil
    end,Color3.fromRGB(60,120,180))
    if selectedSell.locked then row("Protected items cannot be sold, crafted, fused or sacrificed.",nil,Color3.fromRGB(70,75,105))
    else
     row("CONFIRM SELL "..selectedSell.name.." for $"..selectedSell.value,function()
      remote:FireServer(selectedSell.action,selectedSell.id); selectedSell=nil
     end,Color3.fromRGB(200,65,85))
    end
    if selectedSell.category=="creature" then
     row("LEVEL UP "..selectedSell.name.." for $"..selectedSell.levelCost,function() remote:FireServer("level",selectedSell.id); selectedSell=nil end,Color3.fromRGB(52,170,105))
    end
    row("CANCEL SELECTION",function() selectedSell=nil; render() end,Color3.fromRGB(70,75,105))
   end
   if bagTab~="Brainrots" then
    row("BULK SELL UP TO "..Config.Rarities[bulkRarity].name.." (tap to change rarity)",function() bulkRarity=bulkRarity%#Config.Rarities+1; confirmBulk=nil; render() end,Color3.fromRGB(85,85,120))
    local ids={}; local value=0
    for _,item in ipairs(state.parts) do if not item.locked and item.rarity<=bulkRarity then table.insert(ids,item.id); value+=Config.PartSellValue(item) end end
    local count=confirmBulk and #confirmBulk.ids or #ids
    local shownValue=confirmBulk and confirmBulk.value or value
    row((confirmBulk and "CONFIRM SELL " or "SELL ")..count.." parts for $"..shownValue.." — ALL unprotected parts, any mutation; ignores filters",function()
     if confirmBulk then
      remote:FireServer("bulkSellParts",{rarity=confirmBulk.rarity,ids=confirmBulk.ids}); confirmBulk=nil
     elseif #ids>0 then confirmBulk={rarity=bulkRarity,ids=ids,value=value}; selectedSell=nil; render() end
    end,Color3.fromRGB(185,60,85))
    if confirmBulk then row("CANCEL BULK SALE",function() confirmBulk=nil; render() end,Color3.fromRGB(70,75,105)) end
   end
   local entries=InventoryView.build(state.parts,state.creatures,bagTab,bagQuery,bagProtection,bagSort,Config.Income)
   local page,current,pages=InventoryView.page(entries,bagPage,20); bagPage=current
   row("PAGE "..current.." / "..pages.." | "..#entries.." matching items",nil,Color3.fromRGB(70,75,105))
   if current>1 then row("PREVIOUS PAGE",function() bagPage-=1; selectedSell=nil; render() end,Color3.fromRGB(60,120,180)) end
   if current<pages then row("NEXT PAGE",function() bagPage+=1; selectedSell=nil; render() end,Color3.fromRGB(60,120,180)) end
   for _,entry in ipairs(page) do
    local item=entry.item; local protected=item.locked and "[PROTECTED] " or ""
    if entry.category=="part" then
     row(protected..(item.mutation or "Standard").." "..item.name.." "..item.kind.." ["..Config.Rarities[item.rarity].name.."] | sell $"..Config.PartSellValue(item),function()
      selectedSell={name=item.name.." "..item.kind,value=Config.PartSellValue(item),id=item.id,action="sellPart",category="part",locked=item.locked==true}; confirmBulk=nil; list.CanvasPosition=Vector2.zero; render()
     end,Config.Rarities[item.rarity].color)
    else
     row(protected..(item.ascended and "ASCENDED " or "")..(item.blueprintApplied and "[BLUEPRINT] " or "")..item.name.." Lv."..item.level.." | $"..math.floor(entry.income).."/s | "..(item.stand==0 and "Unplaced" or "Stand "..item.stand),function()
      selectedSell={name=item.name,value=Config.CreatureSellValue(item),id=item.id,action="sellCreature",category="creature",locked=item.locked==true,levelCost=Config.LevelCost(item)}; confirmBulk=nil; list.CanvasPosition=Vector2.zero; render()
     end,Config.Rarities[entry.rarity].color)
    end
   end
  end
 end
 task.defer(function()
  if panel.Visible then list.CanvasPosition=previousScroll end
 end)
end
rewards.Activated:Connect(function() list.CanvasPosition=Vector2.zero; mode="rewards"; panel.Visible=true; render() end)
slots.Activated:Connect(function() list.CanvasPosition=Vector2.zero; mode="upgrades"; panel.Visible=true; render() end)
travel.Activated:Connect(function() list.CanvasPosition=Vector2.zero; mode="travel"; panel.Visible=true; render() end)
rebirth.Activated:Connect(function() list.CanvasPosition=Vector2.zero; confirmRebirth=false; mode="rebirth"; panel.Visible=true; render() end)
bag.Activated:Connect(function() list.CanvasPosition=Vector2.zero; selectedSell=nil; confirmBulk=nil; mode="bag"; panel.Visible=true; render() end)
local function updateTutorial()
 local step=state.tutorial and state.tutorial.step or 7
 guidance.Visible=step<7
 if step<7 then
  local instruction=Config.TutorialText[step] or ""
  if step==3 then
   local found={}; for _,item in ipairs(state.parts) do found[item.kind]=true end
   local missing={}; for _,kind in ipairs(Config.Types) do if not found[kind] then table.insert(missing,kind) end end
   if #missing>0 then instruction="Still need: "..table.concat(missing,", ") end
  end
  guidance.Text="GOAL "..step.."/6: "..instruction.."  (+$1,000 on completion)"
 end
 local world=workspace:FindFirstChild("GeneratedWorld")
 local plot=world and world:FindFirstChild("Plot"..tostring(state.plotIndex))
 local targetName=(step<=3 and "Roll station") or (step==4 and "Assembly pod") or (step==5 and "Stand 1") or (step==6 and "Cash ATM") or nil
 local target=plot and targetName and plot:FindFirstChild(targetName)
 guideHighlight.Adornee=target
 guideHighlight.Enabled=step<7 and target~=nil
end
task.spawn(function()
 while true do task.wait(2); if loaded then updateTutorial() end end
end)
local tint=Instance.new("ColorCorrectionEffect"); tint.Name="BrainrotEventTint"; tint.Enabled=false; tint.Parent=Lighting
local function updateEvent(flags)
 if not flags then return end
 if flags.eclipse then tint.TintColor=Color3.fromRGB(255,170,175); tint.Enabled=true
 elseif flags.storm then tint.TintColor=Color3.fromRGB(255,235,155); tint.Enabled=true
 elseif flags.frenzy then tint.TintColor=Color3.fromRGB(215,180,255); tint.Enabled=true
 elseif flags.sigma then tint.TintColor=Color3.fromRGB(180,225,255); tint.Enabled=true
 else tint.Enabled=false end
end
remote.OnClientEvent:Connect(function(data)
 if data.oddsSnapshot then
  catalogOdds=data.odds; if mode=="catalog" and panel.Visible then render() end
  return
 end
 if data.adminSnapshot then
  adminData=data; pendingAdmin=nil; if data.inspected then adminTarget=data.inspected.id end
  if mode=="admin" then render() end
  return
 end
 if data.announcement then notice.Text=data.announcement; playEffect("rare"); return end
 if data.effectOnly then playEffect(data.effectOnly); return end
 if data.effect then playEffect(data.effect) end
 if data.tick then updateEvent(data.eventFlags); state.serverDay=data.serverDay; state.income=data.income or state.income; state.giftElapsed=data.giftElapsed; state.luckRemaining=data.luckRemaining; state.tripleLuckRemaining=data.tripleLuckRemaining; state.rollRemaining=data.rollRemaining; eventLabel.Text=(data.event or "")..((data.luckRemaining or 0)>0 and " | 2x boost "..data.luckRemaining.."s" or "")..((data.tripleLuckRemaining or 0)>0 and " | 3x boost "..data.tripleLuckRemaining.."s" or ""); refreshTimedLabels(); state.cash=data.cash; state.pending=data.pending; hud.Text="$"..math.floor(state.cash).."  |  Collect $"..math.floor(state.pending).."  |  R"..(state.rebirth or 0); return end
 if data.open then list.CanvasPosition=Vector2.zero; if data.open=="assemble" then chosen={}; useBlueprint=false; craftConfirm=false end; if data.open=="forge" then forgeIds={}; forgeConfirm=false end; if data.open=="roll" then discardConfirm=false end; mode=data.open; stand=data.stand or 0; panel.Visible=true; render(); return end
 state=data; updateEvent(data.eventFlags); eventLabel.Text=(data.event or "")..((data.luckRemaining or 0)>0 and " | 2x boost "..data.luckRemaining.."s" or "")..((data.tripleLuckRemaining or 0)>0 and " | 3x boost "..data.tripleLuckRemaining.."s" or ""); loaded=true; updateTutorial()
 if data.message and data.message~="" then notice.Text=data.message end
 render()
end)

task.spawn(function()
 while not loaded do remote:FireServer("sync"); task.wait(2) end
end)
