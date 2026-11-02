--!strict
-- Local-only idle motion: display models remain non-collidable and the server owns gameplay.
local RunService=game:GetService("RunService")
local CollectionService=game:GetService("CollectionService")
local origins={}
local lastUpdate=0
RunService.RenderStepped:Connect(function()
 local now=os.clock()
 if now-lastUpdate<0.12 then return end
 lastUpdate=now
 for _,model in ipairs(CollectionService:GetTagged("BrainrotDisplay")) do
  if model:IsA("Model") and model:IsDescendantOf(workspace) and #model:GetChildren()>=4 then
   if not origins[model] then origins[model]=model:GetPivot() end
   local phase=now*1.6+origins[model].Position.X*0.1
   model:PivotTo(origins[model]*CFrame.new(0,math.sin(phase)*0.12,0)*CFrame.Angles(0,math.sin(phase*0.6)*0.04,0))
   for _,child in ipairs(model:GetChildren()) do
    if child:IsA("BasePart") and child:GetAttribute("Rainbow") then
     child.Color=Color3.fromHSV((now*0.12+origins[model].Position.X*0.01)%1,0.85,1)
    end
   end
  end
 end
 for model in pairs(origins) do if not model:IsDescendantOf(workspace) then origins[model]=nil end end
end)
