--!strict
-- Server-wide prototype exploration rewards. Callers must validate player,
-- health and position; this module handles one-use and resource limits.
local Treasure={}
Treasure.RoundSeconds=900
Treasure.Count=10
Treasure.Spots=32
Treasure.ChestCooldown=2
Treasure.DailyLimit=10
Treasure.MaxScrap=1000000
Treasure.ChestScrap=3
Treasure.StormScrap=1
function Treasure.new(now,draw)
 local pool={}; for i=1,Treasure.Spots do pool[i]=i end
 local spots={}
 for _=1,Treasure.Count do
  local ok,index=pcall(draw,1,#pool)
  if not ok or type(index)~="number" or index~=index or index%1~=0 or index<1 or index>#pool then return nil end
  table.insert(spots,table.remove(pool,index))
 end
 return {starts=now,expires=now+Treasure.RoundSeconds,spots=spots,claimed={}}
end
function Treasure.status(extras,epoch)
 local day=math.floor(epoch/86400)
 local saved=extras.treasureDay or -1
 if day<saved then return {remaining=0,clockBlocked=true} end
 local used=day==saved and (extras.treasureClaims or 0) or 0
 return {remaining=math.max(0,Treasure.DailyLimit-used),clockBlocked=false}
end
function Treasure.claim(round,index,state,now,epoch)
 if not round or type(index)~="number" or index~=index or index%1~=0 or index<1 or index>#round.spots
  or now<round.starts or now>=round.expires or round.claimed[index] then return nil,"Chest is no longer available." end
 if state.lastTreasureClaim and now>=state.lastTreasureClaim and now-state.lastTreasureClaim<Treasure.ChestCooldown then return nil,"Wait before opening another chest." end
 local status=Treasure.status(state.extras,epoch)
 if status.clockBlocked then return nil,"Treasure claims unavailable until the server clock catches up." end
 if status.remaining==0 then return nil,"Daily treasure limit reached. Come back after UTC midnight." end
 if state.extras.scrap+Treasure.ChestScrap>Treasure.MaxScrap then return nil,"Scrap storage is full." end
 local day=math.floor(epoch/86400)
 local cash=500*(1+state.rebirth)
 -- No yields between validating the shared chest and granting both rewards.
 round.claimed[index]=true; state.lastTreasureClaim=now
 if state.extras.treasureDay~=day then state.extras.treasureDay=day; state.extras.treasureClaims=0 end
 state.extras.treasureClaims+=1
 state.cash+=cash; state.extras.scrap+=Treasure.ChestScrap
 return cash,Treasure.ChestScrap
end
function Treasure.storm(state)
 if state.extras.scrap+Treasure.StormScrap>Treasure.MaxScrap then return nil,"Scrap storage is full." end
 local cash=50*(1+state.rebirth)
 state.cash+=cash; state.extras.scrap+=Treasure.StormScrap
 return cash,Treasure.StormScrap
end
return Treasure
