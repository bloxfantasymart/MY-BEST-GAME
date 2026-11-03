--!strict
-- Shared stand geometry and preview math. The server remains authoritative.
local StandLayout={}
function StandLayout.rates(creatures,incomeFn)
 local occupied={}
 for _,creature in ipairs(creatures) do
  if creature.stand>0 then occupied[creature.stand]=creature end
 end
 local rates={}
 for stand,creature in pairs(occupied) do
  local row=math.floor((stand-1)/6)
  local column=(stand-1)%6
  local neighbors={{row-1,column},{row+1,column},{row,column-1},{row,column+1}}
  local multiplier=1
  for _,position in ipairs(neighbors) do
   local r,c=position[1],position[2]
   if r>=0 and r<4 and c>=0 and c<6 then
    local neighbor=occupied[r*6+c+1]
    if neighbor and neighbor.ascended==true then multiplier+=0.2 end
   end
  end
  rates[stand]=incomeFn(creature)*multiplier
 end
 return rates
end
-- Require explicit intent; a replayed place must never turn into a removal.
function StandLayout.canChange(creatures,stand,id,action)
 if type(stand)~="number" or stand~=stand or stand%1~=0 or stand<1 or stand>24
  or type(id)~="string" or #id<1 or #id>64 or (action~="place" and action~="remove") then
  return nil,"Invalid stand request."
 end
 local selected,occupant=nil,nil
 for _,creature in ipairs(creatures) do
  if creature.id==id then selected=creature end
  if creature.stand==stand then occupant=creature end
 end
 if not selected then return nil,"Creature is no longer in your backpack." end
 if action=="place" then
  if selected.stand~=0 then return nil,"Creature is no longer unplaced." end
  if occupant then return nil,"This stand is occupied." end
 elseif selected.stand~=stand then return nil,"Creature is no longer on this stand." end
 return selected
end
function StandLayout.apply(creatures,stand,id,action)
 local creature,reason=StandLayout.canChange(creatures,stand,id,action)
 if not creature then return nil,reason end
 creature.stand=action=="place" and stand or 0
 return creature
end
-- Estimate ordinary plot income, including adjacency and the permanent statue,
-- but excluding time-limited event and VIP multipliers. Never mutates inventory.
function StandLayout.preview(creatures,stand,id,action,incomeFn,statue)
 local selected,reason=StandLayout.canChange(creatures,stand,id,action)
 if not selected then return nil,reason end
 local before=StandLayout.rates(creatures,incomeFn)
 local modified={}
 for _,creature in ipairs(creatures) do
  if creature==selected then
   local copy=table.clone(creature); copy.stand=action=="place" and stand or 0
   table.insert(modified,copy)
  else table.insert(modified,creature) end
 end
 local after=StandLayout.rates(modified,incomeFn)
 local scale=statue and 1.5 or 1
 local oldTotal,newTotal=0,0
 local changes={}
 for n=1,24 do
  local old=(before[n] or 0)*scale; local new=(after[n] or 0)*scale
  oldTotal+=old; newTotal+=new
  if old~=new then table.insert(changes,{stand=n,before=old,after=new,delta=new-old}) end
 end
 local targetDelta=((after[stand] or 0)-(before[stand] or 0))*scale
 return {before=oldTotal,after=newTotal,delta=newTotal-oldTotal,targetDelta=targetDelta,
  neighborDelta=newTotal-oldTotal-targetDelta,changes=changes}
end
return StandLayout
