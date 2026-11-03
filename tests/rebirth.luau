local function part(kind,id)
 return {id=id,name="Dirt Boy",kind=kind,rarity=1,income=2,mutation="Standard",mutationMultiplier=1}
end
local function creature(id)
 return {id=id,name="Dirt Boy Abomination",income=10,level=3,stand=1,components={Head=part("Head",id.."h"),Chest=part("Chest",id.."c"),Arms=part("Arms",id.."a"),Legs=part("Legs",id.."l")}}
end
local function newState()
 return {rebirth=0,cash=5000,slots=3,rolls={{id="offer1"},{id="offer2"}},autoRolling=false,creatures={creature("first"),creature("chosen")}}
end
local function target(rebirth) return rebirth==0 and "Dirt Boy" or "Other" end
local function cost(rebirth) return 1000*(rebirth+1) end
local function review(s,id,can,keep,now)
 return Rebirth.review(s,id,can,keep,now,"token",target,cost)
end
local state=newState()
assert(review(state,"missing",true,false,10)==nil)
assert(review(state,{},true,false,10)==nil)
assert(review(state,"chosen",false,false,10)==nil)
state.autoRolling=true; assert(review(state,"chosen",true,false,10)==nil); state.autoRolling=false
state.cash=999; assert(review(state,"chosen",true,false,10)==nil); state.cash=5000
state.creatures[2].locked=true; assert(review(state,"chosen",true,false,10)==nil); state.creatures[2].locked=false
state.creatures[2].ascended=true; assert(review(state,"chosen",true,false,10)==nil); state.creatures[2].ascended=false
state.creatures[2].name="Other Abomination"; assert(review(state,"chosen",true,false,10)==nil); state.creatures[2].name="Dirt Boy Abomination"
local quote=review(state,"chosen",true,false,10)
assert(quote and quote.id=="chosen" and quote.expires==40 and #quote.offers==2 and quote.components.Head.id=="chosenh")
assert(#state.creatures==2 and state.cash==5000, "Review must never mutate state")
assert(Rebirth.check(state,quote,"token",true,false,39.99,target,cost)==2, "Explicitly select the second candidate")
assert(Rebirth.check(state,quote,"wrong",true,false,20,target,cost)==nil)
assert(Rebirth.check(state,quote,"token",true,false,40,target,cost)==nil)
assert(Rebirth.check(state,quote,"token",false,false,20,target,cost)==nil)
assert(Rebirth.check(state,quote,"token",true,true,20,target,cost)==nil, "Keep Slots change requires review")
local function changed(mutator)
 local s=newState(); local q=review(s,"chosen",true,false,10); mutator(s); local count=#s.creatures
 assert(Rebirth.check(s,q,"token",true,false,20,target,cost)==nil, "Changed state must invalidate the quote")
 assert(#s.creatures==count, "Failed confirmation must not consume creatures")
end
changed(function(s) s.cash+=1 end)
changed(function(s) s.cash-=1 end)
changed(function(s) s.rebirth=1 end)
changed(function(s) s.slots=4 end)
changed(function(s) s.autoRolling=true end)
changed(function(s) s.creatures[2].locked=true end)
changed(function(s) s.creatures[2].level+=1 end)
changed(function(s) s.creatures[2].stand=0 end)
changed(function(s) s.creatures[2].income+=1 end)
changed(function(s) s.creatures[2].blueprintApplied=true end)
changed(function(s) s.creatures[2].components.Head.mutation="Void" end)
changed(function(s) s.creatures[2].components.Head.id="other" end)
changed(function(s) s.rolls[1].id="different" end)
changed(function(s) table.remove(s.rolls) end)
changed(function(s) table.remove(s.creatures,2) end)
local single=newState(); single.rebirthQuote=review(single,"chosen",true,false,10)
local chosenIndex,consumed=Rebirth.consume(single,"token",true,false,20,target,cost)
assert(chosenIndex==2 and consumed.id=="chosen" and single.rebirthQuote==nil)
assert(Rebirth.consume(single,"token",true,false,20,target,cost)==nil, "A quote cannot be replayed")
single.rebirthQuote=review(single,"chosen",true,false,10)
assert(Rebirth.consume(single,"wrong",true,false,20,target,cost)==nil and single.rebirthQuote==nil, "Failed confirmation also consumes the quote")
state.rebirth=100; assert(review(state,"chosen",true,false,10)==nil)
print("Rebirth quote eligibility, explicit selection, expiry and stale-state tests passed")
