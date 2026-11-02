--!strict
-- Prototype interpretation of the rare assembly blueprint. No parts are consumed here.
local Blueprints={}
Blueprints.MaxOwned=100
local kinds={"Head","Chest","Arms","Legs"}
function Blueprints.validate(selected,count,components)
 if selected~=nil and type(selected)~="boolean" then return nil,"Invalid blueprint selection." end
 if not selected then return true end
 if count<1 then return nil,"No rare assembly blueprints available." end
 for _,kind in ipairs(kinds) do
  local part=components[kind]
  if not part or part.rarity<3 then return nil,"A rare blueprint requires four Rare or higher parts." end
 end
 return true
end
return Blueprints
