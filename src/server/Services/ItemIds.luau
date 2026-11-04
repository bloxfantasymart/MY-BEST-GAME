--!strict
-- Bounded, server-side item ID allocation. Never mutate inventory while preparing.
local ItemIds={}
ItemIds.MaxAttempts=5
local function add(used,id)
 if type(id)=="string" and #id>0 and #id<=64 then used[id]=true end
end
local function addEntries(used,entries)
 if type(entries)~="table" then return end
 for _,entry in ipairs(entries) do if type(entry)=="table" then add(used,entry.id) end end
end
function ItemIds.collect(state)
 local used={}
 addEntries(used,state.parts); addEntries(used,state.rolls)
 for _,creature in ipairs(state.creatures or {}) do
  add(used,creature.id)
  for _,part in pairs(creature.components or {}) do if type(part)=="table" then add(used,part.id) end end
 end
 -- Saved layouts can refer to a creature that has since been sold or fused.
 -- Do not reuse those IDs for a new item, which could resurrect a stale layout.
 for _,entries in pairs(state.standLoadouts or {}) do addEntries(used,entries) end
 local quote=state.layoutQuote
 if quote then addEntries(used,quote.before); addEntries(used,quote.after) end
 quote=state.bulkSaleQuote
 if quote then addEntries(used,quote.items) end
 quote=state.singleSaleQuote
 if quote and quote.item then
  add(used,quote.item.id)
  for _,part in pairs(quote.item.components or {}) do if type(part)=="table" then add(used,part.id) end end
 end
 quote=state.rebirthQuote
 if quote then
  add(used,quote.id)
  for _,part in pairs(quote.components or {}) do if type(part)=="table" then add(used,part.id) end end
  for _,id in ipairs(quote.offers or {}) do add(used,id) end
 end
 return used
end
function ItemIds.allocate(used,generate)
 for _=1,ItemIds.MaxAttempts do
  local ok,id=pcall(generate)
  if ok and type(id)=="string" and #id>=1 and #id<=64 and not used[id] then
   used[id]=true; return id
  end
 end
 return nil
end
-- Build the full batch off-state; if any ID or offer fails, return nothing.
-- generate and makeOffer must not yield or change game state.
function ItemIds.prepareBatch(state,count,generate,makeOffer)
 if type(count)~="number" or count~=count or count%1~=0 or count<1 or count>9 then return nil,"Invalid roll batch size." end
 if #state.rolls>0 then return nil,"Resolve your existing offers first." end
 local used=ItemIds.collect(state); local batch={}
 for _=1,count do
  local id=ItemIds.allocate(used,generate)
  if not id then return nil,"Could not create unique roll offers. Please try again." end
  local ok,offer=pcall(makeOffer,id)
  if not ok or type(offer)~="table" or offer.id~=id then return nil,"Could not create roll offers. Please try again." end
  table.insert(batch,offer)
 end
 return batch
end
return ItemIds
