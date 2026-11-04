--!strict
-- A free session-only exploration buff. Refresh from now, never stack duration.
local Blessing={}
Blessing.Duration=600
Blessing.RefreshCooldown=30
function Blessing.remaining(state,now)
 return math.max(0,math.ceil((state.altarBlessingUntil or 0)-now))
end
function Blessing.activate(state,now)
 if type(now)~="number" or now~=now or now==math.huge or now==-math.huge then return false,"Blessing unavailable." end
 if state.lastAltarActivation and now-state.lastAltarActivation<Blessing.RefreshCooldown and now>=state.lastAltarActivation then
  return false,"Wait before refreshing the blessing."
 end
 state.lastAltarActivation=now
 state.altarBlessingUntil=now+Blessing.Duration
 return true
end
return Blessing
