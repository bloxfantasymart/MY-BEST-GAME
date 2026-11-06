--!strict
-- Presentation math only. The server's roll table remains authoritative.
local OddsMath={}
local function probability(value)
 return type(value)=="number" and value==value and value>=0 and value<=1
end
local function count(value,max)
 return type(value)=="number" and value==value and value%1==0 and value>=1 and value<=max
end
-- Odds of one archetype within its unlocked tier, optionally one type and mutation.
-- typeChoices is 1 for any type or the number of equally likely types for one type.
function OddsMath.target(tierChance,archetypeCount,typeChoices,mutationChance)
 if not probability(tierChance) or not count(archetypeCount,10000) or not count(typeChoices,10000) or not probability(mutationChance) then return nil end
 return tierChance/archetypeCount/typeChoices*mutationChance
end
-- Sum mutually exclusive first-success probabilities; avoids subtracting two
-- nearly equal numbers when per-slot chances are very small.
function OddsMath.atLeastOne(perSlot,slots)
 if not probability(perSlot) or not count(slots,9) then return nil end
 local miss=1; local total=0
 for _=1,slots do total+=miss*perSlot; miss*=1-perSlot end
 return math.clamp(total,0,1)
end
function OddsMath.format(chance)
 if not probability(chance) then return "unavailable" end
 if chance==0 then return "0%" end
 local inverse=1/chance
 if inverse==math.huge then return string.format("%.5g%% (rarer than 1 in 1e308)",chance*100) end
 return string.format("%.5g%% (~1 in %.5g)",chance*100,inverse)
end
return OddsMath
