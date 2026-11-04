local function part(id,kind,mutation,locked)
 return {id=id,name="Dirt",kind=kind,rarity=1,income=2,price=20,mutation=mutation,locked=locked}
end
local function creature(id,mut,locked,stand)
 return {id=id,name="Dirt Abomination",level=10,stand=stand,locked=locked,components={Head=part(id.."h","Head",mut,false)}}
end
local partValue=function(p) return p.price/2 end
local creatureValue=function(_) return 40 end
local parts={part("1","Head",nil,false),part("2","Chest","Golden",false),part("3","Head","Void",true)}
local creatures={creature("a","Golden",false,1),creature("b",nil,false,0),creature("c","Void",true,0)}
local report=InventorySummary.build(parts,creatures,2,partValue,creatureValue)
assert(report.parts==3 and report.freeParts==0 and report.creatures==3 and report.freeCreatures==97)
assert(report.protectedParts==1 and report.protectedCreatures==1 and report.placed==1)
assert(report.mutatedParts==2 and report.unprotectedMutatedParts==1 and report.mutatedCreatures==2 and report.unprotectedMutatedCreatures==1)
assert(report.available.Head==1 and report.available.Chest==1 and report.available.Arms==0)
assert(report.eligiblePartValue==20 and report.eligibleCreatureValue==40)
assert(#report.protect.items==2 and report.protect.parts==1 and report.protect.creatures==1)
assert(Inventory.bulkSetLocked(parts,creatures,report.protect.items,true)==2)
assert(parts[2].locked and creatures[1].locked and creatures[1].stand==1)
assert(not Inventory.bulkSetLocked(parts,creatures,report.protect.items,true))
local new=InventorySummary.build(parts,creatures,5,partValue,creatureValue)
assert(#new.protect.items==0 and new.freeParts==2 and report.protect.parts==1)
-- Non-standard multipliers and unknown future mutation names are protected too.
local unusual=part("u","Arms","Standard",false); unusual.mutationMultiplier=2
local future=part("f","Legs","New Mutation",false)
new=InventorySummary.build({unusual,future},{},2,partValue,creatureValue)
assert(new.mutatedParts==2 and #new.protect.items==2)
-- A captured batch must fail atomically if any selected item is removed or changed to protected.
local a,b=part("a","Head","Shiny",false),part("b","Legs","Golden",false)
local list={a,b}; local captured=InventorySummary.build(list,{},10,partValue,creatureValue).protect
b.locked=true
assert(not Inventory.bulkSetLocked(list,{},captured.items,true) and not a.locked)
b.locked=false; table.remove(list,2)
assert(not Inventory.bulkSetLocked(list,{},captured.items,true) and not a.locked)
-- At the maximum capacity every selected identity fits the server batch bound.
local maxParts={}; local maxCreatures={}
for i=1,265 do maxParts[i]=part("part-"..i,"Head","Void",false) end
for i=1,100 do maxCreatures[i]=creature("creature-"..i,"Void",false,i%2) end
local max=InventorySummary.build(maxParts,maxCreatures,265,partValue,creatureValue)
assert(#max.protect.items==365 and #max.protect.labels==365 and max.placed==50)
assert(Inventory.bulkSetLocked(maxParts,maxCreatures,max.protect.items,true)==365)
print("Inventory overview, capacity, mutation safety, stale batches and maximum inventory passed")
