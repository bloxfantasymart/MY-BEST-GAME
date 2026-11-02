--!strict
-- Tracks in-flight joins, rejects new ones after shutdown starts, and ignores duplicates.
local ShutdownGate={}
function ShutdownGate.new()
 return {closed=false,pending=0,joining={}}
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
function ShutdownGate.close(gate)
 gate.closed=true
end
return ShutdownGate
