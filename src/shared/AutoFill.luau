--!strict
-- Finds the exact highest-income 4-part combination under the current synthesis formula.
local AutoFill={}
local function mutated(item)
 return (item.mutation or "Standard")~="Standard" or (item.mutationMultiplier or 1)~=1
end
-- Counts loose parts by exact name and type. Protected copies count as retained:
-- they cannot be consumed by crafting. Creature components and offers do not.
function AutoFill.looseCounts(parts)
 local counts={}
 for _,item in ipairs(parts) do
  local kind=item.kind or ""; local name=item.name or ""
  counts[kind]=counts[kind] or {}; counts[kind][name]=(counts[kind][name] or 0)+1
 end
 return counts
end
function AutoFill.risks(parts,components,kinds)
 local counts=AutoFill.looseCounts(parts); local result={lastCopies={},mutations={}}
 for _,kind in ipairs(kinds) do
  local item=components[kind]
  if item then
   if ((counts[kind] or {})[item.name or ""] or 0)==1 then table.insert(result.lastCopies,item) end
   if mutated(item) then table.insert(result.mutations,item) end
  end
 end
 return result
end
-- Optional policies restrict auto-fill only; manual selection and server review
-- retain their existing rules. At most one item of each kind can be consumed,
-- so a same-name/same-kind count >= 2 guarantees a loose copy remains.
function AutoFill.best(parts,rarities,kinds,minRarity,options)
 minRarity=minRarity or 1
 local counts=options and options.keepLast and AutoFill.looseCounts(parts) or nil
 local function eligible(item)
  if item.locked or item.rarity<minRarity then return false end
  if options and options.standardOnly and mutated(item) then return false end
  if counts and ((counts[item.kind] or {})[item.name or ""] or 0)<2 then return false end
  return true
 end
 -- Include every mutation present, including future catalog additions.
 local groups={false}; local seen={}
 for _,item in ipairs(parts) do
  local mutation=item.mutation or "Standard"
  if not seen[mutation] then seen[mutation]=true; table.insert(groups,mutation) end
 end
 local bestScore=-1
 local bestSelection=nil
 for rarity=1,#rarities do
  for _,group in ipairs(groups) do
   local highest={}; local exact={}
   for _,item in ipairs(parts) do
    local mutation=item.mutation or "Standard"
    if eligible(item) and item.rarity<=rarity and (group==false or mutation==group) then
     local amount=item.income*(item.mutationMultiplier or 1)
     local current=highest[item.kind]
     if not current or amount>current.income*(current.mutationMultiplier or 1) then highest[item.kind]=item end
     if item.rarity==rarity then
      current=exact[item.kind]
      if not current or amount>current.income*(current.mutationMultiplier or 1) then exact[item.kind]=item end
     end
    end
   end
   -- Force at least one part of the proposed highest rarity; otherwise multiplying
   -- by that rarity's bonus would overstate the creature's actual income.
   for _,forced in ipairs(kinds) do
    local selected={}; local sum=0; local firstMutation=nil; local harmony=true; local valid=true
    for _,kind in ipairs(kinds) do
     local item=highest[kind]
     if kind==forced then item=exact[kind] end
     if not item then valid=false; break end
     selected[kind]=item.id; sum+=item.income*(item.mutationMultiplier or 1)
     local mutation=item.mutation or "Standard"
     if firstMutation==nil then firstMutation=mutation elseif firstMutation~=mutation then harmony=false end
    end
    if valid then
     local score=sum*rarities[rarity].multiplier*0.4*(harmony and 2 or 1)
     if score>bestScore then bestScore=score; bestSelection=selected end
    end
   end
  end
 end
 return bestSelection,bestScore
end
return AutoFill
