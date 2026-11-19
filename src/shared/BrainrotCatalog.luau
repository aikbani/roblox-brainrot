-- BrainrotCatalog: the 48 original junkyard brainrots of Scrapyard Brainrots.
-- Every character is an original absurd meme-born machine that crawled out of the
-- Rustyard scrap. Names, looks and jokes are ours; nothing here copies a real
-- Brainrot character, a brand, or any other game's cast.
-- Fields: id, name, rarity, rate ($/s), price ($), build (parts the WorldBuilder
-- assembles: body part, accent part, face decal mood), blurb (the joke the Index shows).
-- The catalogue is the single source of truth: ShopService prices from it,
-- GameService ticks earnings from it, IndexGui lists it, PrizeBook counts it.

local BrainrotCatalog = {}

export type BrainrotDef = {
	id: string,
	name: string,
	rarity: string,
	rate: number,
	price: number,
	bodyColor: Color3,
	accentColor: Color3,
	build: string,
	blurb: string,
}

-- COMMON — the scrap you trip over. Cheap, cheerful, $1-4/s.
local COMMON: { BrainrotDef } = {
	{ id = "toasterino", name = "Toasterino Cappuccino", rarity = "Common", rate = 1, price = 50,
		bodyColor = Color3.fromRGB(210, 180, 140), accentColor = Color3.fromRGB(120, 72, 20),
		build = "ToasterBody+CoffeeCupHat", blurb = "A toaster that only toasts cappuccinos. It burns the bread and drinks the coffee." },
	{ id = "sockpuppet", name = "Sock Puppet Supreme", rarity = "Common", rate = 1, price = 60,
		bodyColor = Color3.fromRGB(240, 240, 240), accentColor = Color3.fromRGB(255, 80, 80),
		build = "SockBody+ButtonEyes", blurb = "A lost sock that learned to talk. It mostly talks about the dryer." },
	{ id = "conehead", name = "Traffic Cone King", rarity = "Common", rate = 2, price = 100,
		bodyColor = Color3.fromRGB(255, 110, 0), accentColor = Color3.fromRGB(255, 255, 255),
		build = "ConeBody+CardboardCrown", blurb = "He rules the roadworks. His crown is cardboard. His reign is eternal." },
	{ id = "spooner", name = "Sir Spoonington III", rarity = "Common", rate = 2, price = 120,
		bodyColor = Color3.fromRGB(200, 200, 210), accentColor = Color3.fromRGB(180, 160, 90),
		build = "SpoonBody+Monocle", blurb = "A spoon of noble birth. He stirs nothing. He judges everything." },
	{ id = "mopboss", name = "Mop Boss Barry", rarity = "Common", rate = 3, price = 180,
		bodyColor = Color3.fromRGB(90, 140, 200), accentColor = Color3.fromRGB(230, 230, 230),
		build = "StickBody+StringMopHead", blurb = "He mops the yard. The yard is never clean. He is never sad." },
	{ id = "broomzooka", name = "Broomzooka Brenda", rarity = "Common", rate = 3, price = 200,
		bodyColor = Color3.fromRGB(160, 120, 60), accentColor = Color3.fromRGB(255, 220, 0),
		build = "BroomBody+StrawBristles", blurb = "She sweeps dust into piles, then knocks the piles over. It is art." },
	{ id = "lamplarry", name = "Lamp Larry", rarity = "Common", rate = 4, price = 260,
		bodyColor = Color3.fromRGB(255, 220, 120), accentColor = Color3.fromRGB(60, 60, 60),
		build = "LampBody+GlowingBulb", blurb = "A lamp that only lights up when nobody is looking. Shy. Bright. Confusing." },
}

-- UNCOMMON — scrap with a dream. $5-12/s.
local UNCOMMON: { BrainrotDef } = {
	{ id = "washingopera", name = "Washing Machine Opera", rarity = "Uncommon", rate = 5, price = 400,
		bodyColor = Color3.fromRGB(220, 230, 240), accentColor = Color3.fromRGB(40, 120, 200),
		build = "WasherBody+RoundWindow+TopHat", blurb = "She spins at 1400 RPM and sings Verdi. The spin cycle is her aria." },
	{ id = "fridgephil", name = "Fridge Phil", rarity = "Uncommon", rate = 6, price = 500,
		bodyColor = Color3.fromRGB(200, 220, 230), accentColor = Color3.fromRGB(255, 170, 0),
		build = "FridgeBody+MagnetLetters", blurb = "He keeps your leftovers and your secrets. Mostly the leftovers." },
	{ id = "kettleken", name = "Kettle Ken", rarity = "Uncommon", rate = 7, price = 650,
		bodyColor = Color3.fromRGB(80, 80, 90), accentColor = Color3.fromRGB(255, 200, 40),
		build = "KettleBody+SteamPlume", blurb = "He whistles when he is happy. He is always happy. The yard never sleeps." },
	{ id = "microwavemitch", name = "Microwave Mitch", rarity = "Uncommon", rate = 8, price = 800,
		bodyColor = Color3.fromRGB(60, 60, 70), accentColor = Color3.fromRGB(0, 255, 170),
		build = "MicrowaveBody+BeepingDisplay", blurb = "He beeps three times and then forgets why. Your popcorn is done. Probably." },
	{ id = "vacuumvera", name = "Vacuum Vera", rarity = "Uncommon", rate = 10, price = 1000,
		bodyColor = Color3.fromRGB(200, 40, 40), accentColor = Color3.fromRGB(30, 30, 30),
		build = "VacuumBody+HoseTrunk", blurb = "She eats dust, coins and one (1) sock. She denies the sock." },
	{ id = "fanfred", name = "Fan Fred", rarity = "Uncommon", rate = 12, price = 1300,
		bodyColor = Color3.fromRGB(120, 200, 255), accentColor = Color3.fromRGB(255, 255, 255),
		build = "FanBody+SpinningBlades", blurb = "He is your biggest fan. Literally. He has three blades and no chill." },
}

-- RARE — the yard's rising stars. $15-35/s.
local RARE: { BrainrotDef } = {
	{ id = "tvcassette", name = "TV Cassette Carl", rarity = "Rare", rate = 15, price = 2000,
		bodyColor = Color3.fromRGB(40, 40, 50), accentColor = Color3.fromRGB(0, 255, 255),
		build = "TvBody+StaticScreen+VhsTape", blurb = "He only shows static and 1987 cartoons. The static is his favourite show." },
	{ id = "radiorita", name = "Radio Rita", rarity = "Rare", rate = 18, price = 2600,
		bodyColor = Color3.fromRGB(150, 90, 40), accentColor = Color3.fromRGB(255, 215, 0),
		build = "RadioBody+Antenna+TuningDial", blurb = "She picks up stations from 1962. The DJs are all ghosts. Great music." },
	{ id = "typewritertom", name = "Typewriter Tom", rarity = "Rare", rate = 22, price = 3400,
		bodyColor = Color3.fromRGB(30, 30, 35), accentColor = Color3.fromRGB(230, 230, 230),
		build = "TypewriterBody+KeyRow+PaperSheet", blurb = "He types his own biography, one ding at a time. It is 4,000 pages long." },
	{ id = "gramophone", name = "Gramophone Gus", rarity = "Rare", rate = 26, price = 4200,
		bodyColor = Color3.fromRGB(180, 140, 60), accentColor = Color3.fromRGB(90, 50, 20),
		build = "GramophoneBody+BrassHorn+VinylDisc", blurb = "He plays one record. It has been playing since 1923. Nobody dares stop it." },
	{ id = "clockwork", name = "Clockwork Clara", rarity = "Rare", rate = 30, price = 5000,
		bodyColor = Color3.fromRGB(200, 170, 90), accentColor = Color3.fromRGB(255, 255, 255),
		build = "ClockBody+Pendulum+BrassGears", blurb = "She ticks backwards on purpose. She says the future is overrated." },
	{ id = "sewingserena", name = "Sewing Serena", rarity = "Rare", rate = 35, price = 6000,
		bodyColor = Color3.fromRGB(90, 90, 110), accentColor = Color3.fromRGB(255, 120, 180),
		build = "SewingBody+NeedleArm+ThreadSpool", blurb = "She sews patches onto the sky. The sky has never looked better." },
}

-- EPIC — legends of the scrap heap. $45-90/s.
local EPIC: { BrainrotDef } = {
	{ id = "cranekong", name = "Crane Kong", rarity = "Epic", rate = 45, price = 9000,
		bodyColor = Color3.fromRGB(255, 200, 0), accentColor = Color3.fromRGB(40, 40, 40),
		build = "CraneBody+HookArm+HardHat", blurb = "A crane who lifts cars and crushes on the moon. He has never dropped anything. Once." },
	{ id = "forkliftfiona", name = "Forklift Fiona", rarity = "Epic", rate = 55, price = 12000,
		bodyColor = Color3.fromRGB(255, 140, 0), accentColor = Color3.fromRGB(30, 30, 30),
		build = "ForkliftBody+TwinForks+BeaconLight", blurb = "She beeps when she reverses. She reverses everywhere. The yard knows." },
	{ id = "bulldozerben", name = "Bulldozer Ben", rarity = "Epic", rate = 65, price = 15000,
		bodyColor = Color3.fromRGB(230, 180, 40), accentColor = Color3.fromRGB(60, 60, 60),
		build = "DozerBody+BladePlow+TreadWheels", blurb = "He pushes mountains of scrap into slightly smaller mountains. Progress." },
	{ id = "excavatoreve", name = "Excavator Eve", rarity = "Epic", rate = 75, price = 18000,
		bodyColor = Color3.fromRGB(255, 170, 30), accentColor = Color3.fromRGB(200, 60, 60),
		build = "ExcavatorBody+BucketArm+CabGlass", blurb = "She digs for treasure and finds it: more scrap. She calls it winning." },
	{ id = "weldingwalter", name = "Welding Walter", rarity = "Epic", rate = 90, price = 22000,
		bodyColor = Color3.fromRGB(100, 110, 130), accentColor = Color3.fromRGB(0, 200, 255),
		build = "WelderBody+SparkTorch+DarkVisor", blurb = "He welds scrap into sculptures, then welds the sculptures into scrap." },
}

-- LEGENDARY — the yard's royalty. $120-300/s.
local LEGENDARY: { BrainrotDef } = {
	{ id = "ferrisghost", name = "Ferris Ghost", rarity = "Legendary", rate = 120, price = 35000,
		bodyColor = Color3.fromRGB(140, 80, 200), accentColor = Color3.fromRGB(255, 220, 120),
		build = "WheelBody+GondolaRing+GhostTrail", blurb = "The ghost of the old ferris wheel. He still gives rides. The rides never end." },
	{ id = "magnetmonarch", name = "Magnet Monarch", rarity = "Legendary", rate = 150, price = 45000,
		bodyColor = Color3.fromRGB(220, 40, 40), accentColor = Color3.fromRGB(200, 200, 210),
		build = "MagnetBody+HorseshoeArms+CrownCoil", blurb = "He attracts everything metal, including your car keys and your dignity." },
	{ id = "crusherqueen", name = "Crusher Queen", rarity = "Legendary", rate = 180, price = 55000,
		bodyColor = Color3.fromRGB(70, 70, 80), accentColor = Color3.fromRGB(255, 60, 120),
		build = "CrusherBody+JawPlates+PinkBow", blurb = "She flattens cars into pancakes and wears the bow anyway. Royalty." },
	{ id = "scrapdragon", name = "Scrap Dragon", rarity = "Legendary", rate = 220, price = 70000,
		bodyColor = Color3.fromRGB(40, 160, 80), accentColor = Color3.fromRGB(255, 190, 0),
		build = "DragonBody+ScrapWings+ExhaustFlame", blurb = "A dragon built from exhaust pipes. He breathes smoke rings and compliments." },
	{ id = "turbineking", name = "Turbine King", rarity = "Legendary", rate = 300, price = 95000,
		bodyColor = Color3.fromRGB(180, 200, 220), accentColor = Color3.fromRGB(0, 180, 255),
		build = "TurbineBody+SpinningBlades+StormCape", blurb = "He spins so fast the wind asks him for permission. He grants it. Sometimes." },
}

-- MYTHIC — whispered about in the break room. $400-900/s.
local MYTHIC: { BrainrotDef } = {
	{ id = "goldentoaster", name = "Golden Toaster Prime", rarity = "Mythic", rate = 400, price = 150000,
		bodyColor = Color3.fromRGB(255, 215, 0), accentColor = Color3.fromRGB(255, 255, 255),
		build = "ToasterBody+GoldenCrust+SunRays", blurb = "The first toaster. It toasts gold. It has never burned anything. Not once." },
	{ id = "neonfridge", name = "Neon Fridge Overlord", rarity = "Mythic", rate = 550, price = 200000,
		bodyColor = Color3.fromRGB(0, 255, 200), accentColor = Color3.fromRGB(255, 0, 180),
		build = "FridgeBody+NeonTrim+IceCore", blurb = "His light never turns off. His ice cream never melts. His wifi is perfect." },
	{ id = "voidvacuum", name = "Void Vacuum", rarity = "Mythic", rate = 700, price = 260000,
		bodyColor = Color3.fromRGB(20, 20, 30), accentColor = Color3.fromRGB(160, 60, 255),
		build = "VacuumBody+VoidMaw+StarDust", blurb = "She vacuumed a black hole once. She keeps it in the dust bag. It hums." },
	{ id = "timeclock", name = "Time Clock Titan", rarity = "Mythic", rate = 900, price = 340000,
		bodyColor = Color3.fromRGB(220, 200, 140), accentColor = Color3.fromRGB(0, 220, 255),
		build = "ClockBody+TitanGears+HourglassCore", blurb = "He owns every second you have ever wasted. He rents them back, cheap." },
}

-- SECRET — one in a thousand rolls. $1,200-2,500/s. Rebirth 5 unlocks the Secret spawn.
local SECRET: { BrainrotDef } = {
	{ id = "fridgesupreme", name = "Galactus Fridge Supreme", rarity = "Secret", rate = 1200, price = 500000,
		bodyColor = Color3.fromRGB(255, 255, 255), accentColor = Color3.fromRGB(255, 215, 0),
		build = "FridgeBody+GalaxyDoors+CrownOfLight", blurb = "He eats planets and keeps leftovers in the crisper drawer. The drawer is infinite." },
	{ id = "scrapgod", name = "The Scrap God", rarity = "Secret", rate = 1800, price = 750000,
		bodyColor = Color3.fromRGB(255, 240, 180), accentColor = Color3.fromRGB(255, 100, 0),
		build = "GodBody+ScrapHalo+MoltenCore", blurb = "Every bolt, every washer, every lost sock answers to him. He answers to no one." },
	{ id = "brainrotprime", name = "Brainrot Prime", rarity = "Secret", rate = 2500, price = 1000000,
		bodyColor = Color3.fromRGB(255, 0, 140), accentColor = Color3.fromRGB(0, 255, 255),
		build = "PrimeBody+RainbowAura+ThinkingCap", blurb = "The brainrot all other brainrots dream of being. He dreams of being a toaster." },
}

BrainrotCatalog.ALL = {}
for _, group in ipairs({ COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, MYTHIC, SECRET }) do
	for _, def in ipairs(group) do
		table.insert(BrainrotCatalog.ALL, def)
	end
end

BrainrotCatalog.BY_ID = {}
for _, def in ipairs(BrainrotCatalog.ALL) do
	BrainrotCatalog.BY_ID[def.id] = def
end

BrainrotCatalog.COUNT = #BrainrotCatalog.ALL -- 48

--- Returns the definition for an id, or nil when the id is unknown.
function BrainrotCatalog.getById(id: string): BrainrotDef?
	return BrainrotCatalog.BY_ID[id]
end

--- Returns every definition of one rarity, in catalogue order.
function BrainrotCatalog.getByRarity(rarity: string): { BrainrotDef }
	local out: { BrainrotDef } = {}
	for _, def in ipairs(BrainrotCatalog.ALL) do
		if def.rarity == rarity then
			table.insert(out, def)
		end
	end
	return out
end

--- Rolls one brainrot id off the conveyor, weighted by rarity spawn weights.
--- Secret only rolls once the player has 5 rebirths (checked by the caller).
function BrainrotCatalog.rollConveyor(rebirths: number, rng: Random): BrainrotDef
	local weights = { Common = 40, Uncommon = 26, Rare = 17, Epic = 10, Legendary = 5, Mythic = 1.8, Secret = 0.2 }
	if rebirths < 5 then
		weights.Secret = 0
	end
	local total = 0
	for _, w in pairs(weights) do
		total += w
	end
	local pick = rng:NextNumber() * total
	local chosen = "Common"
	for rarity, w in pairs(weights) do
		pick -= w
		if pick <= 0 then
			chosen = rarity
			break
		end
	end
	local pool = BrainrotCatalog.getByRarity(chosen)
	return pool[rng:NextInteger(1, #pool)]
end

return BrainrotCatalog
