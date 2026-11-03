--!strict
-- Client-only display animation policy; never changes gameplay.
local MotionPolicy={}
function MotionPolicy.active(distance,reduced,maxDistance)
 if reduced then return false end
 if distance==nil then return true end
 return distance<=maxDistance
end
return MotionPolicy
