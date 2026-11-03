local parts={
 {id="a",kind="Head",name="Dirt Boy",rarity=1,income=2,mutation="Standard",mutationMultiplier=1},
 {id="b",kind="Head",name="Dirt Boy",rarity=3,income=5,mutation="Golden",mutationMultiplier=2.5},
 {id="c",kind="Head",name="Alpha",rarity=2,income=50,mutation="Void",mutationMultiplier=4},
 {id="d",kind="Head",name="Protected",rarity=8,income=500,locked=true},
 {id="e",kind="Legs",name="Other",rarity=4,income=6},
}
local function browse(q,blue,sort) return CraftPicker.parts(parts,"Head",q,blue,sort) end
assert(#browse("",false,"Newest")==3 and browse("",false,"Newest")[1].item.id=="c")
assert(#browse("golden",false,"Newest")==1 and #browse("[",false,"Newest")==0)
assert(#browse("",true,"Newest")==1 and browse("",true,"Newest")[1].item.id=="b")
assert(browse("",false,"Rarity")[1].item.id=="b")
assert(browse("",false,"Contribution")[1].item.id=="c")
assert(browse("",false,"Name")[1].item.id=="c")
local page,current,pages=InventoryView.page(browse("",false,"Newest"),2,2)
assert(#page==1 and current==2 and pages==2)
local function creature(id)
 local components={}
 for _,kind in ipairs({"Head","Chest","Arms","Legs"}) do components[kind]={id=id..kind,kind=kind,name="Dirt Boy",rarity=1,income=2} end
 return {id=id,name="Dirt Boy Abomination",components=components,income=10,level=10,stand=0}
end
local a=creature("a"); local b=creature("b"); local c=creature("c"); local d=creature("d")
b.level=20; c.components.Head.mutation="Golden"; d.locked=true
assert(FusionRecipe.matches(a,b),"Level and component IDs do not change recipes")
assert(not FusionRecipe.matches(a,c) and not FusionRecipe.eligible(d))
local all=CraftPicker.fusion({a,b,c,d},"",nil); assert(#all==3 and all[1]==b)
local matching=CraftPicker.fusion({a,b,c,d},"DIRT",a); assert(#matching==2 and matching[1]==b)
assert(#CraftPicker.fusion({a,b,c,d},"[",a)==0)
b.blueprintApplied=true; assert(not FusionRecipe.matches(a,b)); b.blueprintApplied=nil
b.components.Head.mutation="Standard"; b.components.Head.mutationMultiplier=1
assert(FusionRecipe.matches(a,b),"Legacy defaults match explicit Standard")
b.components.Head.income=3; assert(not FusionRecipe.matches(a,b)); b.components.Head.income=2
b.stand=2; assert(not FusionRecipe.eligible(b)); b.stand=0; b.level=9; assert(not FusionRecipe.eligible(b)); b.level=10; b.ascended=true; assert(not FusionRecipe.eligible(b))
-- Every recipe field must affect both the picker and server's shared comparison.
local changes={
 function(x) x.name="Different" end,
 function(x) x.income=11 end,
 function(x) x.blueprintApplied=true end,
 function(x) x.components.Arms.kind="Legs" end,
 function(x) x.components.Arms.name="Other" end,
 function(x) x.components.Arms.rarity=2 end,
 function(x) x.components.Arms.income=3 end,
 function(x) x.components.Arms.mutation="Void" end,
 function(x) x.components.Arms.mutationMultiplier=4 end,
}
for _,change in ipairs(changes) do
 local x=creature("x"); change(x)
 assert(not FusionRecipe.matches(a,x) and #CraftPicker.fusion({x},"",a)==0)
end
assert(not FusionRecipe.matches(a,{name=a.name,income=a.income}) and not FusionRecipe.matches(a,nil))
print("Craft picker filtering, sorting, paging and shared fusion recipe tests passed")
