--!strict
-- Shared server calculation for rolling and player-facing probability disclosures.
local RollOdds={}
function RollOdds.nonCommonFactor(modifiers)
 return (modifiers.frenzy and 2 or 1)*(modifiers.weekend and 1.5 or 1)
  *(modifiers.luckPass and 2 or 1)*(modifiers.luck2 and 2 or 1)
  *(modifiers.luck3 and 3 or 1)*(modifiers.goldenLever and 1.05 or 1)*(modifiers.altar and 1.5 or 1)
end
function RollOdds.build(rarities,catalog,rebirth,modifiers)
 local tiers={}; local total=0; local factor=RollOdds.nonCommonFactor(modifiers)
 for index,rarity in ipairs(rarities) do
  local list={}
  for _,entry in ipairs(catalog) do
   if entry.rarity==index and entry.rebirth<=rebirth then table.insert(list,entry) end
  end
  if #list>0 then
   local weight=rarity.weight*(1.15^(rebirth*(index-1)/7))*(index>1 and factor or 1)
   table.insert(tiers,{index=index,list=list,weight=weight})
   total+=weight
  end
 end
 return tiers,total,factor
end
function RollOdds.disclose(tiers,total,rarityCount)
 local result={}
 for index=1,rarityCount do result[index]={chance=0,count=0} end
 if total<=0 then return result end
 for _,tier in ipairs(tiers) do result[tier.index]={chance=tier.weight/total,count=#tier.list} end
 return result
end
return RollOdds
