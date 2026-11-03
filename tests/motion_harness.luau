-- Mock the local animation loop. This is not Roblox rendering or streaming.
local clock=0
local os={clock=function() return clock end}
local vecMeta={}
vecMeta.__sub=function(a,b) return setmetatable({X=a.X-b.X,Y=a.Y-b.Y,Z=a.Z-b.Z},vecMeta) end
vecMeta.__index=function(t,k) if k=="Magnitude" then return math.sqrt(t.X*t.X+t.Y*t.Y+t.Z*t.Z) end end
local function vec(x,y,z) return setmetatable({X=x,Y=y,Z=z},vecMeta) end
local frameMeta={}
frameMeta.__mul=function(a,_) return setmetatable({Position=a.Position},frameMeta) end
local function frame(x,y,z) return setmetatable({Position=vec(x,y,z)},frameMeta) end
local CFrame={new=function() return frame(0,0,0) end,Angles=function() return frame(0,0,0) end}
local Color3={fromHSV=function() return "animated-color" end}
local signal={}
function signal:Connect(callback)
 self.callback=callback
 return {Disconnect=function() signal.disconnected=true end}
end
local function part(name,rainbow)
 return {Name=name,Parent=true,Color="original",IsA=function(_,class) return class=="BasePart" end,GetAttribute=function(_,key) return key=="Rainbow" and rainbow end}
end
local head=part("Head",false); local chest=part("Chest",false); local arms=part("Arms",true); local legs=part("Legs",false)
local fire={Enabled=true,IsA=function(_,class) return class=="Fire" end}
local children={head,chest,arms,legs}; local descendants={head,chest,arms,legs,fire}
local base=frame(0,0,0)
local model={alive=true,pivot=base,DescendantAdded=signal}
function model:IsA(class) return class=="Model" end
function model:IsDescendantOf(_) return self.alive end
function model:FindFirstChild(name) for _,item in ipairs(children) do if item.Name==name then return item end end end
function model:GetPivot() return self.pivot end
function model:PivotTo(pivot) self.pivot=pivot end
function model:GetChildren() return children end
function model:GetDescendants() return descendants end
local workspace={CurrentCamera={CFrame=frame(0,0,0)}}
local reduced=false
local player={GetAttribute=function(_,key) return key=="ReduceDisplayMotion" and reduced end}
local callback=nil
local services={
 RunService={RenderStepped={Connect=function(_,fn) callback=fn end}},
 CollectionService={GetTagged=function() return {model} end},
 Players={LocalPlayer=player},
}
local game={GetService=function(_,name) return services[name] end}
-- INSERT_POLICY
-- INSERT_ANIMATION
assert(callback)
clock=0.2; callback(); assert(fire.Enabled and arms.Color=="animated-color" and model.pivot~=base)
reduced=true; clock=0.4; callback(); assert(not fire.Enabled and arms.Color=="original" and model.pivot==base)
local newSparkle={Enabled=true,IsA=function(_,class) return class=="Sparkles" end}
table.insert(descendants,newSparkle); signal.callback(newSparkle); assert(not newSparkle.Enabled, "Late-streamed effects must respect reduced motion")
clock=0.6; callback(); assert(model.pivot==base and arms.Color=="original")
reduced=false; clock=0.8; callback(); assert(fire.Enabled and newSparkle.Enabled and arms.Color=="animated-color")
workspace.CurrentCamera.CFrame=frame(101,0,0); clock=1; callback(); assert(not fire.Enabled and not newSparkle.Enabled and arms.Color=="original" and model.pivot==base)
workspace.CurrentCamera.CFrame=frame(0,0,0); clock=1.2; callback(); assert(fire.Enabled and arms.Color=="animated-color")
model.alive=false; clock=1.4; callback(); assert(signal.disconnected and arms.Color=="original" and model.pivot==base, "Removed displays must restore state and release their connection")
print("Local motion, color restoration, streamed effects and cleanup tests passed (mocked Roblox)")
