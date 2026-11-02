--!strict
-- The caller supplies monotonic server session time and owns the claims table.
local SessionGifts={}
function SessionGifts.find(gifts,claims,id,elapsed)
 if type(id)~="string" or #id>32 then return nil,"Invalid gift." end
 if type(elapsed)~="number" or elapsed~=elapsed or elapsed<0 or elapsed==math.huge then return nil,"Invalid session time." end
 for _,gift in ipairs(gifts) do
  if gift.id==id then
   if claims[id] then return nil,"This session gift was already claimed." end
   if elapsed<gift.seconds then return nil,"Keep playing to unlock this gift." end
   return gift
  end
 end
 return nil,"Unknown gift."
end
function SessionGifts.offersExpired(expiresAt,now,count)
 return count>0 and type(expiresAt)=="number" and expiresAt>0 and now>=expiresAt
end
return SessionGifts
