local kinds={"Head","Chest","Arms","Legs"}
local components={}
for _,kind in ipairs(kinds) do components[kind]={rarity=3} end
assert(Blueprints.validate(nil,0,{})==true)
assert(Blueprints.validate(false,0,{})==true)
assert(Blueprints.validate(true,1,components)==true)
assert(Blueprints.validate(true,0,components)==nil)
assert(Blueprints.validate("yes",1,components)==nil)
for _,kind in ipairs(kinds) do
 components[kind].rarity=2
 assert(Blueprints.validate(true,1,components)==nil)
 components[kind].rarity=3
end
components.Legs=nil
assert(Blueprints.validate(true,1,components)==nil)
assert(Blueprints.MaxOwned==100)
print("Rare blueprint availability and four-part rarity requirements passed")
