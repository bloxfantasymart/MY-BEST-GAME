--!strict
-- Read-only inventory safety dashboard. This never authorizes an action.
local InventorySummary={}
local kinds={"Head","Chest","Arms","Legs"}
local function mutated(part)
 return (part.mutation or "Standard")~="Standard" or (part.mutationMultiplier or 1)~=1
end
local function mutatedCreature(creature)
 for _,kind in ipairs(kinds) do
  local p=creature.components and creature.components[kind]
  if p and mutated(p) then return true end
 end
 return false
end
function InventorySummary.build(parts,creatures,partCapacity,partValue,creatureValue)
 local summary={parts=#parts,creatures=#creatures,partCapacity=partCapacity,freeParts=math.max(0,partCapacity-#parts),
  freeCreatures=math.max(0,100-#creatures),protectedParts=0,protectedCreatures=0,placed=0,
  mutatedParts=0,mutatedCreatures=0,unprotectedMutatedParts=0,unprotectedMutatedCreatures=0,
  eligiblePartValue=0,eligibleCreatureValue=0,available={Head=0,Chest=0,Arms=0,Legs=0},
  protect={locked=true,items={},labels={},parts=0,creatures=0,source="unprotected mutations across the entire inventory"}}
 local function capture(category,item,detail)
  local batch=summary.protect
  table.insert(batch.items,{category=category,id=item.id})
  table.insert(batch.labels,(category=="part" and "PART: " or "CREATURE: ")..detail.." #"..string.sub(item.id,-6))
  if category=="part" then batch.parts+=1 else batch.creatures+=1 end
 end
 for _,item in ipairs(parts) do
  local locked=item.locked==true
  if locked then summary.protectedParts+=1 else
   if summary.available[item.kind]~=nil then summary.available[item.kind]+=1 end
   summary.eligiblePartValue+=partValue(item)
  end
  if mutated(item) then
   summary.mutatedParts+=1
   if not locked then
    summary.unprotectedMutatedParts+=1
    capture("part",item,(item.mutation or "Standard").." "..item.name.." "..item.kind)
   end
  end
 end
 for _,item in ipairs(creatures) do
  local locked=item.locked==true
  if locked then summary.protectedCreatures+=1 end
  if item.stand>0 then summary.placed+=1 elseif not locked then summary.eligibleCreatureValue+=creatureValue(item) end
  if mutatedCreature(item) then
   summary.mutatedCreatures+=1
   if not locked then
    summary.unprotectedMutatedCreatures+=1
    capture("creature",item,item.name.." Lv."..item.level.." (contains mutation)")
   end
  end
 end
 return summary
end
return InventorySummary
