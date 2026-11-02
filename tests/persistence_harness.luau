-- The runner inserts the DataService source at the marker below.
local function clone(value)
 if type(value)~="table" then return value end
 local result={}
 for key,item in pairs(value) do result[key]=clone(item) end
 return result
end
local database = {}
local store = {}
function store:UpdateAsync(key, callback)
 local newValue = callback(clone(database[key]))
 if newValue ~= nil then database[key] = clone(newValue) end
 return clone(newValue)
end
local counter=0
local http = {}
function http:GenerateGUID() counter+=1; return "token-"..counter end
function http:JSONEncode(value) return clone(value) end
function http:JSONDecode(value) return clone(value) end
local services = {
 DataStoreService = {GetDataStore=function() return store end},
 RunService = {IsStudio=function() return false end},
 HttpService = http,
}
local game = {GetService=function(_,name) return services[name] end}
local task = {wait=function() end}
local warn = function() end
local function makeService()
-- INSERT_SERVICE_SOURCE
end
local a,b=makeService(),makeService()
local profile=a.load(42)
assert(profile and profile.cash==200 and profile.standsUnlocked==12)
assert(b.load(42)==nil, "Concurrent session must not acquire locked data")
profile.cash=777
assert(a.save(42,profile,true), "First session should release successfully")
local loaded=b.load(42)
assert(loaded and loaded.cash==777, "Released profile must retain data")
database.player_42.lock.token="other-owner"
loaded.cash=99
assert(not b.save(42,loaded,true), "Stale owner must not overwrite a different lock")
assert(database.player_42.cash==777)
database.player_11={version=1,cash=-1,pending=0,slots=1,rebirth=0,parts={},creatures={}}
assert(a.load(11)==nil, "Malformed data must not be replaced")
assert(database.player_11.cash==-1)
print("Persistence lease and invalid-profile mock tests passed")
