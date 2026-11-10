--!strict
-- Cosmetic effects are generated locally from the server-supplied tier. Each
-- viewer controls visibility; off-screen/distant effects are removed.
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local AuraStyle=require(ReplicatedStorage.Shared:WaitForChild("AuraStyle"))
local AuraRenderer=require(ReplicatedStorage.Shared:WaitForChild("AuraRenderer"))
local viewer=Players.LocalPlayer
local records={}
local lastUpdate=0
local MaxDistance=100
RunService.Heartbeat:Connect(function()
 local now=os.clock()
 if now>=lastUpdate and now-lastUpdate<0.5 then return end
 lastUpdate=now
 local camera=workspace.CurrentCamera
 local hidden=viewer:GetAttribute("HidePlayerAuras")==true
 local reduced=viewer:GetAttribute("ReduceDisplayMotion")==true
 local active={}
 for _,player in ipairs(Players:GetPlayers()) do
  local character=player.Character
  local root=character and character:FindFirstChild("HumanoidRootPart")
  local tier=character and character:GetAttribute("BrainrotAuraTier")
  local style=AuraStyle.get(tier)
  if not hidden and camera and root and root:IsA("BasePart") and root:IsDescendantOf(workspace) and style
   and (root.Position-camera.CFrame.Position).Magnitude<=MaxDistance then
   active[player]=true
   local record=records[player]
   if record and (record.root~=root or record.tier~=tier) then AuraRenderer.destroy(record); records[player]=nil; record=nil end
   if not record then record=AuraRenderer.create(root,tier,reduced); records[player]=record end
   if record then AuraRenderer.setReduced(record,reduced) end
  end
 end
 for player,record in pairs(records) do
  if not active[player] then AuraRenderer.destroy(record); records[player]=nil end
 end
end)
