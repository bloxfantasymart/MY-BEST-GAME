--!strict
-- Prototype free track. All state is server-owned; no premium purchases are implemented.
local Season={}
Season.MaxXP=5000
Season.RollGoal=250
Season.MaxRollProgress=250000
function Season.new()
 return {xp=0,claimed=0,rollProgress=0}
end
function Season.addXP(season,amount)
 if type(amount)~="number" or amount~=amount or amount<0 or amount%1~=0 then return end
 season.xp=math.min(Season.MaxXP,season.xp+amount)
end
function Season.recordRolls(season,amount)
 if type(amount)~="number" or amount~=amount or amount<0 or amount%1~=0 then return end
 season.rollProgress=math.min(Season.MaxRollProgress,season.rollProgress+amount)
 Season.addXP(season,amount)
end
function Season.unlocked(season)
 return math.floor(season.xp/100)
end
function Season.reward(tier)
 if type(tier)~="number" or tier%1~=0 or tier<1 or tier>50 then return nil end
 if tier%3==1 then return {kind="cash",amount=tier*1000,label="$"..(tier*1000).." cash"} end
 if tier%3==2 then return {kind="potion",amount=1,label="one 15-minute 3x luck potion"} end
 return {kind="voucher",amount=2,label="two free-part vouchers"}
end
function Season.claim(season,extras,maxPotions,maxVouchers)
 local tier=season.claimed+1
 if tier>Season.unlocked(season) or tier>50 then return nil,"Next tier is not unlocked." end
 local reward=Season.reward(tier)
 if reward.kind=="potion" and extras.luckPotions+reward.amount>maxPotions then return nil,"Use a potion before claiming." end
 if reward.kind=="voucher" and extras.rollVouchers+reward.amount>maxVouchers then return nil,"Use some vouchers before claiming." end
 if reward.kind=="potion" then extras.luckPotions+=reward.amount end
 if reward.kind=="voucher" then extras.rollVouchers+=reward.amount end
 season.claimed=tier
 return reward
end
function Season.claimRepeat(season,extras,maxVouchers)
 if season.rollProgress<Season.RollGoal then return false,"Roll more parts first." end
 if extras.rollVouchers>=maxVouchers then return false,"Use a voucher before claiming." end
 season.rollProgress-=Season.RollGoal
 extras.rollVouchers+=1
 return true
end
return Season
