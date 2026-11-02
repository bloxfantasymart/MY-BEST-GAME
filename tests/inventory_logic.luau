local function value(item) return math.floor(item.price/2) end
local parts={{id="a",rarity=1,price=20},{id="b",rarity=2,price=60},{id="c",rarity=3,price=100}}
assert(Inventory.bulkSell(parts,2,{"a","a"},value)==nil and #parts==3)
assert(Inventory.bulkSell(parts,2,{"a","missing"},value)==nil and #parts==3)
assert(Inventory.bulkSell(parts,1,{"a","b"},value)==nil and #parts==3)
assert(Inventory.bulkSell(parts,0,{"a"},value)==nil and #parts==3)
local count,total=Inventory.bulkSell(parts,2,{"a","b"},value)
assert(count==2 and total==40 and #parts==1 and parts[1].id=="c")
assert(Inventory.bulkSell(parts,2,{"a"},value)==nil and #parts==1, "Cannot sell the same item twice")
print("Bulk inventory sale validation tests passed")
