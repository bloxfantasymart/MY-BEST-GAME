--!strict
-- Historic, informational discovery bits for catalog archetypes. No rewards.
local CollectionIndex={}
CollectionIndex.MaxNames=200
local bits={Head=1,Chest=2,Arms=4,Legs=8}
local kinds={"Head","Chest","Arms","Legs"}
function CollectionIndex.catalogNames(catalog)
 local names={}
 for _,entry in ipairs(catalog) do names[entry.name]=true end
 return names
end
function CollectionIndex.has(mask,kind)
 return type(mask)=="number" and bits[kind]~=nil and bit32.band(mask,bits[kind])~=0
end
function CollectionIndex.record(collection,parts,creatures,knownNames)
 local count=0
 for _ in pairs(collection) do count+=1 end
 local changed=0
 local function recordPart(item)
  if type(item)~="table" or type(item.name)~="string" or not knownNames[item.name] then return end
  local bit=bits[item.kind]
  if not bit then return end
  local old=collection[item.name]
  if old==nil and count>=CollectionIndex.MaxNames then return end
  local nextMask=bit32.bor(old or 0,bit)
  if nextMask~=(old or 0) then
   if old==nil then count+=1 end
   collection[item.name]=nextMask; changed+=1
  end
 end
 for _,item in ipairs(parts) do recordPart(item) end
 for _,creature in ipairs(creatures) do
  for _,kind in ipairs(kinds) do recordPart(creature.components and creature.components[kind]) end
 end
 return changed
end
function CollectionIndex.matches(mask,filter)
 mask=mask or 0
 if filter=="All" then return true end
 if filter=="Missing parts" then return mask~=15 end
 if filter=="Started" then return mask>0 and mask<15 end
 if filter=="Complete" then return mask==15 end
 if filter=="Unseen" then return mask==0 end
 return false
end
function CollectionIndex.summary(collection,catalog)
 local partCount,seen,complete=0,0,0
 for _,entry in ipairs(catalog) do
  local mask=collection[entry.name] or 0
  if mask~=0 then seen+=1 end
  if mask==15 then complete+=1 end
  for _,kind in ipairs(kinds) do if CollectionIndex.has(mask,kind) then partCount+=1 end end
 end
 return {parts=partCount,seen=seen,complete=complete,totalParts=#catalog*4,totalArchetypes=#catalog}
end
return CollectionIndex
