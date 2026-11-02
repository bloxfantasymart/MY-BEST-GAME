--!strict
-- Local-only level of detail. The server remains authoritative over all gameplay.
local RunService=game:GetService("RunService")
local CollectionService=game:GetService("CollectionService")
local origins={}
local lastUpdate=0
local MAX_DISTANCE=100
local function effects(model,enabled)
 for _,child in ipairs(model:GetDescendants()) do
  if child:IsA("Fire") or child:IsA("Sparkles") then child.Enabled=enabled end
 end
end
RunService.RenderStepped:Connect(function()
 local now=os.clock()
 if now-lastUpdate<0.12 then return end
 lastUpdate=now
 local camera=workspace.CurrentCamera
 for _,model in ipairs(CollectionService:GetTagged("BrainrotDisplay")) do
  if model:IsA("Model") and model:IsDescendantOf(workspace)
   and model:FindFirstChild("Head") and model:FindFirstChild("Chest")
   and model:FindFirstChild("Arms") and model:FindFirstChild("Legs") then
   local record=origins[model]
   if not record then record={pivot=model:GetPivot(),near=nil}; origins[model]=record end
   local near=not camera or (camera.CFrame.Position-record.pivot.Position).Magnitude<=MAX_DISTANCE
   if near~=record.near then
    record.near=near; effects(model,near)
    if not near then model:PivotTo(record.pivot) end
   end
   if near then
    local phase=now*1.6+record.pivot.Position.X*0.1
    model:PivotTo(record.pivot*CFrame.new(0,math.sin(phase)*0.12,0)*CFrame.Angles(0,math.sin(phase*0.6)*0.04,0))
    for _,child in ipairs(model:GetChildren()) do
     if child:IsA("BasePart") and child:GetAttribute("Rainbow") then
      child.Color=Color3.fromHSV((now*0.12+record.pivot.Position.X*0.01)%1,0.85,1)
     end
    end
   end
  end
 end
 for model in pairs(origins) do if not model:IsDescendantOf(workspace) then origins[model]=nil end end
end)
