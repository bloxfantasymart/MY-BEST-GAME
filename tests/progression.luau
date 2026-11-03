local p=Progression.new()
local start=10*86400
assert(Progression.claimDaily(p,start)==1)
assert(Progression.claimDaily(p,start+200)==nil)
assert(Progression.claimDaily(p,start+86400)==2)
assert(Progression.claimDaily(p,start+3*86400)==1, "Missing a UTC day resets streak")
assert(Progression.claimDaily(p,start)==nil, "Clock rollback must not enable a claim")
p.questDay=13 -- Existing active legacy quests retain their original goals.
Progression.increment(p,"rolls",49,start+3*86400)
assert(Progression.claimQuest(p,"rolls",start+3*86400)==nil)
Progression.increment(p,"rolls",20,start+3*86400)
assert(p.rolls==50 and Progression.claimQuest(p,"rolls",start+3*86400)==10000)
assert(Progression.claimQuest(p,"rolls",start+3*86400)==nil)
Progression.increment(p,"collected",999999,start+3*86400)
assert(p.collected==500000 and Progression.claimQuest(p,"collected",start+3*86400)==0)
Progression.refresh(p,start+4*86400)
assert(p.rolls==0 and p.collected==0 and not p.claimed.rolls)
Progression.increment(p,"rolls",1,start+3*86400)
assert(p.rolls==0, "Clock rollback must not alter a newer day's quest")
local profile={pending=5,lastLogout=100,creatures={{stand=1,income=10},{stand=0,income=500}}}
local income=function(c) return c.income end
Progression.applyOffline(profile,100+100,income)
assert(profile.pending==255 and profile.lastLogout==0 and profile.lastOfflineAward==250)
assert(profile.lastOfflineSeconds==100 and profile.lastOfflineRate==2.5 and not profile.lastOfflineCapped)
Progression.applyOffline(profile,100+200,income)
assert(profile.pending==255 and profile.lastOfflineAward==0 and profile.lastOfflineSeconds==0 and profile.lastOfflineRate==0 and not profile.lastOfflineCapped, "Offline interval cannot pay twice")
profile.lastLogout=100
Progression.applyOffline(profile,100+200000,income)
assert(profile.lastOfflineAward==216000 and profile.lastOfflineSeconds==86400 and profile.lastOfflineCapped, "Offline time is capped at 24 hours")
local fridayBefore=LiveEvents.at(86400+16*3600+59*60)
local fridayAfter=LiveEvents.at(86400+17*3600)
local sundayLate=LiveEvents.at(3*86400+23*3600+59*60)
local monday=LiveEvents.at(4*86400)
assert(not fridayBefore.weekend and fridayAfter.weekend and sundayLate.weekend and not monday.weekend)
assert(LiveEvents.at(0).frenzy and not LiveEvents.at(300).frenzy)
assert(LiveEvents.at(0).eclipse and LiveEvents.at(900).sigma and LiveEvents.at(1800).storm)
assert(not LiveEvents.at(1980).storm)
local forced=LiveEvents.at(1200)
assert(not forced.storm)
LiveEvents.applyOverride(forced,"Storm"); assert(forced.storm)
local unaffected=LiveEvents.at(1200)
LiveEvents.applyOverride(unaffected,"BadEvent"); assert(not unaffected.storm)
print("Daily progression, offline earnings, and UTC event tests passed")

local exact={pending=0,lastLogout=10,creatures={}}
Progression.applyOffline(exact,86410,income,function() return 12 end)
assert(exact.lastOfflineSeconds==86400 and not exact.lastOfflineCapped and exact.lastOfflineRate==3 and exact.lastOfflineAward==259200)
local rollback={pending=5,lastLogout=100,creatures={}}
Progression.applyOffline(rollback,99,income)
assert(rollback.pending==5 and rollback.lastOfflineAward==0 and rollback.lastOfflineSeconds==0 and rollback.lastLogout==0)
print("Offline receipt, cap boundary and clock rollback tests passed")

-- All target combinations stay within the persisted bounds and match their labels/rewards.
local combos={}
for variant=1,18 do
 local daily=Progression.new()
 Progression.refresh(daily,50*86400,function(min,max) assert(min==1 and max==18); return variant end)
 local q=Progression.quests(daily)
 assert(#q==3 and q[1].key=="rolls" and q[2].key=="rareCrafts" and q[3].key=="collected")
 assert(q[1].goal<=50 and q[2].goal<=2 and q[3].goal<=500000)
 local combination=q[1].goal..":"..q[2].goal..":"..q[3].goal
 assert(not combos[combination]); combos[combination]=true
 for _,quest in ipairs(q) do
  Progression.increment(daily,quest.key,quest.goal-1,50*86400)
  assert(not Progression.readyQuest(daily,quest.key,50*86400))
  Progression.increment(daily,quest.key,1000000,50*86400)
  assert(daily[quest.key]==quest.goal and Progression.readyQuest(daily,quest.key,50*86400).rewardKind==quest.rewardKind)
  assert(Progression.claimQuest(daily,quest.key,50*86400)==quest.reward)
  assert(Progression.claimQuest(daily,quest.key,50*86400)==nil)
 end
 Progression.refresh(daily,50*86400+10,function() error("must not redraw same day") end)
 assert(daily.questVariant==variant)
 Progression.refresh(daily,49*86400,function() error("must not redraw on rollback") end)
 assert(daily.questVariant==variant and daily.questDay==50)
 Progression.refresh(daily,51*86400,function() return 18 end)
 assert(daily.questVariant==18 and daily.rolls==0 and daily.rareCrafts==0 and daily.collected==0 and next(daily.claimed)==nil)
end
local legacy=Progression.new(); legacy.questDay=70; legacy.rolls=40
local oldQuests=Progression.quests(legacy)
assert(oldQuests[1].goal==50 and oldQuests[2].goal==2 and oldQuests[3].goal==500000)
Progression.refresh(legacy,70*86400,function() error("legacy day must not be replaced") end)
assert(legacy.questVariant==nil and legacy.rolls==40)
Progression.refresh(legacy,71*86400,function() return 1 end)
assert(legacy.questVariant==1 and Progression.quests(legacy)[1].goal==30 and legacy.rolls==0)
print("Daily randomized target combinations, migration, claims and rollback tests passed")
