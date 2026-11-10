--!strict
-- Shared, deterministic cosmetic milestones. Zero has no aura.
local AuraStyle={}
function AuraStyle.tier(rebirth)
 if type(rebirth)~="number" or rebirth~=rebirth then return 0 end
 if rebirth>=100 then return 4 end
 if rebirth>=50 then return 3 end
 if rebirth>=25 then return 2 end
 if rebirth>=10 then return 1 end
 return 0
end
local styles={
 {rgb={70,235,210},brightness=0.5,range=8},
 {rgb={190,115,255},brightness=0.6,range=9},
 {rgb={255,205,70},brightness=0.7,range=10},
 {rgb={255,80,165},brightness=0.8,range=11},
}
function AuraStyle.get(tier)
 if type(tier)~="number" or tier%1~=0 or tier<1 or tier>4 then return nil end
 return styles[tier]
end
return AuraStyle
