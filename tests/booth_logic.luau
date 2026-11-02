local a,b={},{}
local alice={profile={creatures={{id="a1"},{id="a2"},{id="a3"},{id="a4"},{id="a5"}}}}
local bob={profile={creatures={{id="b1"}}}}
local booth={index=1,owner=nil,listings={}}
local other={index=2,owner=nil,listings={}}
assert(BoothLogic.claim(booth,a,alice))
assert(not BoothLogic.claim(booth,b,bob))
assert(not BoothLogic.claim(other,a,alice))
assert(not BoothLogic.add(booth,b,bob,"b1"))
assert(not BoothLogic.add(booth,a,alice,"b1"))
assert(BoothLogic.add(booth,a,alice,"a1"))
assert(not BoothLogic.add(booth,a,alice,"a1"))
assert(BoothLogic.add(booth,a,alice,"a2"))
assert(BoothLogic.add(booth,a,alice,"a3"))
assert(BoothLogic.add(booth,a,alice,"a4"))
assert(not BoothLogic.add(booth,a,alice,"a5"))
assert(not BoothLogic.remove(booth,b,"a1"))
assert(BoothLogic.remove(booth,a,"a1"))
assert(BoothLogic.add(booth,a,alice,"a5"))
assert(not BoothLogic.release(booth,b,bob))
assert(BoothLogic.release(booth,a,alice))
assert(#booth.listings==0 and alice.booth==nil and booth.owner==nil)
assert(BoothLogic.claim(booth,b,bob))
print("Booth ownership and showcase tests passed")
