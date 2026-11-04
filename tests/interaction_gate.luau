local a,b={},{}
assert(not InteractionGate.allow(a,"unknown",1))
assert(not InteractionGate.allow(a,"prompt",0/0))
assert(not InteractionGate.allow(a,"remote",math.huge))
assert(InteractionGate.allow(a,"remote",10))
assert(not InteractionGate.allow(a,"remote",10.1))
assert(InteractionGate.allow(a,"remote",10.16))
assert(InteractionGate.allow(a,"prompt",10.16)) -- independent channels
assert(not InteractionGate.allow(a,"prompt",10.4))
assert(InteractionGate.allow(a,"prompt",10.42))
assert(InteractionGate.allow(b,"prompt",10.42)) -- independent players
local spam={}
for i=1,15 do InteractionGate.allow(spam,"prompt",100+i/1000) end
assert(not InteractionGate.allow(spam,"prompt",100.016))
assert(not InteractionGate.allow(spam,"prompt",104.9))
assert(InteractionGate.allow(spam,"remote",104.9)) -- prompt penalty cannot block remotes
assert(InteractionGate.allow(spam,"prompt",105.016))
local rewind={}
assert(InteractionGate.allow(rewind,"remote",100))
for _=1,15 do InteractionGate.allow(rewind,"remote",100.01) end
assert(not InteractionGate.allow(rewind,"remote",100.1))
assert(InteractionGate.allow(rewind,"remote",1))
assert(InteractionGate.allow({},"prompt",0))
print("Interaction gate independent channels, spacing, penalty and clock tests passed")
