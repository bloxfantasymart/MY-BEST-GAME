--!strict
-- Validate all server-owned inputs and prepare the output before consuming anything.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local CraftMath=require(ReplicatedStorage.Shared:WaitForChild("CraftMath"))
local Blueprints=require(script.Parent.Blueprints)
local Inventory=require(script.Parent.Inventory)
local Crafting={}
local kinds={"Head","Chest","Arms","Legs"}
function Crafting.plan(parts,creatures,blueprintCount,selection,rarities)
 if type(selection)~="table" then return nil,"Select one owned part of each type." end
 if #creatures>=100 then return nil,"Creature inventory is full (100)." end
 local components={}; local seen={}; local owned={}
 for _,item in ipairs(parts) do owned[item.id]=item end
 for _,kind in ipairs(kinds) do
  local id=selection[kind]
  if type(id)~="string" or #id<1 or #id>64 or seen[id] then return nil,"Select four different owned parts." end
  local item=owned[id]
  if not Inventory.canConsume(item) or item.kind~=kind then return nil,"Select one unlocked owned part of each type." end
  seen[id]=true; components[kind]=item
 end
 local allowed,reason=Blueprints.validate(selection.useBlueprint,blueprintCount,components)
 if not allowed then return nil,reason end
 local blueprint=selection.useBlueprint==true
 local preview,errorMessage=CraftMath.evaluate(components,rarities,blueprint)
 if not preview then return nil,errorMessage end
 return {components=components,seen=seen,preview=preview}
end
function Crafting.execute(parts,creatures,blueprintCount,selection,rarities,newId)
 local plan,reason=Crafting.plan(parts,creatures,blueprintCount,selection,rarities)
 if not plan then return nil,reason end
 local ok,id=pcall(newId)
 if not ok or type(id)~="string" or #id<1 or #id>64 then return nil,"Could not create a new creature safely." end
 for _,part in ipairs(parts) do if part.id==id then return nil,"Could not create a unique creature." end end
 for _,creature in ipairs(creatures) do
  if creature.id==id then return nil,"Could not create a unique creature." end
  for _,part in pairs(creature.components) do if part.id==id then return nil,"Could not create a unique creature." end end
 end
 local preview=plan.preview
 local creature={id=id,name=preview.name,components=plan.components,income=preview.income,level=1,exp=0,stand=0,blueprintApplied=preview.useBlueprint}
 for i=#parts,1,-1 do if plan.seen[parts[i].id] then table.remove(parts,i) end end
 table.insert(creatures,creature)
 return {creature=creature,highest=preview.highest,blueprintCount=blueprintCount-(preview.useBlueprint and 1 or 0),usedBlueprint=preview.useBlueprint}
end
return Crafting
