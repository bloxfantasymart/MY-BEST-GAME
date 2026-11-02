local kinds={"Head","Chest","Arms","Legs"}
local rarities={{multiplier=1},{multiplier=1.5},{multiplier=2.5},{multiplier=4.5}}
local mutations={{"Standard",1},{"Shiny",1.5},{"Golden",2.5},{"Void",4},{"Glitched",6},{"FutureMutation",3}}
local function score(items)
 local total=0; local rarity=0; local mutation=nil; local harmony=true
 for _,item in ipairs(items) do
  total+=item.income*item.mutationMultiplier
  rarity=math.max(rarity,item.rarity)
  if mutation==nil then mutation=item.mutation elseif mutation~=item.mutation then harmony=false end
 end
 return total*rarities[rarity].multiplier*0.4*(harmony and 2 or 1)
end
assert(AutoFill.best({},rarities,kinds)==nil)
math.randomseed(2026)
for trial=1,120 do
 local all={}; local bins={{},{},{},{}}
 for k,kind in ipairs(kinds) do
  for i=1,4 do
   local mutation=mutations[math.random(1,#mutations)]
   local item={id=k.."-"..i,kind=kind,rarity=math.random(1,#rarities),income=math.random(1,200),mutation=mutation[1],mutationMultiplier=mutation[2]}
   table.insert(all,item); table.insert(bins[k],item)
  end
 end
 local maxScore=-1
 for _,a in ipairs(bins[1]) do for _,b in ipairs(bins[2]) do for _,c in ipairs(bins[3]) do for _,d in ipairs(bins[4]) do
  maxScore=math.max(maxScore,score({a,b,c,d}))
 end end end end
 local selected,calculated=AutoFill.best(all,rarities,kinds)
 assert(selected and math.abs(calculated-maxScore)<0.00001, "Must match exhaustive search in trial "..trial)
 local owned={}; for _,item in ipairs(all) do owned[item.id]=item end
 local chosen={}; for _,kind in ipairs(kinds) do local item=owned[selected[kind]]; assert(item and item.kind==kind); table.insert(chosen,item) end
 assert(math.abs(score(chosen)-maxScore)<0.00001)
end
print("Auto-fill matches exhaustive search across 120 randomized inventories")
local protectedParts={}
for i,kind in ipairs(kinds) do
 table.insert(protectedParts,{id="unlocked"..i,kind=kind,rarity=1,income=1,mutation="Standard",mutationMultiplier=1})
 table.insert(protectedParts,{id="locked"..i,kind=kind,rarity=4,income=1000,mutation="Standard",mutationMultiplier=1,locked=true})
end
local selection=AutoFill.best(protectedParts,rarities,kinds)
for i,kind in ipairs(kinds) do assert(selection[kind]=="unlocked"..i, "Auto-fill must never select protected parts") end
protectedParts[1].locked=true
assert(AutoFill.best(protectedParts,rarities,kinds)==nil, "No unlocked head means no complete recipe")
print("Auto-fill excludes protected parts")

local rareParts={}
for i,kind in ipairs(kinds) do
 table.insert(rareParts,{id="common"..i,kind=kind,rarity=1,income=10000,mutation="Standard",mutationMultiplier=1})
 table.insert(rareParts,{id="rare"..i,kind=kind,rarity=3,income=10,mutation="Standard",mutationMultiplier=1})
end
local rareSelection=AutoFill.best(rareParts,rarities,kinds,3)
for i,kind in ipairs(kinds) do assert(rareSelection[kind]=="rare"..i) end
rareParts[2].locked=true
assert(AutoFill.best(rareParts,rarities,kinds,3)==nil)
print("Blueprint auto-fill rarity restriction tests passed")
