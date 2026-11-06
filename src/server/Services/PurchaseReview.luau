--!strict
-- Session-only reviews of cash or voucher offer purchases. Callers validate
-- location, data health and rate limits; no function here yields.
local PurchaseReview={}
PurchaseReview.Lifetime=60
local fields={"id","name","kind","rarity","income","price","mutation","mutationMultiplier","rarityChance","exactChance","locked"}
local function snapshot(item)
 local copy={}
 for _,field in ipairs(fields) do copy[field]=item[field] end
 return copy
end
local function same(item,copy)
 for _,field in ipairs(fields) do if item[field]~=copy[field] then return false end end
 return true
end
local function find(state,id)
 for _,offer in ipairs(state.rolls) do if offer.id==id then return offer end end
 return nil
end
local function validate(state,item,voucher,capacity,now)
 if state.autoRolling then return false,"Stop auto-roll before buying manually." end
 if not item then return false,"Offer is no longer available." end
 if type(state.offerExpires)~="number" or state.offerExpires~=state.offerExpires or now>=state.offerExpires then return false,"Offer expired." end
 if #state.parts>=capacity then return false,"Free part inventory space first." end
 if type(item.price)~="number" or item.price~=item.price or item.price<0 or item.price==math.huge then return false,"Offer price unavailable." end
 if voucher then
  if state.extras.rollVouchers<1 then return false,"No free-part vouchers available." end
 elseif state.cash<item.price then return false,"Not enough cash for this offer." end
 return true
end
function PurchaseReview.review(state,id,voucher,capacity,now,token)
 if type(id)~="string" or #id<1 or #id>64 or type(voucher)~="boolean"
  or type(token)~="string" or #token<1 or #token>64 then return nil,"Invalid purchase review request." end
 local item=find(state,id)
 local ok,reason=validate(state,item,voucher,capacity,now)
 if not ok then return nil,reason end
 local protect=state.manualProtectMutations~=false
 local willProtect=item.locked==true or (protect and ((item.mutation or "Standard")~="Standard" or (item.mutationMultiplier or 1)~=1))
 return {token=token,expires=math.min(now+PurchaseReview.Lifetime,state.offerExpires),item=snapshot(item),voucher=voucher,
  protectMutations=protect,willProtect=willProtect}
end
function PurchaseReview.confirm(state,token,capacity,now,inventory)
 local quote=state.purchaseQuote; state.purchaseQuote=nil
 if not quote or quote.kind=="all" or type(quote.item)~="table" or type(token)~="string" or token~=quote.token then return nil,"Review the purchase again." end
 if now>=quote.expires then return nil,"Purchase review or offer expired. Review again." end
 local item=find(state,quote.item.id)
 local ok,reason=validate(state,item,quote.voucher,capacity,now)
 if not ok then return nil,reason end
 if not same(item,quote.item) or (state.manualProtectMutations~=false)~=quote.protectMutations then
  return nil,"Offer or protection setting changed. Review again."
 end
 -- The inventory service checks eligibility again and performs the purchase
 -- without yielding. It spends the reviewed payment and consumes the offer once.
 return inventory.purchaseOffer(state,quote.item.id,quote.voucher,capacity)
end
-- Optional all-cash batch purchase. The exact offer order and all item fields
-- are captured; no vouchers are spent and no partial purchase is possible.
function PurchaseReview.reviewAll(state,capacity,now,token)
 if type(token)~="string" or #token<1 or #token>64 then return nil,"Invalid batch review request." end
 if #state.rolls<2 or #state.rolls>9 then return nil,"A batch needs two to nine offers." end
 if #state.parts+#state.rolls>capacity then return nil,"Free enough part inventory space for every offer." end
 local valid,reason=validate(state,state.rolls[1],false,capacity,now)
 if not valid then return nil,reason end
 local protect=state.manualProtectMutations~=false
 local quote={kind="all",token=token,expires=math.min(now+PurchaseReview.Lifetime,state.offerExpires),protectMutations=protect,items={},ids={},total=0}
 local seen={}
 for _,item in ipairs(state.rolls) do
  local ok,reason=validate(state,item,false,capacity,now)
  if not ok then return nil,reason end
  if type(item.id)~="string" or #item.id<1 or #item.id>64 or seen[item.id] then return nil,"Invalid or repeated offer." end
  seen[item.id]=true
  local copy=snapshot(item)
  copy.willProtect=item.locked==true or (protect and ((item.mutation or "Standard")~="Standard" or (item.mutationMultiplier or 1)~=1))
  table.insert(quote.items,copy); table.insert(quote.ids,item.id); quote.total+=item.price
  if quote.total~=quote.total or quote.total==math.huge then return nil,"Batch price unavailable." end
 end
 if state.cash<quote.total then return nil,"Not enough cash to buy every offer." end
 return quote
end
function PurchaseReview.confirmAll(state,token,capacity,now)
 local quote=state.purchaseQuote; state.purchaseQuote=nil
 if not quote or quote.kind~="all" or type(token)~="string" or token~=quote.token then return nil,"Review the batch again." end
 if now>=quote.expires then return nil,"Batch review or offers expired. Review again." end
 if state.autoRolling or (state.manualProtectMutations~=false)~=quote.protectMutations then return nil,"Auto-roll or protection setting changed. Review again." end
 if #state.rolls~=#quote.items or #state.rolls<2 or #state.rolls>9 or #state.parts+#state.rolls>capacity then return nil,"Offers or available space changed. Review again." end
 local total=0; local seen={}
 for index,item in ipairs(state.rolls) do
  local saved=quote.items[index]
  local ok,reason=validate(state,item,false,capacity,now)
  if not ok then return nil,reason end
  if not saved or seen[item.id] or not same(item,saved) then return nil,"Offers changed. Review again." end
  seen[item.id]=true; total+=item.price
 end
 if total~=quote.total or state.cash<total then return nil,"Batch price or cash changed. Review again." end
 -- All checks are complete; no yields before the cash, parts and offer update.
 state.cash-=total
 for index,item in ipairs(state.rolls) do
  if quote.items[index].willProtect then item.locked=true end
  table.insert(state.parts,item)
 end
 state.rolls={}; state.offerExpires=0
 return quote
end
return PurchaseReview
