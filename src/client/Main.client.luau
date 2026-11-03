--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local Lighting=game:GetService("Lighting")
local UserInputService=game:GetService("UserInputService")
local Config=require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local AutoFill=require(ReplicatedStorage.Shared:WaitForChild("AutoFill"))
local CraftMath=require(ReplicatedStorage.Shared:WaitForChild("CraftMath"))
local CraftPicker=require(ReplicatedStorage.Shared:WaitForChild("CraftPicker"))
local FusionRecipe=require(ReplicatedStorage.Shared:WaitForChild("FusionRecipe"))
local InventoryView=require(ReplicatedStorage.Shared:WaitForChild("InventoryView"))
local SeasonRewards=require(ReplicatedStorage.Shared:WaitForChild("SeasonRewards"))
local UILayout=require(ReplicatedStorage.Shared:WaitForChild("UILayout"))
local remote=ReplicatedStorage:WaitForChild("GameAction")
local player=Players.LocalPlayer
local sounds={}
local localSettings={mute=false,hideTint=false}
local updateEvent
local function playEffect(name)
 if localSettings.mute then return end
 local id=Config.AudioIds[name]
 if type(id)~="number" or id<=0 then return end
 if not sounds[name] then
  local sound=Instance.new("Sound"); sound.Name="Brainrot_"..name; sound.SoundId="rbxassetid://"..id; sound.Volume=0.5; sound.Parent=SoundService; sounds[name]=sound
 end
 sounds[name]:Play()
end
local gui=Instance.new("ScreenGui"); gui.Name="BrainrotUI"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.Parent=player:WaitForChild("PlayerGui")
local root=Instance.new("Frame"); root.Name="SafeArea"; root.Size=UDim2.fromScale(1,1); root.BackgroundTransparency=1; root.BorderSizePixel=0; root.Parent=gui
local function round(frame)
 local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,12); corner.Parent=frame
 local stroke=Instance.new("UIStroke"); stroke.Thickness=2; stroke.Color=Color3.fromRGB(28,25,53); stroke.Parent=frame
end
local function button(parent,text,size,pos,color)
 local b=Instance.new("TextButton"); b.Size=size; b.Position=pos; b.BackgroundColor3=color or Color3.fromRGB(105,70,220)
 b.Text=text; b.TextScaled=true; local limit=Instance.new("UITextSizeConstraint"); limit.MinTextSize=10; limit.MaxTextSize=16; limit.Parent=b; b.TextColor3=(b.BackgroundColor3.R*0.299+b.BackgroundColor3.G*0.587+b.BackgroundColor3.B*0.114)>0.68 and Color3.fromRGB(22,24,45) or Color3.new(1,1,1); b.Font=Enum.Font.GothamBold; b.TextSize=16; b.TextWrapped=true; b.Parent=parent; round(b); return b
end
local hud=button(root,"Loading...",UDim2.new(0.4,0,0,55),UDim2.new(0.02,0,0,8),Color3.fromRGB(38,42,72))
hud.Activated:Connect(function() remote:FireServer("collect") end)
local bag=button(root,"BACKPACK",UDim2.new(0,120,0,48),UDim2.new(1,-130,0,8))
local slots=button(root,"UPGRADES",UDim2.new(0,120,0,48),UDim2.new(1,-130,0,62),Color3.fromRGB(230,135,40))

local travel=button(root,"TRAVEL",UDim2.new(0,120,0,48),UDim2.new(1,-130,0,170),Color3.fromRGB(39,145,180))
local rewards=button(root,"REWARDS",UDim2.new(0,120,0,48),UDim2.new(1,-130,0,224),Color3.fromRGB(66,155,115))
local rebirth=button(root,"REBIRTH",UDim2.new(0,120,0,48),UDim2.new(1,-130,0,116),Color3.fromRGB(218,65,135))
local eventLabel=Instance.new("TextLabel"); eventLabel.BackgroundTransparency=1; eventLabel.Size=UDim2.new(1,-155,0,28); eventLabel.Position=UDim2.new(0.02,0,0,98); eventLabel.TextColor3=Color3.fromRGB(255,225,80); eventLabel.TextStrokeTransparency=0; eventLabel.Font=Enum.Font.GothamBold; eventLabel.TextScaled=true; eventLabel.Parent=root
local notice=Instance.new("TextLabel"); notice.BackgroundTransparency=1; notice.Size=UDim2.new(1,-155,0,30); notice.Position=UDim2.new(0.02,0,0,67); notice.TextColor3=Color3.new(1,1,1); notice.TextStrokeTransparency=0; notice.Font=Enum.Font.GothamBold; notice.TextScaled=true; notice.Parent=root
local guidance=Instance.new("TextLabel"); guidance.Size=UDim2.new(1,-155,0,42); guidance.Position=UDim2.new(0.02,0,0,130)
guidance.BackgroundColor3=Color3.fromRGB(105,75,30); guidance.TextColor3=Color3.new(1,1,1); guidance.TextWrapped=true
guidance.Font=Enum.Font.GothamBold; guidance.TextSize=14; guidance.TextScaled=true; guidance.Visible=false; guidance.Parent=root; local guideLimit=Instance.new("UITextSizeConstraint"); guideLimit.MinTextSize=10; guideLimit.MaxTextSize=14; guideLimit.Parent=guidance; round(guidance)
local guideHighlight=Instance.new("Highlight"); guideHighlight.Name="TutorialTarget"; guideHighlight.FillColor=Color3.fromRGB(255,220,60)
guideHighlight.OutlineColor=Color3.new(1,1,1); guideHighlight.FillTransparency=0.65; guideHighlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; guideHighlight.Enabled=false; guideHighlight.Parent=workspace
local panel=Instance.new("Frame"); panel.Size=UDim2.new(0.85,0,0.68,0); panel.Position=UDim2.new(0.075,0,0.2,0); panel.BackgroundColor3=Color3.fromRGB(37,39,70); panel.Visible=false; panel.Parent=root; round(panel)
local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,-70,0,45); title.BackgroundTransparency=1; title.TextColor3=Color3.new(1,1,1); title.Font=Enum.Font.GothamBold; title.TextSize=20; title.TextScaled=true; title.TextWrapped=true; title.Parent=panel
local titleLimit=Instance.new("UITextSizeConstraint"); titleLimit.MinTextSize=10; titleLimit.MaxTextSize=20; titleLimit.Parent=title
local close=button(panel,"X",UDim2.fromOffset(48,40),UDim2.new(1,-54,0,4),Color3.fromRGB(200,65,85)); close.Activated:Connect(function() panel.Visible=false end)
local list=Instance.new("ScrollingFrame"); list.Size=UDim2.new(1,-20,1,-55); list.Position=UDim2.fromOffset(10,50); list.BackgroundTransparency=1; list.BorderSizePixel=0; list.ScrollBarThickness=7; list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.CanvasSize=UDim2.new(); list.Parent=panel
local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,6); layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Parent=list
local render; local requestRender
local function applyLayout()
 local size=root.AbsoluteSize
 if size.X<1 or size.Y<1 then return end
 local metrics=UILayout.main(size.X,size.Y)
 local nav={bag,slots,rebirth,travel,rewards}
 for i,control in ipairs(nav) do
  control.Size=UDim2.fromOffset(metrics.navWidth,metrics.navHeight)
  control.Position=UDim2.fromOffset(metrics.navX,metrics.margin+(i-1)*(metrics.navHeight+metrics.gap))
 end
 hud.Size=UDim2.fromOffset(metrics.contentWidth,metrics.hudHeight); hud.Position=UDim2.fromOffset(metrics.margin,metrics.margin)
 local noticeY=metrics.margin+metrics.hudHeight+metrics.gap
 notice.Size=UDim2.fromOffset(metrics.contentWidth,metrics.lineHeight); notice.Position=UDim2.fromOffset(metrics.margin,noticeY)
 eventLabel.Size=UDim2.fromOffset(metrics.contentWidth,metrics.lineHeight); eventLabel.Position=UDim2.fromOffset(metrics.margin,noticeY+metrics.lineHeight+metrics.gap)
 guidance.Size=UDim2.fromOffset(metrics.contentWidth,math.min(42,math.max(1,size.Y-noticeY-2*metrics.lineHeight-2*metrics.gap)))
 guidance.Position=UDim2.fromOffset(metrics.margin,noticeY+2*metrics.lineHeight+2*metrics.gap)
 panel.ZIndex=5; panel.AnchorPoint=Vector2.new(0.5,0.5); panel.Position=UDim2.fromScale(0.5,0.5); panel.Size=UDim2.fromOffset(metrics.panelWidth,metrics.panelHeight)
 if panel.Visible and requestRender then task.defer(function() if panel.Visible then requestRender() end end) end
end
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyLayout)
applyLayout()
local state={cash=0,pending=0,slots=1,standsUnlocked=12,plotIndex=0,tutorial={step=1},theme="Classic",passes={},partCapacity=100,backpackUpgrades=0,rareBlueprints=0,autoRolling=false,autoCollect=false,income={placed=0,normal=0,online=0,offline=0},autoRun=nil,rebirth=0,isAdmin=false,rebirthCost=1000,target="Dirt Boy",parts={},creatures={},rolls={},progress={dailyLastDay=-1,dailyStreak=0,questDay=-1,rolls=0,rareCrafts=0,collected=0,claimed={}},quests={},season={xp=0,claimed=0,rollProgress=0},extras={luckPotions=0,rollVouchers=0,goldenLever=false,sigmaStatue=false,ohioCrown=false},serverDay=0,giftClaims={},giftElapsed=0,luckRemaining=0,rollRemaining=0}
local loaded=false
local mode=""; local stand=0; local chosen={}; local rowOrder=0
local bagTab="All"; local selectedSell=nil; local levelReview=nil; local rebirthSelected=nil; local rebirthQuote=nil
local bulkRarity=1; local confirmBulk=nil
local bagQuery=""; local bagDraft=""; local bagProtection="All"; local bagSort="Newest"; local bagPage=1
local forgeIds={}; local forgeConfirm=false; local useBlueprint=false; local craftConfirm=false
local craftKind="Head"; local craftPage=1; local craftQuery=""; local craftDraft=""; local craftSort="Newest"
local forgePage=1; local forgeQuery=""; local forgeDraft=""
local standPage=1; local standQuery=""; local standDraft=""; local standSort="Income"
local autoRules={"skip","skip","hold","hold","hold","hold","hold","hold"}
local autoMaxSpend="10000"; local autoMaxPrice="1000"; local autoMaxBatches="50"; local autoConfirm=false; local discardConfirm=false
local giftButtons={}
local incomeLabels={}
local catalogOdds=nil; local catalogRarity=0; local catalogUnlockedOnly=false
local catalogQuery=""; local catalogDraft=""; local catalogPage=1
local seasonPage=1
local adminData=nil; local adminTarget=nil; local adminAmount="1000"; local adminCatalog=1; local adminKind=1; local pendingAdmin=nil
local function row(text, callback, color)
 local b=button(list,text,UDim2.new(1,-10,0,UILayout.rowHeight(text,math.max(200,panel.AbsoluteSize.X))),UDim2.new(),color)
 rowOrder+=1; b.LayoutOrder=rowOrder
 if callback then b.Activated:Connect(callback) end
 return b
end
local function searchField(draft,placeholder,onChange)
 local field=Instance.new("TextBox"); field.Size=UDim2.new(1,-10,0,50); field.BackgroundColor3=Color3.fromRGB(60,65,95); field.TextColor3=Color3.new(1,1,1)
 field.Text=draft; field.PlaceholderText=placeholder; field.ClearTextOnFocus=false; field.Font=Enum.Font.GothamBold; field.TextSize=16
 field.Parent=list; rowOrder+=1; field.LayoutOrder=rowOrder; round(field)
 field:GetPropertyChangedSignal("Text"):Connect(function() onChange(string.sub(field.Text,1,80)) end)
end
local function questRewardTools(extras)
 row("USE 2x LUCK POTION (10 min) — "..(extras.doubleLuckPotions or 0).." owned",function() remote:FireServer("useDoubleLuckPotion") end,Color3.fromRGB(125,75,175))
 row("OPEN UNCOMMON MYSTERY BOX — "..(extras.uncommonBoxes or 0).." owned",function() remote:FireServer("openUncommonBox") end,Color3.fromRGB(60,145,150))
 row("OPEN STANDARD ROLL CRATE — "..(extras.standardBoxes or 0).." owned",function() remote:FireServer("openStandardBox") end,Color3.fromRGB(60,145,150))
 row("Free Standard Roll Crate: 80% Common, 20% Uncommon; uniform archetype within its tier and 25% per part type. Standard mutation; luck/rebirth do not affect odds.",nil,Color3.fromRGB(70,75,105))
 local count=0; for _,entry in ipairs(Config.Catalog) do if entry.rarity==2 then count+=1 end end
 row("Each free box gives one Standard Uncommon part. "..count.." archetypes and 4 part types are uniform (1 in "..(count*4).." per combination), regardless of luck or rebirth. Requires space.",nil,Color3.fromRGB(70,75,105))
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
render=function()
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
  row("CHOOSE A SOCKET",nil,Color3.fromRGB(70,75,105))
  for _,kind in ipairs(Config.Types) do
   local picked=components[kind]
   row((craftKind==kind and "▶ " or "")..kind..": "..(picked and ((picked.mutation or "Standard").." "..picked.name.." ["..Config.Rarities[picked.rarity].name.."] #"..string.sub(picked.id,-6)) or "empty"),function()
    craftKind=kind; craftPage=1; craftConfirm=false; render()
   end,craftKind==kind and Color3.fromRGB(60,120,180) or Color3.fromRGB(70,75,105))
  end
  if chosen[craftKind] then row("CLEAR "..craftKind.." SOCKET",function() chosen[craftKind]=nil; craftConfirm=false; render() end,Color3.fromRGB(150,65,65)) end
  searchField(craftDraft,"Search part names or mutations",function(v) craftDraft=v end)
  row("APPLY PART SEARCH"..(craftQuery~="" and (": "..craftQuery) or ""),function() craftQuery=craftDraft; craftPage=1; render() end,Color3.fromRGB(60,120,180))
  row("SORT PARTS: "..craftSort.." (tap to change)",function()
   if craftSort=="Newest" then craftSort="Rarity" elseif craftSort=="Rarity" then craftSort="Contribution" elseif craftSort=="Contribution" then craftSort="Name" else craftSort="Newest" end
   craftPage=1; render()
  end,Color3.fromRGB(70,75,105))
  local entries=CraftPicker.parts(state.parts,craftKind,craftQuery,useBlueprint,craftSort)
  local page,current,pages=InventoryView.page(entries,craftPage,12); craftPage=current
  row(craftKind.." | PAGE "..current.." / "..pages.." | "..#entries.." eligible parts",nil,Color3.fromRGB(70,75,105))
  if current>1 then row("PREVIOUS PART PAGE",function() craftPage-=1; render() end,Color3.fromRGB(60,120,180)) end
  if current<pages then row("NEXT PART PAGE",function() craftPage+=1; render() end,Color3.fromRGB(60,120,180)) end
  for _,entry in ipairs(page) do
   local item=entry.item
   row((chosen[craftKind]==item.id and "✓ " or "")..(item.mutation or "Standard").." "..item.name.." ["..Config.Rarities[item.rarity].name.."] | contribution "..string.format("%.4g",item.income*(item.mutationMultiplier or 1)).." #"..string.sub(item.id,-6),function()
    chosen[item.kind]=item.id; craftConfirm=false; render()
   end,Config.Rarities[item.rarity].color)
  end
  if #entries==0 then row("No eligible parts match. Protected parts and blueprint-ineligible parts are hidden.",nil,Color3.fromRGB(70,75,105)) end
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
  local valid=state.rebirth>=15 and #forgeIds==3 and first and first.income*5<=CraftMath.MaxIncome and state.cash>=fee
  for _,id in ipairs(forgeIds) do
   local selected=nil; for _,c in ipairs(state.creatures) do if c.id==id then selected=c; break end end
   if not FusionRecipe.eligible(selected) or not FusionRecipe.matches(first,selected) then valid=false end
   row("REMOVE SELECTED: "..(selected and (selected.name.." Lv."..selected.level) or "no longer available").." #"..string.sub(id,-6),function()
    for i,chosenId in ipairs(forgeIds) do if chosenId==id then table.remove(forgeIds,i); break end end
    forgePage=1; forgeConfirm=false; render()
   end,Color3.fromRGB(150,65,65))
  end
  row(forgeConfirm and "CONFIRM: CONSUME 3 CREATURES AND CASH" or "REVIEW FUSION",function()
   if not valid then notice.Text="Choose three matching eligible creatures and check rebirth and cash."; return end
   if forgeConfirm then remote:FireServer("fusion",forgeIds); forgeIds={}; forgeConfirm=false
   else forgeConfirm=true; render() end
  end,Color3.fromRGB(185,100,35))
  if forgeConfirm then row("CANCEL FUSION REVIEW",function() forgeConfirm=false; render() end,Color3.fromRGB(70,75,105)) end
  searchField(forgeDraft,"Search creature names",function(v) forgeDraft=v end)
  row("APPLY CREATURE SEARCH"..(forgeQuery~="" and (": "..forgeQuery) or ""),function() forgeQuery=forgeDraft; forgePage=1; render() end,Color3.fromRGB(60,120,180))
  local entries=CraftPicker.fusion(state.creatures,forgeQuery,first)
  local page,current,pages=InventoryView.page(entries,forgePage,12); forgePage=current
  row("PAGE "..current.." / "..pages.." | "..#entries.." eligible "..(first and "matching " or "").."creatures",nil,Color3.fromRGB(70,75,105))
  if current>1 then row("PREVIOUS CREATURE PAGE",function() forgePage-=1; render() end,Color3.fromRGB(60,120,180)) end
  if current<pages then row("NEXT CREATURE PAGE",function() forgePage+=1; render() end,Color3.fromRGB(60,120,180)) end
  for _,creature in ipairs(page) do
   local selected=false; for _,id in ipairs(forgeIds) do if id==creature.id then selected=true end end
   local text=(selected and "✓ " or "")..(creature.blueprintApplied and "[BLUEPRINT] " or "")..creature.name.." Lv."..creature.level.." | base $"..string.format("%.4g",creature.income).."/s #"..string.sub(creature.id,-6)
   row(text,function()
    if selected then for i,id in ipairs(forgeIds) do if id==creature.id then table.remove(forgeIds,i); break end end
    elseif #forgeIds<3 then table.insert(forgeIds,creature.id) end
    forgePage=1; forgeConfirm=false; render()
   end,selected and Color3.fromRGB(45,150,110) or nil)
  end
  if #entries==0 then row("No matching eligible creatures. Use unplaced, unprotected, non-ascended level 10+ creatures.",nil,Color3.fromRGB(70,75,105)) end
 elseif mode=="stand" then
  title.Text="STAND "..stand..": choose a creature"
  local occupant=nil; local available={}
  for _,c in ipairs(state.creatures) do
   if c.stand==stand then occupant=c elseif c.stand==0 then table.insert(available,c) end
  end
  if occupant then
   row("REMOVE FROM THIS STAND: "..(occupant.ascended and "ASCENDED " or "")..occupant.name.." Lv."..occupant.level.." #"..string.sub(occupant.id,-6),function() remote:FireServer("stand",{stand=stand,id=occupant.id}) end,Color3.fromRGB(185,100,35))
   row("Remove the current creature before placing another.",nil,Color3.fromRGB(70,75,105))
  else row("This stand is empty. Choose an unplaced creature below.",nil,Color3.fromRGB(70,75,105)) end
  searchField(standDraft,"Search creature names",function(v) standDraft=v end)
  row("APPLY CREATURE SEARCH"..(standQuery~="" and (": "..standQuery) or ""),function() standQuery=standDraft; standPage=1; render() end,Color3.fromRGB(60,120,180))
  row("SORT: "..standSort.." (tap to change)",function()
   if standSort=="Income" then standSort="Rarity" elseif standSort=="Rarity" then standSort="Name" elseif standSort=="Name" then standSort="Newest" else standSort="Income" end
   standPage=1; render()
  end,Color3.fromRGB(70,75,105))
  local entries=InventoryView.build({},available,"Brainrots",standQuery,"All",standSort,Config.Income)
  local page,current,pages=InventoryView.page(entries,standPage,12); standPage=current
  row("PAGE "..current.." / "..pages.." | "..#entries.." unplaced creatures",nil,Color3.fromRGB(70,75,105))
  if current>1 then row("PREVIOUS CREATURE PAGE",function() standPage-=1; render() end,Color3.fromRGB(60,120,180)) end
  if current<pages then row("NEXT CREATURE PAGE",function() standPage+=1; render() end,Color3.fromRGB(60,120,180)) end
  for _,entry in ipairs(page) do
   local c=entry.item
   row((c.locked and "[PROTECTED] " or "")..(c.ascended and "ASCENDED " or "")..c.name.." Lv."..c.level.." | $"..string.format("%.4g",entry.income).."/s #"..string.sub(c.id,-6),function()
    if occupant then notice.Text="Remove the current creature first."; return end
    remote:FireServer("stand",{stand=stand,id=c.id})
   end,Config.Rarities[entry.rarity].color)
  end
  if #entries==0 then row("No unplaced creatures match. Creatures on other stands must be removed there first.",nil,Color3.fromRGB(70,75,105)) end
 elseif mode=="rebirth" then
  title.Text="REBIRTH "..(state.rebirth or 0).." / 100"
  if state.rebirth>=100 then row("Maximum rebirth reached",nil) else
   local target=state.target.." Abomination"
   row("REQUIRED: $"..state.rebirthCost.." AND "..target,nil,Color3.fromRGB(70,75,105))
   row("Rebirth resets ALL wallet cash and normally resets roll slots. Pending bank cash, other inventory and stands remain.",nil,Color3.fromRGB(70,75,105))
   row("Rebirth increases tier weights differently by rarity; see the catalog for exact current odds.",nil,Color3.fromRGB(70,75,105))
   local candidates=0; local selected=nil
   for _,creature in ipairs(state.creatures) do
    if creature.name==target then
     candidates+=1
     local reason=creature.locked and "PROTECTED — unlock in backpack" or (creature.ascended and "ASCENDED — cannot sacrifice" or "SELECT")
     if creature.id==rebirthSelected and not creature.locked and not creature.ascended then selected=creature end
     row((creature.id==rebirthSelected and "✓ " or "")..(creature.blueprintApplied and "[BLUEPRINT] " or "")..creature.name.." Lv."..creature.level.." | "..(creature.stand==0 and "Unplaced" or "Stand "..creature.stand).." | "..reason,function()
      if not creature.locked and not creature.ascended then rebirthSelected=creature.id; rebirthQuote=nil; render() end
     end,creature.id==rebirthSelected and Color3.fromRGB(45,150,110) or Color3.fromRGB(70,75,105))
    end
   end
   if candidates==0 then row("No matching creature owned. Assemble the required target first.",nil,Color3.fromRGB(150,65,65)) end
   if selected then
    row("SELECTED: Lv."..selected.level.." | base $"..string.format("%.4g",selected.income).."/s | "..(selected.blueprintApplied and "Blueprint boosted" or "No blueprint"),nil,Color3.fromRGB(70,75,105))
    row("REVIEW SELECTED REBIRTH",function() rebirthQuote=nil; remote:FireServer("rebirthReview",selected.id); notice.Text="Requesting server review..." end,Color3.fromRGB(210,120,45))
   end
   if rebirthQuote and selected and rebirthQuote.id==selected.id then
    local q=rebirthQuote
    row("SERVER REVIEW — valid for 30 seconds; changes require another review.",nil,Color3.fromRGB(150,85,45))
    row("SACRIFICE: "..q.name.." Lv."..q.level.." | "..(q.stand==0 and "Unplaced" or "Stand "..q.stand).." | "..(q.blueprint and "Blueprint boosted" or "No blueprint"),nil,Color3.fromRGB(150,65,65))
    for _,kind in ipairs(Config.Types) do
     local component=q.components[kind]
     row(kind..": "..component.name.." ["..Config.Rarities[component.rarity].name.."] "..component.mutation.." x"..component.multiplier,nil,Color3.fromRGB(70,75,105))
    end
    row("RESET: ALL $"..math.floor(q.cash).." wallet cash | slots "..(q.keepSlots and "retained" or (q.slots.." → 1")).." | "..#q.offers.." unpurchased offers discarded",nil,Color3.fromRGB(150,65,65))
    row("CONFIRM: SACRIFICE THIS CREATURE AND REBIRTH",function()
     remote:FireServer("rebirthConfirm",q.token); rebirthQuote=nil; rebirthSelected=nil
    end,Color3.fromRGB(200,65,85))
    row("CANCEL REVIEW",function() rebirthQuote=nil; remote:FireServer("cancelRebirthReview"); render() end,Color3.fromRGB(70,75,105))
   end
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
  questRewardTools(extras)
  row("Free-part vouchers: "..(extras.rollVouchers or 0).." — use at roll station; rolls are already free.",nil,Color3.fromRGB(70,75,105))
  row("Golden Lever: "..(extras.goldenLever and "unlocked (+5% non-common weight)" or "locked").." | Sigma Statue: "..(extras.sigmaStatue and "unlocked (+50% income)" or "locked"),nil,Color3.fromRGB(70,75,105))
  for _,quest in ipairs(state.quests) do
   local value=p[quest.key] or 0
   local status=p.claimed[quest.key] and "CLAIMED" or (value>=quest.goal and "CLAIM" or "IN PROGRESS")
   row(quest.label.."  "..value.."/"..quest.goal.." | "..quest.rewardLabel.." + "..quest.xp.." season XP — "..status,function() remote:FireServer("claimQuest",quest.key) end,Color3.fromRGB(90,80,150))
  end
  row("CATALOG & ROLL ODDS",function() catalogOdds=nil; mode="catalog"; list.CanvasPosition=Vector2.zero; remote:FireServer("requestOdds"); render() end,Color3.fromRGB(60,120,180))
  row("OPEN FREE SEASON TRACK",function() seasonPage=1; mode="season"; list.CanvasPosition=Vector2.zero; render() end,Color3.fromRGB(120,75,180))
  row("SESSION GIFTS — timers reset when you leave",nil,Color3.fromRGB(70,75,105))
  for _,gift in ipairs(Config.SessionGifts) do
   local b=row(giftText(gift),function() remote:FireServer("claimGift",gift.id) end,Color3.fromRGB(155,105,45))
   giftButtons[gift.id]=b
  end
  local total=0; for i=4,#Config.Rarities do total+=Config.Rarities[i].weight end
  local odds={}; for i=4,#Config.Rarities do table.insert(odds,Config.Rarities[i].name.." "..string.format("%.2f%%",100*Config.Rarities[i].weight/total)) end
  row("60m Epic+ gift tier odds: "..table.concat(odds,", ")..". Standard mutation; any rebirth.",nil,Color3.fromRGB(70,75,105))
  if state.isAdmin then row("DEVELOPER ADMIN",function() pendingAdmin=nil; mode="admin"; list.CanvasPosition=Vector2.zero; remote:FireServer("adminOpen",adminTarget); render() end,Color3.fromRGB(155,65,65)) end
  row("ACCESSIBILITY SETTINGS",function() mode="settings"; list.CanvasPosition=Vector2.zero; render() end,Color3.fromRGB(60,120,180))
  row("REFRESH GAME STATE FROM SERVER",function() remote:FireServer("sync"); notice.Text="Requesting current game state..." end,Color3.fromRGB(60,120,180))
  row("HOW TO PLAY",function() mode="help"; list.CanvasPosition=Vector2.zero; render() end,Color3.fromRGB(60,120,180))
 elseif mode=="season" then
  title.Text="FREE SEASON TRACK"
  local season=state.season or {xp=0,claimed=0,rollProgress=0}
  local unlocked=math.floor(season.xp/100)
  row("Season XP: "..season.xp.." / 5000 | tiers unlocked: "..unlocked.." / 50",nil,Color3.fromRGB(70,75,105))
  row("Earn XP: +1 per part rolled, +20 per assembly, +100 per rebirth; daily quests award 50/75/100.",nil,Color3.fromRGB(70,75,105))
  row("Permanent season part slots: +"..SeasonRewards.bonusSlots(season.claimed).." | +5 at claimed tiers 10, 30 and 50.",nil,Color3.fromRGB(70,75,105))
  local nextTier=season.claimed+1
  if nextTier<=50 then
   local reward=SeasonRewards.reward(nextTier)
   row("TIER "..nextTier.." — "..reward.label.." — "..(nextTier<=unlocked and "CLAIM" or "LOCKED"),function() remote:FireServer("claimSeason") end,Color3.fromRGB(120,75,180))
  else row("All 50 free tiers claimed!",nil,Color3.fromRGB(52,170,105)) end
  local tiers={}; for i=1,50 do table.insert(tiers,i) end
  local shown,current,pages=InventoryView.page(tiers,seasonPage,10); seasonPage=current
  row("REWARD PREVIEW PAGE "..current.." / "..pages,nil,Color3.fromRGB(70,75,105))
  if current>1 then row("PREVIOUS SEASON PAGE",function() seasonPage-=1; render() end,Color3.fromRGB(60,120,180)) end
  if current<pages then row("NEXT SEASON PAGE",function() seasonPage+=1; render() end,Color3.fromRGB(60,120,180)) end
  for _,tier in ipairs(shown) do
   local reward=SeasonRewards.reward(tier)
   local status=tier<=season.claimed and "CLAIMED" or (tier<=unlocked and "UNLOCKED (claim in order)" or "LOCKED")
   row("TIER "..tier.." — "..reward.label.." — "..status,nil,Color3.fromRGB(70,75,105))
  end
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
 elseif mode=="settings" then
  title.Text="ACCESSIBILITY — THIS SESSION"
  local reduced=player:GetAttribute("ReduceDisplayMotion")==true
  row("REDUCE DISPLAY MOTION: "..(reduced and "ON" or "OFF").." (idle movement, rainbow cycling and display particles)",function()
   player:SetAttribute("ReduceDisplayMotion",not reduced); render()
  end,Color3.fromRGB(60,120,180))
  row("MUTE GAME SOUND EFFECTS: "..(localSettings.mute and "ON" or "OFF"),function()
   localSettings.mute=not localSettings.mute
   if localSettings.mute then for _,sound in pairs(sounds) do sound:Stop() end end
   render()
  end,Color3.fromRGB(60,120,180))
  row("HIDE EVENT COLOR TINT: "..(localSettings.hideTint and "ON" or "OFF"),function()
   localSettings.hideTint=not localSettings.hideTint
   if updateEvent then updateEvent(state.eventFlags) end
   render()
  end,Color3.fromRGB(60,120,180))
  row("These settings are local to this play session and do not affect gameplay or other players. They reset when changing places or rejoining.",nil,Color3.fromRGB(70,75,105))
  row("BACK TO REWARDS",function() mode="rewards"; list.CanvasPosition=Vector2.zero; render() end,Color3.fromRGB(70,75,105))
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
  questRewardTools(extras)
   row("Free-part vouchers: "..(extras.rollVouchers or 0).." | Rare blueprints: "..(state.rareBlueprints or 0).." — use at assembly.",nil,Color3.fromRGB(70,75,105))
  else
   row("Parts "..#state.parts.."/"..state.partCapacity.." | Creatures "..#state.creatures.."/100",nil,Color3.fromRGB(70,75,105))
   local search=Instance.new("TextBox"); search.Size=UDim2.new(1,-10,0,50); search.BackgroundColor3=Color3.fromRGB(60,65,95); search.TextColor3=Color3.new(1,1,1)
   search.Text=bagDraft; search.PlaceholderText="Search names, components, types or mutations"; search.ClearTextOnFocus=false; search.Font=Enum.Font.GothamBold; search.TextSize=16
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
   if not selectedSell then levelReview=nil end
   if selectedSell then
    local selected=InventoryView.find(state.parts,state.creatures,selectedSell.category,selectedSell.id)
    if not selected then
     selectedSell=nil; levelReview=nil
     row("Selected item is no longer in your inventory.",nil,Color3.fromRGB(150,65,65))
    else
     local category=selectedSell.category
     local name=selected.name..(category=="part" and (" "..selected.kind) or "")
     local resale=category=="part" and Config.PartSellValue(selected) or Config.CreatureSellValue(selected)
     row("ITEM DETAILS: "..name.." #"..string.sub(selected.id,-6),nil,Color3.fromRGB(60,120,180))
     if category=="part" then
      row(Config.Rarities[selected.rarity].name.." | "..(selected.mutation or "Standard").." x"..(selected.mutationMultiplier or 1).." | base contribution "..string.format("%.4g",selected.income).." | mutated contribution "..string.format("%.4g",selected.income*(selected.mutationMultiplier or 1)),nil,Color3.fromRGB(70,75,105))
      row("Original recorded price: $"..(selected.price or 10).." | resale: $"..resale.." | "..(selected.locked and "Protected" or "Unprotected"),nil,Color3.fromRGB(70,75,105))
     else
      row((selected.ascended and "ASCENDED | " or "")..(selected.blueprintApplied and "BLUEPRINT | " or "")..Config.Rarities[InventoryView.creatureRarity(selected)].name.." | Lv."..selected.level.." | "..(selected.stand==0 and "Unplaced" or "Stand "..selected.stand).." | "..(selected.locked and "Protected" or "Unprotected"),nil,Color3.fromRGB(70,75,105))
      row("Base income $"..string.format("%.4g",selected.income).."/s | Lv."..selected.level.." income $"..string.format("%.4g",Config.Income(selected)).."/s before stand/event bonuses | resale $"..resale,nil,Color3.fromRGB(70,75,105))
      for _,kind in ipairs(Config.Types) do
       local component=selected.components[kind]
       row(kind..": "..component.name.." ["..Config.Rarities[component.rarity].name.."] | "..(component.mutation or "Standard").." x"..(component.mutationMultiplier or 1).." | base contribution "..string.format("%.4g",component.income),nil,Color3.fromRGB(70,75,105))
      end
     end
     row((selected.locked and "UNPROTECT " or "PROTECT ")..name,function()
      remote:FireServer("setItemLock",{category=category,id=selected.id,locked=not selected.locked}); selectedSell=nil; levelReview=nil; confirmBulk=nil
     end,Color3.fromRGB(60,120,180))
     if selected.locked then row("Protected items cannot be sold, crafted, fused or sacrificed.",nil,Color3.fromRGB(70,75,105))
     elseif category=="creature" and selected.stand>0 then row("Remove this creature from its stand before selling.",nil,Color3.fromRGB(70,75,105))
     else
      row("CONFIRM PERMANENT SALE: "..name.." for $"..resale,function()
       remote:FireServer(category=="part" and "sellPart" or "sellCreature",selected.id); selectedSell=nil; levelReview=nil
      end,Color3.fromRGB(200,65,85))
     end
     if category=="creature" then
      if selected.level>=1000 then levelReview=nil; row("Maximum creature level reached.",nil,Color3.fromRGB(70,75,105))
      else
       local cost=Config.LevelCost(selected)
       if levelReview and (levelReview.id~=selected.id or levelReview.level~=selected.level or levelReview.cost~=cost) then levelReview=nil end
       local review=levelReview
       row(review and ("CONFIRM LEVEL UP: Lv."..review.level.." → "..(review.level+1).." for $"..review.cost) or ("REVIEW LEVEL UP: Lv."..selected.level.." → "..(selected.level+1).." for $"..cost),function()
        if review then remote:FireServer("level",review); levelReview=nil
        else levelReview={id=selected.id,level=selected.level,cost=cost}; render() end
       end,Color3.fromRGB(52,170,105))
       if review then row("CANCEL LEVEL UP",function() levelReview=nil; render() end,Color3.fromRGB(70,75,105)) end
      end
     end
     row("CANCEL SELECTION",function() selectedSell=nil; levelReview=nil; render() end,Color3.fromRGB(70,75,105))
    end
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
      selectedSell={id=item.id,category="part"}; levelReview=nil; confirmBulk=nil; list.CanvasPosition=Vector2.zero; render()
     end,Config.Rarities[item.rarity].color)
    else
     row(protected..(item.ascended and "ASCENDED " or "")..(item.blueprintApplied and "[BLUEPRINT] " or "")..item.name.." Lv."..item.level.." | $"..math.floor(entry.income).."/s | "..(item.stand==0 and "Unplaced" or "Stand "..item.stand),function()
      selectedSell={id=item.id,category="creature"}; levelReview=nil; confirmBulk=nil; list.CanvasPosition=Vector2.zero; render()
     end,Config.Rarities[entry.rarity].color)
    end
   end
  end
 end
 task.defer(function()
  if panel.Visible then list.CanvasPosition=previousScroll end
 end)
end
-- Server updates can arrive while a player is typing. Preserve the focused
-- field and apply the latest state after focus is released instead of destroying it.
local pendingRender=false
requestRender=function()
 local focused=UserInputService:GetFocusedTextBox()
 if panel.Visible and focused and focused:IsDescendantOf(list) then
  pendingRender=true
  hud.Text="$"..math.floor(state.cash).."  |  Collect $"..math.floor(state.pending).."  |  R"..(state.rebirth or 0)
  return
 end
 pendingRender=false; render()
end
UserInputService.TextBoxFocusReleased:Connect(function(box)
 if pendingRender and box:IsDescendantOf(list) then task.defer(function() if pendingRender then requestRender() end end) end
end)
rewards.Activated:Connect(function() list.CanvasPosition=Vector2.zero; mode="rewards"; panel.Visible=true; render() end)
slots.Activated:Connect(function() list.CanvasPosition=Vector2.zero; mode="upgrades"; panel.Visible=true; render() end)
travel.Activated:Connect(function() list.CanvasPosition=Vector2.zero; mode="travel"; panel.Visible=true; render() end)
rebirth.Activated:Connect(function() list.CanvasPosition=Vector2.zero; rebirthSelected=nil; rebirthQuote=nil; mode="rebirth"; panel.Visible=true; render() end)
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
updateEvent=function(flags)
 if localSettings.hideTint then tint.Enabled=false; return end
 if not flags then return end
 if flags.eclipse then tint.TintColor=Color3.fromRGB(255,170,175); tint.Enabled=true
 elseif flags.storm then tint.TintColor=Color3.fromRGB(255,235,155); tint.Enabled=true
 elseif flags.frenzy then tint.TintColor=Color3.fromRGB(215,180,255); tint.Enabled=true
 elseif flags.sigma then tint.TintColor=Color3.fromRGB(180,225,255); tint.Enabled=true
 else tint.Enabled=false end
end
remote.OnClientEvent:Connect(function(data)
 if data.rebirthQuote then
  if mode=="rebirth" and panel.Visible and rebirthSelected==data.rebirthQuote.id then rebirthQuote=data.rebirthQuote; render() end
  return
 end
 if data.oddsSnapshot then
  catalogOdds=data.odds; if mode=="catalog" and panel.Visible then requestRender() end
  return
 end
 if data.adminSnapshot then
  adminData=data; pendingAdmin=nil; if data.inspected then adminTarget=data.inspected.id end
  if mode=="admin" then requestRender() end
  return
 end
 if data.announcement then notice.Text=data.announcement; playEffect("rare"); return end
 if data.effectOnly then playEffect(data.effectOnly); return end
 if data.effect then playEffect(data.effect) end
 if data.tick then updateEvent(data.eventFlags); state.serverDay=data.serverDay; state.income=data.income or state.income; state.giftElapsed=data.giftElapsed; state.luckRemaining=data.luckRemaining; state.tripleLuckRemaining=data.tripleLuckRemaining; state.rollRemaining=data.rollRemaining; eventLabel.Text=(data.event or "")..((data.luckRemaining or 0)>0 and " | 2x boost "..data.luckRemaining.."s" or "")..((data.tripleLuckRemaining or 0)>0 and " | 3x boost "..data.tripleLuckRemaining.."s" or ""); refreshTimedLabels(); state.cash=data.cash; state.pending=data.pending; hud.Text="$"..math.floor(state.cash).."  |  Collect $"..math.floor(state.pending).."  |  R"..(state.rebirth or 0); return end
 if data.open then list.CanvasPosition=Vector2.zero; if data.open=="assemble" then chosen={}; useBlueprint=false; craftConfirm=false; craftKind="Head"; craftPage=1; craftQuery=""; craftDraft="" end; if data.open=="forge" then forgeIds={}; forgeConfirm=false; forgePage=1; forgeQuery=""; forgeDraft="" end; if data.open=="roll" then discardConfirm=false end; if data.open=="stand" then standPage=1; standQuery=""; standDraft="" end; mode=data.open; stand=data.stand or 0; panel.Visible=true; render(); return end
 state=data; updateEvent(data.eventFlags); eventLabel.Text=(data.event or "")..((data.luckRemaining or 0)>0 and " | 2x boost "..data.luckRemaining.."s" or "")..((data.tripleLuckRemaining or 0)>0 and " | 3x boost "..data.tripleLuckRemaining.."s" or ""); loaded=true; updateTutorial()
 if data.message and data.message~="" then notice.Text=data.message end
 requestRender()
end)

task.spawn(function()
 -- The reliable RemoteEvent snapshot is server-authoritative. Retry initial
 -- load, then periodically reconcile missed/stale UI state without mutations.
 while true do
  remote:FireServer("sync")
  task.wait(loaded and 30 or 2)
 end
end)
