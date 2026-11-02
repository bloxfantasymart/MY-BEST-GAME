--!strict
-- Read-only inventory browsing. The server always validates inventory mutations.
local InventoryView={}
function InventoryView.creatureRarity(creature)
 local rarity=1
 for _,part in pairs(creature.components or {}) do rarity=math.max(rarity,part.rarity or 1) end
 return rarity
end
function InventoryView.build(parts,creatures,tab,query,protection,sortMode,incomeFn)
 local entries={}; local text=string.lower(query or "")
 local function add(category,item,index)
  if protection=="Protected" and not item.locked then return end
  if protection=="Unprotected" and item.locked then return end
  local kind=category=="part" and (item.kind or "") or "creature brainrot"
  local mutation=category=="part" and (item.mutation or "Standard") or ""
  local haystack=string.lower(item.name.." "..kind.." "..mutation)
  if text~="" and not string.find(haystack,text,1,true) then return end
  local rarity=category=="part" and item.rarity or InventoryView.creatureRarity(item)
  local income=category=="part" and item.income*(item.mutationMultiplier or 1) or incomeFn(item)
  table.insert(entries,{category=category,item=item,index=index,rarity=rarity,income=income})
 end
 if tab=="All" or tab=="Body Parts" then for i,item in ipairs(parts) do add("part",item,i) end end
 if tab=="All" or tab=="Brainrots" then for i,item in ipairs(creatures) do add("creature",item,i) end end
 table.sort(entries,function(a,b)
  if sortMode=="Rarity" and a.rarity~=b.rarity then return a.rarity>b.rarity end
  if sortMode=="Income" and a.income~=b.income then return a.income>b.income end
  if sortMode=="Name" then
   local aName,bName=string.lower(a.item.name),string.lower(b.item.name)
   if aName~=bName then return aName<bName end
  end
  if sortMode=="Newest" and a.category==b.category and a.index~=b.index then return a.index>b.index end
  if a.category~=b.category then return a.category<b.category end
  return a.item.id<b.item.id
 end)
 return entries
end
function InventoryView.page(entries,page,size)
 local pages=math.max(1,math.ceil(#entries/size))
 local current=math.clamp(page,1,pages); local result={}
 for i=(current-1)*size+1,math.min(current*size,#entries) do table.insert(result,entries[i]) end
 return result,current,pages
end
return InventoryView
