--!strict
-- Pure permission and input validation; execution happens on the authoritative server.
local AdminService={}
local function integer(value,min,max)
 return type(value)=="number" and value==value and value>=min and value<=max and value%1==0
end
function AdminService.authorized(allowed,userId)
 if not integer(userId,1,9007199254740991) then return false end
 for _,id in ipairs(allowed) do if id==userId then return true end end
 return false
end
function AdminService.plan(allowed,userId,payload,catalogSize)
 if not AdminService.authorized(allowed,userId) or type(payload)~="table" then return nil,"Not authorized." end
 local command=payload.command
 if type(command)~="string" or #command>24 then return nil,"Invalid command." end
 if command=="event" then
  local events={Frenzy=true,Eclipse=true,Sigma=true,Storm=true}
  if type(payload.event)~="string" or not events[payload.event] then return nil,"Invalid event." end
  return {command=command,event=payload.event}
 end
 if not integer(payload.target,1,9007199254740991) then return nil,"Invalid target." end
 if command=="inspect" then
  return {command=command,target=payload.target}
 elseif command=="grantCash" then
  if not integer(payload.amount,1,1000000000000) then return nil,"Cash grant must be a whole number from 1 to 1 trillion." end
  return {command=command,target=payload.target,amount=payload.amount}
 elseif command=="setCash" then
  if not integer(payload.amount,0,1000000000000) then return nil,"Cash must be a whole number from 0 to 1 trillion." end
  return {command=command,target=payload.target,amount=payload.amount}
 elseif command=="setRebirth" then
  if not integer(payload.amount,0,100) then return nil,"Rebirth must be a whole number from 0 to 100." end
  return {command=command,target=payload.target,amount=payload.amount}
 elseif command=="grantPart" then
  if not integer(payload.index,1,catalogSize) then return nil,"Invalid catalog entry." end
  if payload.kind~="Head" and payload.kind~="Chest" and payload.kind~="Arms" and payload.kind~="Legs" then return nil,"Invalid body part type." end
  return {command=command,target=payload.target,index=payload.index,kind=payload.kind}
 elseif command=="kick" then
  return {command=command,target=payload.target}
 end
 return nil,"Unknown command."
end
return AdminService
