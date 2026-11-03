local s=Season.new()
local e=RewardExtras.new()
assert(Season.unlocked(s)==0 and Season.claim(s,e,100,1000)==nil)
Season.recordRolls(s,99)
assert(s.xp==99 and s.rollProgress==99 and Season.unlocked(s)==0)
Season.recordRolls(s,1)
assert(Season.unlocked(s)==1 and Season.claim(s,e,100,1000).amount==1000)
assert(s.claimed==1 and Season.claim(s,e,100,1000)==nil)
Season.addXP(s,100)
e.luckPotions=100
assert(Season.claim(s,e,100,1000)==nil and s.claimed==1)
e.luckPotions=99
assert(Season.claim(s,e,100,1000).kind=="potion" and e.luckPotions==100)
Season.addXP(s,100)
e.rollVouchers=999
assert(Season.claim(s,e,100,1000)==nil and s.claimed==2)
e.rollVouchers=998
assert(Season.claim(s,e,100,1000).kind=="voucher" and e.rollVouchers==1000)
assert(not Season.claimRepeat(s,e,1000))
Season.recordRolls(s,400)
assert(s.rollProgress==500 and not Season.claimRepeat(s,e,1000))
e.rollVouchers=998
assert(Season.claimRepeat(s,e,1000) and Season.claimRepeat(s,e,1000))
assert(s.rollProgress==0 and not Season.claimRepeat(s,e,1000))
Season.addXP(s,100000)
assert(s.xp==5000 and Season.unlocked(s)==50)
e.luckPotions=0; e.rollVouchers=0
for tier=4,50 do
 local reward=Season.claim(s,e,100,1000)
 assert(reward and s.claimed==tier)
end
assert(Season.claim(s,e,100,1000)==nil and not Season.reward(51))
Season.recordRolls(s,300000)
assert(s.rollProgress==250000 and s.xp==5000)
print("Season XP, sequential claims, caps, repeatable objective and reward tests passed")

assert(SeasonRewards.bonusSlots(0)==0 and SeasonRewards.bonusSlots(9)==0 and SeasonRewards.bonusSlots(10)==5)
assert(SeasonRewards.bonusSlots(29)==5 and SeasonRewards.bonusSlots(30)==10 and SeasonRewards.bonusSlots(49)==10 and SeasonRewards.bonusSlots(50)==15)
for _,tier in ipairs({10,30,50}) do assert(Season.reward(tier).kind=="slots") end
for _,tier in ipairs({6,12,18,24,36,42,48}) do assert(Season.reward(tier).kind=="crate") end
local profile={xp=600,claimed=5,rollProgress=0}; local stash=RewardExtras.new(); stash.standardBoxes=100
assert(Season.claim(profile,stash,100,1000,100)==nil and profile.claimed==5 and stash.standardBoxes==100)
stash.standardBoxes=99
local crate=Season.claim(profile,stash,100,1000,100)
assert(crate and crate.kind=="crate" and stash.standardBoxes==100 and profile.claimed==6)
local legacy={xp=1000,claimed=10,rollProgress=0}; assert(SeasonRewards.bonusSlots(legacy.claimed)==5, "Previously claimed tiers gain the capacity milestone")
assert(not Season.reward(0) and not Season.reward(0/0) and not Season.reward(1.5))
print("Season crate caps, slot milestones and legacy claimed tiers passed")
