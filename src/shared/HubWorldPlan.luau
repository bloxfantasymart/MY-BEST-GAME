--!strict
-- Hub-local layout data. The walls bound normal walking; buildings and lounge
-- decorations are non-colliding and never determine booth ownership.
local HubWorldPlan={}
HubWorldPlan.FloorHalf=115
HubWorldPlan.WallEdge=114
function HubWorldPlan.buildings()
 local result={}
 local along={-84,-42,0,42,84}
 for side=1,4 do
  for index,offset in ipairs(along) do
   local horizontal=side<=2
   local edge=(side==1 or side==3) and -108 or 108
   table.insert(result,{x=horizontal and offset or edge,z=horizontal and edge or offset,
    width=horizontal and 14 or 10,depth=horizontal and 10 or 14,
    height=30+((side*3+index*7)%4)*10,variant=(side+index)%3})
  end
 end
 return result
end
function HubWorldPlan.benches()
 return {{x=-14,z=12},{x=14,z=12}}
end
function HubWorldPlan.lights()
 return {{x=-42,z=-42},{x=42,z=-42},{x=-42,z=42},{x=42,z=42}}
end
return HubWorldPlan
