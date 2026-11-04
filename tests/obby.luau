local spec={name="Peak Mountain",kind="Head",rarity=3,income=50,price=10,mutation="Standard",mutationMultiplier=1}
local function fresh() return {cash=100,extras={rollVouchers=0},obbyLastClaim=0,parts={},creatures={},rolls={}} end
local function claim(state,character,now,epoch,maxVouchers)
 return Obby.claimWithDrop(state,character,now,epoch,maxVouchers,100,function() return 100 end,function() return "unused" end,spec)
end
local player={}; local other={}; local s=fresh()
assert(not Obby.touch(s,2,player,0) and not claim(s,player,1,100000,1000))
assert(Obby.touch(s,1,player,10) and s.obbyRun.step==1)
assert(not Obby.touch(s,1,player,10.1) and s.obbyRun.started==10)
assert(not Obby.touch(s,3,player,11) and not Obby.touch(s,2,other,11))
assert(not Obby.touch(s,2,player,10.34) and s.obbyRun.step==1)
for i=2,9 do assert(Obby.touch(s,i,player,10+i)) end
assert(s.obbyRun.ready and not claim(s,other,20,100000,1000))
s.extras.rollVouchers=998
assert(not claim(s,player,20,100000,1000) and s.obbyRun.ready and s.cash==100)
s.extras.rollVouchers=997
assert(claim(s,player,20,100000,1000) and s.cash==50100 and s.extras.rollVouchers==1000 and s.obbyLastClaim==100000 and not s.obbyRun)
assert(not claim(s,player,20,100000,1000) and s.cash==50100)
assert(Obby.remaining(s.obbyLastClaim,99999)==21601 and Obby.remaining(s.obbyLastClaim,121599)==1 and Obby.remaining(s.obbyLastClaim,121600)==0)
for i=1,9 do assert(Obby.touch(s,i,player,100+i)) end
assert(not claim(s,player,110,121599,1000) and s.obbyRun.ready)
s.extras.rollVouchers=0
assert(claim(s,player,110,121600,1000) and s.cash==100100 and s.extras.rollVouchers==3)
local stale=fresh(); assert(Obby.touch(stale,1,player,0)); assert(not Obby.touch(stale,2,player,46) and stale.obbyRun==nil)
assert(Obby.touch(stale,1,player,50)); assert(not Obby.touch(stale,2,player,49) and stale.obbyRun==nil)
assert(Obby.touch(stale,1,player,100)); for i=2,9 do assert(Obby.touch(stale,i,player,100+i)) end
assert(not claim(stale,player,170,500000,1000) and stale.obbyRun==nil)
local total=fresh(); assert(Obby.touch(total,1,player,0))
for i=2,5 do assert(Obby.touch(total,i,player,(i-1)*44)) end
assert(not Obby.touch(total,6,player,181) and total.obbyRun==nil)
assert(not Obby.touch(total,0,player,1) and not Obby.touch(total,10,player,1) and not Obby.touch(total,1,nil,1))
print("Obby sequence, timing, character, cooldown, caps and replay tests passed")
-- Exact boundary: cooldown is enforced until six hours and a finished run
-- is claimable at exactly 60 seconds, but never after.
local boundary=fresh()
for i=1,9 do assert(Obby.touch(boundary,i,player,i)) end
assert(claim(boundary,player,69,200000,1000))
local again=fresh()
for i=1,9 do assert(Obby.touch(again,i,player,i)) end
assert(not claim(again,player,69.01,200000,1000) and again.cash==100 and again.extras.rollVouchers==0)
-- Starting over discards old progress; prior character cannot claim.
local restart=fresh()
for i=1,9 do assert(Obby.touch(restart,i,player,100+i)) end
assert(Obby.touch(restart,1,other,200) and restart.obbyRun.step==1)
assert(not claim(restart,player,201,200000,1000) and not claim(restart,other,201,200000,1000))
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
local function ready()
 local state={cash=100,extras={rollVouchers=0},obbyLastClaim=0,parts={},creatures={},rolls={}}
 for i=1,9 do assert(Obby.touch(state,i,player,i)) end
 return state
end
for _,roll in ipairs({1,10,11,100}) do
 local state=ready(); local calls=0
 local ok,drop=Obby.claimWithDrop(state,player,10,100000,1000,100,function() calls+=1; return roll end,function() return "head" end,spec)
 assert(ok and calls==1 and state.cash==50100 and state.extras.rollVouchers==3 and state.obbyLastClaim==100000)
 assert((drop~=nil)==(roll<=10) and #state.parts==(roll<=10 and 1 or 0))
 if drop then assert(drop.id=="head" and drop.name=="Peak Mountain" and drop.kind=="Head" and drop.locked and drop.rarity==3) end
 assert(not Obby.claimWithDrop(state,player,11,100000,1000,100,function() error("replay draw") end,function() return "x" end,spec))
end
local limited=ready(); limited.parts={{id="full"}}; local calls=0
local function win() calls+=1; return 1 end
assert(not Obby.claimWithDrop(limited,player,10,100000,1000,1,win,function() return "x" end,spec) and calls==0 and limited.cash==100)
limited.extras.rollVouchers=998
assert(not Obby.claimWithDrop(limited,player,10,100000,1000,2,win,function() return "x" end,spec) and calls==0)
limited.extras.rollVouchers=0
-- Force repeated collisions; no reward is consumed and the winning roll stays fixed.
assert(not Obby.claimWithDrop(limited,player,10,100000,1000,2,win,function() return "full" end,spec))
assert(calls==1 and limited.obbyPendingDrop==true and limited.cash==100 and limited.obbyLastClaim==0 and #limited.parts==1)
assert(not Obby.claimWithDrop(limited,player,11,100000,1000,2,function() error("must not redraw") end,function() error("id unavailable") end,spec))
-- Expiry/restart doesn't turn a failed winning grant into a new draw in this session.
assert(not Obby.claimWithDrop(limited,player,70,100000,1000,2,win,function() return "x" end,spec))
for i=1,9 do assert(Obby.touch(limited,i,player,100+i)) end
local ok,drop=Obby.claimWithDrop(limited,player,110,100000,1000,2,function() error("must not redraw") end,function() return "new-head" end,spec)
assert(ok and drop.id=="new-head" and limited.obbyPendingDrop==nil and limited.cash==50100 and #limited.parts==2 and calls==1)
for _,value in ipairs({0,101,1.5,math.huge}) do
 local invalid=ready(); assert(not Obby.claimWithDrop(invalid,player,10,100000,1000,1,function() return value end,function() return "x" end,spec))
 assert(invalid.cash==100 and invalid.obbyPendingDrop==nil and #invalid.parts==0)
end
local failed=ready(); assert(not Obby.claimWithDrop(failed,player,10,100000,1000,1,function() error("rng") end,function() return "x" end,spec) and failed.cash==100)
print("Summit drop odds boundaries, protected reward, capacity and no-reroll failures passed")
