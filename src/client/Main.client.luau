--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local remote=ReplicatedStorage:WaitForChild("GameAction")
local player=Players.LocalPlayer
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
local rebirth=button(gui,"REBIRTH",UDim2.new(0,120,0,48),UDim2.new(1,-130,0,116),Color3.fromRGB(218,65,135))
local eventLabel=Instance.new("TextLabel"); eventLabel.BackgroundTransparency=1; eventLabel.Size=UDim2.new(0.6,0,0,28); eventLabel.Position=UDim2.new(0.02,0,0,98); eventLabel.TextColor3=Color3.fromRGB(255,225,80); eventLabel.TextStrokeTransparency=0; eventLabel.Font=Enum.Font.GothamBold; eventLabel.TextScaled=true; eventLabel.Parent=gui
local notice=Instance.new("TextLabel"); notice.BackgroundTransparency=1; notice.Size=UDim2.new(0.65,0,0,30); notice.Position=UDim2.new(0.02,0,0,67); notice.TextColor3=Color3.new(1,1,1); notice.TextStrokeTransparency=0; notice.Font=Enum.Font.GothamBold; notice.TextScaled=true; notice.Parent=gui
local panel=Instance.new("Frame"); panel.Size=UDim2.new(0.85,0,0.68,0); panel.Position=UDim2.new(0.075,0,0.2,0); panel.BackgroundColor3=Color3.fromRGB(37,39,70); panel.Visible=false; panel.Parent=gui; round(panel)
local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,-70,0,45); title.BackgroundTransparency=1; title.TextColor3=Color3.new(1,1,1); title.Font=Enum.Font.GothamBold; title.TextSize=20; title.Parent=panel
local close=button(panel,"X",UDim2.fromOffset(48,40),UDim2.new(1,-54,0,4),Color3.fromRGB(200,65,85)); close.Activated:Connect(function() panel.Visible=false end)
local list=Instance.new("ScrollingFrame"); list.Size=UDim2.new(1,-20,1,-55); list.Position=UDim2.fromOffset(10,50); list.BackgroundTransparency=1; list.BorderSizePixel=0; list.ScrollBarThickness=7; list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.CanvasSize=UDim2.new(); list.Parent=panel
local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,6); layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Parent=list
local state={cash=0,pending=0,slots=1,standsUnlocked=12,autoRolling=false,autoRarity=1,rebirth=0,rebirthCost=1000,target="Dirt Boy",parts={},creatures={},rolls={}}
local loaded=false
local mode=""; local stand=0; local chosen={}; local rowOrder=0
local rarityFilter=1; local bagTab="All"; local selectedSell=nil; local confirmRebirth=false
local function row(text, callback, color)
 local b=button(list,text,UDim2.new(1,-10,0,50),UDim2.new(),color)
 rowOrder+=1; b.LayoutOrder=rowOrder
 if callback then b.Activated:Connect(callback) end
end
local function render()
 hud.Text="$"..math.floor(state.cash).."  |  Collect $"..math.floor(state.pending).."  |  R"..(state.rebirth or 0)
 if not panel.Visible then return end
 for _,child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 rowOrder=0
 if mode=="roll" then
  title.Text="ROLL STATION"
  row("PULL LEVER / REROLL",function() remote:FireServer("roll") end,Color3.fromRGB(220,78,93))
  row("Auto-buy rarity: "..Config.Rarities[rarityFilter].name.." and above (tap to change)",function() rarityFilter=rarityFilter%#Config.Rarities+1; render() end,Color3.fromRGB(70,75,105))
  if state.autoRolling then row("STOP AUTO-ROLL",function() remote:FireServer("autoRoll",false) end,Color3.fromRGB(200,65,85))
  else row("START AUTO-ROLL (buys matching parts)",function() remote:FireServer("autoRoll",rarityFilter) end,Color3.fromRGB(52,170,105)) end
  for _,item in ipairs(state.rolls) do
   local rarity=Config.Rarities[item.rarity]
   row("BUY "..(item.mutation or "Standard").." "..item.name.." "..item.kind.." ["..rarity.name.."]  $"..item.price,function() remote:FireServer("buy",item.id) end,rarity.color)
  end
 elseif mode=="assemble" then
  title.Text="ASSEMBLY: select one of each"
  row("AUTO-FILL BEST owned part of each type",function()
   chosen={}
   for _,kind in ipairs(Config.Types) do
    local best=nil; local bestScore=-1
    for _,item in ipairs(state.parts) do
     local score=item.income*(item.mutationMultiplier or 1)*Config.Rarities[item.rarity].multiplier
     if item.kind==kind and score>bestScore then best=item; bestScore=score end
    end
    if best then chosen[kind]=best.id end
   end
   render()
  end,Color3.fromRGB(60,120,180))
  row("ASSEMBLE selected parts",function() remote:FireServer("assemble",chosen); chosen={} end,Color3.fromRGB(52,170,105))
  for _,kind in ipairs(Config.Types) do
   row(kind..": "..(chosen[kind] and "selected" or "choose below"),nil,Color3.fromRGB(70,75,105))
   for _,item in ipairs(state.parts) do
    if item.kind==kind then row((item.mutation or "Standard").." "..item.name.." "..kind..(chosen[kind]==item.id and " ✓" or ""),function() chosen[kind]=item.id; render() end,Config.Rarities[item.rarity].color) end
   end
  end
 elseif mode=="stand" then
  title.Text="STAND "..stand..": choose a creature"
  for _,c in ipairs(state.creatures) do
   row(c.name.." | $"..math.floor(Config.Income(c)).."/s | "..(c.stand==0 and "Unplaced" or "Stand "..c.stand),function() remote:FireServer("stand",{stand=stand,id=c.id}) end)
  end
 elseif mode=="rebirth" then
  title.Text="REBIRTH "..(state.rebirth or 0).." / 100"
  if state.rebirth>=100 then row("Maximum rebirth reached",nil) else
   row("Cost: $"..state.rebirthCost.." | Sacrifice: "..state.target.." Abomination",nil,Color3.fromRGB(70,75,105))
   row("Rebirth resets cash and slots; other items remain. Luck x"..string.format("%.2f",1.15^(state.rebirth+1)),nil,Color3.fromRGB(70,75,105))
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
 elseif mode=="travel" then
  title.Text="TRAVEL AROUND YOUR PLOT"
  row("ROLL STATION",function() remote:FireServer("teleport","lever"); panel.Visible=false end)
  row("ASSEMBLY POD",function() remote:FireServer("teleport","pod"); panel.Visible=false end)
  row("CASH ATM",function() remote:FireServer("teleport","atm"); panel.Visible=false end)
 elseif mode=="bag" then
  title.Text="BACKPACK — "..bagTab
  row("FILTER: "..bagTab.." (tap to change)",function()
   if bagTab=="All" then bagTab="Body Parts" elseif bagTab=="Body Parts" then bagTab="Brainrots" else bagTab="All" end
   selectedSell=nil; render()
  end,Color3.fromRGB(70,75,105))
  if selectedSell then
   row("CONFIRM SELL "..selectedSell.name.." for $"..selectedSell.value,function()
    remote:FireServer(selectedSell.action,selectedSell.id); selectedSell=nil
   end,Color3.fromRGB(200,65,85))
   row("CANCEL SELL",function() selectedSell=nil; render() end,Color3.fromRGB(70,75,105))
  end
  if bagTab~="Brainrots" then
   row("BODY PARTS: "..#state.parts.." / 100 — tap a part to sell",nil,Color3.fromRGB(70,75,105))
   for _,item in ipairs(state.parts) do
    row((item.mutation or "Standard").." "..item.name.." "..item.kind.." ["..Config.Rarities[item.rarity].name.."] | sell $"..Config.PartSellValue(item),function()
     selectedSell={name=item.name.." "..item.kind,value=Config.PartSellValue(item),id=item.id,action="sellPart"}; render()
    end,Config.Rarities[item.rarity].color)
   end
  end
  if bagTab~="Body Parts" then
   row("BRAINROTS: "..#state.creatures.." / 100 — tap to choose action",nil,Color3.fromRGB(70,75,105))
   for _,c in ipairs(state.creatures) do
    row(c.name.." Lv."..c.level.." | $"..math.floor(Config.Income(c)).."/s | level $"..Config.LevelCost(c),function()
     selectedSell={name=c.name,value=Config.CreatureSellValue(c),id=c.id,action="sellCreature"}; render()
    end)
    if selectedSell and selectedSell.id==c.id then
     row("LEVEL UP "..c.name.." for $"..Config.LevelCost(c),function() remote:FireServer("level",c.id); selectedSell=nil end,Color3.fromRGB(52,170,105))
    end
   end
  end
 end
end
slots.Activated:Connect(function() mode="upgrades"; panel.Visible=true; render() end)
travel.Activated:Connect(function() mode="travel"; panel.Visible=true; render() end)
rebirth.Activated:Connect(function() confirmRebirth=false; mode="rebirth"; panel.Visible=true; render() end)
bag.Activated:Connect(function() selectedSell=nil; mode="bag"; panel.Visible=true; render() end)
remote.OnClientEvent:Connect(function(data)
 if data.tick then eventLabel.Text=data.event or ""; state.cash=data.cash; state.pending=data.pending; hud.Text="$"..math.floor(state.cash).."  |  Collect $"..math.floor(state.pending).."  |  R"..(state.rebirth or 0); return end
 if data.open then mode=data.open; stand=data.stand or 0; panel.Visible=true; render(); return end
 state=data; eventLabel.Text=data.event or ""; loaded=true
 if data.message and data.message~="" then notice.Text=data.message end
 render()
end)

task.spawn(function()
 while not loaded do remote:FireServer("sync"); task.wait(2) end
end)
