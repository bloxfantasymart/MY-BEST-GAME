local p=Progression.new(); local extras=RewardExtras.new(); local now=123*86400
local old={luckPotions=1,rollVouchers=2,goldenLever=false,sigmaStatue=false,ohioCrown=false}
assert(RewardExtras.normalize(old)==old and old.doubleLuckPotions==0 and old.uncommonBoxes==0)
local result=QuestRewards.claim(p,extras,"rolls",now); assert(result==nil and not p.claimed.rolls)
Progression.increment(p,"rolls",50,now)
result=QuestRewards.claim(p,extras,"rolls",now); assert(result and result.reward==10000 and result.xp==50 and p.claimed.rolls)
assert(QuestRewards.claim(p,extras,"rolls",now)==nil)
Progression.increment(p,"rareCrafts",2,now); extras.doubleLuckPotions=100
assert(QuestRewards.claim(p,extras,"rareCrafts",now)==nil and not p.claimed.rareCrafts)
extras.doubleLuckPotions=99
result=QuestRewards.claim(p,extras,"rareCrafts",now); assert(result and result.xp==75 and extras.doubleLuckPotions==100 and p.claimed.rareCrafts)
Progression.increment(p,"collected",500000,now); extras.uncommonBoxes=100
assert(QuestRewards.claim(p,extras,"collected",now)==nil and not p.claimed.collected)
extras.uncommonBoxes=99
result=QuestRewards.claim(p,extras,"collected",now); assert(result and result.xp==100 and extras.uncommonBoxes==100 and p.claimed.collected)
assert(QuestRewards.claim(p,extras,{},now)==nil)
assert(QuestRewards.claim(p,extras,"rolls",now-86400)==nil)
local parts={{id="owned"}}; local creatures={{id="unit",components={Head={id="component"}}}}; local offers={{id="offer"}}
local function factory(id) return function() return {id=id,rarity=2,name="Rizzler",kind="Head"} end end
for _,id in ipairs({"owned","unit","component","offer",""}) do
 assert(MysteryBoxes.open(extras,parts,creatures,offers,10,factory(id))==nil and extras.uncommonBoxes==100 and #parts==1)
end
assert(MysteryBoxes.open(extras,parts,creatures,offers,1,factory("fresh"))==nil and extras.uncommonBoxes==100)
assert(MysteryBoxes.open(extras,parts,creatures,offers,10,function() error("factory error") end)==nil and extras.uncommonBoxes==100)
assert(MysteryBoxes.open(extras,parts,creatures,offers,10,function() return {id="fresh",rarity=3} end)==nil and extras.uncommonBoxes==100)
local reward=MysteryBoxes.open(extras,parts,creatures,offers,10,factory("fresh")); assert(reward and reward.id=="fresh" and extras.uncommonBoxes==99 and #parts==2)
extras.uncommonBoxes=0; assert(MysteryBoxes.open(extras,parts,creatures,offers,10,factory("next"))==nil and #parts==2)
print("Quest item rewards, caps and atomic mystery box opening tests passed")

assert(MysteryBoxes.standardRarity(1)==1 and MysteryBoxes.standardRarity(80)==1 and MysteryBoxes.standardRarity(81)==2 and MysteryBoxes.standardRarity(100)==2)
assert(MysteryBoxes.standardRarity(0)==nil and MysteryBoxes.standardRarity(101)==nil and MysteryBoxes.standardRarity(0/0)==nil)
extras.standardBoxes=1
assert(MysteryBoxes.openStandard(extras,parts,creatures,offers,2,factory("standard"))==nil and extras.standardBoxes==1)
assert(MysteryBoxes.openStandard(extras,parts,creatures,offers,10,function() return {id="standard",rarity=3} end)==nil and extras.standardBoxes==1)
assert(MysteryBoxes.openStandard(extras,parts,creatures,offers,10,function() return {id="new-common",rarity=1} end) and extras.standardBoxes==0 and #parts==3)
assert(not MysteryBoxes.openStandard(extras,parts,creatures,offers,10,factory("next")))
print("Standard crate odds boundaries, capacity and atomic consumption tests passed")
