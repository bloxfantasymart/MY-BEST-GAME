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
local themeIds={}
for i,theme in ipairs(Config.Themes) do
 assert(not themeIds[theme.id] and theme.rebirth>=0 and theme.rebirth<=100)
 if i>1 then assert(theme.rebirth>Config.Themes[i-1].rebirth) end
 themeIds[theme.id]=true
end
print("Config runtime tests passed")
