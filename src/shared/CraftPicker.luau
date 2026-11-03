--!strict
-- Client-only browsing helpers; the server validates every submitted item.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local FusionRecipe=require(ReplicatedStorage.Shared:WaitForChild("FusionRecipe"))
local CraftPicker={}
local function matches(text,query)
 return query=="" or string.find(string.lower(text),string.lower(query),1,true)~=nil
end
function CraftPicker.parts(parts,kind,query,blueprint,sortMode)
 local found={}
 for index,item in ipairs(parts) do
  if item.kind==kind and not item.locked and (not blueprint or item.rarity>=3)
   and matches(item.name.." "..(item.mutation or "Standard"),query or "") then
   table.insert(found,{item=item,index=index})
  end
 end
 table.sort(found,function(a,b)
  if sortMode=="Rarity" and a.item.rarity~=b.item.rarity then return a.item.rarity>b.item.rarity end
  local ai=a.item.income*(a.item.mutationMultiplier or 1); local bi=b.item.income*(b.item.mutationMultiplier or 1)
  if sortMode=="Contribution" and ai~=bi then return ai>bi end
  if sortMode=="Name" then
   local an,bn=string.lower(a.item.name),string.lower(b.item.name)
   if an~=bn then return an<bn end
  end
  if sortMode=="Newest" and a.index~=b.index then return a.index>b.index end
  return a.item.id<b.item.id
 end)
 return found
end
function CraftPicker.fusion(creatures,query,first)
 local found={}
 for _,c in ipairs(creatures) do
  if FusionRecipe.eligible(c) and (not first or FusionRecipe.matches(first,c))
   and matches(c.name,query or "") then table.insert(found,c) end
 end
 table.sort(found,function(a,b)
  if a.level~=b.level then return a.level>b.level end
  return a.id<b.id
 end)
 return found
end
return CraftPicker
