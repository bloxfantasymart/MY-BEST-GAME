--!strict
-- Server-owned items and permanent reward unlocks; no Roblox purchases are handled here.
local RewardExtras={}
RewardExtras.MaxPotions=100
RewardExtras.MaxVouchers=1000
RewardExtras.MaxMultiRollTokens=1000
RewardExtras.MaxBoxes=100
function RewardExtras.new()
 return {luckPotions=0,doubleLuckPotions=0,uncommonBoxes=0,standardBoxes=0,rollVouchers=0,multiRollTokens=0,goldenLever=false,sigmaStatue=false,ohioCrown=false}
end
-- Called only after profile validation; older profiles have no new fields.
function RewardExtras.normalize(extras)
 if extras.doubleLuckPotions==nil then extras.doubleLuckPotions=0 end
 if extras.uncommonBoxes==nil then extras.uncommonBoxes=0 end
 if extras.standardBoxes==nil then extras.standardBoxes=0 end
 if extras.multiRollTokens==nil then extras.multiRollTokens=0 end
 return extras
end
function RewardExtras.daily(extras,day)
 if day==1 then return {cash=1000,message="$1,000 cash"} end
 if day==2 then
  if extras.luckPotions+3>RewardExtras.MaxPotions then return nil,"Use some potions before claiming." end
  extras.luckPotions+=3; return {cash=0,message="three 15-minute 3x luck potions"}
 end
 if day==3 then
  if extras.goldenLever then return {cash=5000,message="$5,000 (lever already unlocked)"} end
  extras.goldenLever=true; return {cash=0,message="Golden Lever unlocked"}
 end
 if day==4 then return {cash=50000,message="$50,000 cash"} end
 if day==5 then
  if extras.multiRollTokens+3>RewardExtras.MaxMultiRollTokens then return nil,"Use some multi-roll tokens before claiming." end
  extras.multiRollTokens+=3; return {cash=0,message="three multi-roll tokens"}
 end
 if day==6 then return {cash=250000,message="$250,000 cash"} end
 if day==7 then
  if extras.sigmaStatue then return {cash=100000,message="$100,000 (statue already unlocked)"} end
  extras.sigmaStatue=true; return {cash=0,message="Sigma Statue unlocked"}
 end
 return nil,"Invalid daily reward."
end
return RewardExtras
