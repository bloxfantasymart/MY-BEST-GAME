--!strict
-- Online-only, server-owned timer. There is no catch-up collection after a delay.
local AutoCollector={}
AutoCollector.RequiredRebirth=10
AutoCollector.Interval=10
function AutoCollector.new(enabled,rebirth,now)
 return {enabled=enabled==true and rebirth>=AutoCollector.RequiredRebirth,nextAt=now+AutoCollector.Interval}
end
function AutoCollector.set(state,enabled,rebirth,now)
 if type(enabled)~="boolean" then return false,"Invalid auto-collector setting." end
 if enabled and rebirth<AutoCollector.RequiredRebirth then return false,"Auto-collector requires rebirth 10." end
 state.enabled=enabled; state.nextAt=now+AutoCollector.Interval
 return true
end
function AutoCollector.due(state,rebirth,now,pending)
 if not state.enabled then return false end
 if rebirth<AutoCollector.RequiredRebirth then state.enabled=false; return false end
 if now<state.nextAt then return false end
 state.nextAt=now+AutoCollector.Interval
 return pending>=1
end
return AutoCollector
