local function part(id,kind,rarity,mutation,locked,price,income)
 return {id=id,name="Dirt",kind=kind or "Head",rarity=rarity or 1,mutation=mutation or "Standard",locked=locked,price=price or 20,income=income or 2}
end
local value=function(p) return math.max(1,math.floor((p.price or 10)*0.5)) end
local a,b,c=part("a"),part("b"),part("c")
local protected=part("locked",nil,nil,nil,true)
local shiny=part("shiny",nil,nil,"Shiny")
local alternate=part("price",nil,nil,nil,false,30)
local multiplier=part("multiplier"); multiplier.mutationMultiplier=2
local otherKind=part("arm","Arms")
local rare1,rare2=part("rare1",nil,2),part("rare2",nil,2)
local state={cash=100,parts={a,b,c,protected,shiny,alternate,multiplier,otherKind,rare1,rare2},creatures={},rolls={}}
local function review(r,token) local q=Cleanup.review(state.parts,r or 1,0,token or "token",value); state.duplicateQuote=q; return q end
for _,invalid in ipairs({0,9,-1,1.5,0/0,math.huge}) do assert(not review(invalid)) end
assert(not Cleanup.review(state.parts,1,0,"",value))
local q=review(); assert(#q.items==2 and #q.keepers==1 and q.keepers[1].id=="a" and q.total==20)
assert(q.items[1].id=="b" and q.items[2].id=="c" and q.items[1].keeperId=="a")
assert(not Cleanup.confirm(state,"wrong",1,value) and #state.parts==10 and state.cash==100)
assert(not Cleanup.confirm(state,"token",1,value))
q=review(); assert(not Cleanup.confirm(state,"token",60,value) and #state.parts==10)
q=review(); b.locked=true; assert(not Cleanup.confirm(state,"token",1,value) and #state.parts==10 and state.cash==100); b.locked=false
q=review(); a.locked=true; assert(not Cleanup.confirm(state,"token",1,value) and #state.parts==10); a.locked=false
q=review(); a.income=3; assert(not Cleanup.confirm(state,"token",1,value)); a.income=2
q=review(); c.price=21; assert(not Cleanup.confirm(state,"token",1,value)); c.price=20
q=review(); b.mutation="Golden"; assert(not Cleanup.confirm(state,"token",1,value)); b.mutation="Standard"
q=review(); table.remove(state.parts,1); assert(not Cleanup.confirm(state,"token",1,value) and #state.parts==9); table.insert(state.parts,1,a)
q=review(); local used=ItemIds.collect(state); assert(used.a and used.b and used.c)
table.remove(state.parts,2); used=ItemIds.collect(state); assert(used.b, "Review must reserve a removed candidate ID")
table.insert(state.parts,2,b)
local new=part("new"); table.insert(state.parts,new)
assert(Cleanup.confirm(state,"token",1,value) and state.cash==120 and #state.parts==9)
assert(state.parts[1]==a and state.parts[#state.parts]==new and not Cleanup.confirm(state,"token",1,value))
q=review(2); assert(#q.items==2 and #q.keepers==2 and q.total==20)
assert(Cleanup.confirm(state,"token",1,value) and state.cash==140)
assert(state.parts[1]==a and protected.locked and shiny.mutation=="Shiny" and multiplier.mutationMultiplier==2)
-- A survivor that disappears cannot be replaced silently by another copy.
local x,y,z=part("x"),part("y"),part("z")
state={cash=0,parts={x,y,z},creatures={},rolls={}}
q=review(); table.remove(state.parts,1); table.insert(state.parts,part("new-keeper"))
assert(not Cleanup.confirm(state,"token",1,value) and state.cash==0 and #state.parts==3)
-- Distinct attributes and higher rarities cannot silently merge.
assert(not Cleanup.review({part("one"),part("different","Arms"),part("other",nil,2)},1,0,"t",value))
assert(not Cleanup.review({part("one"),part("other",nil,nil,nil,false,30)},1,0,"t",value))
-- Full-size review remains bounded and preserves the first copy.
local all={}; for i=1,265 do all[i]=part("p"..i) end
state={cash=0,parts=all,creatures={},rolls={}}; q=review()
assert(#q.items==264 and #q.keepers==1 and q.keepers[1].id=="p1")
assert(Cleanup.confirm(state,"token",1,value) and #state.parts==1 and state.parts[1].id=="p1" and state.cash==2640)
print("Duplicate cleanup eligibility, exact groups, stale state, token safety and atomic sale passed")
