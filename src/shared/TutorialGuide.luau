--!strict
-- Presentation only. The server owns tutorial advancement and rewards.
local Guide={}
local types={"Head","Chest","Arms","Legs"}
function Guide.describe(step,parts,creatures,standsUnlocked,text)
 if step>=7 then return nil,nil,nil end
 if step<=3 then
  local instruction=text[step] or ""
  if step==3 then
   local usable={}; local protected={}
   for _,item in ipairs(parts) do
    if item.locked==true then protected[item.kind]=true else usable[item.kind]=true end
   end
   local missing={}; local blocked=false
   for _,kind in ipairs(types) do
    if not usable[kind] then table.insert(missing,kind); if protected[kind] then blocked=true end end
   end
   if #missing>0 then
    instruction="Need unprotected: "..table.concat(missing,", ")..(blocked and ". Unprotect parts in BACKPACK." or ".")
   end
  end
  return instruction,"Roll station","ROLL STATION"
 elseif step==4 then
  return text[step],"Assembly pod","ASSEMBLY POD"
 elseif step==5 then
  local occupied={}; local unplaced=false; local firstOccupied=nil
  for _,creature in ipairs(creatures) do
   if creature.stand==0 then unplaced=true else occupied[creature.stand]=true; firstOccupied=math.min(firstOccupied or creature.stand,creature.stand) end
  end
  local free=nil
  for i=1,standsUnlocked do if not occupied[i] then free=i; break end end
  if #creatures==0 then return "Assemble a creature before placing it.","Assembly pod","ASSEMBLY POD" end
  if not unplaced then return "Remove a creature from a stand, then place it again.","Stand "..firstOccupied,"REMOVE, THEN PLACE" end
  if not free then return "All stands are occupied. Remove a creature first.","Stand 1","FREE A STAND" end
  return "Place your creature on an empty stand.","Stand "..free,"EMPTY STAND "..free
 elseif step==6 then
  return "Collect income at the ATM or tap the cash counter.","Cash ATM","CASH ATM"
 end
 return nil,nil,nil
end
return Guide
