--!strict
-- Server-side gamepass ownership checks. Never trust a client to declare ownership.
local MarketplaceService=game:GetService("MarketplaceService")
local PassService={}
local function validId(id)
 return type(id)=="number" and id==id and id>0 and id<=9007199254740991 and id%1==0
end
function PassService.initial(ids,order)
 local counts={}
 for _,key in ipairs(order) do
  local id=ids[key]
  if validId(id) then counts[id]=(counts[id] or 0)+1 end
 end
 local states={}
 for _,key in ipairs(order) do
  local id=ids[key]
  if id==0 then states[key]="disabled"
  elseif not validId(id) or counts[id]~=1 then states[key]="invalid"
  else states[key]="unknown" end
 end
 return states
end
function PassService.owned(states,key)
 return states[key]=="owned"
end
function PassService.capacity(states,upgrades)
 return 100+(upgrades or 0)*5+(PassService.owned(states,"Backpack") and 100 or 0)
end
function PassService.canAuto(states,rebirth)
 return rebirth>=5 or PassService.owned(states,"AutoRoll")
end
function PassService.keepSlots(states,confirmedEntitlement)
 return confirmedEntitlement==true or PassService.owned(states,"KeepSlots")
end
function PassService.canRebirth(states,confirmedEntitlement)
 return PassService.keepSlots(states,confirmedEntitlement) or states.KeepSlots=="notOwned" or states.KeepSlots=="disabled"
end
function PassService.lookup(userId,id)
 if not validId(id) then return "invalid" end
 for attempt=1,3 do
  local ok,result=pcall(function() return MarketplaceService:UserOwnsGamePassAsync(userId,id) end)
  if ok and type(result)=="boolean" then return result and "owned" or "notOwned" end
  if attempt<3 then task.wait(2) end
 end
 return "unknown"
end
function PassService.prompt(player,id)
 if not validId(id) then return false,"Invalid gamepass ID" end
 return pcall(function() MarketplaceService:PromptGamePassPurchase(player,id) end)
end
return PassService
