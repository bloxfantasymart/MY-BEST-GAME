-- The runner inserts the DataService source at the marker below.
local function clone(value)
 if type(value)~="table" then return value end
 local result={}
 for key,item in pairs(value) do result[key]=clone(item) end
 return result
end
local database = {}
local store = {}
local pauseNextStore=false
local retryNextTransform=false
function store:UpdateAsync(key, callback)
 if pauseNextStore then pauseNextStore=false; coroutine.yield("store") end
 if retryNextTransform then retryNextTransform=false; callback(clone(database[key])) end
 local newValue = callback(clone(database[key]))
 if newValue ~= nil then database[key] = clone(newValue) end
 return clone(newValue)
end
local counter=0
local http = {}
function http:GenerateGUID() counter+=1; return "token-"..counter end
local copyFails=false
function http:JSONEncode(value) if copyFails then error("encoding failed") end; return clone(value) end
function http:JSONDecode(value) return clone(value) end
local services = {
 DataStoreService = {GetDataStore=function() return store end},
 RunService = {IsStudio=function() return false end},
 HttpService = http,
}
local game = {GetService=function(_,name) return services[name] end}
local yieldWait=false
local task = {wait=function() if yieldWait then coroutine.yield("wait") end end}
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
database.player_505={version=1,cash=200,pending=0,slots=1,rebirth=10,parts={},creatures={}}
local legacy=a.load(505); assert(legacy and legacy.autoCollect==nil)
legacy.autoCollect=true; assert(a.save(505,legacy,true))
local auto=b.load(505); assert(auto and auto.autoCollect==true); assert(b.save(505,auto,true))
database.player_505.autoCollect="true"; assert(a.load(505)==nil)
print("Auto-collector profile compatibility and validation tests passed")
local manyParts={}
for i=1,250 do table.insert(manyParts,item("exp-"..i,"Head")) end
database.player_506={version=1,cash=200,pending=0,slots=1,rebirth=0,parts=manyParts,creatures={},backpackUpgrades=10,rareBlueprints=100}
local upgrades=a.load(506); assert(upgrades and #upgrades.parts==250 and upgrades.backpackUpgrades==10 and upgrades.rareBlueprints==100)
assert(a.save(506,upgrades,true))
local upgradesAgain=b.load(506); assert(upgradesAgain and upgradesAgain.rareBlueprints==100); assert(b.save(506,upgradesAgain,true))
for i=1,16 do table.insert(database.player_506.parts,item("excess-"..i,"Head")) end; assert(a.load(506)==nil)
for i=1,16 do table.remove(database.player_506.parts) end; database.player_506.backpackUpgrades=11; assert(a.load(506)==nil)
database.player_506.backpackUpgrades=10; database.player_506.rareBlueprints=101; assert(a.load(506)==nil)
database.player_506.rareBlueprints=1; database.player_506.creatures={{id="bp-creature",name="Dirt Boy Abomination",income=10,level=1,stand=0,components=clone(complete),blueprintApplied=true}}
local crafted=a.load(506); assert(crafted and crafted.creatures[1].blueprintApplied==true); assert(a.save(506,crafted,true))
database.player_506.creatures[1].blueprintApplied="yes"; assert(a.load(506)==nil)
print("Backpack upgrade and blueprint schema tests passed")

database.player_507={version=1,cash=200,pending=0,slots=1,rebirth=0,parts={},creatures={}}
local guarded=a.load(507); assert(guarded)
guarded.cash=-1; assert(not a.save(507,guarded,false)); assert(database.player_507.cash==200, "Invalid snapshots must not overwrite the store")
guarded.cash=500; copyFails=true; assert(not a.save(507,guarded,false), "A failed copy must be reported")
copyFails=false; assert(a.save(507,guarded,true), "Copy failure must not leave the session permanently busy")
local after=b.load(507); assert(after and after.cash==500); assert(b.save(507,after,true))
print("Invalid-save and copy-failure recovery tests passed")
database.player_508={version=1,cash=200,pending=0,slots=1,rebirth=0,parts={item("mutation-test","Head")},creatures={}}
database.player_508.parts[1].mutation={}
assert(a.load(508)==nil, "Malformed mutation metadata must not be loaded")
database.player_508.parts[1].mutation=string.rep("x",41)
assert(a.load(508)==nil, "Mutation metadata must be bounded")
database.player_508.parts[1].mutation=nil
local legacyMutation=a.load(508); assert(legacyMutation and a.save(508,legacyMutation,true), "Legacy Standard parts without mutation metadata remain valid")
print("Mutation metadata and legacy profile validation tests passed")
-- New daily quest item balances are optional on legacy profiles and validated when present.
database.player_510={version=1,cash=200,pending=0,slots=1,rebirth=0,parts={},creatures={},extras={luckPotions=0,rollVouchers=0,goldenLever=false,sigmaStatue=false,ohioCrown=false}}
local questLegacy=a.load(510); assert(questLegacy and questLegacy.extras.doubleLuckPotions==nil and questLegacy.extras.uncommonBoxes==nil)
questLegacy.extras.doubleLuckPotions=4; questLegacy.extras.uncommonBoxes=2
assert(a.save(510,questLegacy,true))
local questRoundtrip=b.load(510); assert(questRoundtrip and questRoundtrip.extras.doubleLuckPotions==4 and questRoundtrip.extras.uncommonBoxes==2)
assert(b.save(510,questRoundtrip,true))
database.player_510.extras.doubleLuckPotions=101; assert(a.load(510)==nil)
database.player_510.extras.doubleLuckPotions=1; database.player_510.extras.uncommonBoxes=0.5; assert(a.load(510)==nil)
database.player_510.extras.uncommonBoxes=-1; assert(a.load(510)==nil)
print("Quest consumable compatibility, round-trip and validation tests passed")

-- Invalid inventory shapes or lease metadata must never be silently rewritten.
local function badData(parts,creatures,lock)
 return {version=1,cash=200,pending=0,slots=1,rebirth=0,parts=parts,creatures=creatures,lock=lock}
end
database.player_511=badData({[1]=item("v1","Head"),extra=item("v2","Legs")},{})
assert(a.load(511)==nil and database.player_511.parts.extra.id=="v2")
database.player_511=badData({[1]=item("v1","Head"),[3]=item("v3","Legs")},{})
assert(a.load(511)==nil and database.player_511.parts[3].id=="v3")
database.player_511=badData({item("","Head")},{})
assert(a.load(511)==nil)
database.player_511=badData({}, {[2]={id="hidden",name="test"}})
assert(a.load(511)==nil, "Sparse creatures must be rejected")
database.player_511=badData({}, {{id="",name="Dirt Boy Abomination",components=clone(complete),income=10,level=1,stand=0}})
assert(a.load(511)==nil, "Empty creature IDs must be rejected")
database.player_511=badData({}, {}, "invalid")
assert(a.load(511)==nil and database.player_511.lock=="invalid")
database.player_511=badData({}, {}, {token="abc",expires="tomorrow"})
assert(a.load(511)==nil and database.player_511.lock.expires=="tomorrow")
local profile512=a.load(512); assert(profile512)
profile512.parts.extra=item("hidden","Legs")
assert(not a.save(512,profile512,false) and database.player_512.parts.extra==nil)
profile512.parts.extra=nil; assert(a.save(512,profile512,true))
print("Sparse inventories, invalid IDs and malformed leases are rejected")

-- Explicitly resume waiters in the opposite order from their creation order.
local function startSave(user,data,release)
 local thread=coroutine.create(function() return a.save(user,data,release) end)
 local ok,result=coroutine.resume(thread); assert(ok,result)
 return thread,result
end
local function resume(thread)
 local ok,result=coroutine.resume(thread); assert(ok,result); return result
end
local base=a.load(513); assert(base)
local first=clone(base); first.cash=100
local older=clone(base); older.cash=200
local newer=clone(base); newer.cash=300
pauseNextStore=true; yieldWait=true
local firstThread,step=startSave(513,first,false); assert(step=="store")
local olderThread,oldWait=startSave(513,older,false); assert(oldWait=="wait")
local newerThread,newWait=startSave(513,newer,false); assert(newWait=="wait")
assert(resume(firstThread)==true and resume(newerThread)==true and database.player_513.cash==300)
assert(resume(olderThread)==true and database.player_513.cash==300, "An earlier waiter must not overwrite the newer snapshot")
assert(a.save(513,newer,true))
local ending=a.load(514); assert(ending)
local prior=clone(ending); prior.cash=20
local waiting=clone(ending); waiting.cash=30
local final=clone(ending); final.cash=40; final.parts={item("kept","Head")}
pauseNextStore=true
local priorThread=startSave(514,prior,false)
local waitingThread=startSave(514,waiting,false)
local finalThread=startSave(514,final,true)
final.parts[1].name="mutated after queueing"
assert(resume(priorThread)==true)
assert(resume(waitingThread)==true and database.player_514.cash==20, "Final save should supersede waiting autosaves")
assert(resume(finalThread)==true and database.player_514.cash==40 and database.player_514.parts[1].name=="Dirt Boy")
yieldWait=false
local finalLoaded=b.load(514); assert(finalLoaded and finalLoaded.cash==40 and #finalLoaded.parts==1); assert(b.save(514,finalLoaded,true))
print("Out-of-order save waiters, final-save priority and snapshot isolation tests passed")

local maxParts={}; for i=1,265 do table.insert(maxParts,item("season-"..i,"Head")) end
database.player_515={version=1,cash=0,pending=0,slots=1,rebirth=0,parts=maxParts,creatures={},season={xp=5000,claimed=50,rollProgress=0},extras={luckPotions=0,rollVouchers=0,goldenLever=false,sigmaStatue=false,ohioCrown=false,standardBoxes=100}}
local seasonFull=a.load(515); assert(seasonFull and #seasonFull.parts==265 and seasonFull.extras.standardBoxes==100)
assert(a.save(515,seasonFull,true)); seasonFull=b.load(515); assert(seasonFull and b.save(515,seasonFull,true))
database.player_515.extras.standardBoxes=101; assert(a.load(515)==nil)
database.player_515.extras.standardBoxes=1; database.player_515.parts[266]=item("overflow","Head"); assert(a.load(515)==nil)
print("Season crate and 265-part persistence limits passed")

-- The offline receipt and credit come from the successfully committed acquisition,
-- even if Roblox invokes the transform more than once against the same old record.
database.player_516={version=1,cash=0,pending=5,slots=1,rebirth=0,parts={},creatures={{id="offline",name="Dirt Boy Abomination",income=10,level=1,stand=1,components=clone(complete)}},lastLogout=100}
local calls=0
local function offlineAcquire(data)
 calls+=1
 return Progression.applyOffline(data,200,function(c) return c.income end)
end
retryNextTransform=true
local receipt=a.load(516,offlineAcquire)
assert(calls==2 and receipt.pending==255 and receipt.lastOfflineAward==250 and receipt.lastOfflineSeconds==100 and receipt.lastOfflineRate==2.5 and not receipt.lastOfflineCapped)
assert(database.player_516.pending==255 and database.player_516.lastLogout==0)
assert(a.save(516,receipt,true))
local noReplay=b.load(516,offlineAcquire)
assert(noReplay and noReplay.pending==255 and noReplay.lastOfflineAward==0 and noReplay.lastOfflineSeconds==0)
assert(b.save(516,noReplay,true))
database.player_516.lastOfflineSeconds=86401; assert(a.load(516)==nil)
database.player_516.lastOfflineSeconds=1; database.player_516.lastOfflineRate=-1; assert(a.load(516)==nil)
database.player_516.lastOfflineRate=1; database.player_516.lastOfflineCapped="true"; assert(a.load(516)==nil)
print("Atomic offline receipt, transform retry and metadata validation tests passed")
-- Daily variants persist without changing the current legacy day.
database.player_517={version=1,cash=0,pending=0,slots=1,rebirth=0,parts={},creatures={},progress={dailyLastDay=-1,dailyStreak=0,questDay=100,rolls=22,rareCrafts=0,collected=0,claimed={}}}
local legacyQuest=a.load(517)
assert(legacyQuest and legacyQuest.progress.questVariant==nil and Progression.quests(legacyQuest.progress)[1].goal==50)
Progression.refresh(legacyQuest.progress,100*86400,function() error("legacy day redrawn") end)
assert(legacyQuest.progress.rolls==22 and a.save(517,legacyQuest,true))
local nextDay=b.load(517)
Progression.refresh(nextDay.progress,101*86400,function() return 7 end)
Progression.increment(nextDay.progress,"rolls",10,101*86400)
assert(b.save(517,nextDay,true))
local reopened=a.load(517)
assert(reopened.progress.questVariant==7 and reopened.progress.rolls==10 and Progression.quests(reopened.progress)[1].goal==30)
assert(a.save(517,reopened,true))
for _,invalid in ipairs({0,19,1.5,"1",true}) do
 database.player_517.progress.questVariant=invalid
 assert(a.load(517)==nil and database.player_517.progress.questVariant==invalid)
end
print("Daily quest variant legacy compatibility, round trip and validation passed")
-- Legacy collection data is optional; valid masks survive main/hub-style save round trips.
database.player_518={version=1,cash=0,pending=0,slots=1,rebirth=0,parts={},creatures={}}
local oldCollection=a.load(518); assert(oldCollection and oldCollection.collection==nil)
oldCollection.collection={['Dirt Boy']=15,Retired=1}
assert(a.save(518,oldCollection,true))
local loadedCollection=b.load(518)
assert(loadedCollection.collection['Dirt Boy']==15 and loadedCollection.collection.Retired==1)
assert(b.save(518,loadedCollection,true))
for _,bad in ipairs({0,16,1.5,-1,"15",true,math.huge}) do
 database.player_518.collection['Dirt Boy']=bad
 assert(a.load(518)==nil and database.player_518.collection['Dirt Boy']==bad)
end
database.player_518.collection={['']=1}; assert(a.load(518)==nil)
database.player_518.collection={[1]=1}; assert(a.load(518)==nil)
database.player_518.collection={[string.rep("x",101)]=1}; assert(a.load(518)==nil)
database.player_518.collection={}; for i=1,200 do database.player_518.collection["old"..i]=1 end
local limit=a.load(518); assert(limit and a.save(518,limit,true))
database.player_518.collection.extra=1; assert(a.load(518)==nil and database.player_518.collection.extra==1)
print("Collection legacy compatibility, bounds, malformed profiles and round-trip tests passed")
database.player_519={version=1,cash=0,pending=0,slots=1,rebirth=0,parts={item("loose","Head")},creatures={{id="unit",name="Dirt Boy Abomination",income=10,level=1,stand=0,components=clone(complete)}}}
local bootstrap=a.load(519); bootstrap.collection=bootstrap.collection or {}
local known=CollectionIndex.catalogNames({{name="Dirt Boy"}})
assert(CollectionIndex.record(bootstrap.collection,bootstrap.parts,bootstrap.creatures,known)==4)
bootstrap.parts={}; bootstrap.creatures={}
assert(a.save(519,bootstrap,true))
local retained=b.load(519)
assert(retained.collection["Dirt Boy"]==15 and #retained.parts==0 and #retained.creatures==0)
assert(b.save(519,retained,true))
print("Collection bootstrap from legacy inventory survives later removal and save")
-- Summit cooldown is optional in legacy profiles, bounded and retained on saves.
database.player_520={version=1,cash=0,pending=0,slots=1,rebirth=0,parts={},creatures={}}
local legacyObby=a.load(520); assert(legacyObby and legacyObby.obbyLastClaim==nil)
legacyObby.obbyLastClaim=1800000000; assert(a.save(520,legacyObby,true))
local obbySaved=b.load(520); assert(obbySaved and obbySaved.obbyLastClaim==1800000000)
assert(b.save(520,obbySaved,true))
for _,bad in ipairs({-1,1.5,"100",true,math.huge,1000000000001}) do
 database.player_520.obbyLastClaim=bad
 assert(a.load(520)==nil and database.player_520.obbyLastClaim==bad)
end
print("Obby cooldown legacy compatibility, round-trip and validation passed")
-- Layouts are bounded references, including intentionally stale IDs: never reject
-- a profile just because a creature was sold or sacrificed after saving a layout.
database.player_521={version=1,cash=0,pending=0,slots=1,rebirth=0,parts={},creatures={}}
local oldLayouts=a.load(521); assert(oldLayouts and oldLayouts.standLoadouts==nil)
oldLayouts.standLoadouts={["1"]={{id="missing",stand=1},{id="other",stand=24}},["2"]={}}
assert(a.save(521,oldLayouts,true))
local persistedLayouts=b.load(521)
assert(persistedLayouts and persistedLayouts.standLoadouts["1"][2].stand==24 and #persistedLayouts.standLoadouts["2"]==0)
assert(b.save(521,persistedLayouts,true))
local badLayouts={
 {["0"]={}}, {[1]={}}, {["1"]={{id="x",stand=1},{id="x",stand=2}}},
 {["1"]={{id="x",stand=2},{id="y",stand=1}}}, {["1"]={{id="x",stand=25}}},
 {["1"]={{id="x",stand=1,extra=true}}}, {["1"]="bad"},
}
for _,bad in ipairs(badLayouts) do database.player_521.standLoadouts=bad; assert(a.load(521)==nil) end
print("Stand layout legacy, stale-reference round-trip and malformed-data validation passed")

-- One DataService instance cannot load a second profile while a load or final
-- save is in flight; otherwise an old final save could clear a new session.
local concurrent=makeService()
pauseNextStore=true
local loadingThread=coroutine.create(function() return concurrent.load(93001) end)
local started,step=coroutine.resume(loadingThread)
assert(started and step=="store")
assert(concurrent.load(93001)==nil, "Concurrent load must be refused")
local resumed,owned=coroutine.resume(loadingThread)
assert(resumed and owned and concurrent.isHealthy(93001))
assert(concurrent.load(93001)==nil, "Existing live session cannot be replaced")
pauseNextStore=true
local closing=coroutine.create(function() return concurrent.save(93001,owned,true) end)
local closeOk,closeStep=coroutine.resume(closing)
assert(closeOk and closeStep=="store")
assert(concurrent.load(93001)==nil, "Loading must be blocked until final save completes")
local finished,saved=coroutine.resume(closing)
assert(finished and saved)
local nextProfile=concurrent.load(93001)
assert(nextProfile and concurrent.save(93001,nextProfile,true))
-- An acquisition error must not permanently wedge the local load guard.
local failService=makeService()
assert(failService.load(93002,function() error("bad acquire") end)==nil)
local retry=failService.load(93002)
assert(retry and failService.save(93002,retry,true))
-- Studio memory sessions obey the same exclusion and do not leak on callback errors.
services.RunService.IsStudio=function() return true end
local studio=makeService()
assert(studio.load(93003,function() error("bad studio acquire") end)==nil)
local memory=studio.load(93003)
assert(memory and studio.load(93003)==nil and studio.save(93003,memory,true))
assert(studio.load(93004,function(data) data.cash=-1; return data end)==nil)
local validMemory=studio.load(93004); assert(validMemory and studio.save(93004,validMemory,true))
services.RunService.IsStudio=function() return false end
print("Concurrent local loads and final-save overlap are refused, including Studio")
-- Failed final snapshots do not write invalid data or permanently wedge this
-- server's local session. The persisted lease still prevents premature reload.
local finalFailure=makeService()
local badFinal=finalFailure.load(93005); assert(badFinal)
badFinal.cash=-1
assert(not finalFailure.save(93005,badFinal,true) and not finalFailure.isHealthy(93005))
assert(database.player_93005.cash==200 and finalFailure.load(93005)==nil)
database.player_93005.lock.expires=0
local recovered=finalFailure.load(93005); assert(recovered and recovered.cash==200 and finalFailure.save(93005,recovered,true))
local copyFailure=finalFailure.load(93006); assert(copyFailure)
copyFails=true; assert(not finalFailure.save(93006,copyFailure,true)); copyFails=false
assert(not finalFailure.isHealthy(93006) and finalFailure.load(93006)==nil)
database.player_93006.lock.expires=0
local copyRecovered=finalFailure.load(93006); assert(copyRecovered and finalFailure.save(93006,copyRecovered,true))
print("Failed final snapshot leaves a lease but does not wedge local sessions")
local isolated=makeService()
local stale=isolated.load(93007); assert(stale)
local oldSnapshot=clone(stale); oldSnapshot.cash=400
pauseNextStore=true
local inFlight=coroutine.create(function() return isolated.save(93007,oldSnapshot,false) end)
local oldStarted,oldStep=coroutine.resume(inFlight); assert(oldStarted and oldStep=="store")
stale.cash=-1; assert(not isolated.save(93007,stale,true))
database.player_93007.lock.expires=0
local replacement=isolated.load(93007); assert(replacement)
local oldFinished,oldResult=coroutine.resume(inFlight)
assert(oldFinished and not oldResult and database.player_93007.cash==200)
assert(isolated.isHealthy(93007) and isolated.save(93007,replacement,true))
print("A rejected final save cannot let an old in-flight save overwrite a replacement session")
-- The summit-only head uses ordinary saved-part schema and remains protected.
local summitService=makeService()
local summitProfile=summitService.load(93008); assert(summitProfile)
summitProfile.parts={{id="peak-head",name="Peak Mountain",kind="Head",rarity=3,income=50,price=10,mutation="Standard",mutationMultiplier=1,locked=true}}
assert(summitService.save(93008,summitProfile,true))
local summitLoaded=summitService.load(93008)
assert(summitLoaded and summitLoaded.parts[1].name=="Peak Mountain" and summitLoaded.parts[1].locked)
assert(summitService.save(93008,summitLoaded,true))
print("Protected exclusive summit head profile round-trip passed")
-- Multi-roll tokens are optional for legacy profiles and validated when present.
local tokens=makeService()
local tokenProfile=tokens.load(93009); assert(tokenProfile)
tokenProfile.extras={luckPotions=0,rollVouchers=3,goldenLever=false,sigmaStatue=false,ohioCrown=false}
assert(tokens.save(93009,tokenProfile,true))
local oldTokens=tokens.load(93009); assert(oldTokens and oldTokens.extras.multiRollTokens==nil)
oldTokens.extras.multiRollTokens=1000
assert(tokens.save(93009,oldTokens,true))
local restored=tokens.load(93009); assert(restored.extras.multiRollTokens==1000 and restored.extras.rollVouchers==3)
assert(tokens.save(93009,restored,true))
for _,bad in ipairs({-1,1001,1.5,"3"}) do
 database.player_93009.extras.multiRollTokens=bad
 assert(tokens.load(93009)==nil and database.player_93009.extras.multiRollTokens==bad)
end
print("Multi-roll token legacy compatibility, limits and profile round-trip passed")
-- Scrap is optional for legacy data, capped and preserved in saved extras.
local scrapService=makeService()
local scrapProfile=scrapService.load(93010); assert(scrapProfile)
scrapProfile.extras={luckPotions=0,rollVouchers=0,goldenLever=false,sigmaStatue=false,ohioCrown=false}
assert(scrapService.save(93010,scrapProfile,true))
local legacyScrap=scrapService.load(93010); assert(legacyScrap and legacyScrap.extras.scrap==nil)
legacyScrap.extras.scrap=1000000; assert(scrapService.save(93010,legacyScrap,true))
local savedScrap=scrapService.load(93010); assert(savedScrap.extras.scrap==1000000 and scrapService.save(93010,savedScrap,true))
for _,bad in ipairs({-1,1000001,0.5,"3"}) do
 database.player_93010.extras.scrap=bad
 assert(scrapService.load(93010)==nil and database.player_93010.extras.scrap==bad)
end
print("Scrap legacy compatibility, caps and saved-profile validation passed")
local dailyTreasure=makeService()
local dailyProfile=dailyTreasure.load(93011); assert(dailyProfile)
dailyProfile.extras={luckPotions=0,rollVouchers=0,goldenLever=false,sigmaStatue=false,ohioCrown=false,treasureDay=20000,treasureClaims=10}
assert(dailyTreasure.save(93011,dailyProfile,true))
local loadedDaily=dailyTreasure.load(93011); assert(loadedDaily and loadedDaily.extras.treasureClaims==10 and dailyTreasure.save(93011,loadedDaily,true))
for _,bad in ipairs({-1,11,1.5,"1"}) do
 database.player_93011.extras.treasureClaims=bad
 assert(dailyTreasure.load(93011)==nil and database.player_93011.extras.treasureClaims==bad)
end
database.player_93011.extras.treasureClaims=nil
assert(dailyTreasure.load(93011)==nil, "A partially missing daily counter must not load")
print("Daily treasure counters round-trip and malformed data rejection passed")

database.player_93011.extras.treasureDay=-1; database.player_93011.extras.treasureClaims=1
assert(dailyTreasure.load(93011)==nil, "Uninitialized day cannot have claims")

local giftPersistence=makeService()
local giftProfile=giftPersistence.load(93012); assert(giftProfile)
giftProfile.extras={luckPotions=0,rollVouchers=5,goldenLever=false,sigmaStatue=false,ohioCrown=false,sessionGiftDay=20000,sessionGiftClaims={cash1=true,vouchers3=true}}
assert(giftPersistence.save(93012,giftProfile,true))
local reloadedGift=giftPersistence.load(93012)
assert(reloadedGift and reloadedGift.extras.sessionGiftDay==20000 and reloadedGift.extras.sessionGiftClaims.vouchers3 and giftPersistence.save(93012,reloadedGift,true))
for _,bad in ipairs({false,1,"true"}) do
 database.player_93012.extras.sessionGiftClaims.cash1=bad
 assert(giftPersistence.load(93012)==nil and database.player_93012.extras.sessionGiftClaims.cash1==bad)
end
database.player_93012.extras.sessionGiftClaims.cash1=true
database.player_93012.extras.sessionGiftClaims.forged=true
assert(giftPersistence.load(93012)==nil)
database.player_93012.extras.sessionGiftClaims.forged=nil
database.player_93012.extras.sessionGiftDay=nil
assert(giftPersistence.load(93012)==nil, "Partially missing daily gift state must fail closed")
print("Saved gift limit round-trip and malformed-data rejection passed")
