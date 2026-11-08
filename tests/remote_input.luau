assert(RemoteInput.accept("main","sync",nil))
assert(not RemoteInput.accept("main","sync",{}))
assert(not RemoteInput.accept("main","sync",0))
assert(RemoteInput.accept("main","adminOpen",nil) and RemoteInput.accept("main","adminOpen",1234))
assert(not RemoteInput.accept("main","adminOpen",0/0) and not RemoteInput.accept("main","adminOpen",math.huge))
assert(RemoteInput.accept("main","autoRoll",false) and RemoteInput.accept("main","autoRoll",{rules={"hold","skip"},maxSpend=1000}))
assert(not RemoteInput.accept("main","autoRoll",true))
assert(RemoteInput.accept("main","craftReview",{requestId=1,selection={Head="id",Chest="id2",Arms="id3",Legs="id4",useBlueprint=false,keepLast=true,standardOnly=false}}))
assert(RemoteInput.accept("main","saveStandLayout",{slot=1,entries={{id="A",stand=1}},oldSaved={{id="B",stand=2}},hadSaved=true}))
assert(RemoteInput.accept("main","discardOffers",{"a","b"}))
assert(RemoteInput.accept("main","selectedSaleConfirm",string.rep("x",64)))
assert(not RemoteInput.accept("main","selectedSaleConfirm",string.rep("x",129)))
assert(not RemoteInput.accept("main","unknown",nil) and not RemoteInput.accept("unknown","sync",nil))
assert(RemoteInput.accept("hub","directory",{requestId=1}))
assert(not RemoteInput.accept("hub","directory",nil) and not RemoteInput.accept("hub","collect",{}))
assert(not RemoteInput.accept("main",{},nil) and not RemoteInput.accept("main",string.rep("x",41),nil))
assert(not RemoteInput.accept("main","claimQuest",{key="x",day=0/0}))
assert(not RemoteInput.accept("main","claimQuest",{key="x",day=-math.huge}))
assert(not RemoteInput.accept("main","claimQuest",{[true]="x"}))
assert(not RemoteInput.accept("main","claimQuest",{[0]="x"}) and not RemoteInput.accept("main","claimQuest",{[366]="x"}))
assert(not RemoteInput.accept("main","claimQuest",{[string.rep("a",65)]="x"}))
local cycle={}; cycle.self=cycle
assert(not RemoteInput.accept("main","claimQuest",cycle))
local shared={}; assert(not RemoteInput.accept("main","claimQuest",{a=shared,b=shared}))
local nested={a={a={a={a={a={a=true}}}}}}
assert(not RemoteInput.accept("main","claimQuest",nested))
local items={}
for i=1,365 do items[i]={category=i<=265 and "part" or "creature",id=string.rep("x",63).."z"} end
assert(RemoteInput.accept("main","bulkSetItemLock",{items=items,locked=true}),"Maximum valid inventory protection batch must fit")
local ids={}; for i=1,265 do ids[i]=tostring(i) end
assert(RemoteInput.accept("main","selectedSaleReview",{ids=ids,requestId=1}))
local large={}; for i=1,401 do large["key"..i]=true end
assert(not RemoteInput.accept("main","claimQuest",large))
local huge={}; for i=1,365 do huge[i]={a=1,b=2,c=3,d=4,e=5} end
assert(not RemoteInput.accept("main","bulkSetItemLock",{items=huge}))
local player={}
for i=1,16 do
 local allowed=InteractionGate.allow(player,"remote",100+i/1000)
 if allowed then assert(not RemoteInput.accept("main","claimQuest",{key="x",day=0/0})) end
end
assert(not InteractionGate.allow(player,"remote",104.9),"Malformed spam still incurs the normal penalty")
assert(InteractionGate.allow(player,"remote",105.016))
print("Remote envelopes: malformed shapes, limits, cycles, nonfinite numbers, valid maxima and throttling passed")
