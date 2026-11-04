local function income(c) return c.income end
local function near(a,b) return math.abs(a-b)<1e-8 end
local function makeState()
 return {standsUnlocked=12,standLoadouts={},creatures={
  {id="a",name="Alpha",stand=1,income=10},
  {id="b",name="Beta",stand=2,income=20,ascended=true},
  {id="c",name="Gamma",stand=0,income=30,locked=true},
 }}
end
local s=makeState(); local entries=Loadouts.capture(s.creatures)
assert(Loadouts.validEntries(entries) and Loadouts.valid({["1"]=entries}))
assert(Loadouts.save(s,1,entries,false,nil))
entries[1].id="changed"; assert(s.standLoadouts["1"][1].id=="a", "Saved entries are copied")
assert(not Loadouts.save(s,1,Loadouts.capture(s.creatures),false,nil), "Overwrites require matching saved slot")
assert(not Loadouts.save(s,1,{},true,s.standLoadouts["1"]), "Stale plot snapshots do not save")
s.creatures[1].stand=0; s.creatures[2].stand=3; s.creatures[3].stand=1
local before=Loadouts.capture(s.creatures)
local q=Loadouts.review(s,1,100,"token",StandLayout.rates,income,true)
assert(q and #q.changes==3 and q.slot==1 and q.expires==160)
assert(q.changes[1].oldName=="Gamma" and q.changes[1].newName=="Alpha")
local a,b=0,0
for _,rate in pairs(StandLayout.rates(s.creatures,income)) do a+=rate*1.5 end
local expected=makeState()
for _,rate in pairs(StandLayout.rates(expected.creatures,income)) do b+=rate*1.5 end
assert(near(q.beforeIncome,a) and near(q.afterIncome,b))
assert(Loadouts.same(Loadouts.capture(s.creatures),before), "Review cannot mutate inventory")
s.layoutQuote=q
local applied=Loadouts.apply(s,"token",101)
assert(applied and Loadouts.same(Loadouts.capture(s.creatures),s.standLoadouts["1"]))
assert(s.creatures[3].stand==0 and s.creatures[3].locked==true, "Other/protected creatures survive")
assert(not Loadouts.apply(s,"token",102), "Quote is one-use")
assert(not Loadouts.review(s,1,102,"t",StandLayout.rates,income,false), "Already-active layout needs no action")
-- Every stale or invalid condition is checked before mutating anything.
s.creatures[1].stand=0; s.creatures[2].stand=3; s.creatures[3].stand=1
q=Loadouts.review(s,1,200,"t2",StandLayout.rates,income,false); s.layoutQuote=q
s.creatures[2].stand=4; local stale=Loadouts.capture(s.creatures)
assert(not Loadouts.apply(s,"t2",201) and Loadouts.same(Loadouts.capture(s.creatures),stale))
s.creatures[2].stand=3; q=Loadouts.review(s,1,200,"t3",StandLayout.rates,income,false); s.layoutQuote=q
s.standLoadouts["1"]={{id="b",stand=2}}
assert(not Loadouts.apply(s,"t3",201) and Loadouts.same(Loadouts.capture(s.creatures),before))
s.standLoadouts["1"]={{id="a",stand=1},{id="b",stand=2}}
q=Loadouts.review(s,1,200,"t4",StandLayout.rates,income,false); s.layoutQuote=q
assert(not Loadouts.apply(s,"wrong",201) and not s.layoutQuote and Loadouts.same(Loadouts.capture(s.creatures),before))
q=Loadouts.review(s,1,200,"t5",StandLayout.rates,income,false); s.layoutQuote=q
assert(not Loadouts.apply(s,"t5",260) and Loadouts.same(Loadouts.capture(s.creatures),before))
q=Loadouts.review(s,1,200,"t6",StandLayout.rates,income,false); s.layoutQuote=q
table.remove(s.creatures,1) -- "a" was unplaced, so current layout remains the same.
assert(not Loadouts.apply(s,"t6",201) and Loadouts.same(Loadouts.capture(s.creatures),before))
assert(not Loadouts.review(s,1,200,"t",StandLayout.rates,income,false))
local locked=makeState(); locked.standsUnlocked=12; locked.standLoadouts["1"]={{id="a",stand=13}}
assert(not Loadouts.review(locked,1,0,"t",StandLayout.rates,income,false))
local empty=makeState(); empty.standLoadouts["1"]={}
local clear=Loadouts.review(empty,1,0,"clear",StandLayout.rates,income,false)
assert(clear and #clear.after==0 and #clear.changes==2); empty.layoutQuote=clear
assert(Loadouts.apply(empty,"clear",1) and #Loadouts.capture(empty.creatures)==0 and #empty.creatures==3)
local current=Loadouts.capture(empty.creatures); assert(Loadouts.save(empty,2,current,false,nil))
assert(not Loadouts.delete(empty,2,{{id="x",stand=1}}) and empty.standLoadouts["2"])
assert(Loadouts.delete(empty,2,{}) and empty.standLoadouts["2"]==nil)
assert(Loadouts.valid({}))
local invalid={
 {["4"]={}}, {[1]={}}, {["1"]={{id="",stand=1}}}, {["1"]={{id="x",stand=0}}},
 {["1"]={{id="x",stand=25}}}, {["1"]={{id="x",stand=1.5}}},
 {["1"]={{id="x",stand=1},{id="x",stand=2}}}, {["1"]={{id="x",stand=2},{id="y",stand=1}}},
 {["1"]={{id="x",stand=1,extra=true}}}, {["1"]={[1]={id="x",stand=1},[3]={id="y",stand=3}}},
 {["1"]={{id=string.rep("x",65),stand=1}}}, {["1"]="invalid"},
}
for _,bad in ipairs(invalid) do assert(not Loadouts.valid(bad)) end
local full={}; for i=1,24 do full[i]={id="id"..i,stand=i} end
assert(Loadouts.valid({["1"]=full,["2"]={},["3"]=full}))
table.insert(full,{id="extra",stand=25}); assert(not Loadouts.validEntries(full))
print("Saved stand layouts, previews, stale quotes, empty layouts and replay tests passed")
local changing=makeState(); changing.standsUnlocked=24; changing.standLoadouts["1"]={{id="a",stand=13}}
changing.layoutQuote=Loadouts.review(changing,1,0,"lock",StandLayout.rates,income,false)
local prior=Loadouts.capture(changing.creatures); changing.standsUnlocked=12
assert(not Loadouts.apply(changing,"lock",1) and Loadouts.same(Loadouts.capture(changing.creatures),prior))
local overwrite=makeState(); local first=Loadouts.capture(overwrite.creatures)
assert(Loadouts.save(overwrite,1,first,false,nil))
overwrite.standLoadouts["1"]={{id="b",stand=2}}
assert(not Loadouts.save(overwrite,1,first,true,first) and overwrite.standLoadouts["1"][1].id=="b")
math.randomseed(27)
for _=1,80 do
 local st={creatures={},standsUnlocked=24,standLoadouts={}}
 for i=1,24 do table.insert(st.creatures,{id="i"..i,name="Unit "..i,stand=i,income=i,ascended=i%4==0}) end
 local target={}
 local shuffled={}; for i=1,24 do shuffled[i]=i end
 for i=24,2,-1 do local j=math.random(i); shuffled[i],shuffled[j]=shuffled[j],shuffled[i] end
 for stand=1,24 do table.insert(target,{id="i"..shuffled[stand],stand=stand}) end
 st.standLoadouts["1"]=target
 if not Loadouts.same(Loadouts.capture(st.creatures),target) then
  local review=Loadouts.review(st,1,100,"t",StandLayout.rates,income,false); assert(review)
  st.layoutQuote=review; assert(Loadouts.apply(st,"t",101))
  assert(Loadouts.same(Loadouts.capture(st.creatures),target) and #st.creatures==24)
 end
end
print("Locked-stand changes, overwrite review and randomized full-layout tests passed")
