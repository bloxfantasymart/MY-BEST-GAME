local parts={
 {id="a",name="Dirt Boy",kind="Head",rarity=1,income=2,mutation="Standard"},
 {id="b",name="Spark",kind="Legs",rarity=3,income=10,mutation="Golden",locked=true},
 {id="c",name="Spark",kind="Arms",rarity=2,income=20,mutation="Void"},
}
local creatures={{id="d",name="Zed Abomination",income=100,components={Head={rarity=4}},locked=true}}
local income=function(c) return c.income end
local function view(tab,query,protection,sort)
 return InventoryView.build(parts,creatures,tab,query,protection,sort,income)
end
assert(#view("All","","All","Newest")==4)
assert(#view("Brainrots","","All","Newest")==1)
assert(#view("Body Parts","golden","All","Newest")==1)
assert(#view("All","HEAD","All","Newest")==1)
assert(#view("All","[","All","Newest")==0, "Search must be literal, not a Lua pattern")
assert(#view("All","","Protected","Newest")==2)
assert(#view("All","","Unprotected","Newest")==2)
local rarity=view("All","","All","Rarity"); assert(rarity[1].item.id=="d" and rarity[2].item.id=="b")
local amount=view("Body Parts","","All","Income"); assert(amount[1].item.id=="c")
local newest=view("Body Parts","","All","Newest"); assert(newest[1].item.id=="c")
local p,current,pages=InventoryView.page(rarity,99,2)
assert(current==2 and pages==2 and #p==2)
local empty,first,total=InventoryView.page({},1,20); assert(#empty==0 and first==1 and total==1)
print("Inventory search, protection filters, sorting and pagination tests passed")
creatures[1].components.Head={name="Rizzler",kind="Head",rarity=4,mutation="Golden"}
assert(#view("Brainrots","RIZZLER","All","Newest")==1)
assert(#view("Brainrots","golden","All","Newest")==1)
assert(#view("Brainrots","[","All","Newest")==0)
assert(InventoryView.find(parts,creatures,"part","b")==parts[2])
assert(InventoryView.find(parts,creatures,"creature","d")==creatures[1])
assert(InventoryView.find(parts,creatures,"part","missing")==nil)
assert(InventoryView.find(parts,creatures,"invalid","a")==nil)
assert(InventoryView.find(parts,creatures,"part",{})==nil)
print("Creature component search and current-selection lookup tests passed")
creatures[1].stand=2
local function filtered(tab,rarity,mutation,placement)
 return InventoryView.build(parts,creatures,tab,"","All","Newest",income,rarity,mutation,placement)
end
assert(#filtered("All",3,"All","All")==1 and filtered("All",3,"All","All")[1].item.id=="b")
assert(#filtered("Brainrots",4,"Golden","Placed")==1)
assert(#filtered("Brainrots",4,"Void","All")==0)
assert(#filtered("Brainrots",4,"Golden","Unplaced")==0)
assert(#filtered("All",0,"Standard","All")==1)
assert(#filtered("All",0,"Golden","Placed")==1, "Placement filters exclude parts")
creatures[1].stand=0
assert(#filtered("Brainrots",4,"Golden","Unplaced")==1)
print("Rarity, mutation and placement filter tests passed")
