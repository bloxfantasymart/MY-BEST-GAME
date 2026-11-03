--!strict
-- Validate all inputs before consuming anything. Caller supplies server-owned data and GUIDs.
local Fusion={}
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local FusionRecipe=require(ReplicatedStorage.Shared:WaitForChild("FusionRecipe"))
function Fusion.execute(creatures,ids,rebirth,cash,costFn,newId)
 if rebirth<15 then return nil,"Fusion requires rebirth 15." end
 if type(ids)~="table" or #ids~=3 then return nil,"Select exactly three creatures." end
 local byId={}
 for _,creature in ipairs(creatures) do byId[creature.id]=creature end
 local seen={}; local chosen={}
 for i=1,3 do
  local id=ids[i]
  if type(id)~="string" or #id>64 or seen[id] or not byId[id] then return nil,"Select three different owned creatures." end
  local creature=byId[id]
  if creature.locked then return nil,"Unlock protected creatures before fusion." end
  if creature.stand~=0 then return nil,"Remove all three creatures from their stands first." end
  if creature.level<10 or creature.ascended==true then return nil,"Use three non-ascended creatures at level 10 or above." end
  seen[id]=true; chosen[i]=creature
 end
 if not FusionRecipe.matches(chosen[1],chosen[2]) or not FusionRecipe.matches(chosen[1],chosen[3]) then
  return nil,"All four components and mutations must match exactly."
 end
 if chosen[1].income*5>1e18 then return nil,"This creature is too powerful to fuse safely." end
 local cost=costFn(chosen[1])
 if cash<cost then return nil,"Not enough cash for fusion." end
 local ok,id=pcall(newId)
 if not ok or type(id)~="string" or #id<1 or #id>64 then return nil,"Could not create a new creature safely." end
 for _,creature in ipairs(creatures) do
  if creature.id==id then return nil,"Could not create a unique creature." end
  for _,part in pairs(creature.components) do if part.id==id then return nil,"Could not create a unique creature." end end
 end
 local result={id=id,name=chosen[1].name,components=chosen[1].components,income=chosen[1].income*5,level=1,exp=0,stand=0,ascended=true,blueprintApplied=chosen[1].blueprintApplied==true}
 for i=#creatures,1,-1 do if seen[creatures[i].id] then table.remove(creatures,i) end end
 table.insert(creatures,result)
 return result,cost
end
return Fusion
