local function part(id,mutation)
 return {id=id,name="Dirt Boy",kind="Head",rarity=1,income=5,price=20,mutation=mutation or "Standard",mutationMultiplier=mutation and 2.5 or 1}
end
local function value(p) return math.floor((p.price or 10)/2) end
local function setup() return {parts={part("a"),part("b","Golden"),part("c")},cash=100,creatures={},rolls={}} end
local function review(s,ids,token)
 local q=SelectedSale.review(s,ids,10,token or "selected",value); s.selectedSaleQuote=q; return q
end
local s=setup()
for _,bad in ipairs({{}, {"a","a"}, {"a","missing"}, {""}, {[1]="a",bad="b"}, {[1]="a",[3]="c"}}) do
 assert(not SelectedSale.review(s,bad,10,"token",value))
end
assert(not SelectedSale.review(s,nil,10,"token",value))
assert(not SelectedSale.review(s,{"a"},10,"",value))
assert(not SelectedSale.review(s,{"a"},10,"token",function() return -1 end))
assert(not SelectedSale.review(s,{"a"},10,"token",function() return 0/0 end))
assert(not SelectedSale.review(s,{"a"},10,"token",function() return nil end))
s.parts[2].locked=true; assert(not review(s,{"a","b"})); s.parts[2].locked=false
local q=review(s,{"b","a"}); assert(q and #q.items==2 and q.items[1].id=="b" and q.items[2].id=="a" and q.total==20 and q.expires==70)
assert(q.items[1].mutation=="Golden" and q.items[1]~=s.parts[2])
assert(ItemIds.collect({parts={},creatures={},rolls={},selectedSaleQuote=q}).a)
assert(not SelectedSale.confirm(s,"wrong",11,value) and #s.parts==3 and s.cash==100)
assert(not SelectedSale.confirm(s,"selected",11,value))
q=review(s,{"a","b"}); assert(not SelectedSale.confirm(s,"selected",70,value) and #s.parts==3)
q=review(s,{"a","b"}); s.parts[2].locked=true
assert(not SelectedSale.confirm(s,"selected",11,value) and #s.parts==3 and s.cash==100); s.parts[2].locked=false
q=review(s,{"a","b"}); s.parts[2].mutation="Void"
assert(not SelectedSale.confirm(s,"selected",11,value) and #s.parts==3); s.parts[2].mutation="Golden"
q=review(s,{"a","b"}); s.parts[2].price=40
assert(not SelectedSale.confirm(s,"selected",11,value) and #s.parts==3); s.parts[2].price=20
q=review(s,{"a","b"}); table.insert(s.parts,part("new"))
local count,total=SelectedSale.confirm(s,"selected",11,value)
assert(count==2 and total==20 and #s.parts==2 and s.parts[1].id=="c" and s.parts[2].id=="new" and s.cash==100)
assert(not SelectedSale.confirm(s,"selected",11,value))
s=setup(); q=review(s,{"a","b"}); table.remove(s.parts,2)
assert(not SelectedSale.confirm(s,"selected",11,value) and #s.parts==2 and s.parts[1].id=="a")
s=setup(); q=review(s,{"a"},"selected"); s.bulkSaleQuote=Inventory.reviewBulkSale(s.parts,1,true,10,"bulk",value)
assert(not SelectedSale.confirm(s,"bulk",11,value) and #s.parts==3 and s.bulkSaleQuote)
assert(not Inventory.confirmBulkSale(s,"selected",11,value) and #s.parts==3)
s=setup(); s.parts={}; local ids={}
for i=1,265 do local id=tostring(i); s.parts[i]=part(id); ids[i]=id end
q=review(s,ids); assert(q and #q.items==265 and q.total==2650)
count,total=SelectedSale.confirm(s,"selected",11,value); assert(count==265 and total==2650 and #s.parts==0)
ids[266]="extra"; assert(not SelectedSale.review(s,ids,10,"selected",value))
print("Hand-picked sale: exact selection, malformed input, protection, staleness, atomicity, quote isolation and limits passed")
