--!strict
-- Stands form a 6-column by 4-row grid. Each adjacent ascended unit adds 20%.
local PlotEconomy={}
function PlotEconomy.rates(creatures,incomeFn)
 local occupied={}
 for _,creature in ipairs(creatures) do
  if creature.stand>0 then occupied[creature.stand]=creature end
 end
 local rates={}
 for stand,creature in pairs(occupied) do
  local row=math.floor((stand-1)/6)
  local column=(stand-1)%6
  local neighbors={{row-1,column},{row+1,column},{row,column-1},{row,column+1}}
  local multiplier=1
  for _,position in ipairs(neighbors) do
   local r,c=position[1],position[2]
   if r>=0 and r<4 and c>=0 and c<6 then
    local neighbor=occupied[r*6+c+1]
    if neighbor and neighbor.ascended==true then multiplier+=0.2 end
   end
  end
  rates[stand]=incomeFn(creature)*multiplier
 end
 return rates
end
function PlotEconomy.multiplier(event,vip,statue)
 return (event.sigma and 3 or 1)*(event.weekend and 2 or 1)*(vip and 1.2 or 1)*(statue and 1.5 or 1)
end
function PlotEconomy.summary(rates,event,vip,statue)
 local base,placed=0,0
 for _,rate in pairs(rates) do base+=rate; placed+=1 end
 local normal=base*(statue and 1.5 or 1)
 return {placed=placed,normal=normal,online=base*PlotEconomy.multiplier(event,vip,statue),offline=normal*0.25,
  sigma=event.sigma==true,weekend=event.weekend==true,vip=vip==true,statue=statue==true}
end
function PlotEconomy.total(creatures,incomeFn)
 local total=0
 for _,rate in pairs(PlotEconomy.rates(creatures,incomeFn)) do total+=rate end
 return total
end
return PlotEconomy
