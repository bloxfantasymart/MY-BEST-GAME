--!strict
-- Stable cosmetic choices derived only from the archetype name; never affects gameplay.
local VisualStyle={}
function VisualStyle.resolve(name)
 local text=type(name)=="string" and name or ""
 local hash=0
 for i=1,#text do hash=(hash*131+string.byte(text,i))%2147483647 end
 local lower=string.lower(text)
 local headwear=hash%6+1
 -- Readable silhouettes for a few broad themes; everything remains asset-free.
 if string.find(lower,"toilet",1,true) then headwear=1
 elseif string.find(lower,"camera",1,true) then headwear=2
 elseif string.find(lower,"tv",1,true) then headwear=3
 elseif string.find(lower,"speaker",1,true) then headwear=4
 elseif string.find(lower,"king",1,true) or string.find(lower,"god",1,true) then headwear=5 end
 return {headwear=headwear,face=math.floor(hash/6)%4+1,chest=math.floor(hash/24)%4+1,
  limbs=math.floor(hash/96)%4+1,palette=math.floor(hash/384)%8+1}
end
function VisualStyle.levelTier(level)
 if level>=10 then return 3 end
 if level>=5 then return 2 end
 return 1
end
function VisualStyle.compositeRarity(creature)
 local highest=1
 for _,component in pairs(creature.components) do highest=math.max(highest,component.rarity or 1) end
 return highest
end
return VisualStyle
