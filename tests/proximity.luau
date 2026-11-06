local vmeta={}
vmeta.__sub=function(a,b) return {Magnitude=math.sqrt((a.x-b.x)^2+(a.y-b.y)^2+(a.z-b.z)^2)} end
local function v(x,y,z) return setmetatable({x=x,y=y,z=z},vmeta) end
local root={Position=v(0,0,0),IsA=function(_,class) return class=="BasePart" end}
local humanoid={Health=100}
local character={FindFirstChild=function(_,name) return name=="HumanoidRootPart" and root or nil end,FindFirstChildOfClass=function(_,class) return class=="Humanoid" and humanoid or nil end}
local part={Position=v(20,0,0)}
assert(Proximity.isAliveNear(character,part,20))
part.Position=v(20.01,0,0); assert(not Proximity.isAliveNear(character,part,20))
part.Position=v(0,0,0); humanoid.Health=0; assert(not Proximity.isAliveNear(character,part,20))
humanoid.Health=-1; assert(not Proximity.isAliveNear(character,part,20)); humanoid.Health=100
assert(not Proximity.isAliveNear(nil,part,20) and not Proximity.isAliveNear(character,nil,20))
assert(not Proximity.isAliveNear(character,part,0/0) and not Proximity.isAliveNear(character,part,math.huge) and not Proximity.isAliveNear(character,part,-1))
local missing={FindFirstChild=function() return nil end,FindFirstChildOfClass=function() return humanoid end}
assert(not Proximity.isAliveNear(missing,part,20))
local missingHumanoid={FindFirstChild=function() return root end,FindFirstChildOfClass=function() return nil end}
assert(not Proximity.isAliveNear(missingHumanoid,part,20))
root.IsA=function() return false end; assert(not Proximity.isAliveNear(character,part,20))
print("Living character, distance boundary and missing-rig proximity checks passed")
