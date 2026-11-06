--!strict
-- Server-owned, opt-in sale of redundant Standard loose parts. Protected parts
-- never qualify as sold items or keepers. Review and confirmation do not yield.
local Cleanup={}
Cleanup.Lifetime=60
local fields={"name","kind","rarity","income"}
local function eligible(item,maxRarity)
 return item.locked~=true and item.rarity<=maxRarity and (item.mutation or "Standard")=="Standard" and (item.mutationMultiplier or 1)==1
end
local function same(a,b)
 for _,field in ipairs(fields) do if a[field]~=b[field] then return false end end
 return (a.price or 10)==(b.price or 10) and (a.mutation or "Standard")=="Standard"
  and (b.mutation or "Standard")=="Standard" and (a.mutationMultiplier or 1)==1 and (b.mutationMultiplier or 1)==1
end
local function snapshot(item)
 return {id=item.id,name=item.name,kind=item.kind,rarity=item.rarity,income=item.income,
  price=item.price or 10,mutation="Standard",mutationMultiplier=1}
end
local function finiteValue(value)
 return type(value)=="number" and value==value and value>=0 and value<math.huge
end
function Cleanup.review(parts,maxRarity,now,token,valueFn)
 if type(maxRarity)~="number" or maxRarity~=maxRarity or maxRarity%1~=0 or maxRarity<1 or maxRarity>8
  or type(token)~="string" or #token<1 or #token>64 then return nil,"Invalid duplicate review request." end
 local quote={token=token,expires=now+Cleanup.Lifetime,rarity=maxRarity,keepers={},items={},total=0}
 for _,item in ipairs(parts) do
  if eligible(item,maxRarity) then
   local keeper=nil
   for _,candidate in ipairs(quote.keepers) do if same(item,candidate) then keeper=candidate; break end end
   if not keeper then table.insert(quote.keepers,snapshot(item))
   else
    local value=valueFn(item)
    if not finiteValue(value) or not finiteValue(quote.total+value) then return nil,"Sale value unavailable." end
    local sold=snapshot(item); sold.value=value; sold.keeperId=keeper.id
    table.insert(quote.items,sold); quote.total+=value
   end
  end
 end
 if #quote.items==0 then return nil,"No eligible duplicates found. Protected or mutated parts are never included." end
 -- Only keepers associated with sold items need to be checked and displayed.
 local used={}; for _,item in ipairs(quote.items) do used[item.keeperId]=true end
 for i=#quote.keepers,1,-1 do if not used[quote.keepers[i].id] then table.remove(quote.keepers,i) end end
 return quote
end
function Cleanup.confirm(state,token,now,valueFn)
 local quote=state.duplicateQuote; state.duplicateQuote=nil
 if not quote or type(token)~="string" or token~=quote.token then return nil,"Review duplicate cleanup again." end
 if now>=quote.expires then return nil,"Duplicate review expired. Review again." end
 local owned={}; for _,item in ipairs(state.parts) do owned[item.id]=item end
 local kept={}; local sold={}; local total=0
 for _,saved in ipairs(quote.keepers) do
  local item=owned[saved.id]
  if kept[saved.id] or not item or not eligible(item,quote.rarity) or not same(item,saved) then return nil,"A kept part changed. Review again." end
  kept[saved.id]=item
 end
 for _,saved in ipairs(quote.items) do
  local item=owned[saved.id]; local keeper=kept[saved.keeperId]
  if sold[saved.id] or kept[saved.id] or not item or not keeper or not eligible(item,quote.rarity)
   or not same(item,saved) or not same(item,keeper) or valueFn(item)~=saved.value then
   return nil,"A duplicate changed. Review again."
  end
  sold[saved.id]=true; total+=saved.value
 end
 if #quote.items==0 or total~=quote.total or not finiteValue(total) then return nil,"Duplicate review invalid." end
 -- No yields after checking all items; unrelated newly acquired parts stay put.
 for i=#state.parts,1,-1 do if sold[state.parts[i].id] then table.remove(state.parts,i) end end
 state.cash+=total
 return quote
end
return Cleanup
