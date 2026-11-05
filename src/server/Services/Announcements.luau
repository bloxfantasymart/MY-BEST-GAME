--!strict
-- Best-effort cosmetic announcements. Never use messages to grant rewards.
local Announcements={}
Announcements.PublishInterval=60
Announcements.ReceiveInterval=5
Announcements.MaxAge=120
Announcements.SeenLimit=128
function Announcements.new(jobId)
 return {jobId=jobId,lastPublish=-math.huge,lastReceive=-math.huge,seen={},order={}}
end
local function safeToken(value,maxLength)
 return type(value)=="string" and #value>=1 and #value<=maxLength and value:match("^[%w_%-]+$")~=nil
end
local function integer(value,minimum,maximum)
 return type(value)=="number" and value==value and value%1==0 and value>=minimum and value<=maximum
end
function Announcements.prepare(bus,now,epoch,token,username,item,catalog,kinds)
 if now-bus.lastPublish<Announcements.PublishInterval or not safeToken(bus.jobId,64)
  or not safeToken(token,64) or type(username)~="string" or #username<1 or #username>20
  or not username:match("^[%w_]+$") or type(item)~="table" or not integer(epoch,0,1e12) then return nil end
 local catalogIndex=nil; local kindIndex=nil
 for index,entry in ipairs(catalog) do if entry.name==item.name and entry.rarity==item.rarity and entry.rarity>=7 then catalogIndex=index; break end end
 for index,kind in ipairs(kinds) do if kind==item.kind then kindIndex=index; break end end
 if not catalogIndex or not kindIndex then return nil end
 bus.lastPublish=now
 return {id=token,origin=bus.jobId,user=username,archetype=catalogIndex,kind=kindIndex,at=epoch}
end
function Announcements.receive(bus,payload,now,epoch,catalog,kinds,rarities)
 if type(payload)~="table" or not safeToken(payload.id,64) or not safeToken(payload.origin,64)
  or payload.origin==bus.jobId or type(payload.user)~="string" or #payload.user<1 or #payload.user>20
  or not payload.user:match("^[%w_]+$") or not integer(payload.at,0,1e12)
  or math.abs(epoch-payload.at)>Announcements.MaxAge
  or not integer(payload.archetype,1,#catalog) or not integer(payload.kind,1,#kinds) then return nil end
 local entry=catalog[payload.archetype]
 if not entry or not integer(entry.rarity,7,8) or not rarities[entry.rarity] or bus.seen[payload.id] then return nil end
 -- Bounded duplicate cache; even rate-limited messages are marked seen.
 bus.seen[payload.id]=true; table.insert(bus.order,payload.id)
 if #bus.order>Announcements.SeenLimit then bus.seen[table.remove(bus.order,1)]=nil end
 if now-bus.lastReceive<Announcements.ReceiveInterval then return nil end
 bus.lastReceive=now
 return "GLOBAL OFFER: "..payload.user.." rolled "..entry.name.." "..kinds[payload.kind].." ["..rarities[entry.rarity].name.."]! (offer, not a purchase)"
end
return Announcements
