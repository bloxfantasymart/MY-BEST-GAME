--!strict
-- Open earned boxes without consuming them unless a valid unique part can be granted.
local MysteryBoxes={}
function MysteryBoxes.standardRarity(roll)
 if type(roll)~="number" or roll~=roll or roll%1~=0 or roll<1 or roll>100 then return nil end
 return roll<=80 and 1 or 2
end
local function open(extras,parts,creatures,offers,capacity,makePart,key,allowedRarity,label)
 if extras[key]<1 then return nil,"No "..label.." available." end
 if #parts>=capacity then return nil,"Free inventory space before opening a box." end
 local ok,item=pcall(makePart)
 if not ok or type(item)~="table" or type(item.id)~="string" or #item.id<1 or #item.id>64 or not allowedRarity(item.rarity) then return nil,"Could not create a box reward safely." end
 for _,part in ipairs(parts) do if part.id==item.id then return nil,"Could not create a unique box reward." end end
 for _,offer in ipairs(offers) do if offer.id==item.id then return nil,"Could not create a unique box reward." end end
 for _,creature in ipairs(creatures) do
  if creature.id==item.id then return nil,"Could not create a unique box reward." end
  for _,part in pairs(creature.components) do if part.id==item.id then return nil,"Could not create a unique box reward." end end
 end
 extras[key]-=1; table.insert(parts,item)
 return item
end
function MysteryBoxes.open(extras,parts,creatures,offers,capacity,makePart)
 return open(extras,parts,creatures,offers,capacity,makePart,"uncommonBoxes",function(r) return r==2 end,"Uncommon Mystery Boxes")
end
function MysteryBoxes.openStandard(extras,parts,creatures,offers,capacity,makePart)
 return open(extras,parts,creatures,offers,capacity,makePart,"standardBoxes",function(r) return r==1 or r==2 end,"Standard Roll Crates")
end
return MysteryBoxes
