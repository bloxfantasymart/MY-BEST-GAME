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
   local missing={}; local blocked=false; local allBlocked=true
   for _,kind in ipairs(types) do
    if not usable[kind] then
     table.insert(missing,kind)
     if protected[kind] then blocked=true else allBlocked=false end
    end
   end
   if #missing>0 then
    if allBlocked then return "Open BACKPACK and unprotect: "..table.concat(missing,", ")..".","BACKPACK","OPEN BACKPACK" end
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
-- Resolve only server-owned plot objects, never arbitrary client positions.
function Guide.destination(target,plot,standsUnlocked)
 if type(target)~="string" or type(plot)~="table" then return nil end
 if target=="Roll station" then return plot.lever end
 if target=="Assembly pod" then return plot.pod end
 if target=="Cash ATM" then return plot.atm end
 local digits=target:match("^Stand (%d+)$")
 local stand=digits and tonumber(digits)
 if stand and stand>=1 and stand<=standsUnlocked and stand<=24 and plot.stands then return plot.stands[stand] end
 return nil
end
return Guide
