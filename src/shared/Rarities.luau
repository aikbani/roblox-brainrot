-- Rarities: the 7-rung ladder every brainrot climbs.
-- Each rung has a display colour (the name label, the base glow, the Index chip),
-- a spawn weight on the conveyor, a cash multiplier applied on top of the
-- brainrot's own $/s, and the rebirth count that unlocks its spawn.

local Rarities = {}

export type RarityDef = {
	name: string,
	order: number,
	color: Color3,
	spawnWeight: number,
	cashMultiplier: number,
	minRebirth: number,
	tagline: string,
}

Rarities.LIST = {
	{ name = "Common", order = 1, color = Color3.fromRGB(180, 180, 180), spawnWeight = 40, cashMultiplier = 1, minRebirth = 0, tagline = "Scrap you trip over" },
	{ name = "Uncommon", order = 2, color = Color3.fromRGB(80, 200, 90), spawnWeight = 26, cashMultiplier = 1.5, minRebirth = 0, tagline = "Scrap with a dream" },
	{ name = "Rare", order = 3, color = Color3.fromRGB(60, 140, 255), spawnWeight = 17, cashMultiplier = 2, minRebirth = 0, tagline = "The yard's rising stars" },
	{ name = "Epic", order = 4, color = Color3.fromRGB(160, 70, 255), spawnWeight = 10, cashMultiplier = 3, minRebirth = 0, tagline = "Legends of the heap" },
	{ name = "Legendary", order = 5, color = Color3.fromRGB(255, 170, 0), spawnWeight = 5, cashMultiplier = 4.5, minRebirth = 0, tagline = "Royalty of the Rustyard" },
	{ name = "Mythic", order = 6, color = Color3.fromRGB(255, 60, 120), spawnWeight = 1.8, cashMultiplier = 7, minRebirth = 0, tagline = "Whispered in the break room" },
	{ name = "Secret", order = 7, color = Color3.fromRGB(0, 230, 220), spawnWeight = 0.2, cashMultiplier = 12, minRebirth = 5, tagline = "One in a thousand rolls" },
}

Rarities.BY_NAME = {}
for _, def in ipairs(Rarities.LIST) do
	Rarities.BY_NAME[def.name] = def
end

Rarities.COUNT = #Rarities.LIST -- 7

--- The rung for a name, or the Common rung when the name is unknown.
function Rarities.get(name: string): RarityDef
	return Rarities.BY_NAME[name] or Rarities.BY_NAME.Common
end

--- Cash per second of a brainrot on this rung, before mutations and rebirths.
function Rarities.rateFor(def: { rate: number, rarity: string }): number
	return def.rate * Rarities.get(def.rarity).cashMultiplier
end

--- The next rung up, or nil at the top of the ladder.
function Rarities.nextUp(name: string): RarityDef?
	local current = Rarities.get(name)
	if current.order >= Rarities.COUNT then
		return nil
	end
	return Rarities.LIST[current.order + 1]
end

return Rarities
