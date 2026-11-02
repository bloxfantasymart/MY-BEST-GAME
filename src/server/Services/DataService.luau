--!strict
-- A lease prevents two servers from actively modifying the same profile.
-- Studio defaults to an in-memory profile; turn on TestPersistence explicitly to test DataStores.
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local store = DataStoreService:GetDataStore("RollABrainrotProfiles_v1")
local DataService = {}
DataService.TestPersistence = false
local leaseSeconds = 180
local sessions = {}
local function defaults()
 return {version=1, cash=200, pending=0, slots=1, standsUnlocked=12, rebirth=0, parts={}, creatures={}}
end
local function finite(value, low, high)
 return type(value)=="number" and value==value and value>=low and value<=high
end
local function validPart(item)
 return type(item)=="table" and type(item.id)=="string" and #item.id<=64
  and type(item.name)=="string" and #item.name<=100
  and (item.kind=="Head" or item.kind=="Chest" or item.kind=="Arms" or item.kind=="Legs")
  and finite(item.rarity,1,8) and item.rarity%1==0 and finite(item.income,0,1e15)
  and (item.locked==nil or type(item.locked)=="boolean")
  and (item.price==nil or finite(item.price,0,1e15))
  and (item.mutationMultiplier==nil or finite(item.mutationMultiplier,1,6))
end
local function validProfile(data)
 if type(data)~="table" or (data.version~=nil and data.version~=1) then return false end
 if not finite(data.cash,0,1e300) or not finite(data.pending,0,1e300)
  or not finite(data.slots,1,9) or data.slots%1~=0
  or not finite(data.rebirth,0,100) or data.rebirth%1~=0
  or type(data.parts)~="table" or #data.parts>200
  or type(data.creatures)~="table" or #data.creatures>100 then return false end
 if data.autoCollect~=nil and type(data.autoCollect)~="boolean" then return false end
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
 if data.lastLogout~=nil and (not finite(data.lastLogout,0,1e12) or data.lastLogout%1~=0) then return false end
 if data.lastOfflineAward~=nil and not finite(data.lastOfflineAward,0,1e300) then return false end
 if data.progress~=nil then
  local p=data.progress
  if type(p)~="table" or not finite(p.dailyLastDay,-1,1e9) or p.dailyLastDay%1~=0
   or not finite(p.dailyStreak,0,7) or p.dailyStreak%1~=0
   or not finite(p.questDay,-1,1e9) or p.questDay%1~=0
   or not finite(p.rolls,0,50) or not finite(p.rareCrafts,0,2) or not finite(p.collected,0,500000)
   or type(p.claimed)~="table" then return false end
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
  if type(creature)~="table" or type(creature.id)~="string" or #creature.id>64 or ids[creature.id]
   or type(creature.name)~="string" or #creature.name>120
   or not finite(creature.income,0,1e18) or not finite(creature.level,1,1000) or creature.level%1~=0
   or not finite(creature.stand,0,maxStands) or creature.stand%1~=0
   or (creature.exp~=nil and not finite(creature.exp,0,1e12))
   or (creature.ascended~=nil and type(creature.ascended)~="boolean")
   or (creature.locked~=nil and type(creature.locked)~="boolean") or type(creature.components)~="table" then return false end
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
function DataService.load(userId,onAcquire)
 if RunService:IsStudio() and not DataService.TestPersistence then
  sessions[userId]={memory=true, lastSuccess=os.clock()}; local data=defaults(); if onAcquire then data=onAcquire(data) end; return data
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
   sessions[userId]={token=token,lastSuccess=os.clock(),busy=false}
   result.lock=nil
   return result
  end
  if attempt<6 then task.wait(2) end
 end
 return nil
end
function DataService.save(userId, data, release)
 local session=sessions[userId]
 if not session then return false end
 if session.memory then if release then sessions[userId]=nil end; return true end
 -- Serialize operations; never allow an earlier save to overwrite a later one.
 while session.busy do task.wait(0.1) end
 if sessions[userId]~=session then return false end
 session.busy=true
 local snapshot=copy(data)
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
  if ok and wrote then saved=true; session.lastSuccess=os.clock(); break end
  if attempt<3 then task.wait(attempt*2) end
 end
 session.busy=false
 if release then sessions[userId]=nil end
 return saved
end
function DataService.isHealthy(userId)
 local session=sessions[userId]
 return session~=nil and (session.memory or os.clock()-session.lastSuccess<120)
end
return DataService
