local rarities={{multiplier=1},{multiplier=1.5},{multiplier=2.5},{multiplier=4.5}}
local kinds={"Head","Chest","Arms","Legs"}
local function makeParts(rarity)
 local parts={}
 for i,kind in ipairs(kinds) do
  table.insert(parts,{id="part"..i,name="Unit"..i,kind=kind,rarity=rarity,income=i*10,mutation="Standard",mutationMultiplier=1,price=100})
 end
 return parts
end
local function selected()
 return {Head="part1",Chest="part2",Arms="part3",Legs="part4"}
end
local function close(a,b) return math.abs(a-b)<1e-8 end
local parts=makeParts(3); local creatures={}
local plan=Crafting.plan(parts,creatures,1,selected(),rarities)
assert(plan and close(plan.preview.income,100*2.5*0.4*2) and plan.preview.harmony and plan.preview.name=="Unit1 Abomination")
assert(#parts==4 and #creatures==0, "Preview must not change inventory")
local function fail(selection,count,newId)
 local before=#parts; local oldCreatures=#creatures
 local result=Crafting.execute(parts,creatures,count,selection,rarities,newId or function() return "generated" end)
 assert(result==nil and #parts==before and #creatures==oldCreatures, "Rejected assembly must not consume anything")
end
fail({Head="part1",Chest="part1",Arms="part3",Legs="part4"},1)
fail({Head="missing",Chest="part2",Arms="part3",Legs="part4"},1)
fail({Head={},Chest="part2",Arms="part3",Legs="part4"},1)
fail({Head="part2",Chest="part1",Arms="part3",Legs="part4"},1)
parts[1].locked=true; fail(selected(),1); parts[1].locked=false
local malformed=selected(); malformed.useBlueprint="true"; fail(malformed,1)
local bp=selected(); bp.useBlueprint=true; fail(bp,0)
parts[2].rarity=2; fail(bp,1); parts[2].rarity=3
fail(bp,1,function() error("GUID service failure") end)
fail(bp,1,function() return "part1" end)
for i=1,100 do table.insert(creatures,{id="creature"..i,components={}}) end
fail(selected(),1)
table.clear(creatures)
local result=Crafting.execute(parts,creatures,1,bp,rarities,function() return "generated" end)
assert(result and result.usedBlueprint and result.blueprintCount==0 and result.highest==3)
assert(#parts==0 and #creatures==1 and creatures[1].blueprintApplied and close(creatures[1].income,250))
assert(creatures[1].components.Head.id=="part1" and creatures[1].level==1 and creatures[1].stand==0)
parts=makeParts(3); creatures={}; parts[2].mutation="Shiny"; parts[2].mutationMultiplier=1.5
local mixed=Crafting.plan(parts,creatures,0,selected(),rarities)
assert(mixed and not mixed.preview.harmony and close(mixed.preview.income,110*2.5*0.4))
parts[1].income=0/0; fail(selected(),0)
parts=makeParts(3); parts[1].mutation={}; fail(selected(),0)
math.randomseed(188)
for _=1,200 do
 local randomParts=makeParts(1); local sum=0; local highest=0; local dominant=nil; local first=nil; local harmony=true
 for _,item in ipairs(randomParts) do
  item.rarity=math.random(1,4); item.income=math.random(1,10000); item.mutation=math.random(1,2)==1 and "Standard" or "Golden"; item.mutationMultiplier=item.mutation=="Golden" and 2.5 or 1
  sum+=item.income*item.mutationMultiplier
  if item.rarity>highest then highest=item.rarity; dominant=item.name end
  if first==nil then first=item.mutation elseif first~=item.mutation then harmony=false end
 end
 local output=Crafting.plan(randomParts,{},0,selected(),rarities)
 assert(output and close(output.preview.income,sum*rarities[highest].multiplier*0.4*(harmony and 2 or 1)))
 assert(output.preview.name==dominant.." Abomination")
end
print("Crafting validation, atomicity, blueprint and preview parity tests passed")
