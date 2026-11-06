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
-- Stable IDs, rather than array positions, keep saved claims meaningful if the
-- display order changes. Changing these IDs requires an explicit migration.
local known={cash1=true,vouchers3=true,uncommon=true,cash10=true,luck=true,blueprint25=true,cash40=true,epic60=true,crown90=true}
function SessionGifts.validDaily(day,claims)
 if day==nil and claims==nil then return true end -- legacy profile
 if type(day)~="number" or day~=day or day%1~=0 or day< -1 or day>1e9 or type(claims)~="table" then return false end
 local count=0
 for id,value in pairs(claims) do
  count+=1
  if count>9 or type(id)~="string" or not known[id] or value~=true then return false end
 end
 return day~=-1 or count==0
end
-- Prepare before granting anything, and commit the returned plan immediately
-- after the successful grant without yielding. The saved day never rolls back.
function SessionGifts.dailyPlan(extras,id,epoch)
 if not known[id] or type(epoch)~="number" or epoch~=epoch or epoch%1~=0 or epoch<0 or epoch>1e12
  or not SessionGifts.validDaily(extras.sessionGiftDay,extras.sessionGiftClaims) then return nil,"Gift limit unavailable." end
 local day=math.floor(epoch/86400); local saved=extras.sessionGiftDay or -1
 if day<saved then return nil,"Gifts are unavailable until the server clock catches up." end
 if day==saved and extras.sessionGiftClaims and extras.sessionGiftClaims[id] then return nil,"This gift was already claimed today. Come back after UTC midnight." end
 return {day=day,id=id}
end
function SessionGifts.commitDaily(extras,plan)
 if extras.sessionGiftDay~=plan.day then extras.sessionGiftDay=plan.day; extras.sessionGiftClaims={} end
 extras.sessionGiftClaims[plan.id]=true
end
function SessionGifts.offersExpired(expiresAt,now,count)
 return count>0 and type(expiresAt)=="number" and expiresAt>0 and now>=expiresAt
end
return SessionGifts
