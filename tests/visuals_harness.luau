-- Minimal structural Roblox stubs, not a renderer or engine simulation.
local vectorMeta={}
vectorMeta.__add=function(a,b) return setmetatable({X=a.X+b.X,Y=a.Y+b.Y,Z=a.Z+b.Z},vectorMeta) end
local Vector3={new=function(x,y,z) return setmetatable({X=x,Y=y,Z=z},vectorMeta) end}
local Color3={fromRGB=function(r,g,b) return {R=r/255,G=g/255,B=b/255} end}
local Enum={Material={SmoothPlastic="SmoothPlastic",Metal="Metal",Neon="Neon",Glass="Glass"},PartType={Ball="Ball"}}
local methods={}
function methods:SetAttribute(key,value) self._attributes[key]=value end
function methods:GetAttribute(key) return self._attributes[key] end
function methods:IsA(class) return self._class==class or (class=="BasePart" and self._class=="Part") end
function methods:GetChildren() return self._children end
function methods:GetDescendants()
 local all={}
 local function walk(node) for _,child in ipairs(node._children) do table.insert(all,child); walk(child) end end
 walk(self); return all
end
local objectMeta={
 __index=function(self,key) return methods[key] or self._properties[key] end,
 __newindex=function(self,key,value)
  self._properties[key]=value
  if key=="Parent" and value then table.insert(value._children,self) end
 end,
}
local Instance={new=function(class)
 return setmetatable({_class=class,_properties={},_children={},_attributes={}},objectMeta)
end}
-- INSERT_STYLE
-- INSERT_CONFIG
-- INSERT_VISUALS
local signatures={}
for _,entry in ipairs(Config.Catalog) do
 local style=VisualStyle.resolve(entry.name)
 assert(style.headwear>=1 and style.headwear<=6 and style.face>=1 and style.face<=4 and style.chest>=1 and style.chest<=4 and style.limbs>=1 and style.limbs<=4 and style.palette>=1 and style.palette<=8)
 local signature=style.headwear..":"..style.face..":"..style.chest..":"..style.limbs..":"..style.palette
 signatures[signature]=true
 local again=VisualStyle.resolve(entry.name)
 assert(again.headwear==style.headwear and again.face==style.face and again.palette==style.palette)
end
local signatureCount=0; for _ in pairs(signatures) do signatureCount+=1 end
assert(signatureCount>=40, "Catalog should have varied stable cosmetic combinations")
for _,entry in ipairs(Config.Catalog) do
 local components={}
 for _,kind in ipairs({"Head","Chest","Arms","Legs"}) do components[kind]={kind=kind,name=entry.name,rarity=entry.rarity,income=entry.income,mutation="Standard",mutationMultiplier=1} end
 local model=Instance.new("Model")
 Visuals.makeCreature(model,Vector3.new(0,0,0),{level=10,components=components,ascended=true})
 local count=0
 for _,child in ipairs(model:GetDescendants()) do if child:IsA("BasePart") then count+=1 end end
 assert(count<=30 and count>=15, "Every catalog entry must render with a bounded primitive count")
end
assert(VisualStyle.resolve("Skibidi Toilet").headwear==1)
assert(VisualStyle.resolve("Titan Cameraman").headwear==2)
assert(VisualStyle.resolve("Titan TV Man").headwear==3)
assert(VisualStyle.resolve("Titan Speakerman").headwear==4)
assert(VisualStyle.levelTier(1)==1 and VisualStyle.levelTier(4)==1 and VisualStyle.levelTier(5)==2 and VisualStyle.levelTier(9)==2 and VisualStyle.levelTier(10)==3 and VisualStyle.levelTier(1000)==3)
local function piece(kind,name,rarity,mutation)
 return {kind=kind,name=name,rarity=rarity,income=10,mutation=mutation or "Standard",mutationMultiplier=1}
end
local creature={level=1,components={Head=piece("Head","Skibidi Toilet",1),Chest=piece("Chest","Nooblet",2),Arms=piece("Arms","Titan Speakerman",5,"Glitched"),Legs=piece("Legs","Dirt Boy",1,"Void")}}
assert(VisualStyle.compositeRarity(creature)==5)
local function build(level,ascended)
 creature.level=level; creature.ascended=ascended
 local model=Instance.new("Model")
 Visuals.makeCreature(model,Vector3.new(0,0,0),creature)
 local counts={}; local parts=0; local rainbow=0
 for _,node in ipairs(model:GetDescendants()) do
  if node:IsA("BasePart") then
   parts+=1; assert(node.Anchored and node.CanCollide==false)
   counts[node.Name]=(counts[node.Name] or 0)+1
   if node:GetAttribute("Rainbow") then rainbow+=1 end
   if node.Name=="Eye" then assert(node.Material==(level>=5 and "Neon" or "SmoothPlastic")) end
  end
 end
 for _,name in ipairs({"Head","Chest","Arms","Legs"}) do assert(counts[name]==1) end
 assert(counts.Eye==2 and counts.Pupil==2 and counts.Hand==2 and counts.Foot==2)
 assert(parts<=30 and rainbow==1, "Each display has a bounded number of parts and preserves glitch styling")
 return counts
end
local young=build(1,false); assert(not young["Prestige halo"] and not young["Ascension crown"])
local mid=build(5,false); assert(not mid["Prestige halo"])
local prestige=build(10,true); assert(prestige["Prestige halo"]==1 and prestige["Ascension crown"]==1)
print("Procedural identity, tier, mutation and bounded display structure tests passed (mocked Roblox)")
