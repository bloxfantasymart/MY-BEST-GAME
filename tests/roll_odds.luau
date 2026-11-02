local function near(a,b) return math.abs(a-b)<1e-10 end
local noBoost={}
for rebirth=0,100 do
 local tiers,total,factor=RollOdds.build(Config.Rarities,Config.Catalog,rebirth,noBoost)
 assert(#tiers>0 and total>0 and factor==1)
 local expected=0
 for index,rarity in ipairs(Config.Rarities) do
  local count=0
  for _,entry in ipairs(Config.Catalog) do if entry.rarity==index and entry.rebirth<=rebirth then count+=1 end end
  if count>0 then expected+=rarity.weight*(1.15^(rebirth*(index-1)/7)) end
 end
 assert(near(total,expected),"Weights must match the original rolling formula")
 local disclosed=RollOdds.disclose(tiers,total,#Config.Rarities)
 local sum=0
 for _,tier in ipairs(tiers) do
  assert(near(disclosed[tier.index].chance,tier.weight/total) and disclosed[tier.index].count==#tier.list)
  sum+=disclosed[tier.index].chance
  for _,entry in ipairs(tier.list) do assert(entry.rebirth<=rebirth and entry.rarity==tier.index) end
 end
 assert(near(sum,1),"Unlocked tier probabilities must sum to one")
end
local flags={frenzy=true,weekend=true,luckPass=true,luck2=true,luck3=true,goldenLever=true}
assert(near(RollOdds.nonCommonFactor(flags),2*1.5*2*2*3*1.05))
local plain,plainTotal=RollOdds.build(Config.Rarities,Config.Catalog,10,noBoost)
local boosted,boostedTotal=RollOdds.build(Config.Rarities,Config.Catalog,10,flags)
assert(near(plain[1].weight,boosted[1].weight) and boostedTotal>plainTotal)
for index=2,#boosted do assert(near(boosted[index].weight,plain[index].weight*RollOdds.nonCommonFactor(flags))) end
local locked=RollOdds.disclose({},0,8)
for i=1,8 do assert(locked[i].chance==0 and locked[i].count==0) end
-- Exercise weighted selection with a seeded pseudo-random source against disclosed chances.
math.randomseed(2027)
local tiers,total=RollOdds.build(Config.Rarities,Config.Catalog,5,noBoost)
local counts={}; local samples=50000
for _=1,samples do
 local pick=math.random()*total; local selected=tiers[#tiers]
 for _,tier in ipairs(tiers) do pick-=tier.weight; if pick<=0 then selected=tier; break end end
 counts[selected.index]=(counts[selected.index] or 0)+1
end
for _,tier in ipairs(tiers) do
 local expected=tier.weight/total
 if expected>0.01 then assert(math.abs((counts[tier.index] or 0)/samples-expected)<0.015) end
end
print("Roll-weight formula, unlocks, disclosures, stacking and sampling tests passed")
