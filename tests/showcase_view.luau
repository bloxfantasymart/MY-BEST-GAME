local rarities={{name="Common"},{name="Uncommon"},{name="Rare"},{name="Epic"}}
local function creature(id,level)
 local components={}
 for _,kind in ipairs({"Head","Chest","Arms","Legs"}) do components[kind]={id=id..kind,kind=kind,name="Dirt Boy",rarity=1,income=2} end
 return {id=id,name="Dirt Boy Abomination",components=components,income=10,level=level,stand=4,locked=true}
end
local c=creature("c1",10); c.components.Head.rarity=3; c.components.Head.name="Rizzler"; c.components.Head.mutation="Golden"; c.components.Head.mutationMultiplier=2.5; c.blueprintApplied=true
local public=ShowcaseView.describe(c,rarities,function(v) return v.income*(1+0.25*(v.level-1)) end,false)
assert(public.id=="c1" and public.rarity==3 and public.income==32 and public.blueprint and not public.ascended)
assert(public.locked==nil and public.stand==nil and public.components==nil)
assert(#public.parts==4 and string.find(public.parts[1],"Golden Rizzler Head [Rare] x2.5",1,true))
public.parts[1]="modified"; assert(c.components.Head.name=="Rizzler", "UI descriptions must not share mutable component records")
local own=ShowcaseView.describe(c,rarities,function() return 20 end,true)
assert(own.locked==true and own.stand==4 and own.parts[2]=="Standard Dirt Boy Chest [Common] x1")
local a=ShowcaseView.describe(creature("a",1),rarities,function() return 10 end,true)
local b=ShowcaseView.describe(creature("b",2),rarities,function() return 30 end,true)
local all={a,b,own}; local listings={{id="b"}}
local function build(q,mode,hide) return ShowcaseInventory.build(all,listings,q,mode,hide) end
assert(#build("", "Newest",false)==3 and build("","Newest",false)[1].item.id=="c1")
assert(build("","Income",false)[1].item.id=="b" and build("","Rarity",false)[1].item.id=="c1")
assert(#build("", "Name",true)==2)
assert(#build("golden rizzler", "Newest",false)==1 and #build("[", "Newest",false)==3)
assert(#build("not present", "Newest",false)==0)
assert(build("","Newest",false)[2].displayed)
local page,current,pages=InventoryView.page(build("","Newest",false),99,2)
assert(current==2 and pages==2 and #page==1)
assert(#all==3 and a.id=="a" and b.id=="b", "Browsing cannot mutate inventory")
print("Showcase sanitized details, owner inventory filters and pagination tests passed")
