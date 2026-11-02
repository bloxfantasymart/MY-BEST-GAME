--!strict
-- Each run owns a validated, server-side copy. No DataStore or purchases are involved.
local AutoRoll={}
AutoRoll.MaxBudget=1e15
AutoRoll.MaxBatches=1000
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
 if not integer(input.maxSpend,1,AutoRoll.MaxBudget) or not integer(input.maxPrice,1,AutoRoll.MaxBudget) then
  return nil,"Enter whole-number cash limits from 1 to 1 quadrillion."
 end
 if not integer(input.maxBatches,1,AutoRoll.MaxBatches) then return nil,"Choose 1 to 1,000 batches." end
 return {rules=rules,maxSpend=input.maxSpend,maxPrice=input.maxPrice,maxBatches=input.maxBatches}
end
-- Process offers in displayed slot order. Stop before a Hold or unaffordable Buy;
-- the current and remaining offers stay available for manual review.
function AutoRoll.process(offers,parts,config,cash,remaining,capacity)
 local bought,skipped,spent=0,0,0
 while #offers>0 do
  local item=offers[1]
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
   table.insert(parts,table.remove(offers,1))
  else
   return {cash=cash,remaining=remaining,bought=bought,skipped=skipped,spent=spent,stop="Invalid auto-roll rule."}
  end
 end
 return {cash=cash,remaining=remaining,bought=bought,skipped=skipped,spent=spent}
end
return AutoRoll
