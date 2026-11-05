local state={extras={scrap=1000,uncommonBoxes=90},parts={},creatures={},rolls={}}
local function review(q,token)
 local result=Refinery.review(state.extras,q,10,token or "token",100); state.refineQuote=result; return result
end
for _,n in ipairs({0,11,0.5,-1,math.huge,0/0}) do assert(not review(n)) end
assert(not review(1,""))
local q=review(10); assert(q and q.cost==1000 and q.boxes==90 and q.scrap==1000)
assert(not Refinery.confirm(state,"wrong",11,100) and state.extras.scrap==1000 and state.extras.uncommonBoxes==90)
assert(not Refinery.confirm(state,"token",11,100))
q=review(10); assert(not Refinery.confirm(state,"token",70,100) and state.extras.scrap==1000)
q=review(10); state.extras.scrap=999
assert(not Refinery.confirm(state,"token",11,100) and state.extras.uncommonBoxes==90)
state.extras.scrap=1000; q=review(10); state.extras.uncommonBoxes=91
assert(not Refinery.confirm(state,"token",11,100) and state.extras.scrap==1000)
assert(not review(10))
state.extras.uncommonBoxes=90; q=review(10)
assert(Refinery.confirm(state,"token",11,100) and state.extras.scrap==0 and state.extras.uncommonBoxes==100)
assert(not Refinery.confirm(state,"token",11,100) and not review(1))
local item=MysteryBoxes.open(state.extras,state.parts,state.creatures,state.rolls,1,function() return {id="reward",rarity=2} end)
assert(item and state.extras.uncommonBoxes==99 and #state.parts==1)
state.extras.scrap=100
q=review(1); assert(Refinery.confirm(state,"token",11,100) and state.extras.uncommonBoxes==100)
assert(not MysteryBoxes.open(state.extras,state.parts,state.creatures,state.rolls,1,function() return {id="other",rarity=2} end) and state.extras.uncommonBoxes==100)
print("Scrap refinery quote bounds, stale state, replay, atomicity and box opening passed")
