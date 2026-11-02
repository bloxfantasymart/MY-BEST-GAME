local function offer(id,rarity,price) return {id=id,rarity=rarity,price=price} end
local rules={"skip","buy","hold","buy","skip","hold","buy","hold"}
local function config(spend,price,batches)
 return {rules=rules,maxSpend=spend or 100,maxPrice=price or 60,maxBatches=batches or 5}
end
assert(AutoRoll.validate(nil)==nil)
assert(AutoRoll.validate({rules=rules,maxSpend=0,maxPrice=10,maxBatches=1})==nil)
assert(AutoRoll.validate({rules=rules,maxSpend=0/0,maxPrice=10,maxBatches=1})==nil)
assert(AutoRoll.validate({rules=rules,maxSpend=10,maxPrice=math.huge,maxBatches=1})==nil)
assert(AutoRoll.validate({rules=rules,maxSpend=10,maxPrice=1.5,maxBatches=1})==nil)
assert(AutoRoll.validate({rules=rules,maxSpend=10,maxPrice=10,maxBatches=1001})==nil)
assert(AutoRoll.validate({rules={"skip"},maxSpend=10,maxPrice=10,maxBatches=1})==nil)
local valid=AutoRoll.validate(config())
assert(valid and valid.rules~=rules)
rules[2]="skip"; assert(valid.rules[2]=="buy"); rules[2]="buy"
local parts={}
local offers={offer("skip",1,10),offer("buy",2,30),offer("hold",3,5),offer("later",4,20)}
local result=AutoRoll.process(offers,parts,valid,200,100,100)
assert(result.cash==170 and result.remaining==70 and result.spent==30 and result.bought==1 and result.skipped==1)
assert(result.stop and #offers==2 and offers[1].id=="hold" and offers[2].id=="later" and parts[1].id=="buy")
local function blocked(offerValue,cash,budget,capacity)
 local inventory={}; local remaining={offerValue,offer("tail",4,1)}
 local r=AutoRoll.process(remaining,inventory,valid,cash,budget,capacity)
 assert(r.stop and #inventory==0 and #remaining==2 and remaining[1]==offerValue and r.cash==cash and r.remaining==budget)
end
blocked(offer("tooExpensive",2,61),100,100,100)
blocked(offer("budget",2,50),100,49,100)
blocked(offer("cash",2,50),49,100,100)
blocked(offer("full",2,10),100,100,0)
local exact={offer("exact",2,60)}; local inv={}
result=AutoRoll.process(exact,inv,valid,60,60,1)
assert(not result.stop and result.cash==0 and result.remaining==0 and #exact==0 and #inv==1)
math.randomseed(332)
for _=1,100 do
 local input={}; local initial=0
 for i=1,9 do input[i]=offer(tostring(i),math.random(1,8),math.random(1,80)); initial+=1 end
 local owned={}; local output=AutoRoll.process(input,owned,valid,200,100,5)
 assert(output.cash>=0 and output.remaining>=0 and #owned<=5)
 assert(output.spent==200-output.cash and output.spent==100-output.remaining)
 assert(#owned+#input+output.skipped==initial)
 local paid=0; for _,item in ipairs(owned) do paid+=item.price; assert(valid.rules[item.rarity]=="buy" and item.price<=valid.maxPrice) end
 assert(paid==output.spent)
end
print("Auto-roll rules, budget limits, slot order and conservation tests passed")
