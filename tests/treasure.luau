local function fresh(rebirth,scrap) return {rebirth=rebirth,cash=0,extras={scrap=scrap or 0}} end
assert(not Treasure.new(0,function() return 0 end))
assert(not Treasure.new(0,function() return 1.5 end))
assert(not Treasure.new(0,function() error("rng failed") end))
math.randomseed(424242)
for _=1,500 do
 local r=Treasure.new(100,function(a,b) return math.random(a,b) end)
 assert(r and #r.spots==10 and r.expires==100+900)
 local used={}; for _,spot in ipairs(r.spots) do assert(spot>=1 and spot<=32 and not used[spot]); used[spot]=true end
end
local round=Treasure.new(100,function() return 1 end)
local a,b=fresh(2),fresh(10)
assert(not Treasure.claim(round,0,a,100,100000) and not Treasure.claim(round,11,a,100,100000))
assert(not Treasure.claim(round,1,a,99,100000) and not Treasure.claim(round,1,a,1000,100000))
local cash,scrap=Treasure.claim(round,1,a,100,100000)
assert(cash==1500 and scrap==3 and a.cash==1500 and a.extras.scrap==3)
assert(not Treasure.claim(round,1,b,102,100000) and b.cash==0 and b.extras.scrap==0)
assert(not Treasure.claim(round,2,a,101.99,100000) and not round.claimed[2])
assert(Treasure.claim(round,2,a,102,100000) and a.cash==3000)
local full=fresh(0,999998)
assert(not Treasure.claim(round,3,full,103,100000) and not round.claimed[3] and full.cash==0)
assert(Treasure.claim(round,3,b,103,100000) and b.cash==5500 and b.extras.scrap==3)
local storm=fresh(3,999999)
assert(Treasure.storm(storm)==200 and storm.cash==200 and storm.extras.scrap==1000000)
assert(not Treasure.storm(storm) and storm.cash==200)
-- Round expiry and stale callbacks cannot claim a replaced chest.
local nextRound=Treasure.new(1000,function() return 1 end)
assert(not Treasure.claim(round,4,b,1000,100000))
assert(Treasure.claim(nextRound,4,b,1000,100000))
print("Treasure uniqueness, one-use races, expiry, caps, cooldown and storm rewards passed")

-- Saved daily quota follows UTC days and cannot roll backwards.
local quota=fresh(0); local day=200000*86400
for i=1,10 do
 local new=Treasure.new(i*10,function() return 1 end)
 assert(Treasure.claim(new,1,quota,i*10,day))
end
assert(quota.extras.treasureDay==200000 and quota.extras.treasureClaims==10)
local r=Treasure.new(200,function() return 1 end)
assert(not Treasure.claim(r,1,quota,200,day) and not r.claimed[1] and quota.cash==5000)
assert(not Treasure.claim(r,1,quota,200,day-86400) and Treasure.status(quota.extras,day-86400).clockBlocked)
assert(Treasure.status(quota.extras,day+86400).remaining==10)
assert(Treasure.claim(r,1,quota,200,day+86400) and quota.extras.treasureClaims==1)
print("Daily treasure limits, rollover and clock rollback passed")
