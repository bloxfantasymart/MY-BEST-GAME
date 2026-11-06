local function close(a,b,epsilon) return math.abs(a-b)<(epsilon or 1e-12) end
assert(OddsMath.target(0.5,2,4,0.1)==0.00625)
assert(OddsMath.target(0.5,2,1,1)==0.25)
for _,bad in ipairs({-1,1.01,0/0,math.huge}) do
 assert(not OddsMath.target(bad,1,1,1))
 assert(not OddsMath.target(0.5,1,1,bad))
 assert(not OddsMath.atLeastOne(bad,1))
end
for _,bad in ipairs({0,-1,1.5,0/0,math.huge}) do assert(not OddsMath.target(0.5,bad,4,1) and not OddsMath.target(0.5,1,bad,1)) end
for _,bad in ipairs({0,10,1.5,0/0,math.huge}) do assert(not OddsMath.atLeastOne(0.5,bad)) end
assert(OddsMath.atLeastOne(0,9)==0 and OddsMath.atLeastOne(1,9)==1)
assert(close(OddsMath.atLeastOne(0.5,3),0.875))
assert(close(OddsMath.atLeastOne(1e-20,9),9e-20,1e-30),"Tiny probabilities must not round to zero")
assert(OddsMath.format(0)=="0%" and OddsMath.format(-1)=="unavailable" and OddsMath.format(0.5):find("1 in 2",1,true))
assert(OddsMath.format(1e-320):find("rarer",1,true))
for _,rebirth in ipairs({0,3,15,50,100}) do
 for _,modifiers in ipairs({{}, {frenzy=true,weekend=true,luck2=true}}) do
  local tiers,total=RollOdds.build(Config.Rarities,Config.Catalog,rebirth,modifiers)
  local sum=0
  for _,tier in ipairs(tiers) do
   local tierChance=tier.weight/total
   local perArchetype=OddsMath.target(tierChance,#tier.list,1,1)
   local detailed=0
   for _,mutation in ipairs(Config.Mutations) do
    for _=1,#Config.Types do detailed+=OddsMath.target(tierChance,#tier.list,#Config.Types,mutation.weight/10000) end
   end
   assert(close(perArchetype,detailed),"Summed type/mutation probabilities equal archetype probability")
   sum+=perArchetype*#tier.list
   local one=OddsMath.atLeastOne(perArchetype,1); assert(close(one,perArchetype))
   local batch=OddsMath.atLeastOne(perArchetype,9)
   assert(batch>=perArchetype and batch<=1 and close(batch,1-(1-perArchetype)^9))
  end
  assert(close(sum,1),"All per-archetype probabilities must sum to one")
 end
end
print("Exact offer odds, independent batch probabilities, precision and validation passed")
