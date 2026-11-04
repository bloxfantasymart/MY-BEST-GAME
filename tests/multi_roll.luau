local s={parts={},creatures={},rolls={},slots=2,extras={multiRollTokens=1},offerExpires=0}
local count=0
local function generate() count+=1; return "id"..count end
local function offer(id) return {id=id} end
assert(not MultiRoll.create(s,"yes",10,generate,offer) and count==0)
assert(MultiRoll.create(s,true,10,generate,offer)==9 and #s.rolls==9 and s.extras.multiRollTokens==0 and s.offerExpires==70)
assert(not MultiRoll.create(s,false,11,generate,offer) and #s.rolls==9 and s.offerExpires==70)
assert(not MultiRoll.create(s,true,11,generate,offer) and #s.rolls==9)
s.rolls={}; s.offerExpires=0
assert(not MultiRoll.create(s,true,12,generate,offer) and #s.rolls==0)
assert(MultiRoll.create(s,false,12,generate,offer)==2 and #s.rolls==2 and s.offerExpires==72)
s.rolls={}; s.offerExpires=0; s.extras.multiRollTokens=1
local calls=0
assert(not MultiRoll.create(s,true,20,function() calls+=1; return "repeat" end,offer))
assert(#s.rolls==0 and s.extras.multiRollTokens==1 and s.offerExpires==0 and calls==1+ItemIds.MaxAttempts)
count=0
assert(not MultiRoll.create(s,true,20,generate,function(key) if key=="id5" then error("offer failure") end; return offer(key) end))
assert(#s.rolls==0 and s.extras.multiRollTokens==1 and s.offerExpires==0)
s.rolls={{id="held"}}; count=0
assert(not MultiRoll.create(s,true,20,generate,offer) and count==0 and s.rolls[1].id=="held" and s.extras.multiRollTokens==1)
print("Multi-roll token batch commit, preservation, failures and slot counts passed")
