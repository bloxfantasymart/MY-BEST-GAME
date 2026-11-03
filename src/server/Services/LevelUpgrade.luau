--!strict
-- Atomic server-side cash upgrade using the exact level and price the player reviewed.
local LevelUpgrade={}
function LevelUpgrade.execute(state,request,costFn)
 if type(request)~="table" or type(request.id)~="string" or #request.id<1 or #request.id>64
  or type(request.level)~="number" or request.level~=request.level or request.level%1~=0 or request.level<1 or request.level>999
  or type(request.cost)~="number" or request.cost~=request.cost or request.cost<0 or request.cost==math.huge then return nil,"Review the upgrade again." end
 local creature=nil
 for _,item in ipairs(state.creatures) do if item.id==request.id then creature=item; break end end
 if not creature then return nil,"Creature is no longer in your backpack." end
 if creature.level>=1000 then return nil,"This creature is already at the maximum level." end
 local cost=costFn(creature)
 if creature.level~=request.level or cost~=request.cost then return nil,"The level or price changed. Review the upgrade again." end
 if state.cash<cost then return nil,"Not enough cash to level up." end
 -- Ownership, level, price and balance are checked without yielding before mutation.
 state.cash-=cost; creature.level+=1
 return creature,cost
end
return LevelUpgrade
