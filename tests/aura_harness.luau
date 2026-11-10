local time=0; local os={clock=function() return time end}
local vm={}
vm.__sub=function(a,b) return setmetatable({X=a.X-b.X,Y=a.Y-b.Y,Z=a.Z-b.Z},vm) end
vm.__index=function(t,k) if k=="Magnitude" then return math.sqrt(t.X^2+t.Y^2+t.Z^2) end end
local Vector3={new=function(x,y,z) return setmetatable({X=x,Y=y,Z=z},vm) end}
local Color3={fromRGB=function(r,g,b) return {r=r,g=g,b=b} end}
local ColorSequence={new=function(color) return color end}
local NumberSequence={new=function(value) return value end}
local methods={}
function methods:Destroy() self.Parent=nil; self.destroyed=true end
local mt={__index=function(t,k) return methods[k] or t.props[k] end,__newindex=function(t,k,v)
 t.props[k]=v; if k=="Parent" and v then table.insert(v.children,t) end
end}
local Instance={new=function(class) return setmetatable({props={},children={},class=class},mt) end}
local function root(x)
 return {Position=Vector3.new(x,0,0),children={},alive=true,IsA=function(_,name) return name=="BasePart" end,IsDescendantOf=function(self) return self.alive end}
end
local function visible(r,name)
 local count=0; local found=nil
 for _,item in ipairs(r.children) do if item.Parent==r and (not name or item.Name==name) then count+=1; found=item end end
 return count,found
end
local viewerAttrs={}
local viewer={GetAttribute=function(_,name) return viewerAttrs[name] end}
local r=root(0); local charAttrs={BrainrotAuraTier=0}
local character={FindFirstChild=function(_,name) return name=="HumanoidRootPart" and r end,GetAttribute=function(_,name) return charAttrs[name] end}
local target={Character=character}
local players={target}; local Players={LocalPlayer=viewer,GetPlayers=function() return players end}
local tick=nil; local RunService={Heartbeat={Connect=function(_,fn) tick=fn end}}
local workspace={CurrentCamera={CFrame={Position=Vector3.new(0,0,0)}}}
-- INSERT_STYLE
assert(AuraStyle.tier(0)==0 and AuraStyle.tier(9)==0 and AuraStyle.tier(10)==1 and AuraStyle.tier(24)==1)
assert(AuraStyle.tier(25)==2 and AuraStyle.tier(49)==2 and AuraStyle.tier(50)==3 and AuraStyle.tier(99)==3 and AuraStyle.tier(100)==4)
assert(AuraStyle.tier(0/0)==0 and AuraStyle.get(0)==nil and AuraStyle.get(5)==nil and AuraStyle.get(1).range==8)
-- INSERT_RENDERER
-- INSERT_CLIENT
local function update(t) time=t; tick() end
assert(tick); update(0.5); assert(visible(r)==0)
charAttrs.BrainrotAuraTier=1; update(1); assert(visible(r)==5)
local _,sparkle=visible(r,"LocalAuraSparkles"); assert(sparkle.Enabled)
local _,beam=visible(r,"LocalAuraBeam"); assert(beam.Attachment0.Parent==r and beam.Attachment1.Parent==r)
update(1.5); assert(visible(r)==5,"Heartbeat must not duplicate effects")
viewerAttrs.ReduceDisplayMotion=true; update(2); assert(not sparkle.Enabled and visible(r)==5)
viewerAttrs.ReduceDisplayMotion=false; update(2.5); assert(sparkle.Enabled)
viewerAttrs.HidePlayerAuras=true; update(3); assert(visible(r)==0)
viewerAttrs.HidePlayerAuras=false; update(3.5); assert(visible(r)==5)
charAttrs.BrainrotAuraTier=3; update(4); assert(visible(r)==5)
local _,light=visible(r,"LocalAuraLight"); assert(light.Range==10 and light.Color.r==255)
workspace.CurrentCamera.CFrame.Position=Vector3.new(101,0,0); update(4.5); assert(visible(r)==0)
workspace.CurrentCamera.CFrame.Position=Vector3.new(0,0,0); update(5); assert(visible(r)==5)
local old=r; r=root(3); update(5.5); assert(visible(old)==0 and visible(r)==5,"Respawn must clean up old effects")
r.alive=false; update(6); assert(visible(r)==0)
r.alive=true; update(6.5); assert(visible(r)==5)
players={}; update(7); assert(visible(r)==0,"Leaving players must release effects")
players={target}; workspace.CurrentCamera=nil; update(7.5); assert(visible(r)==0)
print("Aura tier boundaries, local LOD, accessibility, respawn and cleanup passed (mocked Roblox)")
