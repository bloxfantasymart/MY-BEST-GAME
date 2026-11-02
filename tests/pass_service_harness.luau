-- The runner inserts the service into the function below.
local calls=0
local behavior="success"
local market={}
function market:UserOwnsGamePassAsync(userId,id)
 calls+=1
 if behavior=="error" then error("service unavailable") end
 assert(userId==42)
 return id==101
end
function market:PromptGamePassPurchase(player,id)
 assert(player=="player" and id==101)
end
local game={GetService=function(_,name) assert(name=="MarketplaceService"); return market end}
local task={wait=function() end}
local function makeService()
-- INSERT_SERVICE_SOURCE
end
local PassService=makeService()
local ids={Luck=101,AutoRoll=102,KeepSlots=0,Backpack=104,VIP=105}
local order={"Luck","AutoRoll","KeepSlots","Backpack","VIP"}
local state=PassService.initial(ids,order)
assert(state.Luck=="unknown" and state.KeepSlots=="disabled")
assert(PassService.lookup(42,101)=="owned" and PassService.lookup(42,102)=="notOwned")
behavior="error"; calls=0
assert(PassService.lookup(42,101)=="unknown" and calls==3)
assert(PassService.lookup(42,0)=="invalid")
assert(PassService.prompt("player",101))
assert(not PassService.prompt("player",0))
assert(PassService.canRebirth(state))
state.KeepSlots="unknown"; assert(not PassService.canRebirth(state))
state.KeepSlots="invalid"; assert(not PassService.canRebirth(state))
assert(PassService.canRebirth(state,true) and PassService.keepSlots(state,true), "A previously confirmed entitlement protects slots")
assert(not PassService.keepSlots(state,false))
state.KeepSlots="notOwned"; assert(PassService.canRebirth(state))
state.KeepSlots="owned"; assert(PassService.canRebirth(state))
assert(PassService.capacity(state)==100 and not PassService.canAuto(state,4))
assert(PassService.canAuto(state,5))
state.Backpack="owned"; state.AutoRoll="owned"
assert(PassService.capacity(state)==200 and PassService.canAuto(state,0))
assert(PassService.capacity(state,10)==250)
state.Backpack="notOwned"; assert(PassService.capacity(state,10)==150)
ids.Luck=104 -- duplicate IDs must be treated as invalid, not sold as multiple perks.
state=PassService.initial(ids,order)
assert(state.Luck=="invalid" and state.Backpack=="invalid")
ids.KeepSlots=-1; state=PassService.initial(ids,order)
assert(state.KeepSlots=="invalid" and not PassService.canRebirth(state))
print("Gamepass policy, service failure, and ID validation tests passed")
