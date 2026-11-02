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
assert(Config.CreatureSellValue(creature) == 1000)
assert(#Config.StandCosts == 12 and #Config.SlotCosts == 9)
print("Config runtime tests passed")
