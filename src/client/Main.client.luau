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
 b.Text=text; b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBold; b.TextSize=16; b.TextWrapped=true; b.Parent=parent; round(b); return b
end
local hud=button(gui,"Loading...",UDim2.new(0.4,0,0,55),UDim2.new(0.02,0,0,8),Color3.fromRGB(38,42,72))
hud.Activated:Connect(function() remote:FireServer("collect") end)
local bag=button(gui,"BACKPACK",UDim2.new(0,120,0,48),UDim2.new(1,-130,0,8))
local slots=button(gui,"SLOTS +",UDim2.new(0,120,0,48),UDim2.new(1,-130,0,62),Color3.fromRGB(230,135,40))
slots.Activated:Connect(function() remote:FireServer("upgradeSlots") end)
local rebirth=button(gui,"REBIRTH",UDim2.new(0,120,0,48),UDim2.new(1,-130,0,116),Color3.fromRGB(218,65,135))
local eventLabel=Instance.new("TextLabel"); eventLabel.BackgroundTransparency=1; eventLabel.Size=UDim2.new(0.6,0,0,28); eventLabel.Position=UDim2.new(0.02,0,0,98); eventLabel.TextColor3=Color3.fromRGB(255,225,80); eventLabel.TextStrokeTransparency=0; eventLabel.Font=Enum.Font.GothamBold; eventLabel.TextScaled=true; eventLabel.Parent=gui
local notice=Instance.new("TextLabel"); notice.BackgroundTransparency=1; notice.Size=UDim2.new(0.65,0,0,30); notice.Position=UDim2.new(0.02,0,0,67); notice.TextColor3=Color3.new(1,1,1); notice.TextStrokeTransparency=0; notice.Font=Enum.Font.GothamBold; notice.TextScaled=true; notice.Parent=gui
local panel=Instance.new("Frame"); panel.Size=UDim2.new(0.85,0,0.68,0); panel.Position=UDim2.new(0.075,0,0.2,0); panel.BackgroundColor3=Color3.fromRGB(37,39,70); panel.Visible=false; panel.Parent=gui; round(panel)
local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,-70,0,45); title.BackgroundTransparency=1; title.TextColor3=Color3.new(1,1,1); title.Font=Enum.Font.GothamBold; title.TextSize=20; title.Parent=panel
local close=button(panel,"X",UDim2.fromOffset(48,40),UDim2.new(1,-54,0,4),Color3.fromRGB(200,65,85)); close.Activated:Connect(function() panel.Visible=false end)
local list=Instance.new("ScrollingFrame"); list.Size=UDim2.new(1,-20,1,-55); list.Position=UDim2.fromOffset(10,50); list.BackgroundTransparency=1; list.BorderSizePixel=0; list.ScrollBarThickness=7; list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.CanvasSize=UDim2.new(); list.Parent=panel
local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,6); layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Parent=list
local state={cash=0,pending=0,slots=1,rebirth=0,rebirthCost=1000,target="Dirt Boy",parts={},creatures={},rolls={}}
local loaded=false
local mode=""; local stand=0; local chosen={}; local rowOrder=0
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
  for _,item in ipairs(state.rolls) do
   local rarity=Config.Rarities[item.rarity]
   row("BUY "..(item.mutation or "Standard").." "..item.name.." "..item.kind.." ["..rarity.name.."]  $"..item.price,function() remote:FireServer("buy",item.id) end,rarity.color)
  end
 elseif mode=="assemble" then
  title.Text="ASSEMBLY: select one of each"
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
   row("CONFIRM REBIRTH",function() remote:FireServer("rebirth") end,Color3.fromRGB(220,75,130))
  end
 elseif mode=="bag" then
  title.Text="BACKPACK"
  row("BODY PARTS: "..#state.parts.." / 100",nil,Color3.fromRGB(70,75,105))
  for _,item in ipairs(state.parts) do row((item.mutation or "Standard").." "..item.name.." "..item.kind.." ["..Config.Rarities[item.rarity].name.."]",nil,Config.Rarities[item.rarity].color) end
  row("BRAINROTS: "..#state.creatures,nil,Color3.fromRGB(70,75,105))
  for _,c in ipairs(state.creatures) do row(c.name.." Lv."..c.level.." | $"..math.floor(Config.Income(c)).."/s | Level up $"..Config.LevelCost(c),function() remote:FireServer("level",c.id) end) end
 end
end
rebirth.Activated:Connect(function() mode="rebirth"; panel.Visible=true; render() end)
bag.Activated:Connect(function() mode="bag"; panel.Visible=true; render() end)
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
