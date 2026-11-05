--!strict
-- An optional free-resource conversion, not a purchase. Quotes are session-only.
local Refinery={}
Refinery.CostPerBox=100
Refinery.MaxBatch=10
Refinery.Lifetime=60
function Refinery.review(extras,quantity,now,token,maxBoxes)
 if type(quantity)~="number" or quantity~=quantity or quantity%1~=0 or quantity<1 or quantity>Refinery.MaxBatch
  or type(token)~="string" or #token<1 or #token>64 then return nil,"Invalid refinery review." end
 local cost=quantity*Refinery.CostPerBox
 if extras.scrap<cost then return nil,"Not enough scrap." end
 if extras.uncommonBoxes+quantity>maxBoxes then return nil,"Open some Uncommon Mystery Boxes first." end
 return {token=token,expires=now+Refinery.Lifetime,quantity=quantity,cost=cost,scrap=extras.scrap,boxes=extras.uncommonBoxes}
end
function Refinery.confirm(state,token,now,maxBoxes)
 local quote=state.refineQuote; state.refineQuote=nil
 if not quote or type(token)~="string" or token~=quote.token then return nil,"Review the refinery again." end
 if now>=quote.expires then return nil,"Refinery review expired. Review again." end
 local extras=state.extras
 if extras.scrap~=quote.scrap or extras.uncommonBoxes~=quote.boxes or extras.scrap<quote.cost
  or extras.uncommonBoxes+quote.quantity>maxBoxes then return nil,"Scrap or box inventory changed. Review again." end
 -- No yields between checking and applying the entire conversion.
 extras.scrap-=quote.cost; extras.uncommonBoxes+=quote.quantity
 return quote
end
return Refinery
