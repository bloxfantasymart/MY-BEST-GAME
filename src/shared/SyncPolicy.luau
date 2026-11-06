--!strict
-- Client-only reconciliation policy. Revisions are session-local and never
-- authorize gameplay; every mutation still goes through the server.
local SyncPolicy={}
SyncPolicy.InitialRetry=2
SyncPolicy.GapRetry=5
SyncPolicy.PeriodicAge=30
SyncPolicy.PeriodicRetry=15
local function revision(value)
 return type(value)=="number" and value==value and value%1==0 and value>=0 and value<=1e15
end
function SyncPolicy.new()
 return {loaded=false,versioned=false,revision=0,target=0,lastFull=nil,lastRequest=nil}
end
function SyncPolicy.full(policy,rev,now)
 if not revision(rev) then
  -- A legacy server may not include revisions. Do not let a missing revision
  -- roll back an already-versioned session.
  if policy.versioned then return false end
  policy.loaded=true; policy.lastFull=now
  return true
 end
 if policy.versioned and rev<=policy.revision then return false end
 policy.loaded=true; policy.versioned=true; policy.revision=rev; policy.lastFull=now
 return true
end
function SyncPolicy.tick(policy,rev)
 if not revision(rev) then return policy.versioned and "stale" or "unknown" end
 if rev<policy.target or (policy.versioned and rev<policy.revision) then return "stale" end
 if rev>policy.target then policy.target=rev end
 if not policy.versioned or rev>policy.revision then return "gap" end
 return "current"
end
function SyncPolicy.behind(policy)
 return policy.versioned and policy.target>policy.revision
end
function SyncPolicy.due(policy,now)
 if type(now)~="number" or now~=now or now==math.huge or now==-math.huge then return false end
 local interval
 if not policy.loaded then interval=SyncPolicy.InitialRetry
 elseif SyncPolicy.behind(policy) then interval=SyncPolicy.GapRetry
 elseif not policy.lastFull or now<policy.lastFull or now-policy.lastFull>=SyncPolicy.PeriodicAge then interval=SyncPolicy.PeriodicRetry
 else return false end
 return policy.lastRequest==nil or now<policy.lastRequest or now-policy.lastRequest>=interval
end
function SyncPolicy.sent(policy,now)
 policy.lastRequest=now
end
return SyncPolicy
