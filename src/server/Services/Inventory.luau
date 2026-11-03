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
-- Snapshot-based batch protection. Validate every item before changing any.
function Inventory.bulkSetLocked(parts,creatures,items,locked)
 if type(locked)~="boolean" or type(items)~="table" or #items<1 or #items>365 then return nil end
 local length=#items; local count=0
 for key in pairs(items) do
  count+=1
  if count>365 or type(key)~="number" or key%1~=0 or key<1 or key>length then return nil end
 end
 if count~=length then return nil end
 local owned={part={},creature={}}
 for _,item in ipairs(parts) do owned.part[item.id]=item end
 for _,item in ipairs(creatures) do owned.creature[item.id]=item end
 local seen={}; local selected={}
 for _,entry in ipairs(items) do
  if type(entry)~="table" or (entry.category~="part" and entry.category~="creature")
   or type(entry.id)~="string" or #entry.id<1 or #entry.id>64 or seen[entry.id] then return nil end
  local item=owned[entry.category][entry.id]
  if not item or (item.locked==true)==locked then return nil end
  seen[entry.id]=true; table.insert(selected,item)
 end
 for _,item in ipairs(selected) do item.locked=locked end
 return #selected
end
function Inventory.bulkSell(parts,rarity,ids,valueFn)
 if type(rarity)~="number" or rarity~=rarity or rarity%1~=0 or rarity<1 or rarity>8 then return nil end
 if type(ids)~="table" or #ids<1 or #ids>265 then return nil end
 -- Reject sparse or dictionary-shaped payloads instead of silently ignoring entries.
 local length=#ids; local entries=0
 for key in pairs(ids) do
  entries+=1
  if entries>265 or type(key)~="number" or key%1~=0 or key<1 or key>length then return nil end
 end
 if entries~=length then return nil end
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
