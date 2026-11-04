local state={parts={{id="part"}}, rolls={}, creatures={{id="creature",components={Head={id="component"}}}},
 standLoadouts={{{id="stale"}}}, layoutQuote={before={{id="before"}},after={{id="after"}}},
 bulkSaleQuote={items={{id="sale"}}}, rebirthQuote={id="rebirth",components={Head={id="rebirthpart"}},offers={"quotedoffer"}}}
local used=ItemIds.collect(state)
for _,id in ipairs({"part","creature","component","stale","before","after","sale","rebirth","rebirthpart","quotedoffer"}) do assert(used[id],id) end
local calls=0
local id=ItemIds.allocate(used,function() calls+=1; return "stale" end)
assert(id==nil and calls==ItemIds.MaxAttempts)
local inputs={false,"",string.rep("x",65),"part","fresh"}; calls=0
id=ItemIds.allocate(used,function() calls+=1; if calls==1 then error("failed") end; return inputs[calls] end)
assert(id=="fresh" and calls==5 and used.fresh)
local ids={"one","one","two","three"}; calls=0
local batch=ItemIds.prepareBatch(state,3,function() calls+=1; return ids[calls] end,function(key) return {id=key} end)
assert(batch and #batch==3 and batch[1].id=="one" and batch[2].id=="two" and batch[3].id=="three")
assert(#state.rolls==0 and #state.parts==1)
calls=0
local failed=ItemIds.prepareBatch(state,3,function() calls+=1; return tostring(calls) end,function(key) if key=="2" then error("offer failed") end; return {id=key} end)
assert(failed==nil and #state.rolls==0 and #state.parts==1)
failed=ItemIds.prepareBatch(state,1,function() return "new" end,function() return {id="wrong"} end)
assert(failed==nil and #state.rolls==0)
state.rolls={{id="existing"}}; calls=0
assert(ItemIds.collect(state).existing)
failed=ItemIds.prepareBatch(state,1,function() calls+=1; return "new" end,function(key) return {id=key} end)
assert(failed==nil and calls==0 and state.rolls[1].id=="existing")
state.rolls={}
for _,n in ipairs({0,10,1.5,math.huge}) do assert(ItemIds.prepareBatch(state,n,function() return "x" end,function(key) return {id=key} end)==nil) end
local extras={uncommonBoxes=1}
local item=MysteryBoxes.open(extras,state.parts,state.creatures,state.rolls,10,function()
 local key=ItemIds.allocate(ItemIds.collect(state),function() return "stale" end)
 if not key then return nil end
 return {id=key,rarity=2}
end)
assert(item==nil and extras.uncommonBoxes==1 and #state.parts==1)
item=MysteryBoxes.open(extras,state.parts,state.creatures,state.rolls,10,function()
 return {id=ItemIds.allocate(ItemIds.collect(state),function() return "box" end),rarity=2}
end)
assert(item and item.id=="box" and extras.uncommonBoxes==0 and #state.parts==2)
print("item ID tests passed")
