local gifts={{id="cash",seconds=60},{id="part",seconds=300}}
local claimed={}
assert(SessionGifts.find(gifts,claimed,"cash",59)==nil)
local gift=SessionGifts.find(gifts,claimed,"cash",60)
assert(gift and gift.id=="cash")
claimed.cash=true
assert(SessionGifts.find(gifts,claimed,"cash",500)==nil)
assert(SessionGifts.find(gifts,claimed,"part",299)==nil)
assert(SessionGifts.find(gifts,claimed,"part",300).id=="part")
assert(SessionGifts.find(gifts,claimed,"unknown",1000)==nil)
assert(SessionGifts.find(gifts,claimed,{},1000)==nil)
assert(SessionGifts.find(gifts,{},"cash",0/0)==nil)
assert(not SessionGifts.offersExpired(100,99.99,1))
assert(SessionGifts.offersExpired(100,100,1))
assert(not SessionGifts.offersExpired(100,101,0))
assert(not SessionGifts.offersExpired(0,101,1))
print("Session gift eligibility and roll-offer expiration tests passed")
