-- Appended by run_luau_tests.py after Config is loaded with a Color3 stub.
assert(#Config.Catalog == 50)
assert(#Config.Rarities == 8)
assert(#Config.Mutations == 5)
assert(Config.RebirthTarget(0) == "Dirt Boy")
assert(Config.RebirthCost(0) == 1000)
for tier = 0, 99 do
 local target = Config.RebirthTarget(tier)
 local reachable = false
 for _, archetype in ipairs(Config.Catalog) do
  if archetype.name == target and archetype.rebirth <= tier then reachable = true end
 end
 assert(reachable, "Unreachable rebirth target at " .. tier)
 assert(Config.RebirthCost(tier) > 0)
end
local creature = {income=100, level=1}
assert(Config.FusionCost(creature)==10000)
assert(Config.FusionCost({income=500})==50000)
assert(Config.Income(creature) == 100)
creature.level=2
assert(Config.Income(creature) == 125)
assert(Config.LevelCost(creature) == 1500)
assert(Config.PartSellValue({price=101}) == 50)
creature.components={Head={price=100},Chest={price=80},Arms={price=10},Legs={price=10}}
assert(Config.CreatureSellValue(creature) == 100)
for price=1,1000 do
 local part={price=price}
 local combined={components={Head=part,Chest=part,Arms=part,Legs=part}}
 assert(Config.CreatureSellValue(combined)<=price*4, "Crafting must not create a resale profit")
end
assert(#Config.StandCosts == 12 and #Config.SlotCosts == 9)
assert(#Config.Themes==5 and #Config.TutorialText==7)
assert(#Config.BackpackUpgradeCosts==10 and Config.BackpackUpgradeCosts[1]==5000)
assert(#Config.SessionGifts==9 and #Config.DailyRewardLabels==7)
for rarity=4,8 do
 local present=false
 for _,entry in ipairs(Config.Catalog) do if entry.rarity==rarity then present=true end end
 assert(present, "Epic+ odds require an item in every listed tier")
end
local giftIds={}
for i,gift in ipairs(Config.SessionGifts) do
 assert(not giftIds[gift.id] and gift.seconds>0)
 if i>1 then assert(gift.seconds>Config.SessionGifts[i-1].seconds) end
 giftIds[gift.id]=true
end
local themeIds={}
for i,theme in ipairs(Config.Themes) do
 assert(not themeIds[theme.id] and theme.rebirth>=0 and theme.rebirth<=100)
 if i>1 then assert(theme.rebirth>Config.Themes[i-1].rebirth) end
 themeIds[theme.id]=true
end
local head=Config.SummitHead
assert(head.name=="Peak Mountain" and head.kind=="Head" and head.rarity==3 and head.income==50 and head.price==10 and head.mutation=="Standard" and head.mutationMultiplier==1)
for _,entry in ipairs(Config.Catalog) do assert(entry.name~=head.name, "Exclusive head must not enter normal rolls or rebirth targets") end
print("Config runtime tests passed")
