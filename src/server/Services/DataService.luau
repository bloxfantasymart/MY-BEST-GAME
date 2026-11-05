--!strict
-- A lease prevents two servers from actively modifying the same profile.
-- Studio defaults to an in-memory profile; turn on TestPersistence explicitly to test DataStores.
local Loadouts=require(script.Parent.Loadouts)
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local store = DataStoreService:GetDataStore("RollABrainrotProfiles_v1")
local DataService = {}
DataService.TestPersistence = false
local leaseSeconds = 180
local sessions = {}
local loading = {}
local function defaults()
 return {version=1, cash=200, pending=0, slots=1, standsUnlocked=12, rebirth=0, parts={}, creatures={}}
end
local function finite(value, low, high)
 return type(value)=="number" and value==value and value>=low and value<=high
end
-- Reject sparse or dictionary-shaped inventory arrays: ipairs/JSON could silently
-- skip items or change their representation. Empty legacy arrays remain valid.
local function denseArray(value,limit)
 if type(value)~="table" then return false end
 local length=#value
 if length>limit then return false end
 local count=0
 for key in pairs(value) do
  count+=1
  if count>limit or type(key)~="number" or key%1~=0 or key<1 or key>length then return false end
 end
 return count==length
end
local function validPart(item)
 return type(item)=="table" and type(item.id)=="string" and #item.id>=1 and #item.id<=64
  and type(item.name)=="string" and #item.name<=100
  and (item.kind=="Head" or item.kind=="Chest" or item.kind=="Arms" or item.kind=="Legs")
  and finite(item.rarity,1,8) and item.rarity%1==0 and finite(item.income,0,1e15)
  and (item.mutation==nil or (type(item.mutation)=="string" and #item.mutation<=40))
  and (item.locked==nil or type(item.locked)=="boolean")
  and (item.price==nil or finite(item.price,0,1e15))
  and (item.mutationMultiplier==nil or finite(item.mutationMultiplier,1,6))
end
local function validProfile(data)
 if type(data)~="table" or (data.version~=nil and data.version~=1) then return false end
 if not finite(data.cash,0,1e300) or not finite(data.pending,0,1e300)
  or not finite(data.slots,1,9) or data.slots%1~=0
  or not finite(data.rebirth,0,100) or data.rebirth%1~=0
  or not denseArray(data.parts,265)
  or not denseArray(data.creatures,100) then return false end
 if data.lock~=nil and (type(data.lock)~="table" or type(data.lock.token)~="string" or #data.lock.token<1 or #data.lock.token>64
  or not finite(data.lock.expires,0,1e12) or data.lock.expires%1~=0) then return false end
 if data.backpackUpgrades~=nil and (not finite(data.backpackUpgrades,0,10) or data.backpackUpgrades%1~=0) then return false end
 if data.rareBlueprints~=nil and (not finite(data.rareBlueprints,0,100) or data.rareBlueprints%1~=0) then return false end
 if data.autoCollect~=nil and type(data.autoCollect)~="boolean" then return false end
 if data.standLoadouts~=nil and not Loadouts.valid(data.standLoadouts) then return false end
 if data.season~=nil then
  local season=data.season
  if type(season)~="table" or not finite(season.xp,0,5000) or season.xp%1~=0
   or not finite(season.claimed,0,50) or season.claimed%1~=0 or season.claimed>math.floor(season.xp/100)
   or not finite(season.rollProgress,0,250000) or season.rollProgress%1~=0 then return false end
 end
 if data.extras~=nil then
  local e=data.extras
  if type(e)~="table" or not finite(e.luckPotions,0,100) or e.luckPotions%1~=0
   or not finite(e.rollVouchers,0,1000) or e.rollVouchers%1~=0
   or (e.doubleLuckPotions~=nil and (not finite(e.doubleLuckPotions,0,100) or e.doubleLuckPotions%1~=0))
   or (e.uncommonBoxes~=nil and (not finite(e.uncommonBoxes,0,100) or e.uncommonBoxes%1~=0))
   or (e.standardBoxes~=nil and (not finite(e.standardBoxes,0,100) or e.standardBoxes%1~=0))
   or (e.multiRollTokens~=nil and (not finite(e.multiRollTokens,0,1000) or e.multiRollTokens%1~=0))
   or (e.scrap~=nil and (not finite(e.scrap,0,1000000) or e.scrap%1~=0))
   or ((e.treasureDay==nil)~=(e.treasureClaims==nil))
   or (e.treasureDay~=nil and (not finite(e.treasureDay,-1,1e9) or e.treasureDay%1~=0
    or not finite(e.treasureClaims,0,10) or e.treasureClaims%1~=0 or (e.treasureDay==-1 and e.treasureClaims~=0)))
   or type(e.goldenLever)~="boolean" or type(e.sigmaStatue)~="boolean" or type(e.ohioCrown)~="boolean" then return false end
 end
 if data.tripleLuckUntil~=nil and (not finite(data.tripleLuckUntil,0,1e12) or data.tripleLuckUntil%1~=0) then return false end
 if data.tutorial~=nil then
  if type(data.tutorial)~="table" or not finite(data.tutorial.step,1,7) or data.tutorial.step%1~=0 then return false end
 end
 if data.theme~=nil then
  local thresholds={Classic=0,Cyber=10,Magma=25,Gold=50,Void=100}
  if type(data.theme)~="string" or not thresholds[data.theme] or data.rebirth<thresholds[data.theme] then return false end
 end
 if data.keepSlotsEntitled~=nil and type(data.keepSlotsEntitled)~="boolean" then return false end
 if data.luckUntil~=nil and (not finite(data.luckUntil,0,1e12) or data.luckUntil%1~=0) then return false end
 if data.obbyLastClaim~=nil and (not finite(data.obbyLastClaim,0,1e12) or data.obbyLastClaim%1~=0) then return false end
 if data.lastLogout~=nil and (not finite(data.lastLogout,0,1e12) or data.lastLogout%1~=0) then return false end
 if data.lastOfflineAward~=nil and not finite(data.lastOfflineAward,0,1e300) then return false end
 if data.lastOfflineSeconds~=nil and (not finite(data.lastOfflineSeconds,0,86400) or data.lastOfflineSeconds%1~=0) then return false end
 if data.lastOfflineRate~=nil and not finite(data.lastOfflineRate,0,1e300) then return false end
 if data.lastOfflineCapped~=nil and type(data.lastOfflineCapped)~="boolean" then return false end
 -- Matches CollectionIndex.MaxNames. Preserve unknown old/future archetype names.
 if data.collection~=nil then
  if type(data.collection)~="table" then return false end
  local count=0
  for name,mask in pairs(data.collection) do
   count+=1
   if count>200 or type(name)~="string" or #name<1 or #name>100
    or not finite(mask,1,15) or mask%1~=0 then return false end
  end
 end
 if data.progress~=nil then
  local p=data.progress
  if type(p)~="table" or not finite(p.dailyLastDay,-1,1e9) or p.dailyLastDay%1~=0
   or not finite(p.dailyStreak,0,7) or p.dailyStreak%1~=0
   or not finite(p.questDay,-1,1e9) or p.questDay%1~=0
   or not finite(p.rolls,0,50) or not finite(p.rareCrafts,0,2) or not finite(p.collected,0,500000)
   or type(p.claimed)~="table" then return false end
  if p.questVariant~=nil and (not finite(p.questVariant,1,18) or p.questVariant%1~=0) then return false end
  for key,value in pairs(p.claimed) do
   if (key~="rolls" and key~="rareCrafts" and key~="collected") or value~=true then return false end
  end
 end
 local maxStands=data.standsUnlocked or 12
 if not finite(maxStands,12,24) or maxStands%1~=0 then return false end
 local ids,stands={},{}
 for _,item in ipairs(data.parts) do
  if not validPart(item) or ids[item.id] then return false end
  ids[item.id]=true
 end
 for _,creature in ipairs(data.creatures) do
  if type(creature)~="table" or type(creature.id)~="string" or #creature.id<1 or #creature.id>64 or ids[creature.id]
   or type(creature.name)~="string" or #creature.name>120
   or not finite(creature.income,0,1e18) or not finite(creature.level,1,1000) or creature.level%1~=0
   or not finite(creature.stand,0,maxStands) or creature.stand%1~=0
   or (creature.exp~=nil and not finite(creature.exp,0,1e12))
   or (creature.ascended~=nil and type(creature.ascended)~="boolean")
   or (creature.locked~=nil and type(creature.locked)~="boolean")
   or (creature.blueprintApplied~=nil and type(creature.blueprintApplied)~="boolean") or type(creature.components)~="table" then return false end
  ids[creature.id]=true
  if creature.stand>0 then if stands[creature.stand] then return false end; stands[creature.stand]=true end
  for _,kind in ipairs({"Head","Chest","Arms","Legs"}) do
   local item=creature.components[kind]
   if not validPart(item) or item.kind~=kind or ids[item.id] then return false end
   ids[item.id]=true
  end
 end
 return true
end
local function copy(data)
 return HttpService:JSONDecode(HttpService:JSONEncode(data))
end
local function loadImpl(userId,onAcquire)
 if RunService:IsStudio() and not DataService.TestPersistence then
  local data=defaults(); if onAcquire then data=onAcquire(data) end
  if not validProfile(data) then return nil end
  sessions[userId]={memory=true, lastSuccess=os.clock()}; return data
 end
 local token=HttpService:GenerateGUID(false)
 local key="player_"..userId
 for attempt=1,6 do
  local acquired=false
  local ok,result=pcall(function()
   return store:UpdateAsync(key,function(old)
    acquired=false
    if old~=nil and not validProfile(old) then warn("Invalid or unsupported player profile: "..userId); return nil end
    if old and old.lock and old.lock.expires>os.time() and old.lock.token~=token then return nil end
    local profile=old or defaults()
    if onAcquire then profile=onAcquire(profile) end
    if not validProfile(profile) then return nil end
    profile.lock={token=token,expires=os.time()+leaseSeconds}
    acquired=true
    return profile
   end)
  end)
  if ok and acquired and result then
   sessions[userId]={token=token,lastSuccess=os.clock(),busy=false,issued=0,lastWritten=0,closing=false}
   result.lock=nil
   return result
  end
  if attempt<6 then task.wait(2) end
 end
 return nil
end
function DataService.load(userId,onAcquire)
 -- One live or in-flight load per user within this server, including Studio.
 -- The outer guard is released even if a service or callback throws.
 if sessions[userId] or loading[userId] then return nil end
 loading[userId]=true
 local ok,result=pcall(loadImpl,userId,onAcquire)
 loading[userId]=nil
 if not ok then warn("Profile load failed: "..tostring(userId)); return nil end
 return result
end
function DataService.save(userId, data, release)
 local session=sessions[userId]
 if not session or session.closing then return false end
 local function failEarly(message)
  warn(message..userId)
  -- No invalid final snapshot is written. Drop the local session so future
  -- joins can retry after the persisted lease expires; pending saves observe
  -- closing/session identity and cannot replace a newer local session.
  if release then session.closing=true; if sessions[userId]==session then sessions[userId]=nil end end
  return false
 end
 if not validProfile(data) then return failEarly("Refusing to save invalid profile: ") end
 if session.memory then if release then sessions[userId]=nil end; return true end
 -- Snapshot before waiting so scalar and table fields describe the same moment.
 local copied,snapshot=pcall(copy,data)
 if not copied then return failEarly("Failed to copy player profile: ") end
 if not validProfile(snapshot) then return failEarly("Refusing to save invalid profile snapshot: ") end
 session.issued+=1
 local sequence=session.issued
 if release then session.closing=true end
 -- Waiters are not guaranteed FIFO. A later completed snapshot supersedes older
 -- queued snapshots; a final save also prevents queued autosaves from delaying it.
 while session.busy do task.wait(0.1) end
 if sessions[userId]~=session then return false end
 if not release and (session.closing or sequence<=session.lastWritten) then return true end
 session.busy=true
 local saved=false
 for attempt=1,3 do
  local wrote=false
  local ok=pcall(function()
   store:UpdateAsync("player_"..userId,function(old)
    wrote=false
    if not old or not old.lock or old.lock.token~=session.token then return nil end
    if release then snapshot.lock=nil else snapshot.lock={token=session.token,expires=os.time()+leaseSeconds} end
    wrote=true
    return snapshot
   end)
  end)
  if ok and wrote then saved=true; session.lastSuccess=os.clock(); session.lastWritten=sequence; break end
  if attempt<3 then task.wait(attempt*2) end
 end
 session.busy=false
 if release and sessions[userId]==session then sessions[userId]=nil end
 return saved
end
function DataService.isHealthy(userId)
 local session=sessions[userId]
 return session~=nil and (session.memory or os.clock()-session.lastSuccess<120)
end
return DataService
