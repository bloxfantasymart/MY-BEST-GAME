--!strict
local Titles={}
function Titles.forRebirth(rebirth)
 if rebirth>=100 then return "Brainrot Overlord" end
 if rebirth>=50 then return "Ohio Conqueror" end
 if rebirth>=25 then return "Mewing Champion" end
 if rebirth>=10 then return "Sigma Grinder" end
 return "Rookie Roller"
end
function Titles.apply(character,rebirth)
 local head=character and character:FindFirstChild("Head")
 if not head or not head:IsA("BasePart") then return end
 local old=head:FindFirstChild("BrainrotTitle"); if old then old:Destroy() end
 local gui=Instance.new("BillboardGui"); gui.Name="BrainrotTitle"; gui.Size=UDim2.fromOffset(180,35)
 gui.StudsOffset=Vector3.new(0,3,0); gui.AlwaysOnTop=true; gui.Parent=head
 local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1
 label.Text=Titles.forRebirth(rebirth); label.Font=Enum.Font.GothamBold; label.TextScaled=true
 label.TextColor3=rebirth>=50 and Color3.fromRGB(255,215,70) or Color3.fromRGB(220,255,255)
 label.TextStrokeTransparency=0; label.Parent=gui
end
return Titles
