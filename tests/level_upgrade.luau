local function cost(c) return math.max(50,math.floor(c.income*10*(1+c.level*0.25))) end
local creature={id="a",name="Creature",income=100,level=2,stand=1,exp=4,locked=true}
local state={cash=5000,creatures={creature}}
local review={id="a",level=2,cost=cost(creature)}
local function rejected(request)
 local beforeCash=state.cash; local beforeLevel=creature.level
 assert(LevelUpgrade.execute(state,request,cost)==nil and state.cash==beforeCash and creature.level==beforeLevel)
end
rejected("a"); rejected(nil); rejected({id={},level=2,cost=1500})
rejected({id="",level=2,cost=1500}); rejected({id="missing",level=2,cost=1500})
rejected({id="a",level=0/0,cost=1500}); rejected({id="a",level=2,cost=0/0})
rejected({id="a",level=2,cost=1}); rejected({id="a",level=1,cost=1500})
state.cash=1499; rejected(review); state.cash=5000
-- A level earned between review and confirmation invalidates the old price.
creature.level=3; rejected(review); creature.level=2
local changedCost=creature.income; creature.income=101; rejected(review); creature.income=changedCost
local result,paid=LevelUpgrade.execute(state,review,cost)
assert(result==creature and paid==1500 and state.cash==3500 and creature.level==3 and creature.exp==4)
rejected(review) -- replay must not spend again
assert(creature.locked and creature.stand==1, "Protected/placed creatures may be upgraded")
creature.level=999; creature.income=0; state.cash=100
local last={id="a",level=999,cost=50}
assert(LevelUpgrade.execute(state,last,cost)==creature and creature.level==1000 and state.cash==50)
rejected(last); rejected({id="a",level=1000,cost=50})
print("Reviewed level upgrades, stale prices, replay and balance tests passed")
