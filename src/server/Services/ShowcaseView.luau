--!strict
-- Read-only showcase details. Inventory is only sent to its owner.
local ShowcaseView={}
function ShowcaseView.describe(creature,rarities,incomeFn,includePrivate)
 local parts={}; local highest=1
 for _,kind in ipairs({"Head","Chest","Arms","Legs"}) do
  local p=creature.components[kind]
  highest=math.max(highest,p.rarity)
  table.insert(parts,(p.mutation or "Standard").." "..p.name.." "..kind.." ["..rarities[p.rarity].name.."] x"..(p.mutationMultiplier or 1))
 end
 local result={id=creature.id,name=creature.name,level=creature.level,income=math.floor(incomeFn(creature)),rarity=highest,
  ascended=creature.ascended==true,blueprint=creature.blueprintApplied==true,parts=parts}
 if includePrivate then result.locked=creature.locked==true; result.stand=creature.stand end
 return result
end
return ShowcaseView
