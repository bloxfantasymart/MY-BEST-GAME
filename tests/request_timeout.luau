local time=0; local scheduled={}
local function schedule(seconds,callback) table.insert(scheduled,{at=time+seconds,callback=callback}) end
local function advance(to)
 while true do
  local index,at=nil,math.huge
  for i,event in ipairs(scheduled) do if event.at<=to and event.at<at then index=i; at=event.at end end
  if not index then break end
  local event=table.remove(scheduled,index); time=event.at; event.callback()
 end
 time=to
end
local waiting=nil; local expired=0; local requests=0; local accepted=0
local function request(id)
 waiting=id; requests+=1
 local expected=id
 RequestTimeout.watch(schedule,function() return waiting==expected end,function() waiting=nil; expired+=1 end)
end
local function response(id)
 if waiting==id then waiting=nil; accepted+=1 end
end
request(1); advance(11.99); assert(waiting==1 and expired==0)
advance(12); assert(waiting==nil and expired==1 and requests==1,"Timeout must never automatically repeat a request")
response(1); assert(accepted==0,"A late response after timeout is ignored")
request(2); advance(13); request(3); response(2)
assert(waiting==3 and accepted==0,"An older response must not satisfy the new request")
advance(24); assert(waiting==3 and expired==1,"An old timer cannot clear a replacement request")
response(3); assert(waiting==nil and accepted==1)
advance(26); assert(expired==1,"An accepted response cannot later time out")
request(4); waiting=nil; advance(38); assert(expired==1,"Cancel or panel changes invalidate an old timer")
local first={requestId=5}; local second={requestId=6}; local current=first; local objectExpired=0
RequestTimeout.watch(schedule,function() return current==first end,function() current=nil; objectExpired+=1 end)
current=second
RequestTimeout.watch(schedule,function() return current==second end,function() current=nil; objectExpired+=1 end)
advance(50); assert(objectExpired==1 and current==nil,"Only the currently pending object expires")
print("Review timeouts, cancellation, delayed responses and replacement requests passed")
