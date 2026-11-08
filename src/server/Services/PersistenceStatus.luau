--!strict
-- A non-sensitive description of the local session's most recent successful
-- DataStore contact. It is NOT proof that later changes or a final save persist.
local PersistenceStatus={}
PersistenceStatus.WarningAge=75
PersistenceStatus.ExpiryAge=120
function PersistenceStatus.describe(session,now)
 if not session then return {state="unavailable"} end
 if session.memory then return {state="temporary"} end
 local last=session.lastSuccess
 if type(now)~="number" or now~=now or now==math.huge or now==-math.huge
  or type(last)~="number" or last~=last or last==math.huge or last==-math.huge then return {state="unavailable"} end
 local age=math.max(0,math.floor(now-last))
 if session.closing then return {state="closing",age=age} end
 if age>=PersistenceStatus.ExpiryAge then return {state="expired",age=age} end
 if age>=PersistenceStatus.WarningAge then return {state="delayed",age=age} end
 return {state="connected",age=age}
end
return PersistenceStatus
