local function part(kind,id)
 return {id=id,kind=kind,name="Dirt Boy",rarity=1,income=2,mutation="Standard",mutationMultiplier=1,price=10}
end
local function creature(id)
 return {id=id,name="Dirt Boy Abomination",income=10,level=10,stand=0,components={Head=part("Head",id.."h"),Chest=part("Chest",id.."c"),Arms=part("Arms",id.."a"),Legs=part("Legs",id.."l")}}
end
local function cost(c) return math.max(10000,math.floor(c.income*100)) end
local function newId() return "new-guid" end
local roster={creature("one"),creature("two"),creature("three")}
local function fail(ids,rebirth,cash)
 local result=Fusion.execute(roster,ids,rebirth,cash,cost,newId)
 assert(result==nil and #roster==3, "Failed fusion must never consume items")
end
fail({"one","two","three"},14,999999)
fail({"one","one","three"},15,999999)
fail({"one","two","missing"},15,999999)
fail({"one","two","three"},15,9999)
roster[2].locked=true; fail({"one","two","three"},15,999999); roster[2].locked=false
roster[2].stand=1; fail({"one","two","three"},15,999999); roster[2].stand=0
roster[2].level=9; fail({"one","two","three"},15,999999); roster[2].level=10
roster[2].ascended=true; fail({"one","two","three"},15,999999); roster[2].ascended=nil
roster[2].components.Head.mutation="Golden"; fail({"one","two","three"},15,999999); roster[2].components.Head.mutation="Standard"
local result,fee=Fusion.execute(roster,{"one","two","three"},15,10000,cost,newId)
assert(result and result.id=="new-guid" and result.income==50 and result.level==1 and result.ascended and fee==10000)
assert(#roster==1 and roster[1]==result)
local a=creature("a"); a.ascended=true; a.stand=1; a.income=50
local b=creature("b"); b.stand=2
local c=creature("c"); c.stand=7
local d=creature("d"); d.stand=6
local e=creature("e"); e.stand=8; e.ascended=true; e.income=50
local slots={a,b,c,d,e}
local income=function(unit) return unit.income end
local rates=PlotEconomy.rates(slots,income)
local function near(x,y) return math.abs(x-y)<0.00001 end
assert(near(rates[1],50) and near(rates[2],14) and near(rates[7],14) and near(rates[6],10) and near(rates[8],50))
assert(near(PlotEconomy.total(slots,income),138), "Neighbor bonuses add, never wrap rows")
local data={pending=0,lastLogout=100,creatures=slots}
Progression.applyOffline(data,200,income,PlotEconomy.total)
assert(data.pending==3450, "Offline earnings must include adjacent auras at 25% efficiency")
assert(data.lastLogout==0)
print("Fusion validation, aura adjacency, and offline economy tests passed")
local empty=PlotEconomy.summary({}, {sigma=false,weekend=false}, false,false)
assert(empty.placed==0 and empty.online==0 and empty.offline==0)
local snapshot=PlotEconomy.summary(rates,{sigma=true,weekend=true},true,true)
assert(snapshot.placed==5 and near(snapshot.normal,138*1.5))
assert(near(snapshot.online,138*3*2*1.2*1.5))
assert(near(snapshot.offline,138*1.5*0.25))
assert(near(PlotEconomy.multiplier({sigma=true,weekend=true},true,true),3*2*1.2*1.5))
assert(snapshot.sigma and snapshot.weekend and snapshot.vip and snapshot.statue)
print("Income summary and multiplier stacking tests passed")
