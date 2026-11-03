local function income(c) return c.income*(1+0.25*(c.level-1)) end
local function near(a,b) return math.abs(a-b)<1e-8 end
local creatures={{id="a",stand=1,income=10,level=1},{id="b",stand=2,income=20,level=1,ascended=true},{id="c",stand=0,income=30,level=1,ascended=true}}
local preview=StandLayout.preview(creatures,7,"c","place",income,true)
assert(preview and near(preview.before,48) and near(preview.after,96) and near(preview.delta,48))
assert(near(preview.targetDelta,45) and near(preview.neighborDelta,3))
assert(#preview.changes==2 and preview.changes[1].stand==1 and preview.changes[2].stand==7)
assert(creatures[3].stand==0, "Preview must not mutate the real inventory")
assert(StandLayout.apply(creatures,7,"c","place") and creatures[3].stand==7)
assert(not StandLayout.apply(creatures,7,"c","place") and creatures[3].stand==7, "Replayed place must not remove")
assert(not StandLayout.apply(creatures,8,"c","remove") and creatures[3].stand==7)
local remove=StandLayout.preview(creatures,7,"c","remove",income,true)
assert(remove and near(remove.delta,-48) and near(remove.neighborDelta,-3))
assert(StandLayout.apply(creatures,7,"c","remove") and creatures[3].stand==0)
assert(not StandLayout.apply(creatures,7,"c","remove") and creatures[3].stand==0, "Replayed removal must not place")
assert(not StandLayout.apply(creatures,1,"c","place") and creatures[3].stand==0)
assert(not StandLayout.apply(creatures,7,"c",nil) and creatures[3].stand==0)
assert(not StandLayout.apply(creatures,7,"missing","place"))
assert(not StandLayout.apply(creatures,0,"c","place"))
assert(not StandLayout.apply(creatures,25,"c","place"))
assert(not StandLayout.apply(creatures,0/0,"c","place"))
assert(not StandLayout.apply(creatures,1.5,"c","place"))
assert(not StandLayout.apply(creatures,7,{},"place"))
assert(not StandLayout.preview(creatures,1,"c","place",income,false))
-- Grid boundaries never wrap between stand 6 and stand 7.
local edge={{id="x",stand=6,income=10,level=1},{id="y",stand=0,income=10,level=1,ascended=true}}
local p=StandLayout.preview(edge,7,"y","place",income,false)
assert(near(p.neighborDelta,0) and near(p.delta,10))
-- Compare every position and both statue modes against actual server economy rates.
for stand=1,24 do
 for _,statue in ipairs({false,true}) do
  local list={{id="x",stand=1,income=10,level=3,ascended=true},{id="y",stand=24,income=25,level=2},{id="z",stand=0,income=50,level=4,ascended=true}}
  if stand~=1 and stand~=24 then
   local plan=StandLayout.preview(list,stand,"z","place",income,statue)
   local before=PlotEconomy.total(list,income)*(statue and 1.5 or 1)
   assert(StandLayout.apply(list,stand,"z","place"))
   local after=PlotEconomy.total(list,income)*(statue and 1.5 or 1)
   assert(near(plan.before,before) and near(plan.after,after) and near(plan.delta,after-before))
   assert(near(plan.targetDelta+plan.neighborDelta,plan.delta))
  end
 end
end
print("Stand preview parity, adjacency boundaries, intent, replay and no-mutation tests passed")
local four={}
for _,n in ipairs({2,7,9,14}) do table.insert(four,{id="n"..n,stand=n,income=20,level=1,ascended=true}) end
table.insert(four,{id="center",stand=0,income=10,level=1,ascended=true})
local surrounded=StandLayout.preview(four,8,"center","place",income,false)
assert(near(surrounded.before,80) and near(surrounded.after,114) and near(surrounded.targetDelta,18) and near(surrounded.neighborDelta,16))
assert(#surrounded.changes==5 and four[5].stand==0)
