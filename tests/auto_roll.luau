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
local function withMutation(id,rarity,price,mutation,multiplier)
 return {id=id,rarity=rarity,price=price,mutation=mutation,mutationMultiplier=multiplier}
end
-- Older clients with no mutation map fail safely to hold every non-Standard mutation.
local defaults=AutoRoll.validate(config())
for _,name in ipairs({"Shiny","Golden","Void","Glitched"}) do
 assert(defaults.mutationRules[name]=="hold")
 for _,rarity in ipairs({1,2,3}) do
  local offered={withMutation(name,rarity,10,name),offer("tail",2,10)}
  local owned={}; local r=AutoRoll.process(offered,owned,defaults,100,100,100)
  assert(r.stop=="Mutation held for review." and #offered==2 and #owned==0 and r.spent==0)
 end
end
local settings=config(); settings.mutationRules={Shiny="rarity",Golden="hold",Void="hold",Glitched="hold"}
local guarded=AutoRoll.validate(settings); assert(guarded)
settings.mutationRules.Shiny="hold"; assert(guarded.mutationRules.Shiny=="rarity")
local mix={withMutation("skipShiny",1,10,"Shiny"),withMutation("buyShiny",2,30,"Shiny"),withMutation("holdGold",1,10,"Golden"),offer("tail",2,5)}
local got={}; local result2=AutoRoll.process(mix,got,guarded,100,100,100)
assert(result2.skipped==1 and result2.bought==1 and result2.spent==30 and result2.stop=="Mutation held for review.")
assert(#mix==2 and mix[1].id=="holdGold" and mix[2].id=="tail" and got[1].id=="buyShiny")
local unknown={withMutation("unknown",1,10,"FutureMutation"),offer("tail",2,5)}
assert(AutoRoll.process(unknown,{},guarded,100,100,100).stop=="Mutation held for review." and #unknown==2)
local odd={withMutation("odd",1,10,"Standard",6)}
assert(AutoRoll.process(odd,{},guarded,100,100,100).stop=="Mutation held for review." and #odd==1)
for _,bad in ipairs({false,"hold",{}, {Shiny="hold",Golden="hold",Void="hold"}, {Shiny=false,Golden="hold",Void="hold",Glitched="hold"}, {Shiny="skip",Golden="hold",Void="hold",Glitched="hold"}, {Shiny="hold",Golden="hold",Void="hold",Glitched="hold",Other="rarity"}}) do
 local request=config(); request.mutationRules=bad; assert(AutoRoll.validate(request)==nil)
end
print("Mutation hold overrides, compatibility, malformed maps and conservation passed")
local names={}
for _,mutation in ipairs(Config.Mutations) do
 if mutation.name~="Standard" then
  assert(defaults.mutationRules[mutation.name]=="hold", "Configured mutations must have an explicit safe default")
  names[mutation.name]=true
 end
end
for name in pairs(defaults.mutationRules) do assert(names[name], "Remove obsolete mutation rules when updating Config") end
-- When explicitly allowed to follow rarity, automatically bought mutations
-- are protected by default before they enter inventory.
local mutated=config(); mutated.mutationRules={Shiny="rarity",Golden="rarity",Void="rarity",Glitched="rarity"}
local protective=AutoRoll.validate(mutated); assert(protective.protectMutations==true)
local purchases={withMutation("mutated",2,30,"Golden",2.5),withMutation("plain",2,20,"Standard",1)}
local backpack={}; local bought=AutoRoll.process(purchases,backpack,protective,100,100,100)
assert(bought.bought==2 and bought.spent==50 and backpack[1].locked==true and not backpack[2].locked)
mutated.protectMutations=false
local optedOut=AutoRoll.validate(mutated); assert(optedOut and not optedOut.protectMutations)
local free={withMutation("g",2,10,"Golden",2.5)}; local unprotected={}
AutoRoll.process(free,unprotected,optedOut,100,100,100)
assert(#unprotected==1 and not unprotected[1].locked)
mutated.protectMutations="true"; assert(AutoRoll.validate(mutated)==nil)
mutated.protectMutations=0; assert(AutoRoll.validate(mutated)==nil)
print("Automatic mutation protection, opt-out and validation passed")
-- Exhaustively exercise hold precedence and conservation for all combinations.
for _,mutation in ipairs({"Shiny","Golden","Void","Glitched"}) do
 for _,rarityAction in ipairs({"skip","hold","buy"}) do
  for _,mutationAction in ipairs({"hold","rarity"}) do
   for _,protect in ipairs({true,false}) do
    local request=config(); request.rules={rarityAction,"hold","hold","hold","hold","hold","hold","hold"}
    request.mutationRules={Shiny="hold",Golden="hold",Void="hold",Glitched="hold"}
    request.mutationRules[mutation]=mutationAction; request.protectMutations=protect
    local policy=AutoRoll.validate(request)
    local mixed={withMutation("first",1,10,mutation,1.5),offer("tail",2,1)}; local inv={}
    local outcome=AutoRoll.process(mixed,inv,policy,100,100,10)
    if mutationAction=="hold" or rarityAction=="hold" then
     assert(#mixed==2 and #inv==0 and outcome.spent==0 and outcome.stop)
    elseif rarityAction=="skip" then
     assert(#mixed==1 and #inv==0 and outcome.skipped==1 and outcome.stop)
    else
     assert(#mixed==1 and #inv==1 and outcome.bought==1 and outcome.spent==10 and (inv[1].locked==true)==protect)
    end
   end
  end
 end
end
print("Mutation safety precedence and accounting across every rule combination passed")
