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

-- Daily claims are durable profile state, separate from session timers.
local extras={sessionGiftDay=-1,sessionGiftClaims={}}
local epoch=20000*86400
for _,id in ipairs({"cash1","vouchers3","uncommon","cash10","luck","blueprint25","cash40","epic60","crown90"}) do
 local plan=SessionGifts.dailyPlan(extras,id,epoch); assert(plan and plan.day==20000)
 SessionGifts.commitDaily(extras,plan)
 assert(not SessionGifts.dailyPlan(extras,id,epoch),"Same gift must be blocked within the UTC day")
end
assert(SessionGifts.validDaily(extras.sessionGiftDay,extras.sessionGiftClaims))
assert(not SessionGifts.dailyPlan(extras,"cash1",epoch-1),"Clock rollback must not reset claims")
local tomorrow=SessionGifts.dailyPlan(extras,"cash1",epoch+86400); assert(tomorrow)
SessionGifts.commitDaily(extras,tomorrow)
assert(extras.sessionGiftDay==20001 and extras.sessionGiftClaims.cash1 and extras.sessionGiftClaims.vouchers3==nil)
assert(SessionGifts.dailyPlan(extras,"vouchers3",epoch+86400))
assert(not SessionGifts.dailyPlan(extras,"unknown",epoch+86400))
assert(not SessionGifts.dailyPlan(extras,"cash1",0/0))
assert(SessionGifts.validDaily(nil,nil) and not SessionGifts.validDaily(nil,{}))
assert(not SessionGifts.validDaily(0,nil) and not SessionGifts.validDaily(-1,{cash1=true}))
assert(not SessionGifts.validDaily(1,{cash1=false}) and not SessionGifts.validDaily(1,{unknown=true}))
assert(not SessionGifts.validDaily(1.5,{}) and not SessionGifts.validDaily(0/0,{}))
print("Daily gift rollover, stable IDs, legacy profiles and rollback checks passed")

local serverExtras={sessionGiftDay=-1,sessionGiftClaims={}}; local sessionClaims={}
assert(#Config.SessionGifts==9)
for _,g in ipairs(Config.SessionGifts) do assert(SessionGifts.dailyPlan(serverExtras,g.id,epoch),"All configured gifts need a stable daily ID") end
local g=SessionGifts.find(Config.SessionGifts,sessionClaims,"cash1",60); assert(g)
local initial=SessionGifts.dailyPlan(serverExtras,g.id,epoch); assert(initial)
-- A failed grant must not commit its plan, so the gift remains claimable.
assert(SessionGifts.dailyPlan(serverExtras,g.id,epoch))
SessionGifts.commitDaily(serverExtras,initial); sessionClaims[g.id]=true
local newSession={}
assert(SessionGifts.find(Config.SessionGifts,newSession,"cash1",60),"Session timer/claim state restarts")
assert(not SessionGifts.dailyPlan(serverExtras,"cash1",epoch),"Saved daily claims survive a new session")
assert(not SessionGifts.find(Config.SessionGifts,sessionClaims,"cash1",86400),"Session claim remains used across UTC midnight until rejoin")
assert(SessionGifts.dailyPlan(serverExtras,"cash1",epoch+86400))
print("Configured gift IDs, failed-grant behavior, session resets and daily cap passed")
