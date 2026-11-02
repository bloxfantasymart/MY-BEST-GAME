--!strict
-- Informational on clients, authoritative only when called with server-owned parts.
local CraftMath={}
CraftMath.BlueprintMultiplier=1.25
CraftMath.MaxIncome=1e18
local kinds={"Head","Chest","Arms","Legs"}
function CraftMath.evaluate(components,rarities,useBlueprint)
 if type(components)~="table" or type(rarities)~="table" or type(useBlueprint)~="boolean" then return nil,"Invalid recipe." end
 local sum,highest=0,0
 local dominant=nil; local mutation=nil; local harmony=true
 for _,kind in ipairs(kinds) do
  local part=components[kind]
  if type(part)~="table" or part.kind~=kind or type(part.name)~="string" then return nil,"Choose one part of each type." end
  if type(part.rarity)~="number" or part.rarity~=part.rarity or part.rarity%1~=0 or not rarities[part.rarity] then return nil,"Invalid rarity." end
  if type(part.income)~="number" or part.income~=part.income or part.income<0 or part.income>1e15 then return nil,"Invalid part income." end
  local multiplier=part.mutationMultiplier or 1
  if type(multiplier)~="number" or multiplier~=multiplier or multiplier<1 or multiplier>6 then return nil,"Invalid mutation multiplier." end
  if useBlueprint and part.rarity<3 then return nil,"A rare blueprint requires four Rare or higher parts." end
  sum+=part.income*multiplier
  if part.mutation~=nil and (type(part.mutation)~="string" or #part.mutation>40) then return nil,"Invalid mutation." end
  local name=part.mutation or "Standard"
  if mutation==nil then mutation=name elseif mutation~=name then harmony=false end
  if part.rarity>highest then highest=part.rarity; dominant=part.name end
 end
 local baseIncome=sum*rarities[highest].multiplier*0.4*(harmony and 2 or 1)*(useBlueprint and CraftMath.BlueprintMultiplier or 1)
 if baseIncome~=baseIncome or baseIncome>CraftMath.MaxIncome then return nil,"This assembly exceeds the supported income limit." end
 return {income=baseIncome,highest=highest,name=dominant.." Abomination",harmony=harmony,mutation=mutation,useBlueprint=useBlueprint}
end
return CraftMath
