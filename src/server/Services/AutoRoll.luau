--!strict
-- Each run owns a validated, server-side copy. No DataStore or purchases are involved.
local AutoRoll={}
AutoRoll.MaxBudget=1e15
AutoRoll.MaxBatches=1000
local mutations={"Shiny","Golden","Void","Glitched"}
local function integer(value,minimum,maximum)
 return type(value)=="number" and value==value and value>=minimum and value<=maximum and value%1==0
end
function AutoRoll.validate(input)
 if type(input)~="table" or type(input.rules)~="table" then return nil,"Configure all eight rarity rules." end
 local rules={}
 for rarity=1,8 do
  local rule=input.rules[rarity]
  if rule~="skip" and rule~="hold" and rule~="buy" then return nil,"Each rarity must be Skip, Hold or Buy." end
  rules[rarity]=rule
 end
 local mutationRules={}
 if input.mutationRules~=nil and type(input.mutationRules)~="table" then return nil,"Configure mutation protections." end
 for _,name in ipairs(mutations) do
  local rule=nil
  if input.mutationRules==nil then rule="hold" else rule=input.mutationRules[name] end
  if rule~="hold" and rule~="rarity" then return nil,"Each mutation must Hold or follow its rarity rule." end
  if input.mutationRules and input.mutationRules[name]==nil then return nil,"Configure every mutation rule." end
  mutationRules[name]=rule
 end
 if input.mutationRules then
  for key in pairs(input.mutationRules) do if mutationRules[key]==nil then return nil,"Unknown mutation rule." end end
 end
 if input.protectMutations~=nil and type(input.protectMutations)~="boolean" then return nil,"Invalid mutation protection setting." end
 local protectMutations=input.protectMutations~=false
 if not integer(input.maxSpend,1,AutoRoll.MaxBudget) or not integer(input.maxPrice,1,AutoRoll.MaxBudget) then
  return nil,"Enter whole-number cash limits from 1 to 1 quadrillion."
 end
 if not integer(input.maxBatches,1,AutoRoll.MaxBatches) then return nil,"Choose 1 to 1,000 batches." end
 return {rules=rules,mutationRules=mutationRules,protectMutations=protectMutations,maxSpend=input.maxSpend,maxPrice=input.maxPrice,maxBatches=input.maxBatches}
end
-- Process offers in displayed slot order. Stop before a Hold or unaffordable Buy;
-- the current and remaining offers stay available for manual review.
function AutoRoll.process(offers,parts,config,cash,remaining,capacity)
 local bought,skipped,spent=0,0,0
 while #offers>0 do
  local item=offers[1]
  local mutation=item.mutation or "Standard"
  if (mutation~="Standard" and config.mutationRules[mutation]~="rarity")
   or (mutation=="Standard" and (item.mutationMultiplier or 1)~=1) then
   return {cash=cash,remaining=remaining,bought=bought,skipped=skipped,spent=spent,stop="Mutation held for review."}
  end
  local rule=config.rules[item.rarity]
  if rule=="hold" then return {cash=cash,remaining=remaining,bought=bought,skipped=skipped,spent=spent,stop="Held offer for review."} end
  if rule=="skip" then
   table.remove(offers,1); skipped+=1
  elseif rule=="buy" then
   if #parts>=capacity then return {cash=cash,remaining=remaining,bought=bought,skipped=skipped,spent=spent,stop="Inventory is full."} end
   if item.price>config.maxPrice then return {cash=cash,remaining=remaining,bought=bought,skipped=skipped,spent=spent,stop="Offer exceeds per-part limit."} end
   if item.price>remaining then return {cash=cash,remaining=remaining,bought=bought,skipped=skipped,spent=spent,stop="Run budget reached."} end
   if item.price>cash then return {cash=cash,remaining=remaining,bought=bought,skipped=skipped,spent=spent,stop="Not enough cash."} end
   cash-=item.price; remaining-=item.price; spent+=item.price; bought+=1
   if mutation~="Standard" and config.protectMutations then item.locked=true end
   table.insert(parts,table.remove(offers,1))
  else
   return {cash=cash,remaining=remaining,bought=bought,skipped=skipped,spent=spent,stop="Invalid auto-roll rule."}
  end
 end
 return {cash=cash,remaining=remaining,bought=bought,skipped=skipped,spent=spent}
end
return AutoRoll
