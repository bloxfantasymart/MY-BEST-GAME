--!strict
-- Shared server-side interaction guard. Client position alone is not a full
-- movement anti-cheat; callers also need ownership, health and rate limits.
local Proximity={}
function Proximity.isAliveNear(character,part,distance)
 if not character or not part or type(distance)~="number" or distance~=distance or distance<0 or distance==math.huge then return false end
 local root=character:FindFirstChild("HumanoidRootPart")
 local humanoid=character:FindFirstChildOfClass("Humanoid")
 if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health<=0 then return false end
 return (root.Position-part.Position).Magnitude<=distance
end
return Proximity
