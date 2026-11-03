--!strict
-- Shared recipe identity. This never grants ownership or authorizes a fusion.
local FusionRecipe={}
local kinds={"Head","Chest","Arms","Legs"}
local function samePart(a,b)
 return a and b and a.kind==b.kind and a.name==b.name and a.rarity==b.rarity
  and a.income==b.income and (a.mutation or "Standard")==(b.mutation or "Standard")
  and (a.mutationMultiplier or 1)==(b.mutationMultiplier or 1)
end
function FusionRecipe.matches(a,b)
 if not a or not b or a.name~=b.name or a.income~=b.income or (a.blueprintApplied==true)~=(b.blueprintApplied==true) then return false end
 if type(a.components)~="table" or type(b.components)~="table" then return false end
 for _,kind in ipairs(kinds) do if not samePart(a.components[kind],b.components[kind]) then return false end end
 return true
end
function FusionRecipe.eligible(c)
 return c and not c.locked and c.stand==0 and c.level>=10 and c.ascended~=true
end
return FusionRecipe
