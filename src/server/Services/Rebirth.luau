--!strict
-- Server-only quote and validation for an explicit, one-use sacrifice.
local Rebirth={}
Rebirth.QuoteLifetime=30
local kinds={"Head","Chest","Arms","Legs"}
local function find(creatures,id)
 if type(id)~="string" or #id<1 or #id>64 then return nil end
 for index,creature in ipairs(creatures) do if creature.id==id then return index,creature end end
 return nil
end
local function componentsSnapshot(creature)
 local result={}
 for _,kind in ipairs(kinds) do
  local part=creature.components[kind]
  result[kind]={id=part.id,name=part.name,rarity=part.rarity,income=part.income,mutation=part.mutation or "Standard",multiplier=part.mutationMultiplier or 1}
 end
 return result
end
local function offersSnapshot(offers)
 local ids={}; for _,offer in ipairs(offers) do table.insert(ids,offer.id) end
 return ids
end
function Rebirth.review(state,id,canRebirth,keepSlots,now,token,targetFn,costFn)
 if state.rebirth>=100 then return nil,"Maximum rebirth reached." end
 if not canRebirth then return nil,"Keep Slots ownership is not verified. Refresh the shop and try again." end
 if state.autoRolling then return nil,"Stop auto-roll before reviewing rebirth." end
 if type(token)~="string" or #token<1 or #token>64 then return nil,"Could not create a rebirth review." end
 local index,creature=find(state.creatures,id)
 if not index then return nil,"Select an owned target creature." end
 if creature.locked then return nil,"Unprotect the selected creature before rebirth." end
 if creature.ascended then return nil,"Ascended creatures cannot be sacrificed." end
 local target=targetFn(state.rebirth).." Abomination"; local cost=costFn(state.rebirth)
 if creature.name~=target then return nil,"The selected creature is not the required target." end
 if state.cash<cost then return nil,"Not enough cash for rebirth." end
 return {token=token,expires=now+Rebirth.QuoteLifetime,id=id,rebirth=state.rebirth,cost=cost,cash=state.cash,slots=state.slots,
  keepSlots=keepSlots==true,offers=offersSnapshot(state.rolls),name=creature.name,level=creature.level,stand=creature.stand,
  income=creature.income,blueprint=creature.blueprintApplied==true,components=componentsSnapshot(creature)}
end
function Rebirth.check(state,quote,token,canRebirth,keepSlots,now,targetFn,costFn)
 if type(quote)~="table" or type(token)~="string" or token~=quote.token then return nil,"Review your rebirth again." end
 if now>=quote.expires then return nil,"The rebirth review expired. Review again." end
 local fresh,reason=Rebirth.review(state,quote.id,canRebirth,keepSlots,now,quote.token,targetFn,costFn)
 if not fresh then return nil,reason end
 if fresh.rebirth~=quote.rebirth or fresh.cost~=quote.cost or fresh.cash~=quote.cash or fresh.slots~=quote.slots
  or fresh.keepSlots~=quote.keepSlots or fresh.name~=quote.name or fresh.level~=quote.level or fresh.stand~=quote.stand
  or fresh.income~=quote.income or fresh.blueprint~=quote.blueprint or #fresh.offers~=#quote.offers then
  return nil,"Your rebirth details changed. Review again."
 end
 for i,id in ipairs(fresh.offers) do if id~=quote.offers[i] then return nil,"Your roll offers changed. Review again." end end
 for _,kind in ipairs(kinds) do
  local a,b=fresh.components[kind],quote.components[kind]
  if a.id~=b.id or a.name~=b.name or a.rarity~=b.rarity or a.income~=b.income or a.mutation~=b.mutation or a.multiplier~=b.multiplier then
   return nil,"Your selected creature changed. Review again."
  end
 end
 return find(state.creatures,quote.id)
end
-- Consume the stored quote before checking, so even a failed confirmation cannot be replayed.
function Rebirth.consume(state,token,canRebirth,keepSlots,now,targetFn,costFn)
 local quote=state.rebirthQuote; state.rebirthQuote=nil
 local index,reason=Rebirth.check(state,quote,token,canRebirth,keepSlots,now,targetFn,costFn)
 if not index then return nil,reason end
 return index,quote
end
return Rebirth
