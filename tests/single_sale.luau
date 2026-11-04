local function part(id,kind)
 return {id=id,name="Dirt Boy",kind=kind,rarity=1,income=5,price=20,mutation="Standard",mutationMultiplier=1}
end
local function creature()
 return {id="cr",name="Dirt Boy",income=20,level=2,stand=0,components={Head=part("head","Head"),Chest=part("chest","Chest"),Arms=part("arms","Arms"),Legs=part("legs","Legs")}}
end
local function partValue(p) return math.floor((p.price or 10)/2) end
local function creatureValue(c) local value=0; for _,p in pairs(c.components) do value+=partValue(p) end; return value end
local function setup()
 return {parts={part("p","Head")},creatures={creature()},cash=100,rolls={},standLoadouts={}}
end
local function review(s,category,id,now)
 local q=SingleSale.review(s,category,id,now or 10,"token",partValue,creatureValue); s.singleSaleQuote=q; return q
end
local s=setup()
assert(not SingleSale.review(s,"invalid","p",0,"token",partValue,creatureValue))
assert(not SingleSale.review(s,"part","",0,"token",partValue,creatureValue))
assert(not SingleSale.review(s,"part","p",0,"",partValue,creatureValue))
s.parts[1].locked=true; assert(not review(s,"part","p")); s.parts[1].locked=false
s.creatures[1].stand=1; assert(not review(s,"creature","cr")); s.creatures[1].stand=0
local q=review(s,"part","p"); assert(q and q.value==10 and q.item~=s.parts[1])
assert(ItemIds.collect(s).p)
assert(not SingleSale.confirm(s,"bad",11,partValue,creatureValue) and #s.parts==1 and s.cash==100)
assert(not SingleSale.confirm(s,"token",11,partValue,creatureValue))
q=review(s,"part","p"); assert(not SingleSale.confirm(s,"token",70,partValue,creatureValue) and #s.parts==1)
q=review(s,"part","p"); s.parts[1].price=40
assert(not SingleSale.confirm(s,"token",11,partValue,creatureValue) and s.cash==100 and #s.parts==1)
s.parts[1].price=20; q=review(s,"part","p"); s.parts[1].locked=true
assert(not SingleSale.confirm(s,"token",11,partValue,creatureValue) and #s.parts==1)
s.parts[1].locked=false; q=review(s,"part","p"); local result=SingleSale.confirm(s,"token",69.99,partValue,creatureValue)
assert(result and result.value==10 and s.cash==110 and #s.parts==0)
assert(not SingleSale.confirm(s,"token",11,partValue,creatureValue))
s=setup(); q=review(s,"creature","cr"); assert(q and q.value==40 and q.item.components.Head~=s.creatures[1].components.Head)
local reserved=ItemIds.collect({parts={},creatures={},rolls={},singleSaleQuote=q}); assert(reserved.cr and reserved.head and reserved.chest)
s.creatures[1].components.Head.mutation="Golden"
assert(not SingleSale.confirm(s,"token",11,partValue,creatureValue) and s.cash==100 and #s.creatures==1)
s.creatures[1].components.Head.mutation="Standard"; q=review(s,"creature","cr"); s.creatures[1].level=3
assert(not SingleSale.confirm(s,"token",11,partValue,creatureValue) and #s.creatures==1)
s.creatures[1].level=2; q=review(s,"creature","cr"); s.creatures[1].stand=2
assert(not SingleSale.confirm(s,"token",11,partValue,creatureValue) and #s.creatures==1)
s.creatures[1].stand=0; q=review(s,"creature","cr")
assert(SingleSale.confirm(s,"token",11,partValue,creatureValue) and #s.creatures==0 and s.cash==140)
s=setup(); q=review(s,"part","p"); table.remove(s.parts,1)
assert(not SingleSale.confirm(s,"token",11,partValue,creatureValue) and s.cash==100)
print("Single sale review, revalidation, expiry, replay and ID reservation passed")
for field,newValue in pairs({id="other",name="Other",kind="Arms",rarity=2,income=11,price=21,mutation="Void",mutationMultiplier=4}) do
 local state=setup(); assert(review(state,"part","p")); state.parts[1][field]=newValue
 assert(not SingleSale.confirm(state,"token",11,partValue,creatureValue) and #state.parts==1 and state.cash==100,field)
end
for field,newValue in pairs({name="Other",income=21,level=3,ascended=true,blueprintApplied=true}) do
 local state=setup(); assert(review(state,"creature","cr")); state.creatures[1][field]=newValue
 assert(not SingleSale.confirm(state,"token",11,partValue,creatureValue) and #state.creatures==1 and state.cash==100,field)
end
s=setup(); q=review(s,"part","p"); assert(not SingleSale.confirm(s,"token",11,function() return 999 end,creatureValue))
assert(s.cash==100 and #s.parts==1)
s=setup(); q=review(s,"part","p"); s.parts[2]=part("new","Legs")
assert(SingleSale.confirm(s,"token",11,partValue,creatureValue) and #s.parts==1 and s.parts[1].id=="new")
print("Individual attribute changes and unrelated new items tested")
