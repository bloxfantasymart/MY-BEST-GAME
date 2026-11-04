--!strict
-- Saved stand layouts store references only, never duplicate or transfer items.
local Loadouts={}
Loadouts.Slots=3
Loadouts.MaxStands=24
Loadouts.QuoteLifetime=60
local function slotKey(slot)
 if type(slot)~="number" or slot~=slot or slot%1~=0 or slot<1 or slot>Loadouts.Slots then return nil end
 return tostring(slot)
end
function Loadouts.validEntries(entries)
 if type(entries)~="table" or #entries>Loadouts.MaxStands then return false end
 local length=#entries; local keys=0
 for key in pairs(entries) do
  keys+=1
  if keys>Loadouts.MaxStands or type(key)~="number" or key%1~=0 or key<1 or key>length then return false end
 end
 if keys~=length then return false end
 local seen={}; local lastStand=0
 for _,entry in ipairs(entries) do
  if type(entry)~="table" or type(entry.id)~="string" or #entry.id<1 or #entry.id>64
   or type(entry.stand)~="number" or entry.stand~=entry.stand or entry.stand%1~=0
   or entry.stand<=lastStand or entry.stand>Loadouts.MaxStands or seen[entry.id] then return false end
  for key in pairs(entry) do if key~="id" and key~="stand" then return false end end
  lastStand=entry.stand; seen[entry.id]=true
 end
 return true
end
function Loadouts.valid(loadouts)
 if type(loadouts)~="table" then return false end
 local count=0
 for key,entries in pairs(loadouts) do
  count+=1
  if count>Loadouts.Slots or (key~="1" and key~="2" and key~="3") or not Loadouts.validEntries(entries) then return false end
 end
 return true
end
function Loadouts.capture(creatures)
 local result={}
 for _,creature in ipairs(creatures) do
  if creature.stand>0 then table.insert(result,{id=creature.id,stand=creature.stand}) end
 end
 table.sort(result,function(a,b) return a.stand<b.stand end)
 return result
end
function Loadouts.same(a,b)
 if not Loadouts.validEntries(a) or not Loadouts.validEntries(b) or #a~=#b then return false end
 for i=1,#a do if a[i].id~=b[i].id or a[i].stand~=b[i].stand then return false end end
 return true
end
local function copyEntries(entries)
 local result={}
 for _,entry in ipairs(entries) do table.insert(result,{id=entry.id,stand=entry.stand}) end
 return result
end
function Loadouts.save(state,slot,reviewed,hadSaved,oldSaved)
 local key=slotKey(slot)
 if not key or type(hadSaved)~="boolean" then return false,"Review the layout slot again." end
 local existing=state.standLoadouts[key]
 if (hadSaved and (not existing or not Loadouts.same(existing,oldSaved))) or (not hadSaved and existing~=nil) then
  return false,"Saved layout changed. Review again."
 end
 if not Loadouts.same(Loadouts.capture(state.creatures),reviewed) then return false,"Plot changed. Review the current layout again." end
 state.standLoadouts[key]=copyEntries(reviewed); state.layoutQuote=nil
 return true
end
function Loadouts.delete(state,slot,reviewed)
 local key=slotKey(slot); local saved=key and state.standLoadouts[key]
 if not saved or not Loadouts.same(saved,reviewed) then return false,"Saved layout changed. Review again." end
 state.standLoadouts[key]=nil; state.layoutQuote=nil
 return true
end
local function resolve(state,entries)
 if not Loadouts.validEntries(entries) then return nil,"Saved layout is invalid." end
 local owned={}
 for _,creature in ipairs(state.creatures) do owned[creature.id]=creature end
 for _,entry in ipairs(entries) do
  if entry.stand>state.standsUnlocked then return nil,"A saved stand is locked." end
  if not owned[entry.id] then return nil,"A saved creature is no longer owned. Save a new layout." end
 end
 return owned
end
function Loadouts.review(state,slot,now,token,ratesFn,incomeFn,statue)
 local key=slotKey(slot); local saved=key and state.standLoadouts[key]
 if not saved then return nil,"This layout slot is empty." end
 if type(token)~="string" or #token<1 or #token>64 then return nil,"Could not create a review." end
 local owned,reason=resolve(state,saved)
 if not owned then return nil,reason end
 local before=Loadouts.capture(state.creatures)
 if Loadouts.same(before,saved) then return nil,"This layout is already active." end
 local target={}
 for _,entry in ipairs(saved) do target[entry.id]=entry.stand end
 local simulated={}
 for _,creature in ipairs(state.creatures) do
  local clone=table.clone(creature); clone.stand=target[creature.id] or 0; table.insert(simulated,clone)
 end
 local oldRates=ratesFn(state.creatures,incomeFn); local newRates=ratesFn(simulated,incomeFn)
 local beforeMap,afterMap={},{}
 for _,entry in ipairs(before) do beforeMap[entry.stand]=entry.id end
 for _,entry in ipairs(saved) do afterMap[entry.stand]=entry.id end
 local changes={}; local oldTotal,newTotal=0,0; local factor=statue and 1.5 or 1
 for stand=1,Loadouts.MaxStands do
  oldTotal+=(oldRates[stand] or 0)*factor; newTotal+=(newRates[stand] or 0)*factor
  if beforeMap[stand]~=afterMap[stand] then
   local old=beforeMap[stand] and owned[beforeMap[stand]]
   local new=afterMap[stand] and owned[afterMap[stand]]
   table.insert(changes,{stand=stand,oldId=old and old.id or "",oldName=old and old.name or "Empty",newId=new and new.id or "",newName=new and new.name or "Empty"})
  end
 end
 return {token=token,expires=now+Loadouts.QuoteLifetime,slot=slot,before=before,after=copyEntries(saved),changes=changes,beforeIncome=oldTotal,afterIncome=newTotal}
end
function Loadouts.apply(state,token,now)
 local quote=state.layoutQuote; state.layoutQuote=nil
 if type(quote)~="table" or type(token)~="string" or token~=quote.token then return nil,"Review the layout again." end
 if now>=quote.expires then return nil,"The layout review expired. Review again." end
 local key=slotKey(quote.slot); local saved=key and state.standLoadouts[key]
 if not saved or not Loadouts.same(saved,quote.after) or not Loadouts.same(Loadouts.capture(state.creatures),quote.before) then
  return nil,"The plot or saved layout changed. Review again."
 end
 local owned,reason=resolve(state,quote.after)
 if not owned then return nil,reason end
 -- Validate the entire target first, then update without yielding.
 for _,creature in ipairs(state.creatures) do creature.stand=0 end
 for _,entry in ipairs(quote.after) do owned[entry.id].stand=entry.stand end
 return quote
end
return Loadouts
