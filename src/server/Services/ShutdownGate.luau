--!strict
-- Tracks in-flight joins, rejects new ones after shutdown starts, and ignores duplicates.
local ShutdownGate={}
function ShutdownGate.new()
 return {closed=false,pending=0,joining={},pendingDepartures=0,departing={}}
end
function ShutdownGate.begin(gate,key)
 if gate.closed or gate.joining[key] then return false end
 gate.joining[key]=true; gate.pending+=1
 return true
end
function ShutdownGate.finish(gate,key)
 if not gate.joining[key] then return false end
 gate.joining[key]=nil; gate.pending-=1
 return true
end
-- Departure saves may already be in flight when BindToClose starts.
function ShutdownGate.beginDeparture(gate,key)
 if gate.departing[key] then return false end
 gate.departing[key]=true; gate.pendingDepartures+=1
 return true
end
function ShutdownGate.finishDeparture(gate,key)
 if not gate.departing[key] then return false end
 gate.departing[key]=nil; gate.pendingDepartures-=1
 return true
end
function ShutdownGate.drained(gate,shutdownSaves)
 return gate.pending==0 and gate.pendingDepartures==0 and shutdownSaves==0
end
function ShutdownGate.close(gate)
 gate.closed=true
end
return ShutdownGate
