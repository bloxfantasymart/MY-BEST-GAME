--!strict
-- Compare a reviewed list against the exact current offer order. No mutations.
local OfferSafety={}
function OfferSafety.canRoll(offers,autoRolling)
 if autoRolling then return false,"Stop auto-roll before rolling manually." end
 if #offers>0 then return false,"Buy, skip or review discarding current offers before rolling again." end
 return true
end
function OfferSafety.matches(offers,ids)
 if type(offers)~="table" or type(ids)~="table" then return false end
 local length=#ids
 if length<1 or length>9 or #offers~=length then return false end
 local entries=0
 for key in pairs(ids) do
  entries+=1
  if entries>9 or type(key)~="number" or key%1~=0 or key<1 or key>length then return false end
 end
 if entries~=length then return false end
 local seen={}
 for i,id in ipairs(ids) do
  if type(id)~="string" or #id<1 or #id>64 or seen[id] or type(offers[i])~="table" or offers[i].id~=id then return false end
  seen[id]=true
 end
 return true
end
return OfferSafety
