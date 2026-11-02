--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local remote=ReplicatedStorage:WaitForChild("HubAction")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui"); gui.Name="TradingHubUI"; gui.ResetOnSpawn=false; gui.Parent=player:WaitForChild("PlayerGui")
local function round(obj)
 local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,12); c.Parent=obj
 local stroke=Instance.new("UIStroke"); stroke.Thickness=2; stroke.Color=Color3.fromRGB(25,20,45); stroke.Parent=obj
end
local function button(parent,text,size,color)
 local b=Instance.new("TextButton"); b.Size=size; b.BackgroundColor3=color or Color3.fromRGB(95,65,175)
 b.Text=text; b.TextWrapped=true; b.TextColor3=Color3.new(1,1,1); b.TextSize=16; b.Font=Enum.Font.GothamBold; b.Parent=parent; round(b); return b
end
local header=Instance.new("TextLabel"); header.Size=UDim2.new(0.8,0,0,65); header.Position=UDim2.new(0.1,0,0,5)
header.BackgroundColor3=Color3.fromRGB(42,35,75); header.TextColor3=Color3.new(1,1,1); header.TextWrapped=true; header.Font=Enum.Font.GothamBold; header.TextSize=16
header.Text="SHOWCASE HUB: Claim a booth or inspect another player's creatures. Buying and trading are disabled."; header.Parent=gui; round(header)
local notice=Instance.new("TextLabel"); notice.BackgroundTransparency=1; notice.Size=UDim2.new(0.8,0,0,30); notice.Position=UDim2.new(0.1,0,0,75)
notice.TextColor3=Color3.new(1,1,1); notice.TextStrokeTransparency=0; notice.TextScaled=true; notice.Font=Enum.Font.GothamBold; notice.Parent=gui
local panel=Instance.new("Frame"); panel.Size=UDim2.new(0.85,0,0.7,0); panel.Position=UDim2.new(0.075,0,0.2,0); panel.BackgroundColor3=Color3.fromRGB(37,32,70); panel.Visible=false; panel.Parent=gui; round(panel)
local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,-65,0,45); title.BackgroundTransparency=1; title.TextColor3=Color3.new(1,1,1); title.Font=Enum.Font.GothamBold; title.TextSize=18; title.TextWrapped=true; title.Parent=panel
local close=button(panel,"X",UDim2.fromOffset(48,40),Color3.fromRGB(195,55,85)); close.Position=UDim2.new(1,-53,0,4); close.Activated:Connect(function() panel.Visible=false end)
local list=Instance.new("ScrollingFrame"); list.Size=UDim2.new(1,-20,1,-55); list.Position=UDim2.fromOffset(10,50); list.BackgroundTransparency=1; list.BorderSizePixel=0
list.ScrollBarThickness=7; list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.CanvasSize=UDim2.new(); list.Parent=panel
local layout=Instance.new("UIListLayout"); layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,6); layout.Parent=list
local current=nil
local function render(data)
 current=data; panel.Visible=true; title.Text="BOOTH "..data.booth.." — "..data.owner
 for _,child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 local order=0
 local function row(text,action,color,height)
  local b=button(list,text,UDim2.new(1,-10,0,height or 50),color); order+=1; b.LayoutOrder=order
  if action then b.Activated:Connect(action) end
 end
 row("SHOWCASE ONLY — no items or cash change hands.",nil,Color3.fromRGB(55,95,130))
 row("REFRESH BOOTH",function() remote:FireServer("refresh",{booth=data.booth}) end)
 if data.own then
  row("RELEASE BOOTH",function() remote:FireServer("release",{booth=data.booth}) end,Color3.fromRGB(185,60,85))
 end
 row("DISPLAYED: "..#data.listings.." / 4",nil,Color3.fromRGB(65,65,95))
 for _,entry in ipairs(data.listings) do
  row(entry.name.." — Level "..entry.level.." — $"..entry.income.."/s\n"..table.concat(entry.parts,", "),nil,Color3.fromRGB(85,65,125),90)
  if data.own then row("REMOVE "..entry.name,function() remote:FireServer("remove",{booth=data.booth,id=entry.id}) end,Color3.fromRGB(185,60,85)) end
 end
 if data.own then
  row("YOUR CREATURES — tap to display",nil,Color3.fromRGB(65,65,95))
  if #data.inventory==0 then row("No creatures yet. Return to the game and assemble one.",nil,Color3.fromRGB(65,65,95)) end
  for _,entry in ipairs(data.inventory) do
   row("DISPLAY "..entry.name.." — Level "..entry.level.." — $"..entry.income.."/s",function() remote:FireServer("add",{booth=data.booth,id=entry.id}) end)
  end
 end
end
remote.OnClientEvent:Connect(function(data)
 if data.message then notice.Text=data.message end
 if data.close then panel.Visible=false; current=nil end
 if data.open then render(data) end
end)
