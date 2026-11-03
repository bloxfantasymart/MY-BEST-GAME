local catalog={{name="Dirt Boy"},{name="Rizzler"},{name="Third"}}
local known=CollectionIndex.catalogNames(catalog)
local owned={{name="Dirt Boy",kind="Head"},{name="Dirt Boy",kind="Head",mutation="Void"},
 {name="Dirt Boy",kind="Chest",locked=true},{name="Rizzler",kind="Legs"},
 {name="Not In Catalog",kind="Head"},{name="Third",kind="Invalid"}}
local creatures={{components={Head={name="Dirt Boy",kind="Head"},Chest={name="Rizzler",kind="Chest"},
 Arms={name="Dirt Boy",kind="Arms"},Legs={name="Dirt Boy",kind="Legs"}}}}
local discovery={}
assert(CollectionIndex.record(discovery,owned,creatures,known)==6)
assert(discovery["Dirt Boy"]==15 and discovery.Rizzler==10 and discovery["Not In Catalog"]==nil and discovery.Third==nil)
assert(CollectionIndex.has(15,"Head") and CollectionIndex.has(15,"Chest") and CollectionIndex.has(15,"Arms") and CollectionIndex.has(15,"Legs"))
assert(not CollectionIndex.has(discovery.Rizzler,"Head") and not CollectionIndex.has(nil,"Head") and not CollectionIndex.has(15,"Tail"))
assert(CollectionIndex.record(discovery,owned,creatures,known)==0)
local stats=CollectionIndex.summary(discovery,catalog)
assert(stats.parts==6 and stats.totalParts==12 and stats.seen==2 and stats.complete==1 and stats.totalArchetypes==3)
-- Selling, crafting, fusion and rebirth must never erase a recorded discovery.
assert(CollectionIndex.record(discovery,{}, {},known)==0)
assert(discovery["Dirt Boy"]==15 and CollectionIndex.summary(discovery,catalog).parts==6)
-- Unknown legacy names are preserved but not counted in current catalog totals.
discovery.Retired=15
assert(CollectionIndex.summary(discovery,catalog).parts==6 and discovery.Retired==15)
assert(CollectionIndex.MaxNames==200)
local full={}; for i=1,200 do full["Old"..i]=1 end
assert(CollectionIndex.record(full,{{name="Dirt Boy",kind="Head"}}, {},known)==0 and full["Dirt Boy"]==nil)
full.Old1=1; local oldKnown={Old1=true}
assert(CollectionIndex.record(full,{{name="Old1",kind="Legs"}}, {},oldKnown)==1 and full.Old1==9)
print("Collection discovery, components, history, unknown names and cap tests passed")
for mask=0,15 do
 assert(CollectionIndex.matches(mask,"All"))
 assert(CollectionIndex.matches(mask,"Missing parts")== (mask~=15))
 assert(CollectionIndex.matches(mask,"Started")== (mask>0 and mask<15))
 assert(CollectionIndex.matches(mask,"Complete")== (mask==15))
 assert(CollectionIndex.matches(mask,"Unseen")== (mask==0))
 assert(not CollectionIndex.matches(mask,"Bad Filter"))
end
local bigCatalog,bigParts={},{}
for i=1,50 do
 local name="Catalog "..i; table.insert(bigCatalog,{name=name})
 for _,kind in ipairs({"Head","Chest","Arms","Legs"}) do table.insert(bigParts,{name=name,kind=kind}) end
end
local big={}
assert(CollectionIndex.record(big,bigParts,{},CollectionIndex.catalogNames(bigCatalog))==200)
local bigStats=CollectionIndex.summary(big,bigCatalog)
assert(bigStats.parts==200 and bigStats.complete==50 and bigStats.seen==50)
print("Collection filter masks and full catalog completion tests passed")
