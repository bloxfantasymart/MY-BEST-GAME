local function near(a,b) return math.abs(a-b)<1e-7 end
local income=function(c) return c.income*(1+0.25*(c.level-1)) end
local noEvent={sigma=false,weekend=false}
local a={stand=1,income=10,level=1,exp=0}
local b={stand=2,income=20,level=1,exp=0,ascended=true}
local loose={stand=0,income=100,level=1,exp=0}
local creatures={a,b,loose}
local earned,leveled=PlotEconomy.advance(creatures,5,income,noEvent,false,false)
assert(near(earned,(12+20)*5) and not leveled and a.exp==5 and b.exp==5 and loose.exp==0)
earned,leveled=PlotEconomy.advance(creatures,7,income,noEvent,false,false)
assert(near(earned,(12+20)*5+(15+25)*2) and leveled and a.level==2 and a.exp==2)
local u={stand=1,income=10,level=1,exp=0}
earned,leveled=PlotEconomy.advance({u},1000,income,noEvent,false,false)
assert(near(earned,10*10+12.5*10+15*10) and u.level==4 and u.exp==0 and leveled, "Long stalls cap at 30 seconds and integrate each level")
local maxed={stand=1,income=10,level=999,exp=9}
earned,leveled=PlotEconomy.advance({maxed},5,income,noEvent,true,true)
assert(maxed.level==1000 and maxed.exp==0 and leveled)
assert(near(earned,(income({income=10,level=999})+income(maxed)*4)*1.2*1.5))
local boosted={stand=1,income=10,level=1,exp=0}
earned=PlotEconomy.advance({boosted},0.5,income,{sigma=true,weekend=true},true,true)
assert(near(earned,10*0.5*3*2*1.2*1.5) and boosted.exp==0.5)
assert(PlotEconomy.advance({boosted},-1,income,noEvent,false,false)==0)
assert(PlotEconomy.advance({boosted},0/0,income,noEvent,false,false)==0)
local one={stand=1,income=10,level=1,exp=9.6}
local whole=PlotEconomy.advance({one},1,income,noEvent,false,false)
local two={stand=1,income=10,level=1,exp=9.6}
local split=PlotEconomy.advance({two},0.25,income,noEvent,false,false)+PlotEconomy.advance({two},0.75,income,noEvent,false,false)
assert(near(whole,split) and one.level==two.level and near(one.exp,two.exp), "Checkpoint frequency must not change earnings")
-- Settling immediately before placement/removal/multiplier changes confines
-- each interval to the state that actually existed during that interval.
local placed={stand=0,income=20,level=1,exp=0}
local total=PlotEconomy.advance({placed},7,income,noEvent,false,false)
placed.stand=1
total+=PlotEconomy.advance({placed},2,income,noEvent,false,false)
placed.stand=0
total+=PlotEconomy.advance({placed},9,income,noEvent,false,false)
assert(near(total,40) and near(placed.exp,2))
placed.stand=1
total+=PlotEconomy.advance({placed},1,income,noEvent,false,false)
total+=PlotEconomy.advance({placed},1,income,{sigma=true,weekend=false},false,false)
assert(near(total,120), "Changed event multiplier must only affect the later checkpoint")
local legacy={stand=1,income=10,level=1,exp=2}
assert(near(PlotEconomy.advance({legacy},0.75,income,noEvent,false,false),7.5) and near(legacy.exp,2.75))
print("Elapsed income, fractional progress, level boundaries and lag cap tests passed")
