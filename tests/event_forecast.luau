local names={"frenzy","eclipse","sigma","storm","weekend"}
for time=0,14*86400,37 do
 local f=LiveEvents.forecast(time); local flags=LiveEvents.at(time)
 assert(f.at==time)
 for _,name in ipairs(names) do
  local e=f.events[name]
  assert(e and e.startsAt<=e.endsAt and e.endsAt>time and e.active==flags[name],name.." forecast must match active event")
  assert(LiveEvents.at(e.startsAt)[name],name.." must be active at predicted start")
  assert(not LiveEvents.at(e.endsAt)[name],name.." must end at predicted boundary")
  if e.active then assert(e.startsAt<=time) else assert(e.startsAt>time) end
 end
end
-- Modern epochs, including leap-day and year-end ranges; calendar parity must
-- not depend on a client timezone or local DST.
for _,base in ipairs({1709164800,1735603200,1793664000}) do
 for time=base,base+8*86400,997 do
  local forecast=LiveEvents.forecast(time); local flags=LiveEvents.at(time)
  for _,name in ipairs(names) do
   local window=forecast.events[name]
   assert(window.active==flags[name] and LiveEvents.at(window.startsAt)[name] and not LiveEvents.at(window.endsAt)[name])
  end
 end
end
local friday=86400+17*3600; local monday=4*86400
local before=LiveEvents.forecast(friday-1).events.weekend
assert(not before.active and before.startsAt==friday and before.endsAt==monday)
local start=LiveEvents.forecast(friday).events.weekend
assert(start.active and start.endsAt==monday)
local endWeek=LiveEvents.forecast(monday).events.weekend
assert(not endWeek.active and endWeek.startsAt==friday+7*86400)
assert(LiveEvents.forecast(179).events.eclipse.active and not LiveEvents.forecast(180).events.eclipse.active)
assert(LiveEvents.forecast(900).events.sigma.active and not LiveEvents.forecast(1020).events.sigma.active)
assert(LiveEvents.forecast(1800).events.storm.active and not LiveEvents.forecast(1920).events.storm.active)
print("Event forecast and UTC transition parity tests passed")
