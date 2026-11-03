--!strict
-- Browsing helpers for sanitized, owner-only showcase inventory records.
local ShowcaseInventory={}
function ShowcaseInventory.build(items,listings,query,sortMode,hideDisplayed)
 local displayed={}
 for _,entry in ipairs(listings) do displayed[entry.id]=true end
 local results={}; local text=string.lower(query or "")
 for index,item in ipairs(items) do
  local shown=displayed[item.id]==true
  local haystack=string.lower(item.name.." "..table.concat(item.parts or {}," "))
  if (not hideDisplayed or not shown) and (text=="" or string.find(haystack,text,1,true)) then
   table.insert(results,{item=item,index=index,displayed=shown})
  end
 end
 table.sort(results,function(a,b)
  if sortMode=="Income" and a.item.income~=b.item.income then return a.item.income>b.item.income end
  if sortMode=="Rarity" and a.item.rarity~=b.item.rarity then return a.item.rarity>b.item.rarity end
  if sortMode=="Name" then
   local an,bn=string.lower(a.item.name),string.lower(b.item.name)
   if an~=bn then return an<bn end
  end
  if sortMode=="Newest" and a.index~=b.index then return a.index>b.index end
  return a.item.id<b.item.id
 end)
 return results
end
return ShowcaseInventory
