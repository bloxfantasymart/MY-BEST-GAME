--!strict
-- Prepare every offer before consuming a token or replacing session state.
local ItemIds=require(script.Parent.ItemIds)
local MultiRoll={}
MultiRoll.TokenSlots=9
function MultiRoll.create(state,useToken,now,generate,makeOffer)
 if type(useToken)~="boolean" then return nil,"Invalid roll request." end
 if useToken and state.extras.multiRollTokens<1 then return nil,"No multi-roll tokens available." end
 local count=useToken and MultiRoll.TokenSlots or state.slots
 local offers,reason=ItemIds.prepareBatch(state,count,generate,makeOffer)
 if not offers then return nil,reason end
 -- No yields between preparation and committing offers and token.
 if useToken then state.extras.multiRollTokens-=1 end
 state.rolls=offers; state.offerExpires=now+60
 return count
end
return MultiRoll
