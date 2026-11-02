--!strict
-- Pure synchronous booth state changes. There are deliberately no trade or payment operations.
local BoothLogic={}
function BoothLogic.claim(booth,player,session)
 if booth.owner then return false,"This booth is already claimed." end
 if session.booth then return false,"You already have a booth. Release it first." end
 booth.owner=player; session.booth=booth.index
 return true
end
function BoothLogic.release(booth,player,session)
 if booth.owner~=player then return false,"Not your booth." end
 booth.owner=nil; booth.listings={}; session.booth=nil
 return true
end
function BoothLogic.add(booth,player,session,id)
 if booth.owner~=player then return false,"Not your booth." end
 if type(id)~="string" or #id>64 then return false,"Invalid creature." end
 local found=false
 for _,creature in ipairs(session.profile.creatures) do if creature.id==id then found=true; break end end
 if not found then return false,"You do not own that creature." end
 if #booth.listings>=4 then return false,"A booth can display at most four creatures." end
 for _,existing in ipairs(booth.listings) do if existing==id then return false,"Already displayed." end end
 table.insert(booth.listings,id)
 return true
end
function BoothLogic.remove(booth,player,id)
 if booth.owner~=player then return false,"Not your booth." end
 if type(id)~="string" or #id>64 then return false,"Invalid creature." end
 for i,existing in ipairs(booth.listings) do if existing==id then table.remove(booth.listings,i); return true end end
 return false,"That creature is not displayed."
end
return BoothLogic
