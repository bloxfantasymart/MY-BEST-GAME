local catalog={{name="Common",rarity=1},{name="Mythic",rarity=6},{name="Godly",rarity=7},{name="Secret",rarity=8}}
local kinds={"Head","Chest","Arms","Legs"}
local rarities={{name="Common"},{name="Uncommon"},{name="Rare"},{name="Epic"},{name="Legendary"},{name="Mythic"},{name="Godly"},{name="Secret"}}
local sender=Announcements.new("server-A"); local receiver=Announcements.new("server-B")
local function prepare(now,token,item,user)
 return Announcements.prepare(sender,now,1000,token,user or "Player_1",item or {name="Secret",rarity=8,kind="Head"},catalog,kinds)
end
assert(not prepare(0,"id0",{name="Mythic",rarity=6,kind="Head"}))
assert(not prepare(0,"id0",nil,"<bad>"))
assert(not prepare(0,"id0",{name="Godly",rarity=8,kind="Head"}))
local p=prepare(0,"id-1"); assert(p and p.archetype==4 and p.kind==1)
assert(not prepare(59,"id-2") and prepare(60,"id-2"))
local text=Announcements.receive(receiver,p,0,1000,catalog,kinds,rarities)
assert(text and text:find("Player_1",1,true) and text:find("offer, not a purchase",1,true))
assert(not Announcements.receive(receiver,p,10,1000,catalog,kinds,rarities))
assert(not Announcements.receive(sender,p,10,1000,catalog,kinds,rarities))
local function invalid(field,value)
 local q={id="new-id",origin="server-A",user="Player_1",archetype=4,kind=1,at=1000}; q[field]=value
 assert(not Announcements.receive(receiver,q,20,1000,catalog,kinds,rarities),field)
end
invalid("id",""); invalid("id",string.rep("a",65)); invalid("origin","server-B")
invalid("user","Player <b>"); invalid("archetype",3.5); invalid("archetype",2); invalid("archetype",0/0)
invalid("kind",5); invalid("at",1000-121); invalid("at",1000+121); invalid("at",math.huge)
assert(not Announcements.receive(receiver,nil,20,1000,catalog,kinds,rarities))
local q={id="id-3",origin="server-A",user="Player_1",archetype=3,kind=2,at=1000}
assert(not Announcements.receive(receiver,q,1,1000,catalog,kinds,rarities))
assert(not Announcements.receive(receiver,q,10,1000,catalog,kinds,rarities),"throttled duplicates must not reappear")
for i=1,200 do
 q={id="flood"..i,origin="server-A",user="Player_1",archetype=3,kind=2,at=1000}
 Announcements.receive(receiver,q,10,1000,catalog,kinds,rarities)
end
assert(#receiver.order==Announcements.SeenLimit)
local count=0; for _ in pairs(receiver.seen) do count+=1 end; assert(count==Announcements.SeenLimit)
print("Announcement validation, rarity, age, self-delivery, rate limits and bounded deduplication passed")
