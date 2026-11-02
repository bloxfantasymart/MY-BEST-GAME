--!strict
-- Finds the exact highest-income 4-part combination under the current synthesis formula.
local AutoFill={}
function AutoFill.best(parts,rarities,kinds)
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
    if not item.locked and item.rarity<=rarity and (group==false or mutation==group) then
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
