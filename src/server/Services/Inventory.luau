--!strict
-- Bulk sales are validated in full before any items or money change.
local Inventory={}
function Inventory.setLocked(items,id,locked)
 if type(id)~="string" or #id==0 or #id>64 or type(locked)~="boolean" then return false end
 for _,item in ipairs(items) do
  if item.id==id then item.locked=locked; return true end
 end
 return false
end
function Inventory.canConsume(item)
 return item~=nil and item.locked~=true
end
function Inventory.bulkSell(parts,rarity,ids,valueFn)
 if type(rarity)~="number" or rarity~=rarity or rarity%1~=0 or rarity<1 or rarity>8 then return nil end
 if type(ids)~="table" or #ids<1 or #ids>200 then return nil end
 local owned={}
 for _,item in ipairs(parts) do owned[item.id]=item end
 local selected={}; local count=0; local total=0
 for _,id in ipairs(ids) do
  if type(id)~="string" or #id>64 or selected[id] then return nil end
  local item=owned[id]
  if not Inventory.canConsume(item) or item.rarity>rarity then return nil end
  selected[id]=true; count+=1; total+=valueFn(item)
 end
 -- No yields between validation and removal: no partial sale or duplicate credit.
 for i=#parts,1,-1 do if selected[parts[i].id] then table.remove(parts,i) end end
 return count,total
end
return Inventory
