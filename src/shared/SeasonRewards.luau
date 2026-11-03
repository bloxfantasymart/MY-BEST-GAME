--!strict
-- Shared descriptions; only the server grants rewards and capacity.
local SeasonRewards={}
function SeasonRewards.bonusSlots(claimed)
 if type(claimed)~="number" or claimed~=claimed then return 0 end
 return (claimed>=10 and 5 or 0)+(claimed>=30 and 5 or 0)+(claimed>=50 and 5 or 0)
end
function SeasonRewards.reward(tier)
 if type(tier)~="number" or tier~=tier or tier%1~=0 or tier<1 or tier>50 then return nil end
 if tier==10 or tier==30 or tier==50 then return {kind="slots",amount=5,label="permanent +5 part slots"} end
 if tier%6==0 then return {kind="crate",amount=1,label="one Standard Roll Crate"} end
 if tier%3==1 then return {kind="cash",amount=tier*1000,label="$"..(tier*1000).." cash"} end
 if tier%3==2 then return {kind="potion",amount=1,label="one 15-minute 3x luck potion"} end
 return {kind="voucher",amount=2,label="two free-part vouchers"}
end
return SeasonRewards
