local extras=RewardExtras.new()
assert(RewardExtras.daily(extras,1).cash==1000)
assert(RewardExtras.daily(extras,2).cash==0 and extras.luckPotions==3)
assert(RewardExtras.daily(extras,3).cash==0 and extras.goldenLever)
assert(RewardExtras.daily(extras,3).cash==5000)
assert(RewardExtras.daily(extras,4).cash==50000)
assert(RewardExtras.daily(extras,5).cash==0 and extras.rollVouchers==3)
assert(RewardExtras.daily(extras,6).cash==250000)
assert(RewardExtras.daily(extras,7).cash==0 and extras.sigmaStatue)
assert(RewardExtras.daily(extras,7).cash==100000)
extras.luckPotions=98
assert(RewardExtras.daily(extras,2)==nil and extras.luckPotions==98)
extras.rollVouchers=998
assert(RewardExtras.daily(extras,5)==nil and extras.rollVouchers==998)
assert(RewardExtras.daily(extras,8)==nil)
local p=Progression.new(); local now=100*86400
for day=1,7 do
 assert(Progression.nextDaily(p,now)==day)
 assert(Progression.claimDaily(p,now)==day)
 assert(Progression.nextDaily(p,now)==nil)
 now+=86400
end
assert(Progression.nextDaily(p,now)==1)
print("Daily reward, caps, duplicate unlock and streak tests passed")
