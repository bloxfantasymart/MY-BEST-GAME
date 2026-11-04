--!strict
-- Bulk sales are validated in full before any items or money change.
local Inventory={}
function Inventory.setLocked(items,id,locked)
 if type(id)~="string" or #id==0 or #id>64 or type(locked)~="boolean" then return false end
 for _,item in ipairs(items) do
  if item.id==id then item.locked=locked; return true end
 end
 return false
end
function Inventory.canConsume(item)
 return item~=nil and item.locked~=true
end
-- Buy one server-owned offer without yielding. Invalid or stale requests spend
-- nothing. Manual mutation protection defaults on and is session-only.
function Inventory.purchaseOffer(state,id,useVoucher,capacity)
 if state.autoRolling then return nil,"Stop auto-roll before buying manually." end
 if type(id)~="string" or #id<1 or #id>64 or type(useVoucher)~="boolean" then return nil,"Invalid offer request." end
 local index,item=nil,nil
 for i,offer in ipairs(state.rolls) do if offer.id==id then index=i; item=offer; break end end
 if not item or #state.parts>=capacity then return nil,"Cannot buy: check the offer and inventory space." end
 if useVoucher then
  if state.extras.rollVouchers<1 then return nil,"No free-part vouchers available." end
 elseif type(item.price)~="number" or item.price~=item.price or item.price<0 or item.price==math.huge or state.cash<item.price then
  return nil,"Cannot buy: check the offer price and cash." end
 if useVoucher then state.extras.rollVouchers-=1 else state.cash-=item.price end
 if state.manualProtectMutations~=false and ((item.mutation or "Standard")~="Standard" or (item.mutationMultiplier or 1)~=1) then item.locked=true end
 table.remove(state.rolls,index); table.insert(state.parts,item)
 if #state.rolls==0 then state.offerExpires=0 end
 return item
end
-- Snapshot-based batch protection. Validate every item before changing any.
function Inventory.bulkSetLocked(parts,creatures,items,locked)
 if type(locked)~="boolean" or type(items)~="table" or #items<1 or #items>365 then return nil end
 local length=#items; local count=0
 for key in pairs(items) do
  count+=1
  if count>365 or type(key)~="number" or key%1~=0 or key<1 or key>length then return nil end
 end
 if count~=length then return nil end
 local owned={part={},creature={}}
 for _,item in ipairs(parts) do owned.part[item.id]=item end
 for _,item in ipairs(creatures) do owned.creature[item.id]=item end
 local seen={}; local selected={}
 for _,entry in ipairs(items) do
  if type(entry)~="table" or (entry.category~="part" and entry.category~="creature")
   or type(entry.id)~="string" or #entry.id<1 or #entry.id>64 or seen[entry.id] then return nil end
  local item=owned[entry.category][entry.id]
  if not item or (item.locked==true)==locked then return nil end
  seen[entry.id]=true; table.insert(selected,item)
 end
 for _,item in ipairs(selected) do item.locked=locked end
 return #selected
end
function Inventory.bulkSell(parts,rarity,ids,valueFn)
 if type(rarity)~="number" or rarity~=rarity or rarity%1~=0 or rarity<1 or rarity>8 then return nil end
 if type(ids)~="table" or #ids<1 or #ids>265 then return nil end
 -- Reject sparse or dictionary-shaped payloads instead of silently ignoring entries.
 local length=#ids; local entries=0
 for key in pairs(ids) do
  entries+=1
  if entries>265 or type(key)~="number" or key%1~=0 or key<1 or key>length then return nil end
 end
 if entries~=length then return nil end
 local owned={}
 for _,item in ipairs(parts) do owned[item.id]=item end
 local selected={}; local count=0; local total=0
 for _,id in ipairs(ids) do
  if type(id)~="string" or #id>64 or selected[id] then return nil end
  local item=owned[id]
  if not Inventory.canConsume(item) or item.rarity>rarity then return nil end
  selected[id]=true; count+=1; total+=valueFn(item)
 end
 -- No yields between validation and removal: no partial sale or duplicate credit.
 for i=#parts,1,-1 do if selected[parts[i].id] then table.remove(parts,i) end end
 return count,total
end
-- A quote freezes the exact part identities, displayed attributes and proceeds.
-- It is session-only, expires, and is consumed even on a failed confirmation.
Inventory.BulkQuoteLifetime=300
function Inventory.reviewBulkSale(parts,rarity,standardOnly,now,token,valueFn)
 if type(rarity)~="number" or rarity~=rarity or rarity%1~=0 or rarity<1 or rarity>8
  or type(standardOnly)~="boolean" or type(token)~="string" or #token<1 or #token>64 then
  return nil,"Invalid bulk sale review request."
 end
 local quote={token=token,expires=now+Inventory.BulkQuoteLifetime,rarity=rarity,standardOnly=standardOnly,items={},total=0}
 for _,item in ipairs(parts) do
  local mutation=item.mutation or "Standard"
  if item.locked~=true and item.rarity<=rarity and (not standardOnly or (mutation=="Standard" and (item.mutationMultiplier or 1)==1)) then
   local value=valueFn(item)
   table.insert(quote.items,{id=item.id,name=item.name,kind=item.kind,rarity=item.rarity,mutation=mutation,
    multiplier=item.mutationMultiplier or 1,income=item.income,price=item.price or 10,value=value})
   quote.total+=value
  end
 end
 if #quote.items==0 then return nil,"No eligible parts match this bulk sale." end
 return quote
end
function Inventory.confirmBulkSale(state,token,now,valueFn)
 local quote=state.bulkSaleQuote; state.bulkSaleQuote=nil
 if type(quote)~="table" or type(token)~="string" or token~=quote.token then return nil,"Review the bulk sale again." end
 if now>=quote.expires then return nil,"Bulk sale review expired. Review again." end
 local owned={}; for _,item in ipairs(state.parts) do owned[item.id]=item end
 local selected={}; local count=0; local total=0
 if #quote.items<1 or #quote.items>265 then return nil,"Bulk sale validation failed." end
 for _,snapshot in ipairs(quote.items) do
  local item=owned[snapshot.id]
  if selected[snapshot.id] or not item or item.locked==true or item.name~=snapshot.name or item.kind~=snapshot.kind
   or item.rarity~=snapshot.rarity or item.rarity>quote.rarity or (item.mutation or "Standard")~=snapshot.mutation
   or (quote.standardOnly and ((item.mutation or "Standard")~="Standard" or (item.mutationMultiplier or 1)~=1))
   or (item.mutationMultiplier or 1)~=snapshot.multiplier or item.income~=snapshot.income
   or (item.price or 10)~=snapshot.price or valueFn(item)~=snapshot.value then
   return nil,"Selected parts changed. Review the bulk sale again."
  end
  selected[snapshot.id]=true; count+=1; total+=snapshot.value
 end
 if total~=quote.total then return nil,"Bulk sale validation failed." end
 -- No yields after validation; new parts not in the quote remain untouched.
 for i=#state.parts,1,-1 do if selected[state.parts[i].id] then table.remove(state.parts,i) end end
 return count,total
end
return Inventory
