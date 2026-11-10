--!strict
-- A timeout only dismisses a still-current client request. It never repeats
-- or commits an action, and a later response must still match the request ID.
local RequestTimeout={}
RequestTimeout.Seconds=12
function RequestTimeout.watch(schedule,isCurrent,onTimeout)
 schedule(RequestTimeout.Seconds,function()
  if isCurrent() then onTimeout() end
 end)
end
return RequestTimeout
