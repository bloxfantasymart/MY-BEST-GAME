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
database.player_16={version=1,cash=0,pending=0,slots=1,rebirth=15,parts={},creatures={{id="asc",name="Dirt Boy Abomination",components=clone(complete),income=32,level=1,stand=1,exp=0,ascended=true}}}
local ascended=a.load(16)
assert(ascended and ascended.creatures[1].ascended==true)
assert(a.save(16,ascended,true))
database.player_16.creatures[1].ascended="yes"
assert(b.load(16)==nil, "Malformed ascension flags must not be loaded")
database.player_17={version=1,cash=0,pending=0,slots=1,rebirth=0,parts={},creatures={},luckUntil=5000}
local boosted=a.load(17); assert(boosted and boosted.luckUntil==5000); assert(a.save(17,boosted,true))
database.player_17.luckUntil=-1
assert(b.load(17)==nil, "Invalid luck-boost expiration must not be loaded")
print("Persistence lease, acquisition, inventory, tutorial, theme, boost and ascension validation tests passed")

-- Old profiles remain loadable; new rewards survive a round trip and reject malformed fields.
database.player_501={version=1,cash=200,pending=0,slots=1,rebirth=0,parts={},creatures={}}
local rewards=a.load(501); assert(rewards and rewards.extras==nil)
rewards.extras={luckPotions=3,rollVouchers=5,goldenLever=true,sigmaStatue=true,ohioCrown=true}
rewards.tripleLuckUntil=1900000000
assert(a.save(501,rewards,true))
local roundtrip=b.load(501); assert(roundtrip and roundtrip.extras.sigmaStatue and roundtrip.extras.rollVouchers==5 and roundtrip.tripleLuckUntil==1900000000)
assert(b.save(501,roundtrip,true))
database.player_501.extras.rollVouchers=1001
assert(a.load(501)==nil, "Malformed reward inventory must not load")
print("Reward profile round-trip and validation tests passed")
database.player_502={version=1,cash=200,pending=0,slots=1,rebirth=0,parts={},creatures={}}
local old=a.load(502); assert(old and old.season==nil)
old.season={xp=456,claimed=4,rollProgress=777}
assert(a.save(502,old,true))
local saved=b.load(502); assert(saved and saved.season.xp==456 and saved.season.claimed==4 and saved.season.rollProgress==777)
assert(b.save(502,saved,true))
database.player_502.season.claimed=5
assert(a.load(502)==nil, "A claimed season tier must be unlocked")
database.player_502.season.claimed=4; database.player_502.season.rollProgress=250001
assert(a.load(502)==nil, "Invalid repeatable progress must not load")
print("Season profile compatibility, round-trip and validation tests passed")

database.player_503={version=1,cash=200,pending=0,slots=1,rebirth=0,parts={item("lockedPart","Head")},creatures={}}
local protect=a.load(503); protect.parts[1].locked=true; assert(a.save(503,protect,true))
local protected=b.load(503); assert(protected.parts[1].locked==true); assert(b.save(503,protected,true))
database.player_503.parts[1].locked="yes"; assert(a.load(503)==nil)
print("Inventory protection persistence tests passed")
database.player_504={version=1,cash=200,pending=0,slots=1,rebirth=0,parts={},creatures={{id="unit504",name="Dirt Boy Abomination",income=10,level=1,stand=0,components=complete,locked=true}}}
local protectedCreature=a.load(504); assert(protectedCreature and protectedCreature.creatures[1].locked)
assert(a.save(504,protectedCreature,true))
protectedCreature=b.load(504); assert(protectedCreature and protectedCreature.creatures[1].locked); assert(b.save(504,protectedCreature,true))
database.player_504.creatures[1].locked=1; assert(a.load(504)==nil)
print("Creature protection persistence tests passed")
