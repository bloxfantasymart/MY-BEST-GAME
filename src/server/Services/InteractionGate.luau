--!strict
-- Separate per-session limits for client remotes and physical prompt events.
-- Only call after authority, health and proximity checks have passed.
local InteractionGate={}
local policies={
 remote={spacing=0.15,window=1,limit=15,penalty=5},
 prompt={spacing=0.25,window=1,limit=15,penalty=5},
}
function InteractionGate.allow(session,channel,now)
 local policy=policies[channel]
 if not policy or type(now)~="number" or now~=now or now==math.huge or now==-math.huge then return false end
 local gates=session.interactionGates
 if not gates then gates={}; session.interactionGates=gates end
 local gate=gates[channel]
 if not gate then gate={windowStart=now,count=0,last=nil,blockedUntil=0}; gates[channel]=gate end
 -- A backward monotonic-clock reading must not create an indefinite block.
 if now<gate.windowStart then gate.windowStart=now; gate.count=0; gate.last=nil; gate.blockedUntil=0 end
 if now<gate.blockedUntil then return false end
 if now-gate.windowStart>=policy.window then gate.windowStart=now; gate.count=0 end
 gate.count+=1
 if gate.count>policy.limit then gate.blockedUntil=now+policy.penalty; return false end
 if gate.last and now-gate.last<policy.spacing then return false end
 gate.last=now
 return true
end
return InteractionGate
