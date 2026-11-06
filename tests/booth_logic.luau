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
-- A directory is a fresh, public-only snapshot; it never includes listings or profiles.
local alice={DisplayName="Alice",UserId=12}; local bob={DisplayName="Bob",UserId=13}
local directoryBooths={
 {index=1,owner=alice,listings={"private-id-1","private-id-2"}},
 {index=2,owner=nil,listings={}},
 {index=3,owner=bob,listings={"private-id-3"}},
}
local directory=BoothLogic.directory(directoryBooths,alice)
assert(#directory==3 and directory[1].owner=="Alice" and directory[1].mine and directory[1].listed==2)
assert(directory[2].owner==nil and not directory[2].mine and directory[2].listed==0)
assert(directory[3].owner=="Bob" and not directory[3].mine and directory[3].listed==1)
for _,row in ipairs(directory) do
 for key in pairs(row) do assert(key=="index" or key=="owner" or key=="listed" or key=="mine") end
 assert(row.listings==nil and row.profile==nil and row.UserId==nil)
end
directoryBooths[1].owner=nil; directoryBooths[1].listings={}
assert(directory[1].owner=="Alice" and directory[1].listed==2, "Snapshot must not change after booth updates")
assert(BoothLogic.directory(directoryBooths,alice)[1].owner==nil)
for _,index in ipairs({-1,0,4,1.5,0/0,math.huge,"1"}) do assert(not BoothLogic.validIndex(index,3)) end
assert(BoothLogic.validIndex(1,3) and BoothLogic.validIndex(3,3))
local session={}
assert(not BoothLogic.allowTravel(session,10,false) and session.lastHubTravel==nil)
assert(BoothLogic.allowTravel(session,10,true))
assert(not BoothLogic.allowTravel(session,12.99,true) and session.lastHubTravel==10)
assert(BoothLogic.allowTravel(session,13,true))
assert(not BoothLogic.allowTravel(session,0/0,true) and session.lastHubTravel==13)
assert(BoothLogic.allowTravel(session,1,true), "Backward clock readings must not cause indefinite lockout")
print("Public booth directory, index validation, snapshot isolation and travel cooldown passed")
