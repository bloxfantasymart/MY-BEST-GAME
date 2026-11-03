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
local locked={{id="p",rarity=1,price=20},{id="q",rarity=1,price=40}}
assert(Inventory.setLocked(locked,"p",true) and locked[1].locked)
assert(not Inventory.canConsume(locked[1]))
assert(Inventory.bulkSell(locked,1,{"q","p"},value)==nil and #locked==2, "Bulk sale must reject every item when one is protected")
assert(not Inventory.setLocked(locked,"missing",false) and not Inventory.setLocked(locked,"p","false"))
assert(Inventory.setLocked(locked,"p",false) and Inventory.canConsume(locked[1]))
assert(Inventory.bulkSell(locked,1,{"q","p"},value)==2 and #locked==0)
print("Item protection and atomic bulk-sale tests passed")

-- Maximum upgraded plus pass capacity; the whole selection must be sellable atomically.
local full={}; local ids={}
for i=1,265 do full[i]={id=tostring(i),rarity=1,price=20}; ids[i]=tostring(i) end
local oversized=table.clone(ids); oversized[266]="extra"
assert(Inventory.bulkSell(full,1,oversized,value)==nil and #full==265)
local keyed=table.clone(ids); keyed.extra="1"
assert(Inventory.bulkSell(full,1,keyed,value)==nil and #full==265)
local sparse={[1]="1",[3]="3"}
assert(Inventory.bulkSell(full,1,sparse,value)==nil and #full==265)
full[265].locked=true
assert(Inventory.bulkSell(full,1,ids,value)==nil and #full==265)
full[265].locked=false
local sold,earned=Inventory.bulkSell(full,1,ids,value)
assert(sold==265 and earned==2650 and #full==0)
print("Full-capacity and malformed bulk-sale tests passed")
local packParts={{id="p1"},{id="p2",locked=true},{id="p3"}}
local packCreatures={{id="c1",stand=1},{id="c2",locked=true,stand=0}}
local pick={{category="part",id="p1"},{category="creature",id="c1"}}
assert(Inventory.bulkSetLocked(packParts,packCreatures,pick,true)==2)
assert(packParts[1].locked and packCreatures[1].locked)
assert(Inventory.bulkSetLocked(packParts,packCreatures,pick,true)==nil, "A stale replay must not change anything")
local stale={{category="part",id="p1"},{category="part",id="p3"}}
assert(Inventory.bulkSetLocked(packParts,packCreatures,stale,false)==nil and packParts[1].locked, "One changed item cancels the whole batch")
assert(Inventory.bulkSetLocked(packParts,packCreatures,pick,false)==2 and not packParts[1].locked and not packCreatures[1].locked)
local invalid={
 {{category="part",id="p1"},{category="part",id="p1"}},
 {{category="part",id="p1"},{category="creature",id="missing"}},
 {{category="creature",id="p1"}},
 {{category="other",id="p1"}},
 {{category="part",id={}}},
}
for _,batch in ipairs(invalid) do assert(Inventory.bulkSetLocked(packParts,packCreatures,batch,true)==nil and not packParts[1].locked) end
local sparseBatch={[1]={category="part",id="p1"},[3]={category="part",id="p3"}}
assert(Inventory.bulkSetLocked(packParts,packCreatures,sparseBatch,true)==nil)
local keyedBatch={{category="part",id="p1"}}; keyedBatch.extra={category="part",id="p3"}
assert(Inventory.bulkSetLocked(packParts,packCreatures,keyedBatch,true)==nil)
assert(Inventory.bulkSetLocked(packParts,packCreatures,pick,"true")==nil)
local massiveParts={}; local massiveCreatures={}; local batch={}
for i=1,265 do massiveParts[i]={id="p"..i}; table.insert(batch,{category="part",id="p"..i}) end
for i=1,100 do massiveCreatures[i]={id="c"..i}; table.insert(batch,{category="creature",id="c"..i}) end
local tooMany=table.clone(batch); table.insert(tooMany,{category="part",id="extra"})
assert(Inventory.bulkSetLocked(massiveParts,massiveCreatures,tooMany,true)==nil and not massiveParts[1].locked)
assert(Inventory.bulkSetLocked(massiveParts,massiveCreatures,batch,true)==365)
assert(massiveParts[265].locked and massiveCreatures[100].locked)
assert(Inventory.bulkSetLocked(massiveParts,massiveCreatures,batch,false)==365)
print("Atomic batch protection, stale selections and full inventory limits passed")
