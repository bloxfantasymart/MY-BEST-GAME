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
 return {version=1, cash=200, pending=0, slots=1, rebirth=0, parts={}, creatures={}}
end
local function copy(data)
 return HttpService:JSONDecode(HttpService:JSONEncode(data))
end
function DataService.load(userId)
 if RunService:IsStudio() and not DataService.TestPersistence then
  sessions[userId]={memory=true, lastSuccess=os.clock()}; return defaults()
 end
 local token=HttpService:GenerateGUID(false)
 local key="player_"..userId
 for attempt=1,3 do
  local acquired=false
  local ok,result=pcall(function()
   return store:UpdateAsync(key,function(old)
    acquired=false
    if old~=nil and (type(old)~="table" or (old.version~=nil and old.version~=1)) then return nil end
    if old and old.lock and old.lock.expires>os.time() and old.lock.token~=token then return nil end
    local profile=old or defaults()
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
  if attempt<3 then task.wait(2*attempt) end
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
