-- Mutations: the 6 rolls that can bless (or rust) a brainrot when it is caught.
-- A mutation multiplies the brainrot's $/s, tints its body, and adds a particle
-- effect the whole yard can see. Diamond is the chase roll: x12 and a sparkle
-- trail. Rusty is the joke roll: the yard's scrap is rusty, and so are you.

local Mutations = {}

export type MutationDef = {
	name: string,
	multiplier: number,
	weight: number,
	color: Color3,
	effect: string,
	tagline: string,
}

Mutations.LIST = {
	{ name = "None", multiplier = 1, weight = 55, color = Color3.fromRGB(255, 255, 255), effect = "None", tagline = "Plain old scrap" },
	{ name = "Rusty", multiplier = 0.8, weight = 15, color = Color3.fromRGB(160, 90, 40), effect = "RustFlakes", tagline = "Extra rusty. Charming, honestly" },
	{ name = "Golden", multiplier = 3, weight = 12, color = Color3.fromRGB(255, 215, 0), effect = "GoldShimmer", tagline = "Shines like a trophy" },
	{ name = "Frozen", multiplier = 4, weight = 8, color = Color3.fromRGB(140, 220, 255), effect = "FrostMist", tagline = "Cold to the touch, hot on the wallet" },
	{ name = "Neon", multiplier = 6, weight = 6, color = Color3.fromRGB(0, 255, 170), effect = "NeonGlow", tagline = "Glows through the whole yard" },
	{ name = "Radioactive", multiplier = 8, weight = 3, color = Color3.fromRGB(120, 255, 60), effect = "GeigerSpark", tagline = "Do not lick. Pays for itself" },
	{ name = "Diamond", multiplier = 12, weight = 1, color = Color3.fromRGB(190, 240, 255), effect = "DiamondTrail", tagline = "The chase roll. x12. Sparkles everywhere" },
}

Mutations.BY_NAME = {}
for _, def in ipairs(Mutations.LIST) do
	Mutations.BY_NAME[def.name] = def
end

Mutations.COUNT = #Mutations.LIST - 1 -- 6 real mutations (None is the no-roll)

--- Rolls a mutation off the weighted table. "None" is the most common outcome.
function Mutations.roll(rng: Random): MutationDef
	local total = 0
	for _, def in ipairs(Mutations.LIST) do
		total += def.weight
	end
	local pick = rng:NextNumber() * total
	for _, def in ipairs(Mutations.LIST) do
		pick -= def.weight
		if pick <= 0 then
			return def
		end
	end
	return Mutations.BY_NAME.None
end

--- The multiplier for a mutation name, 1 when the name is unknown.
function Mutations.multiplierFor(name: string): number
	local def = Mutations.BY_NAME[name]
	if def then
		return def.multiplier
	end
	return 1
end

return Mutations
