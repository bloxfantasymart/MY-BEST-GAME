--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local AuraStyle=require(ReplicatedStorage.Shared:WaitForChild("AuraStyle"))
local Titles={}
function Titles.forRebirth(rebirth)
 if rebirth>=100 then return "Brainrot Overlord" end
 if rebirth>=50 then return "Ohio Conqueror" end
 if rebirth>=25 then return "Mewing Champion" end
 if rebirth>=10 then return "Sigma Grinder" end
 return "Rookie Roller"
end
function Titles.apply(character,rebirth,extras)
 if not character then return end
 -- The tier is derived on the server; nearby clients render cosmetic effects.
 character:SetAttribute("BrainrotAuraTier",AuraStyle.tier(rebirth))
 local head=character:FindFirstChild("Head")
 if not head or not head:IsA("BasePart") then return end
 local old=head:FindFirstChild("BrainrotTitle"); if old then old:Destroy() end
 local oldCrown=head:FindFirstChild("OhioCrown"); if oldCrown then oldCrown:Destroy() end
 if extras and extras.ohioCrown then
  local crown=Instance.new("Part"); crown.Name="OhioCrown"; crown.Size=Vector3.new(2.4,0.35,2.4)
  crown.Color=Color3.fromRGB(255,215,40); crown.Material=Enum.Material.Neon
  crown.Anchored=false; crown.CanCollide=false; crown.CanTouch=false; crown.Massless=true
  crown.CFrame=head.CFrame*CFrame.new(0,1.2,0); crown.Parent=head
  local weld=Instance.new("WeldConstraint"); weld.Part0=head; weld.Part1=crown; weld.Parent=crown
 end
 local gui=Instance.new("BillboardGui"); gui.Name="BrainrotTitle"; gui.Size=UDim2.fromOffset(180,35)
 gui.StudsOffset=Vector3.new(0,3,0); gui.AlwaysOnTop=true; gui.Parent=head
 local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1
 label.Text=Titles.forRebirth(rebirth); label.Font=Enum.Font.GothamBold; label.TextScaled=true
 label.TextColor3=rebirth>=50 and Color3.fromRGB(255,215,70) or Color3.fromRGB(220,255,255)
 label.TextStrokeTransparency=0; label.Parent=gui
end
return Titles
