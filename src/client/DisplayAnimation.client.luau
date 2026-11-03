--!strict
-- Local-only level of detail and accessibility; the server owns gameplay.
local RunService=game:GetService("RunService")
local CollectionService=game:GetService("CollectionService")
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MotionPolicy=require(ReplicatedStorage.Shared:WaitForChild("MotionPolicy"))
local player=Players.LocalPlayer
local origins={}
local lastUpdate=0
local MAX_DISTANCE=100
local function effects(model,enabled)
 for _,child in ipairs(model:GetDescendants()) do
  if child:IsA("Fire") or child:IsA("Sparkles") then child.Enabled=enabled end
 end
end
local function restoreColors(record)
 for part,color in pairs(record.colors) do if part.Parent then part.Color=color end end
end
RunService.RenderStepped:Connect(function()
 local now=os.clock()
 if now-lastUpdate<0.12 then return end
 lastUpdate=now
 local camera=workspace.CurrentCamera
 local reduced=player:GetAttribute("ReduceDisplayMotion")==true
 for _,model in ipairs(CollectionService:GetTagged("BrainrotDisplay")) do
  if model:IsA("Model") and model:IsDescendantOf(workspace)
   and model:FindFirstChild("Head") and model:FindFirstChild("Chest")
   and model:FindFirstChild("Arms") and model:FindFirstChild("Legs") then
   local record=origins[model]
   if not record then
    record={pivot=model:GetPivot(),active=nil,colors={}}
    record.connection=model.DescendantAdded:Connect(function(child)
     if record.active==false and (child:IsA("Fire") or child:IsA("Sparkles")) then child.Enabled=false end
    end)
    origins[model]=record
   end
   local distance=camera and (camera.CFrame.Position-record.pivot.Position).Magnitude or nil
   local active=MotionPolicy.active(distance,reduced,MAX_DISTANCE)
   if active~=record.active then
    record.active=active; effects(model,active)
    if not active then model:PivotTo(record.pivot); restoreColors(record) end
   end
   if active then
    local phase=now*1.6+record.pivot.Position.X*0.1
    model:PivotTo(record.pivot*CFrame.new(0,math.sin(phase)*0.12,0)*CFrame.Angles(0,math.sin(phase*0.6)*0.04,0))
    for _,child in ipairs(model:GetChildren()) do
     if child:IsA("BasePart") and child:GetAttribute("Rainbow") then
      if not record.colors[child] then record.colors[child]=child.Color end
      child.Color=Color3.fromHSV((now*0.12+record.pivot.Position.X*0.01)%1,0.85,1)
     end
    end
   end
  end
 end
 for model,record in pairs(origins) do
  if not model:IsDescendantOf(workspace) then
   restoreColors(record); pcall(function() model:PivotTo(record.pivot) end)
   record.connection:Disconnect(); origins[model]=nil
  end
 end
end)
