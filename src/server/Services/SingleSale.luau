--!strict
-- A one-use, server-owned review for irreversible individual sales.
local SingleSale={}
SingleSale.Lifetime=60
local kinds={"Head","Chest","Arms","Legs"}
local partFields={"id","name","kind","rarity","income","price","mutation","mutationMultiplier"}
local creatureFields={"id","name","income","level","stand","ascended","blueprintApplied"}
local function copyFields(item,fields)
 local result={}
 for _,field in ipairs(fields) do result[field]=item[field] end
 return result
end
local function sameFields(item,snapshot,fields)
 for _,field in ipairs(fields) do if item[field]~=snapshot[field] then return false end end
 return true
end
local function snapshot(category,item)
 local result=copyFields(item,category=="part" and partFields or creatureFields)
 if category=="creature" then
  result.components={}
  for _,kind in ipairs(kinds) do result.components[kind]=copyFields(item.components[kind],partFields) end
 end
 return result
end
local function same(category,item,review)
 if not sameFields(item,review,category=="part" and partFields or creatureFields) then return false end
 if category=="creature" then
  for _,kind in ipairs(kinds) do
   if not item.components[kind] or not sameFields(item.components[kind],review.components[kind],partFields) then return false end
  end
 end
 return true
end
local function find(state,category,id)
 local items=category=="part" and state.parts or (category=="creature" and state.creatures or nil)
 if not items then return nil,nil end
 for index,item in ipairs(items) do if item.id==id then return items,index end end
 return nil,nil
end
function SingleSale.review(state,category,id,now,token,partValue,creatureValue)
 if (category~="part" and category~="creature") or type(id)~="string" or #id<1 or #id>64
  or type(token)~="string" or #token<1 or #token>64 then return nil,"Invalid sale review request." end
 local items,index=find(state,category,id)
 local item=index and items[index]
 if not item then return nil,"Item is no longer in your backpack." end
 if item.locked==true then return nil,"Unlock this item before selling." end
 if category=="creature" and item.stand~=0 then return nil,"Remove the creature from its stand before selling." end
 local value=category=="part" and partValue(item) or creatureValue(item)
 if type(value)~="number" or value~=value or value<0 or value==math.huge then return nil,"Sale value unavailable." end
 return {token=token,expires=now+SingleSale.Lifetime,category=category,item=snapshot(category,item),value=value}
end
function SingleSale.confirm(state,token,now,partValue,creatureValue)
 local quote=state.singleSaleQuote; state.singleSaleQuote=nil
 if not quote or type(token)~="string" or token~=quote.token then return nil,"Review the sale again." end
 if now>=quote.expires then return nil,"Sale review expired. Review it again." end
 local items,index=find(state,quote.category,quote.item.id)
 local item=index and items[index]
 if not item or item.locked==true or (quote.category=="creature" and item.stand~=0)
  or not same(quote.category,item,quote.item) then return nil,"Item changed. Review the sale again." end
 local value=quote.category=="part" and partValue(item) or creatureValue(item)
 if value~=quote.value then return nil,"Sale value changed. Review it again." end
 -- No yields between revalidation, removal and credit.
 table.remove(items,index); state.cash+=value
 return quote
end
return SingleSale
