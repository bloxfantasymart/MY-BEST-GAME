--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local UILayout=require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UILayout"))
local ShowcaseInventory=require(ReplicatedStorage.Shared:WaitForChild("ShowcaseInventory"))
local InventoryView=require(ReplicatedStorage.Shared:WaitForChild("InventoryView"))
local Config=require(ReplicatedStorage.Shared:WaitForChild("Config"))
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
local close=button(panel,"X",UDim2.fromOffset(48,40),Color3.fromRGB(195,55,85)); close.Position=UDim2.new(1,-53,0,4)
local list=Instance.new("ScrollingFrame"); list.Size=UDim2.new(1,-20,1,-55); list.Position=UDim2.fromOffset(10,50); list.BackgroundTransparency=1; list.BorderSizePixel=0
list.ScrollBarThickness=7; list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.CanvasSize=UDim2.new(); list.Parent=panel
local layout=Instance.new("UIListLayout"); layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,6); layout.Parent=list
local accessibility=button(root,"ACCESSIBILITY",UDim2.fromOffset(110,48),Color3.fromRGB(60,120,180))
local directoryButton=button(root,"BOOTH DIRECTORY",UDim2.fromOffset(110,40),Color3.fromRGB(145,85,180))
local current=nil; local render; local showAccessibility; local showDirectory; local requestDirectory; local requestRender; local accessibilityOpen=false
local directoryOpen=false; local directoryData=nil; local directoryWaiting=nil; local directorySequence=0
local query=""; local draft=""; local sortMode="Newest"; local page=1; local hideDisplayed=false; local releaseConfirm=false; local pendingRender=false
close.Activated:Connect(function() panel.Visible=false; current=nil; pendingRender=false; releaseConfirm=false; directoryOpen=false; directoryWaiting=nil end)
local function applyLayout()
 local size=root.AbsoluteSize
 if size.X<1 or size.Y<1 then return end
 local metrics=UILayout.hub(size.X,size.Y)
 header.Position=UDim2.fromOffset(metrics.margin,metrics.margin); header.Size=UDim2.fromOffset(metrics.headerWidth,metrics.headerHeight)
 accessibility.Position=UDim2.fromOffset(size.X-metrics.margin-metrics.settingsWidth,metrics.margin)
 accessibility.Size=UDim2.fromOffset(metrics.settingsWidth,metrics.headerHeight)
 directoryButton.Position=UDim2.fromOffset(size.X-metrics.margin-metrics.settingsWidth,metrics.margin+metrics.headerHeight+4)
 directoryButton.Size=UDim2.fromOffset(metrics.settingsWidth,math.min(40,math.max(1,size.Y-metrics.margin-metrics.headerHeight-4)))
 notice.Position=UDim2.fromOffset(metrics.margin,metrics.margin+metrics.headerHeight+4); notice.Size=UDim2.fromOffset(metrics.headerWidth,math.min(30,math.max(1,size.Y-metrics.margin-metrics.headerHeight-4)))
 panel.ZIndex=5; panel.AnchorPoint=Vector2.new(0.5,0.5); panel.Position=UDim2.fromScale(0.5,0.5); panel.Size=UDim2.fromOffset(metrics.panelWidth,metrics.panelHeight)
 if panel.Visible then
  task.defer(function()
   if not panel.Visible then return end
   if accessibilityOpen and showAccessibility then showAccessibility() elseif directoryOpen and showDirectory then showDirectory() elseif current and requestRender then requestRender() end
  end)
 end
end
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyLayout)
applyLayout()
showAccessibility=function()
 accessibilityOpen=true; directoryOpen=false; directoryWaiting=nil; pendingRender=false; releaseConfirm=false; panel.Visible=true; list.CanvasPosition=Vector2.zero; title.Text="ACCESSIBILITY — THIS SESSION"
 for _,child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 local reduced=player:GetAttribute("ReduceDisplayMotion")==true
 local toggle=button(list,"REDUCE DISPLAY MOTION: "..(reduced and "ON" or "OFF").." (idle movement, rainbow cycling and display particles)",UDim2.new(1,-10,0,UILayout.rowHeight("REDUCE DISPLAY MOTION: idle movement, rainbow cycling and display particles",math.max(200,panel.AbsoluteSize.X))),Color3.fromRGB(60,120,180))
 toggle.LayoutOrder=1; toggle.Activated:Connect(function() player:SetAttribute("ReduceDisplayMotion",not reduced); showAccessibility() end)
 local note=button(list,"This setting is local to this play session. It does not affect other players or gameplay, and resets when changing places or rejoining.",UDim2.new(1,-10,0,UILayout.rowHeight("This setting is local to this play session. It does not affect other players or gameplay, and resets when changing places or rejoining.",math.max(200,panel.AbsoluteSize.X))),Color3.fromRGB(65,65,95)); note.LayoutOrder=2
end
accessibility.Activated:Connect(showAccessibility)
render=function(data)
 accessibilityOpen=false; directoryOpen=false; directoryWaiting=nil; current=data; panel.Visible=true; title.Text="BOOTH "..data.booth.." — "..data.owner
 local previousScroll=list.CanvasPosition
 for _,child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 local order=0
 local function row(text,action,color,height)
  local b=button(list,text,UDim2.new(1,-10,0,math.max(height or 50,UILayout.rowHeight(text,math.max(200,panel.AbsoluteSize.X)))),color); order+=1; b.LayoutOrder=order
  if action then b.Activated:Connect(action) end
 end
 row("SHOWCASE ONLY — no items or cash change hands. Income shown excludes plot bonuses.",nil,Color3.fromRGB(55,95,130))
 row("REFRESH BOOTH",function() remote:FireServer("refresh",{booth=data.booth}) end)
 if data.own then
  row(releaseConfirm and "CONFIRM: RELEASE BOOTH AND CLEAR DISPLAYS" or "RELEASE BOOTH (review first)",function()
   if releaseConfirm then releaseConfirm=false; remote:FireServer("release",{booth=data.booth}) else releaseConfirm=true; render(current) end
  end,Color3.fromRGB(185,60,85))
  if releaseConfirm then row("CANCEL RELEASE",function() releaseConfirm=false; render(current) end,Color3.fromRGB(65,65,95)) end
 end
 row("DISPLAYED: "..#data.listings.." / 4",nil,Color3.fromRGB(65,65,95))
 for _,entry in ipairs(data.listings) do
  local rarity=Config.Rarities[entry.rarity]
  local heading=(entry.ascended and "ASCENDED " or "")..(entry.blueprint and "[BLUEPRINT] " or "")..entry.name.." ["..rarity.name.."] — Level "..entry.level.." — $"..entry.income.."/s #"..string.sub(entry.id,-6)
  row(heading,nil,Color3.fromRGB(85,65,125))
  for _,partDescription in ipairs(entry.parts) do row(partDescription,nil,Color3.fromRGB(65,65,95)) end
  if data.own then row("REMOVE "..entry.name.." #"..string.sub(entry.id,-6),function() remote:FireServer("remove",{booth=data.booth,id=entry.id}) end,Color3.fromRGB(185,60,85)) end
 end
 if data.own then
  row("YOUR CREATURES — only you can see this list",nil,Color3.fromRGB(65,65,95))
  local search=Instance.new("TextBox"); search.Size=UDim2.new(1,-10,0,50); search.BackgroundColor3=Color3.fromRGB(60,65,95); search.TextColor3=Color3.new(1,1,1)
  search.Text=draft; search.PlaceholderText="Search names or components"; search.ClearTextOnFocus=false; search.Font=Enum.Font.GothamBold; search.TextSize=16; search.Parent=list; order+=1; search.LayoutOrder=order; round(search)
  search:GetPropertyChangedSignal("Text"):Connect(function() draft=string.sub(search.Text,1,80) end)
  row("APPLY SEARCH"..(query~="" and (": "..query) or ""),function() query=draft; page=1; render(current) end,Color3.fromRGB(60,120,180))
  row("SORT: "..sortMode.." (tap to change)",function()
   if sortMode=="Newest" then sortMode="Income" elseif sortMode=="Income" then sortMode="Rarity" elseif sortMode=="Rarity" then sortMode="Name" else sortMode="Newest" end
   page=1; render(current)
  end,Color3.fromRGB(65,65,95))
  row("HIDE DISPLAYED: "..(hideDisplayed and "ON" or "OFF"),function() hideDisplayed=not hideDisplayed; page=1; render(current) end,Color3.fromRGB(65,65,95))
  local entries=ShowcaseInventory.build(data.inventory,data.listings,query,sortMode,hideDisplayed)
  local shown,currentPage,pages=InventoryView.page(entries,page,12); page=currentPage
  row("PAGE "..currentPage.." / "..pages.." | "..#entries.." matching creatures",nil,Color3.fromRGB(65,65,95))
  if currentPage>1 then row("PREVIOUS PAGE",function() page-=1; render(current) end,Color3.fromRGB(60,120,180)) end
  if currentPage<pages then row("NEXT PAGE",function() page+=1; render(current) end,Color3.fromRGB(60,120,180)) end
  for _,result in ipairs(shown) do
   local entry=result.item
   local label=(result.displayed and "DISPLAYED: " or "DISPLAY ")..(entry.locked and "[PROTECTED] " or "")..(entry.ascended and "ASCENDED " or "")..(entry.blueprint and "[BLUEPRINT] " or "")..entry.name.." ["..Config.Rarities[entry.rarity].name.."] — Level "..entry.level.." — $"..entry.income.."/s #"..string.sub(entry.id,-6)
   row(label,function()
    if result.displayed then notice.Text="Already displayed. Remove it from the displayed list first."; return end
    if #data.listings>=4 then notice.Text="Your booth is full. Remove a creature first."; return end
    remote:FireServer("add",{booth=data.booth,id=entry.id})
   end,result.displayed and Color3.fromRGB(65,65,95) or nil)
  end
  if #entries==0 then row("No matching creatures. Return to the game to assemble more, or change the filters.",nil,Color3.fromRGB(65,65,95)) end
 end
 task.defer(function() if panel.Visible and current==data and not accessibilityOpen then list.CanvasPosition=previousScroll end end)
end
showDirectory=function()
 if not directoryOpen then return end
 accessibilityOpen=false; current=nil; panel.Visible=true; title.Text="SHOWCASE BOOTH DIRECTORY"
 local previousScroll=list.CanvasPosition
 for _,child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 local order=0
 local function row(text,action,color)
  local b=button(list,text,UDim2.new(1,-10,0,UILayout.rowHeight(text,math.max(200,panel.AbsoluteSize.X))),color)
  order+=1; b.LayoutOrder=order; if action then b.Activated:Connect(action) end
 end
 row("SHOWCASE ONLY — no buying or trading. Directory is a server snapshot; booth owners and displays can change.",nil,Color3.fromRGB(55,95,130))
 row(directoryWaiting and "REFRESH REQUESTED..." or "REFRESH BOOTH DIRECTORY",function() requestDirectory() end,Color3.fromRGB(60,120,180))
 row("TRAVEL TO RETURN PORTAL (use its prompt to leave)",function()
  directoryOpen=false; directoryWaiting=nil; panel.Visible=false; remote:FireServer("visitPortal",{})
 end,Color3.fromRGB(60,145,150))
 if not directoryData then row("Waiting for a directory snapshot. Tap refresh if needed.",nil,Color3.fromRGB(65,65,95))
 else
  for _,entry in ipairs(directoryData) do
   local booth=entry.index
   local status=entry.owner and (entry.owner.."'s showcase"..(entry.mine and " (YOURS)" or "").." | "..entry.listed.." / 4 displayed") or "UNCLAIMED"
   row("VISIT BOOTH "..booth.." — "..status,function()
    directoryOpen=false; directoryWaiting=nil; panel.Visible=false; remote:FireServer("visitBooth",{booth=booth})
   end,entry.owner and Color3.fromRGB(110,75,155) or Color3.fromRGB(65,95,105))
  end
 end
 row("Travel uses a three-second cooldown. Interact with a nearby booth prompt to claim it or inspect its displays.",nil,Color3.fromRGB(65,65,95))
 task.defer(function() if panel.Visible and directoryOpen then list.CanvasPosition=previousScroll end end)
end
requestDirectory=function()
 if not directoryOpen then return end
 directorySequence=directorySequence%2147483647+1; directoryWaiting=directorySequence
 remote:FireServer("directory",{requestId=directoryWaiting}); showDirectory()
end
directoryButton.Activated:Connect(function()
 directoryOpen=true; directoryData=nil; directoryWaiting=nil; accessibilityOpen=false; current=nil; pendingRender=false; releaseConfirm=false
 panel.Visible=true; list.CanvasPosition=Vector2.zero; requestDirectory()
end)
requestRender=function()
 local focused=UserInputService:GetFocusedTextBox()
 if panel.Visible and focused and focused:IsDescendantOf(list) then pendingRender=true; return end
 pendingRender=false
 if current and not accessibilityOpen then render(current) end
end
UserInputService.TextBoxFocusReleased:Connect(function(box)
 if pendingRender and box:IsDescendantOf(list) then task.defer(function() if pendingRender then requestRender() end end) end
end)
remote.OnClientEvent:Connect(function(data)
 if data.directory then
  if directoryOpen and panel.Visible and directoryWaiting==data.requestId then directoryWaiting=nil; directoryData=data.booths; showDirectory() end
  return
 end
 if data.message then notice.Text=data.message end
 if data.close and current and not accessibilityOpen and current.booth==data.booth then panel.Visible=false; current=nil; pendingRender=false; releaseConfirm=false end
 if data.open then
  if data.fromPrompt then
   if not current or current.booth~=data.booth or accessibilityOpen or not panel.Visible then query=""; draft=""; page=1; hideDisplayed=false; releaseConfirm=false; list.CanvasPosition=Vector2.zero end
   pendingRender=false; render(data)
  elseif panel.Visible and not accessibilityOpen and current and current.booth==data.booth then
   releaseConfirm=false; current=data; requestRender()
  end
 end
end)
