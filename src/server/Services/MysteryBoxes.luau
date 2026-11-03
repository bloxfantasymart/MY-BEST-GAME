--!strict
-- Open one free earned box without consuming it unless a valid unique part can be granted.
local MysteryBoxes={}
function MysteryBoxes.open(extras,parts,creatures,offers,capacity,makePart)
 if extras.uncommonBoxes<1 then return nil,"No Uncommon Mystery Boxes available." end
 if #parts>=capacity then return nil,"Free inventory space before opening a box." end
 local ok,item=pcall(makePart)
 if not ok or type(item)~="table" or type(item.id)~="string" or #item.id<1 or #item.id>64 or item.rarity~=2 then return nil,"Could not create a box reward safely." end
 for _,part in ipairs(parts) do if part.id==item.id then return nil,"Could not create a unique box reward." end end
 for _,offer in ipairs(offers) do if offer.id==item.id then return nil,"Could not create a unique box reward." end end
 for _,creature in ipairs(creatures) do
  if creature.id==item.id then return nil,"Could not create a unique box reward." end
  for _,part in pairs(creature.components) do if part.id==item.id then return nil,"Could not create a unique box reward." end end
 end
 extras.uncommonBoxes-=1; table.insert(parts,item)
 return item
end
return MysteryBoxes
