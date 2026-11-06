--!strict
-- Client presentation only. Flags and rewards always remain server-authoritative.
local EventPresentation={}
local events={
 {key="frenzy",text="LUCK FRENZY: 2x non-Common weight"},
 {key="eclipse",text="ECLIPSE: 50% off new offers"},
 {key="sigma",text="SIGMA: 3x online income"},
 {key="storm",text="OHIO STORM: collect your drops"},
 {key="weekend",text="WEEKEND: 1.5x luck weight and 2x income"},
}
function EventPresentation.started(previous,current)
 local names={}
 if type(current)~="table" then return names end
 for _,event in ipairs(events) do
  if current[event.key]==true and not (previous and previous[event.key]==true) then table.insert(names,event.text) end
 end
 return names
end
function EventPresentation.copy(flags)
 local result={}
 for _,event in ipairs(events) do result[event.key]=flags and flags[event.key]==true or false end
 return result
end
return EventPresentation
