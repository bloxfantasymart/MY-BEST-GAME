--!strict
-- Per-session server-side throttle for user-requested checkpoints.
local CheckpointRequest={}
CheckpointRequest.Cooldown=60
function CheckpointRequest.begin(session,now)
 if type(now)~="number" or now~=now or now==math.huge or now==-math.huge then return false,"Save request unavailable." end
 if session.checkpointPending then return false,"A save request is already in progress." end
 local last=session.lastCheckpointRequest
 if last and now>=last and now-last<CheckpointRequest.Cooldown then return false,"Please wait before requesting another save." end
 session.checkpointPending=true; session.lastCheckpointRequest=now
 return true
end
function CheckpointRequest.finish(session)
 session.checkpointPending=false
end
return CheckpointRequest
