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
local function item(id,kind)
 return {id=id,name="Dirt Boy",kind=kind,rarity=1,income=2,price=10,mutation="Standard",mutationMultiplier=1}
end
local complete={Head=item("h","Head"),Chest=item("c","Chest"),Arms=item("a","Arms"),Legs=item("l","Legs")}
database.player_12={version=1,cash=500,pending=12.5,slots=2,rebirth=1,standsUnlocked=13,parts={},creatures={{id="brainrot",name="Dirt Boy Abomination",components=complete,income=6.4,level=2,stand=13,exp=2}}}
local valid=a.load(12)
assert(valid and valid.creatures[1].stand==13, "Valid expanded-stand profile should load")
assert(a.save(12,valid,true))
database.player_12.creatures[1].stand=14
assert(b.load(12)==nil, "A creature on a locked stand should be rejected")
assert(database.player_12.creatures[1].stand==14, "Invalid profile must not be overwritten")
database.player_13={version=1,cash=200,pending=0,slots=1,rebirth=0,parts={},creatures={},lastLogout=100}
local function awardOffline(data)
 if (data.lastLogout or 0)>0 then data.pending+=25; data.lastLogout=0 end
 return data
end
local once=a.load(13,awardOffline)
assert(once and once.pending==25 and database.player_13.lastLogout==0)
assert(a.save(13,once,true))
local twice=b.load(13,awardOffline)
assert(twice and twice.pending==25, "Acquisition must not award the same interval twice")
assert(b.save(13,twice,true))
local extraParts={}
for i=1,150 do table.insert(extraParts,item("part-"..i,"Head")) end
database.player_14={version=1,cash=0,pending=0,slots=1,rebirth=0,parts=extraParts,creatures={}}
local expanded=a.load(14)
assert(expanded and #expanded.parts==150, "Expanded backpacks must remain loadable without live entitlement lookup")
assert(a.save(14,expanded,true))
database.player_15={version=1,cash=0,pending=0,slots=1,rebirth=10,parts={},creatures={},tutorial={step=7},theme="Cyber"}
local themed=a.load(15)
assert(themed and themed.tutorial.step==7 and themed.theme=="Cyber")
assert(a.save(15,themed,true))
database.player_15.theme="Void"
assert(b.load(15)==nil, "A theme cannot be saved below its unlock rebirth")
database.player_15.theme="Cyber"; database.player_15.tutorial.step=8
assert(b.load(15)==nil, "Invalid tutorial state must not be loaded")
print("Persistence lease, acquisition, inventory, tutorial and theme validation tests passed")
