--!strict
-- Prototype free track. All state is server-owned; no premium purchases are implemented.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SeasonRewards=require(ReplicatedStorage.Shared:WaitForChild("SeasonRewards"))
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
 return SeasonRewards.reward(tier)
end
function Season.claim(season,extras,maxPotions,maxVouchers,maxBoxes)
 local tier=season.claimed+1
 if tier>Season.unlocked(season) or tier>50 then return nil,"Next tier is not unlocked." end
 local reward=Season.reward(tier)
 if reward.kind=="potion" and extras.luckPotions+reward.amount>maxPotions then return nil,"Use a potion before claiming." end
 if reward.kind=="voucher" and extras.rollVouchers+reward.amount>maxVouchers then return nil,"Use some vouchers before claiming." end
 if reward.kind=="crate" and extras.standardBoxes+reward.amount>(maxBoxes or 100) then return nil,"Open a Standard Roll Crate before claiming." end
 if reward.kind=="crate" then extras.standardBoxes+=reward.amount end
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
