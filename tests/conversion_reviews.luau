local kinds={"Head","Chest","Arms","Legs"}
local rarities={{multiplier=1},{multiplier=2},{multiplier=3}}
local function part(id,kind)
 return {id=id,name="Dirt Boy",kind=kind,rarity=3,income=5,price=20,mutation="Standard",mutationMultiplier=1}
end
local function setup()
 local s={parts={},creatures={},cash=100000,rebirth=15,rareBlueprints=1,rolls={}}
 local selection={useBlueprint=true}
 for _,kind in ipairs(kinds) do local p=part("part"..kind,kind); table.insert(s.parts,p); selection[kind]=p.id end
 return s,selection
end
local function id() return "new-unique" end
local function craftReview(s,selection)
 local q=Reviews.craft(s,selection,10,"token",Crafting,rarities); s.craftQuote=q; return q
end
local s,selection=setup()
assert(not Reviews.craft(s,selection,10,"",Crafting,rarities))
local q=craftReview(s,selection); assert(q and #q.inputs==4 and q.output.useBlueprint)
assert(ItemIds.collect({parts={},creatures={},rolls={},craftQuote=q}).partHead)
assert(not Reviews.confirmCraft(s,"wrong",11,Crafting,rarities,id) and #s.parts==4)
assert(not Reviews.confirmCraft(s,"token",11,Crafting,rarities,id))
q=craftReview(s,selection); assert(not Reviews.confirmCraft(s,"token",70,Crafting,rarities,id) and #s.parts==4)
q=craftReview(s,selection); s.parts[1].price=21
assert(not Reviews.confirmCraft(s,"token",11,Crafting,rarities,id) and #s.parts==4 and s.rareBlueprints==1)
s.parts[1].price=20; q=craftReview(s,selection); s.parts[1].locked=true
assert(not Reviews.confirmCraft(s,"token",11,Crafting,rarities,id) and #s.parts==4)
s.parts[1].locked=false; q=craftReview(s,selection); s.rareBlueprints=0
assert(not Reviews.confirmCraft(s,"token",11,Crafting,rarities,id) and #s.parts==4)
s.rareBlueprints=1; q=craftReview(s,selection)
assert(not Reviews.confirmCraft(s,"token",11,Crafting,rarities,function() return "partHead" end) and #s.parts==4)
q=craftReview(s,selection); local result=Reviews.confirmCraft(s,"token",11,Crafting,rarities,id)
assert(result and #s.parts==0 and #s.creatures==1 and result.blueprintCount==0 and result.creature.blueprintApplied)
local function fusionSetup()
 local state={parts={},creatures={},cash=1000,rebirth=15,rareBlueprints=0,rolls={}}
 local ids={}
 for i=1,3 do
  local components={}; for _,kind in ipairs(kinds) do components[kind]=part("component"..i..kind,kind) end
  local c={id="creature"..i,name="Dirt",income=20,level=10,stand=0,components=components}
  table.insert(state.creatures,c); table.insert(ids,c.id)
 end
 return state,ids
end
local costFn=function() return 100 end
local function fusionReview(st,ids)
 local quote=Reviews.fusion(st,ids,10,"token",Fusion,costFn); st.fusionQuote=quote; return quote
end
local f,ids=fusionSetup(); q=fusionReview(f,ids); assert(q and #q.inputs==3 and q.cost==100 and q.outputIncome==100)
local reserved=ItemIds.collect({parts={},creatures={},rolls={},fusionQuote=q}); assert(reserved.creature1 and reserved.component1Head)
f.creatures[2].level=11
assert(not Reviews.confirmFusion(f,"token",11,Fusion,costFn,id) and #f.creatures==3 and f.cash==1000)
f.creatures[2].level=10; q=fusionReview(f,ids); f.creatures[2].locked=true
assert(not Reviews.confirmFusion(f,"token",11,Fusion,costFn,id) and #f.creatures==3 and f.cash==1000)
f.creatures[2].locked=false; q=fusionReview(f,ids); f.cash=99
assert(not Reviews.confirmFusion(f,"token",11,Fusion,costFn,id) and #f.creatures==3 and f.cash==99)
f.cash=1000; q=fusionReview(f,ids)
assert(not Reviews.confirmFusion(f,"token",11,Fusion,costFn,function() return nil end) and #f.creatures==3 and f.cash==1000)
q=fusionReview(f,ids); assert(not Reviews.confirmFusion(f,"token",70,Fusion,costFn,id) and #f.creatures==3)
q=fusionReview(f,ids); local fused,cost=Reviews.confirmFusion(f,"token",11,Fusion,costFn,id)
assert(fused and cost==100 and #f.creatures==1 and f.cash==900 and fused.income==100 and fused.ascended)
assert(not Reviews.confirmFusion(f,"token",11,Fusion,costFn,id) and f.cash==900)
print("Conversion review transactions, stale inputs, expiry, replay and allocator failures passed")
for field,value in pairs({id="changed",name="Other",kind="Arms",rarity=2,income=6,price=21,mutation="Void",mutationMultiplier=4}) do
 local state,recipe=setup(); assert(craftReview(state,recipe)); state.parts[1][field]=value
 assert(not Reviews.confirmCraft(state,"token",11,Crafting,rarities,id) and #state.parts==4 and state.rareBlueprints==1,field)
end
s,selection=setup(); q=craftReview(s,selection)
local changedRarities={{multiplier=1},{multiplier=2},{multiplier=4}}
assert(not Reviews.confirmCraft(s,"token",11,Crafting,changedRarities,id) and #s.parts==4)
s,selection=setup(); q=craftReview(s,selection); s.parts[5]=part("newOther","Head")
assert(Reviews.confirmCraft(s,"token",11,Crafting,rarities,id) and #s.parts==1 and s.parts[1].id=="newOther")
for _,change in ipairs({"component","stand","rebirth","cost","ascended"}) do
 f,ids=fusionSetup(); assert(fusionReview(f,ids))
 local nowCost=costFn
 if change=="component" then f.creatures[2].components.Head.price=99
 elseif change=="stand" then f.creatures[2].stand=1
 elseif change=="rebirth" then f.rebirth=14
 elseif change=="cost" then nowCost=function() return 101 end
 elseif change=="ascended" then f.creatures[2].ascended=true end
 assert(not Reviews.confirmFusion(f,"token",11,Fusion,nowCost,id) and #f.creatures==3 and f.cash==1000,change)
end
print("Conversion reviews reject changed recipes, outputs, eligibility and costs")
