local function fresh() return {cash=100,extras={rollVouchers=0},obbyLastClaim=0} end
local player={}; local other={}; local s=fresh()
assert(not Obby.touch(s,2,player,0) and not Obby.claim(s,player,1,100000,1000))
assert(Obby.touch(s,1,player,10) and s.obbyRun.step==1)
assert(not Obby.touch(s,1,player,10.1) and s.obbyRun.started==10)
assert(not Obby.touch(s,3,player,11) and not Obby.touch(s,2,other,11))
assert(not Obby.touch(s,2,player,10.34) and s.obbyRun.step==1)
for i=2,9 do assert(Obby.touch(s,i,player,10+i)) end
assert(s.obbyRun.ready and not Obby.claim(s,other,20,100000,1000))
s.extras.rollVouchers=998
assert(not Obby.claim(s,player,20,100000,1000) and s.obbyRun.ready and s.cash==100)
s.extras.rollVouchers=997
assert(Obby.claim(s,player,20,100000,1000) and s.cash==50100 and s.extras.rollVouchers==1000 and s.obbyLastClaim==100000 and not s.obbyRun)
assert(not Obby.claim(s,player,20,100000,1000) and s.cash==50100)
assert(Obby.remaining(s.obbyLastClaim,99999)==21601 and Obby.remaining(s.obbyLastClaim,121599)==1 and Obby.remaining(s.obbyLastClaim,121600)==0)
for i=1,9 do assert(Obby.touch(s,i,player,100+i)) end
assert(not Obby.claim(s,player,110,121599,1000) and s.obbyRun.ready)
s.extras.rollVouchers=0
assert(Obby.claim(s,player,110,121600,1000) and s.cash==100100 and s.extras.rollVouchers==3)
local stale=fresh(); assert(Obby.touch(stale,1,player,0)); assert(not Obby.touch(stale,2,player,46) and stale.obbyRun==nil)
assert(Obby.touch(stale,1,player,50)); assert(not Obby.touch(stale,2,player,49) and stale.obbyRun==nil)
assert(Obby.touch(stale,1,player,100)); for i=2,9 do assert(Obby.touch(stale,i,player,100+i)) end
assert(not Obby.claim(stale,player,170,500000,1000) and stale.obbyRun==nil)
local total=fresh(); assert(Obby.touch(total,1,player,0))
for i=2,5 do assert(Obby.touch(total,i,player,(i-1)*44)) end
assert(not Obby.touch(total,6,player,181) and total.obbyRun==nil)
assert(not Obby.touch(total,0,player,1) and not Obby.touch(total,10,player,1) and not Obby.touch(total,1,nil,1))
print("Obby sequence, timing, character, cooldown, caps and replay tests passed")
-- Exact boundary: cooldown is enforced until six hours and a finished run
-- is claimable at exactly 60 seconds, but never after.
local boundary=fresh()
for i=1,9 do assert(Obby.touch(boundary,i,player,i)) end
assert(Obby.claim(boundary,player,69,200000,1000))
local again=fresh()
for i=1,9 do assert(Obby.touch(again,i,player,i)) end
assert(not Obby.claim(again,player,69.01,200000,1000) and again.cash==100 and again.extras.rollVouchers==0)
-- Starting over discards old progress; prior character cannot claim.
local restart=fresh()
for i=1,9 do assert(Obby.touch(restart,i,player,100+i)) end
assert(Obby.touch(restart,1,other,200) and restart.obbyRun.step==1)
assert(not Obby.claim(restart,player,201,200000,1000) and not Obby.claim(restart,other,201,200000,1000))
print("Obby claim-window boundaries, respawn and restart tests passed")
local statusState=fresh(); assert(Obby.touch(statusState,1,player,1))
assert(Obby.status(statusState,player,46,100000).step==1)
assert(Obby.status(statusState,player,46.01,100000).step==0 and statusState.obbyRun==nil)
assert(Obby.touch(statusState,1,player,100))
assert(Obby.status(statusState,other,101,100000).step==0)
for i=1,9 do assert(Obby.touch(statusState,i,player,200+i)) end
assert(Obby.status(statusState,player,269,100000).ready)
assert(not Obby.status(statusState,player,269.01,100000).ready and statusState.obbyRun==nil)
print("Obby status expires stale and respawned attempts")
