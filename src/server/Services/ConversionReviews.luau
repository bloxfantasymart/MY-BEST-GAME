--!strict
-- Session-only, one-use reviews of destructive crafting and fusion operations.
-- Dependencies are passed in so the same authoritative plans are used on
-- review and confirmation; no yield is allowed during validation and commit.
local Reviews={}
Reviews.Lifetime=60
local kinds={"Head","Chest","Arms","Legs"}
local partFields={"id","name","kind","rarity","income","price","mutation","mutationMultiplier"}
local creatureFields={"id","name","income","level","stand","ascended","blueprintApplied"}
local function fields(object,keys)
 local result={}; for _,key in ipairs(keys) do result[key]=object[key] end; return result
end
local function part(item) return fields(item,partFields) end
local function creature(item)
 local result=fields(item,creatureFields); result.components={}
 for _,kind in ipairs(kinds) do result.components[kind]=part(item.components[kind]) end
 return result
end
local function same(a,b)
 if type(a)~=type(b) then return false end
 if type(a)~="table" then return a==b end
 for k,v in pairs(a) do if not same(v,b[k]) then return false end end
 for k in pairs(b) do if a[k]==nil then return false end end
 return true
end
local function validToken(token) return type(token)=="string" and #token>0 and #token<=64 end
local function craftSnapshot(plan)
 local inputs={}
 for _,kind in ipairs(kinds) do table.insert(inputs,part(plan.components[kind])) end
 return inputs
end
local function fusionSnapshot(plan)
 local inputs={}; for _,item in ipairs(plan.chosen) do table.insert(inputs,creature(item)) end; return inputs
end
function Reviews.craft(state,selection,now,token,Crafting,rarities)
 if not validToken(token) then return nil,"Could not create a review." end
 local plan,reason=Crafting.plan(state.parts,state.creatures,state.rareBlueprints,selection,rarities)
 if not plan then return nil,reason end
 local selected={useBlueprint=selection.useBlueprint==true}
 for _,kind in ipairs(kinds) do selected[kind]=selection[kind] end
 return {token=token,expires=now+Reviews.Lifetime,selection=selected,inputs=craftSnapshot(plan),output=fields(plan.preview,{"name","income","highest","harmony","mutation","useBlueprint"})}
end
function Reviews.confirmCraft(state,token,now,Crafting,rarities,newId)
 local q=state.craftQuote; state.craftQuote=nil
 if not q or type(token)~="string" or token~=q.token then return nil,"Review the assembly again." end
 if now>=q.expires then return nil,"Assembly review expired. Review again." end
 local plan,reason=Crafting.plan(state.parts,state.creatures,state.rareBlueprints,q.selection,rarities)
 if not plan then return nil,reason end
 if not same(q.inputs,craftSnapshot(plan)) or not same(q.output,fields(plan.preview,{"name","income","highest","harmony","mutation","useBlueprint"})) then return nil,"Assembly inputs or output changed. Review again." end
 return Crafting.execute(state.parts,state.creatures,state.rareBlueprints,q.selection,rarities,newId)
end
function Reviews.fusion(state,ids,now,token,Fusion,costFn)
 if not validToken(token) then return nil,"Could not create a review." end
 local plan,reason=Fusion.plan(state.creatures,ids,state.rebirth,state.cash,costFn)
 if not plan then return nil,reason end
 return {token=token,expires=now+Reviews.Lifetime,ids={ids[1],ids[2],ids[3]},inputs=fusionSnapshot(plan),cost=plan.cost,outputIncome=plan.chosen[1].income*5}
end
function Reviews.confirmFusion(state,token,now,Fusion,costFn,newId)
 local q=state.fusionQuote; state.fusionQuote=nil
 if not q or type(token)~="string" or token~=q.token then return nil,"Review the fusion again." end
 if now>=q.expires then return nil,"Fusion review expired. Review again." end
 local plan,reason=Fusion.plan(state.creatures,q.ids,state.rebirth,state.cash,costFn)
 if not plan then return nil,reason end
 if plan.cost~=q.cost or plan.chosen[1].income*5~=q.outputIncome or not same(q.inputs,fusionSnapshot(plan)) then return nil,"Fusion inputs or cost changed. Review again." end
 local result,cost=Fusion.execute(state.creatures,q.ids,state.rebirth,state.cash,costFn,newId)
 if not result then return nil,cost end
 state.cash-=cost
 return result,cost
end
return Reviews
