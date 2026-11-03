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
local function part(id,rarity,mutation,price,locked)
 return {id=id,name="Dirt Boy",kind="Head",rarity=rarity,mutation=mutation,mutationMultiplier=mutation=="Golden" and 2.5 or 1,income=2,price=price,locked=locked}
end
local inventory={parts={part("s",1,"Standard",20),part("legacy",1,nil,40),part("g",1,"Golden",60),part("r",2,"Standard",80),part("locked",1,"Standard",100,true)}}
local quote=Inventory.reviewBulkSale(inventory.parts,1,true,100,"one",value)
assert(quote and #quote.items==2 and quote.total==30 and quote.expires==400)
assert(quote.items[2].mutation=="Standard" and quote.items[1].value==10)
inventory.bulkSaleQuote=quote
-- New eligible parts are never added to an already displayed quote.
table.insert(inventory.parts,part("new",1,"Standard",200))
local qty,paid=Inventory.confirmBulkSale(inventory,"one",101,value)
assert(qty==2 and paid==30 and #inventory.parts==4 and inventory.parts[4].id=="new")
assert(Inventory.confirmBulkSale(inventory,"one",102,value)==nil)
quote=Inventory.reviewBulkSale(inventory.parts,1,false,200,"two",value)
assert(quote and #quote.items==2 and quote.total==130)
inventory.bulkSaleQuote=quote
inventory.parts[1].locked=true
assert(not Inventory.confirmBulkSale(inventory,"two",201,value) and #inventory.parts==4 and not inventory.bulkSaleQuote)
inventory.parts[1].locked=false
inventory.bulkSaleQuote=quote
assert(not Inventory.confirmBulkSale(inventory,"bad",201,value) and not inventory.bulkSaleQuote)
inventory.bulkSaleQuote=quote
assert(not Inventory.confirmBulkSale(inventory,"two",500,value) and #inventory.parts==4)
local keys={"name","kind","rarity","mutation","mutationMultiplier","income","price"}
local replacements={"Changed","Legs",2,"Void",4,5,61}
for i,key in ipairs(keys) do
 local fresh={parts={part("x",1,"Golden",60),part("y",1,"Standard",20)}}
 fresh.bulkSaleQuote=Inventory.reviewBulkSale(fresh.parts,1,false,200,"t",value)
 fresh.parts[1][key]=replacements[i]
 assert(not Inventory.confirmBulkSale(fresh,"t",201,value) and #fresh.parts==2 and not fresh.bulkSaleQuote,key.." change must cancel entire sale")
end
local missing={parts={part("x",1,"Standard",20),part("y",1,"Standard",20)}}
missing.bulkSaleQuote=Inventory.reviewBulkSale(missing.parts,1,true,0,"t",value)
table.remove(missing.parts,1)
assert(not Inventory.confirmBulkSale(missing,"t",1,value) and #missing.parts==1)
assert(not Inventory.reviewBulkSale(inventory.parts,1,"true",0,"t",value))
assert(not Inventory.reviewBulkSale(inventory.parts,0,true,0,"t",value))
assert(not Inventory.reviewBulkSale(inventory.parts,9,true,0,"t",value))
assert(not Inventory.reviewBulkSale({},1,true,0,"t",value))
local cap={parts={}}
for i=1,265 do table.insert(cap.parts,part("s"..i,1,"Standard",20)) end
cap.bulkSaleQuote=Inventory.reviewBulkSale(cap.parts,1,true,0,"cap",value)
assert(#cap.bulkSaleQuote.items==265 and cap.bulkSaleQuote.total==2650)
assert(Inventory.confirmBulkSale(cap,"cap",299,value)==265 and #cap.parts==0)
print("Server bulk sale reviews, mutation defaults, stale state, expiration and replay passed")
local unusual=part("odd",1,"Standard",20); unusual.mutationMultiplier=6
assert(not Inventory.reviewBulkSale({unusual},1,true,0,"t",value), "Inconsistent Standard multiplier must not be included by the safer default")
assert(Inventory.reviewBulkSale({unusual},1,false,0,"t",value))
local corrupt={parts={part("v",1,"Standard",20)}}
corrupt.bulkSaleQuote=Inventory.reviewBulkSale(corrupt.parts,1,true,0,"t",value)
corrupt.bulkSaleQuote.total=999
assert(not Inventory.confirmBulkSale(corrupt,"t",1,value) and #corrupt.parts==1, "Mismatch must be detected before removal")
local includeMutations={parts={part("shiny",1,"Golden",60),part("protected",1,"Standard",20,true),part("high",2,"Standard",20)}}
includeMutations.bulkSaleQuote=Inventory.reviewBulkSale(includeMutations.parts,1,false,0,"all",value)
local soldAll,cashAll=Inventory.confirmBulkSale(includeMutations,"all",1,value)
assert(soldAll==1 and cashAll==30 and #includeMutations.parts==2 and includeMutations.parts[1].id=="protected")
