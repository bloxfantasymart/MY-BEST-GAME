--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UILayout=require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UILayout"))
local remote=ReplicatedStorage:WaitForChild("HubAction")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui"); gui.Name="TradingHubUI"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.Parent=player:WaitForChild("PlayerGui")
local root=Instance.new("Frame"); root.Name="SafeArea"; root.Size=UDim2.fromScale(1,1); root.BackgroundTransparency=1; root.BorderSizePixel=0; root.Parent=gui
local function round(obj)
 local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,12); c.Parent=obj
 local stroke=Instance.new("UIStroke"); stroke.Thickness=2; stroke.Color=Color3.fromRGB(25,20,45); stroke.Parent=obj
end
local function button(parent,text,size,color)
 local b=Instance.new("TextButton"); b.Size=size; b.BackgroundColor3=color or Color3.fromRGB(95,65,175)
 b.Text=text; b.TextWrapped=true; b.TextScaled=true; local limit=Instance.new("UITextSizeConstraint"); limit.MinTextSize=10; limit.MaxTextSize=16; limit.Parent=b; b.TextColor3=Color3.new(1,1,1); b.TextSize=16; b.Font=Enum.Font.GothamBold; b.Parent=parent; round(b); return b
end
local header=Instance.new("TextLabel"); header.Size=UDim2.new(0.8,0,0,65); header.Position=UDim2.new(0.1,0,0,5)
header.BackgroundColor3=Color3.fromRGB(42,35,75); header.TextColor3=Color3.new(1,1,1); header.TextWrapped=true; header.Font=Enum.Font.GothamBold; header.TextSize=16
header.TextScaled=true
local headerLimit=Instance.new("UITextSizeConstraint"); headerLimit.MinTextSize=10; headerLimit.MaxTextSize=16; headerLimit.Parent=header
header.Text="SHOWCASE HUB: Claim a booth or inspect another player's creatures. Buying and trading are disabled."; header.Parent=root; round(header)
local notice=Instance.new("TextLabel"); notice.BackgroundTransparency=1; notice.Size=UDim2.new(0.8,0,0,30); notice.Position=UDim2.new(0.1,0,0,75)
notice.TextColor3=Color3.new(1,1,1); notice.TextStrokeTransparency=0; notice.TextScaled=true; notice.Font=Enum.Font.GothamBold; notice.Parent=root
local panel=Instance.new("Frame"); panel.Size=UDim2.new(0.85,0,0.7,0); panel.Position=UDim2.new(0.075,0,0.2,0); panel.BackgroundColor3=Color3.fromRGB(37,32,70); panel.Visible=false; panel.Parent=root; round(panel)
local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,-65,0,45); title.BackgroundTransparency=1; title.TextColor3=Color3.new(1,1,1); title.Font=Enum.Font.GothamBold; title.TextSize=18; title.TextWrapped=true; title.TextScaled=true; title.Parent=panel
local titleLimit=Instance.new("UITextSizeConstraint"); titleLimit.MinTextSize=10; titleLimit.MaxTextSize=18; titleLimit.Parent=title
local close=button(panel,"X",UDim2.fromOffset(48,40),Color3.fromRGB(195,55,85)); close.Position=UDim2.new(1,-53,0,4); close.Activated:Connect(function() panel.Visible=false end)
local list=Instance.new("ScrollingFrame"); list.Size=UDim2.new(1,-20,1,-55); list.Position=UDim2.fromOffset(10,50); list.BackgroundTransparency=1; list.BorderSizePixel=0
list.ScrollBarThickness=7; list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.CanvasSize=UDim2.new(); list.Parent=panel
local layout=Instance.new("UIListLayout"); layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,6); layout.Parent=list
local accessibility=button(root,"ACCESSIBILITY",UDim2.fromOffset(110,48),Color3.fromRGB(60,120,180))
local current=nil; local render; local showAccessibility; local accessibilityOpen=false
local function applyLayout()
 local size=root.AbsoluteSize
 if size.X<1 or size.Y<1 then return end
 local metrics=UILayout.hub(size.X,size.Y)
 header.Position=UDim2.fromOffset(metrics.margin,metrics.margin); header.Size=UDim2.fromOffset(metrics.headerWidth,metrics.headerHeight)
 accessibility.Position=UDim2.fromOffset(size.X-metrics.margin-metrics.settingsWidth,metrics.margin)
 accessibility.Size=UDim2.fromOffset(metrics.settingsWidth,metrics.headerHeight)
 notice.Position=UDim2.fromOffset(metrics.margin,metrics.margin+metrics.headerHeight+4); notice.Size=UDim2.fromOffset(metrics.headerWidth,math.min(30,math.max(1,size.Y-metrics.margin-metrics.headerHeight-4)))
 panel.ZIndex=5; panel.AnchorPoint=Vector2.new(0.5,0.5); panel.Position=UDim2.fromScale(0.5,0.5); panel.Size=UDim2.fromOffset(metrics.panelWidth,metrics.panelHeight)
 if panel.Visible then
  task.defer(function()
   if not panel.Visible then return end
   if accessibilityOpen and showAccessibility then showAccessibility() elseif current and render then render(current) end
  end)
 end
end
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyLayout)
applyLayout()
showAccessibility=function()
 accessibilityOpen=true; panel.Visible=true; title.Text="ACCESSIBILITY — THIS SESSION"
 for _,child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 local reduced=player:GetAttribute("ReduceDisplayMotion")==true
 local toggle=button(list,"REDUCE DISPLAY MOTION: "..(reduced and "ON" or "OFF").." (idle movement, rainbow cycling and display particles)",UDim2.new(1,-10,0,UILayout.rowHeight("REDUCE DISPLAY MOTION: idle movement, rainbow cycling and display particles",math.max(200,panel.AbsoluteSize.X))),Color3.fromRGB(60,120,180))
 toggle.LayoutOrder=1; toggle.Activated:Connect(function() player:SetAttribute("ReduceDisplayMotion",not reduced); showAccessibility() end)
 local note=button(list,"This setting is local to this play session. It does not affect other players or gameplay, and resets when changing places or rejoining.",UDim2.new(1,-10,0,UILayout.rowHeight("This setting is local to this play session. It does not affect other players or gameplay, and resets when changing places or rejoining.",math.max(200,panel.AbsoluteSize.X))),Color3.fromRGB(65,65,95)); note.LayoutOrder=2
end
accessibility.Activated:Connect(showAccessibility)
render=function(data)
 accessibilityOpen=false; current=data; panel.Visible=true; title.Text="BOOTH "..data.booth.." — "..data.owner
 for _,child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 local order=0
 local function row(text,action,color,height)
  local b=button(list,text,UDim2.new(1,-10,0,math.max(height or 50,UILayout.rowHeight(text,math.max(200,panel.AbsoluteSize.X)))),color); order+=1; b.LayoutOrder=order
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
