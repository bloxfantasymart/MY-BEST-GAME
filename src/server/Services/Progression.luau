--!strict
-- All timestamps and reward decisions are server-owned. This module is deliberately pure
-- with respect to Roblox services so it can be tested without Studio.
local Progression={}
Progression.Quests={
 {key="rolls",label="Roll 50 body parts",goal=50,reward=10000,rewardKind="cash",rewardLabel="$10,000 cash",xp=50},
 {key="rareCrafts",label="Assemble 2 Rare+ creatures",goal=2,reward=0,rewardKind="potion2",rewardLabel="one 10-minute 2x luck potion",xp=75},
 {key="collected",label="Collect $500,000 from your bank",goal=500000,reward=0,rewardKind="uncommonBox",rewardLabel="one Uncommon Mystery Box",xp=100},
}
-- The three quest types and rewards remain stable; each new UTC day selects
-- one of 18 combinations of target sizes. Legacy active days retain the
-- original targets until their next reset.
local rollGoals={30,40,50}
local craftGoals={1,2}
local collectGoals={100000,250000,500000}
local collectLabels={"$100,000","$250,000","$500,000"}
function Progression.quests(progress)
 local variant=progress.questVariant
 if variant==nil then return Progression.Quests end
 local index=variant-1
 local rollIndex=index%3+1
 local craftIndex=math.floor(index/3)%2+1
 local collectIndex=math.floor(index/6)%3+1
 return {
  {key="rolls",label="Roll "..rollGoals[rollIndex].." body parts",goal=rollGoals[rollIndex],reward=10000,rewardKind="cash",rewardLabel="$10,000 cash",xp=50},
  {key="rareCrafts",label="Assemble "..craftGoals[craftIndex].." Rare+ creatures",goal=craftGoals[craftIndex],reward=0,rewardKind="potion2",rewardLabel="one 10-minute 2x luck potion",xp=75},
  {key="collected",label="Collect "..collectLabels[collectIndex].." from your bank",goal=collectGoals[collectIndex],reward=0,rewardKind="uncommonBox",rewardLabel="one Uncommon Mystery Box",xp=100},
 }
end
function Progression.new()
 return {dailyLastDay=-1,dailyStreak=0,questDay=-1,rolls=0,rareCrafts=0,collected=0,claimed={}}
end
function Progression.day(now)
 return math.floor(now/86400)
end
function Progression.refresh(progress,now,drawVariant)
 local day=Progression.day(now)
 -- Never roll an already-recorded day backwards if a server's clock is wrong.
 if day>progress.questDay then
  progress.questDay=day; progress.rolls=0; progress.rareCrafts=0; progress.collected=0; progress.claimed={}
  progress.questVariant=(drawVariant or math.random)(1,18)
 end
 return day
end
function Progression.nextDaily(progress,now)
 local day=Progression.day(now)
 if day<=progress.dailyLastDay then return nil end
 return progress.dailyLastDay==day-1 and progress.dailyStreak%7+1 or 1
end
function Progression.claimDaily(progress,now)
 local streak=Progression.nextDaily(progress,now)
 if not streak then return nil end
 progress.dailyStreak=streak; progress.dailyLastDay=Progression.day(now)
 return streak
end
function Progression.increment(progress,key,amount,now)
 local day=Progression.refresh(progress,now)
 if day~=progress.questDay or type(amount)~="number" or amount<0 or amount~=amount then return end
 for _,quest in ipairs(Progression.quests(progress)) do
  if quest.key==key then progress[key]=math.min(quest.goal,progress[key]+amount); return end
 end
end
function Progression.readyQuest(progress,key,now)
 local day=Progression.refresh(progress,now)
 if day~=progress.questDay or type(key)~="string" then return nil end
 for _,quest in ipairs(Progression.quests(progress)) do
  if quest.key==key and not progress.claimed[key] and progress[key]>=quest.goal then return quest end
 end
 return nil
end
function Progression.claimQuest(progress,key,now)
 local quest=Progression.readyQuest(progress,key,now)
 if not quest then return nil end
 progress.claimed[key]=true
 return quest.reward
end
function Progression.applyOffline(profile,now,incomeFn,totalFn)
 local last=profile.lastLogout or 0
 profile.lastOfflineAward=0; profile.lastOfflineSeconds=0; profile.lastOfflineRate=0; profile.lastOfflineCapped=false
 if last>0 and now>last then
  local away=now-last
  local seconds=math.min(away,86400)
  local total=0
  if totalFn then total=totalFn(profile.creatures,incomeFn)
  else
   for _,creature in ipairs(profile.creatures) do
    if creature.stand>0 then total+=incomeFn(creature) end
   end
  end
  local rate=total*0.25
  local reward=math.floor(total*seconds*0.25)
  profile.pending+=reward
  profile.lastOfflineAward=reward; profile.lastOfflineSeconds=seconds
  profile.lastOfflineRate=rate; profile.lastOfflineCapped=away>86400
 end
 -- This is saved in the same UpdateAsync that acquires the profile lease, so a
 -- retry/rejoin cannot award the same offline interval a second time.
 profile.lastLogout=0
 return profile
end
return Progression
