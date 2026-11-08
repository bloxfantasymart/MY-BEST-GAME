--!strict
-- Explicitly selected loose parts only. The shared bulk-sale revalidator
-- checks every captured attribute and removes all items without yielding.
local Inventory=require(script.Parent.Inventory)
local SelectedSale={}
SelectedSale.Lifetime=60
SelectedSale.MaxItems=265
function SelectedSale.review(state,ids,now,token,valueFn)
 if type(ids)~="table" then return nil,"Invalid selection." end
 local length=#ids; if length<1 or length>SelectedSale.MaxItems then return nil,"Select between 1 and 265 parts." end
 local count=0
 for key in pairs(ids) do
  count+=1
  if count>SelectedSale.MaxItems or type(key)~="number" or key%1~=0 or key<1 or key>length then return nil,"Invalid selection." end
 end
 if count~=length then return nil,"Invalid selection." end
 local owned={}; for _,part in ipairs(state.parts) do owned[part.id]=part end
 local seen={}; local selected={}
 for _,id in ipairs(ids) do
  if type(id)~="string" or #id<1 or #id>64 or seen[id] then return nil,"Invalid or duplicate selected part." end
  seen[id]=true
  local part=owned[id]
  if not part or part.locked==true then return nil,"A selected part is missing or protected. Review your selection." end
  local value=valueFn(part)
  if type(value)~="number" or value~=value or value<0 or value==math.huge then return nil,"Sale value unavailable." end
  table.insert(selected,part)
 end
 local quote,reason=Inventory.reviewBulkSale(selected,8,false,now,token,valueFn)
 if not quote then return nil,reason end
 -- An unavailable or invalid sale value must never generate credit.
 if type(quote.total)~="number" or quote.total~=quote.total or quote.total<0 or quote.total==math.huge then return nil,"Sale value unavailable." end
 for _,item in ipairs(quote.items) do
  if type(item.value)~="number" or item.value~=item.value or item.value<0 or item.value==math.huge then return nil,"Sale value unavailable." end
 end
 quote.expires=now+SelectedSale.Lifetime
 return quote
end
function SelectedSale.confirm(state,token,now,valueFn)
 -- Keep independent quote slots so a bulk or single-sale token cannot be used
 -- for this action. Alias the parts array, not the actual state quote field.
 local proxy={parts=state.parts,bulkSaleQuote=state.selectedSaleQuote}
 state.selectedSaleQuote=nil
 return Inventory.confirmBulkSale(proxy,token,now,valueFn)
end
return SelectedSale
