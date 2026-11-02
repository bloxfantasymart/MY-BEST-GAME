--!strict
local Config = {}
-- Set these to the two place IDs within the SAME Roblox experience.
-- Zero disables the corresponding portal rather than teleporting to an arbitrary place.
Config.PlaceIds = {Main=0, TradingHub=0}
-- Gamepass IDs are different from developer-product IDs. Zero disables each pass.
-- Set unique IDs from this experience only, after testing in a private experience.
Config.GamePasses = {Luck=0, AutoRoll=0, KeepSlots=0, Backpack=0, VIP=0}
Config.PassOrder = {"Luck", "AutoRoll", "KeepSlots", "Backpack", "VIP"}
Config.PassDescriptions = {
 Luck="2x non-common rarity weight",
 AutoRoll="Auto-roll before rebirth 5",
 KeepSlots="Keep roll slots on rebirth",
 Backpack="100 extra body-part slots",
 VIP="20% extra online stand income",
}
-- Replace 0 with IDs of audio you have permission to use. 0 means silent.
Config.AudioIds = {roll=0, buy=0, craft=0, collect=0, rare=0}
Config.SlotCosts = {0, 500, 2500, 10000, 50000, 250000, 1000000, 5000000, 25000000}
Config.Mutations = {
 {name="Standard", weight=9000, multiplier=1},
 {name="Shiny", weight=700, multiplier=1.5},
 {name="Golden", weight=240, multiplier=2.5},
 {name="Void", weight=50, multiplier=4},
 {name="Glitched", weight=10, multiplier=6},
}
-- A tier may only require an archetype already available before that rebirth.
function Config.RebirthTarget(current)
 if current==0 then return "Dirt Boy" end
 local target=Config.Catalog[1]
 for _,entry in ipairs(Config.Catalog) do
  if entry.rebirth<=current then target=entry end
 end
 return target.name
end
function Config.RebirthCost(current)
 return math.floor(1000*(current+1)^2.7)
end
function Config.LevelCost(creature)
 return math.max(50,math.floor(creature.income*10*(1+creature.level*0.25)))
end
function Config.Income(creature)
 return creature.income*(1+0.25*(creature.level-1))
end
-- Twelve optional stands; each becomes available after its corresponding rebirth.
Config.StandCosts = {2500, 5000, 10000, 20000, 40000, 80000, 160000, 320000, 640000, 1280000, 2560000, 5120000}
function Config.PartSellValue(item)
 return math.max(1, math.floor((item.price or 10) * 0.5))
end
function Config.CreatureSellValue(creature)
 -- Resale must not exceed the original part prices: assembling cannot mint cash.
 local total=0
 for _,item in pairs(creature.components or {}) do
  total += item.price or math.max(10,math.floor(item.income*5))
 end
 return math.max(1, math.floor(total * 0.5))
end
Config.Types = {"Head", "Chest", "Arms", "Legs"}
Config.Rarities = {
 {name="Common", weight=5000, multiplier=1, color=Color3.fromRGB(180,180,180)},
 {name="Uncommon", weight=2500, multiplier=1.5, color=Color3.fromRGB(85,255,85)},
 {name="Rare", weight=1200, multiplier=2.5, color=Color3.fromRGB(85,170,255)},
 {name="Epic", weight=600, multiplier=4.5, color=Color3.fromRGB(170,85,255)},
 {name="Legendary", weight=200, multiplier=10, color=Color3.fromRGB(255,170,0)},
 {name="Mythic", weight=50, multiplier=25, color=Color3.fromRGB(255,85,85)},
 {name="Godly", weight=10, multiplier=75, color=Color3.fromRGB(0,255,255)},
 {name="Secret", weight=1, multiplier=250, color=Color3.fromRGB(255,0,128)},
}
-- name, rarity index, rebirth requirement, base income
local rows = {
 {"Dirt Boy",1,0,2},{"Nooblet",1,0,3},{"Sponge Golem",1,0,4},{"Skibidi Toilet",1,0,5},
 {"Bacon Warrior",1,0,6},{"Cardboard Boxman",1,0,7},{"Robloxian NPC",1,0,8},{"Slime Creeper",1,0,9},
 {"Grimace Shake",2,1,15},{"Rizzler",2,1,18},{"Sigma King",2,1,22},{"Mewing Chad",2,2,28},
 {"Baby Gronk",2,2,35},{"Pizza Tower Peppino",2,2,42},{"Freddy Fazbear",2,3,50},
 {"Livvy Dune",3,3,65},{"Kai Cent",3,3,80},{"IShowSpeed",3,4,100},{"CaseOh",3,4,130},
 {"Quandale Dingle",3,5,170},{"Huggy Wuggy",3,5,210},{"Banban",3,6,260},
 {"Smurf Cat",4,6,350},{"Strawberry Elephant",4,7,480},{"Gigachad Prime",4,8,650},
 {"Glitch Toilet",4,9,900},{"Titan Cameraman",4,10,1250},{"Garten Stinger",4,11,1700},
 {"Rainbow Friend Blue",4,12,2200},{"Titan Speakerman",5,13,3000},{"Titan TV Man",5,15,4500},
 {"Aura Lord",5,17,6800},{"Mewing Overlord",5,20,10000},{"Ohio God",5,23,15000},
 {"Camera Strider",5,26,22000},{"G-Man Astro",5,30,32000},{"Tungsten Cube",6,35,50000},
 {"Cursed Banana",6,40,75000},{"Subway Surfer",6,45,110000},{"Family Guy Clip",6,50,160000},
 {"Kinetic Sand",6,55,230000},{"Soap Cutting",6,60,330000},{"Brainrot Titan",7,65,500000},
 {"Infinite Rizz God",7,70,800000},{"The Ultimate Ohio",7,75,1300000},{"Omega Skibidi",7,80,2200000},
 {"Forbidden Meme",7,85,4000000},{"Void Titan",7,90,7500000},{"Galactic Mew",8,95,25000000},
 {"God of Brainrot",8,100,100000000},
}
Config.Catalog = {}
for _, row in ipairs(rows) do
 table.insert(Config.Catalog, {name=row[1], rarity=row[2], rebirth=row[3], income=row[4]})
end
return Config
