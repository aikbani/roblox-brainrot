-- WorldBuilder: builds the Rustyard's moving parts at run time.
-- The static yard (ground, fences, ferris wheel frame, base pads, conveyor
-- tunnel, spawn) lives in default.project.json so the place file shows a real
-- 3D world. WorldBuilder adds everything that moves or spawns: the brainrot
-- models on the conveyor belt, the brainrot models standing on each base, the
-- tsunami wave wall, the runaway wheel, the leaderboard board's labels, and
-- the scrap piles players climb to survive the wave.
-- buildBrainrotModel(def, mutation) is the one function that turns a catalogue
-- entry into a visible character: body + accent + face, tinted by mutation.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Rarities = require(ReplicatedStorage.Shared.Rarities)
local Mutations = require(ReplicatedStorage.Shared.Mutations)
local Config = require(ReplicatedStorage.Shared.Config)

local WorldBuilder = {}

--- Builds a visible brainrot model from its catalogue definition + mutation.
function WorldBuilder.buildBrainrotModel(def, mutationName: string): Model
	local mutation = Mutations.BY_NAME[mutationName] or Mutations.BY_NAME.None
	local model = Instance.new("Model")
	model.Name = def.name
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = Enum.PartType.Block
	body.Size = Vector3.new(3, 3, 3)
	body.Color = mutationName == "None" and def.bodyColor or mutation.color
	body.Material = Enum.Material.SmoothPlastic
	body.Anchored = true
	body.CanCollide = false
	body.Parent = model
	local accent = Instance.new("Part")
	accent.Name = "Accent"
	accent.Shape = Enum.PartType.Ball
	accent.Size = Vector3.new(1.6, 1.6, 1.6)
	accent.Color = def.accentColor
	accent.Material = Enum.Material.Neon
	accent.Anchored = true
	accent.CanCollide = false
	accent.Position = Vector3.new(0, 2.2, 0)
	accent.Parent = model
	-- The name + rarity + $/s label every brainrot wears (readable at a glance).
	local gui = Instance.new("BillboardGui")
	gui.Name = "BrainrotLabel"
	gui.Size = UDim2.new(0, 140, 0, 60)
	gui.StudsOffset = Vector3.new(0, 3.4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = body
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = def.name
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.Parent = gui
	local rateLabel = Instance.new("TextLabel")
	rateLabel.Name = "RateLabel"
	rateLabel.Size = UDim2.new(1, 0, 0.5, 0)
	rateLabel.Position = UDim2.new(0, 0, 0.5, 0)
	rateLabel.BackgroundTransparency = 1
	rateLabel.Text = Rarities.get(def.rarity).tagline .. " | $" .. def.rate .. "/s"
	rateLabel.TextColor3 = Rarities.get(def.rarity).color
	rateLabel.TextScaled = true
	rateLabel.Font = Enum.Font.GothamBold
	rateLabel.Parent = gui
	-- Mutation effect: a particle emitter on the body, coloured by the roll.
	if mutation.effect ~= "None" then
		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "MutationEffect"
		emitter.Color = ColorSequence.new(mutation.color)
		emitter.Rate = 12
		emitter.Lifetime = NumberRange.new(0.6, 1.2)
		emitter.Speed = NumberRange.new(2, 5)
		emitter.Parent = body
	end
	model.PrimaryPart = body
	return model
end

--- Lays out the 8 base pads in a ring around the yard, one per player.
function WorldBuilder.buildBases()
	local bases = Instance.new("Folder")
	bases.Name = "Bases"
	bases.Parent = Workspace
	for baseId = 1, Config.BASE_COUNT do
		local angle = (baseId - 1) * (math.pi * 2 / Config.BASE_COUNT)
		local x = math.cos(angle) * 110
		local z = math.sin(angle) * 110
		local pad = Instance.new("Part")
		pad.Name = "BasePad" .. baseId
		pad.Size = Vector3.new(28, 1, 28)
		pad.Position = Vector3.new(x, 0.5, z)
		pad.Color = Color3.fromRGB(90, 90, 100)
		pad.Material = Enum.Material.Concrete
		pad.Anchored = true
		pad.Parent = bases
		-- 10 slot markers on the pad, in two rows of five.
		for slot = 1, Config.BASE_SLOTS do
			local marker = Instance.new("Part")
			marker.Name = "Slot" .. slot
			marker.Size = Vector3.new(4, 0.4, 4)
			marker.Position = Vector3.new(x - 10 + ((slot - 1) % 5) * 5, 1.2, z - 4 + math.floor((slot - 1) / 5) * 8)
			marker.Color = Color3.fromRGB(255, 200, 0)
			marker.Material = Enum.Material.Neon
			marker.Anchored = true
			marker.Parent = bases
		end
		-- The lock light: red while locked, green while open.
		local lockLight = Instance.new("Part")
		lockLight.Name = "LockLight" .. baseId
		lockLight.Shape = Enum.PartType.Ball
		lockLight.Size = Vector3.new(2, 2, 2)
		lockLight.Position = Vector3.new(x, 5, z - 12)
		lockLight.Color = Color3.fromRGB(0, 255, 80)
		lockLight.Material = Enum.Material.Neon
		lockLight.Anchored = true
		lockLight.Parent = bases
	end
end

--- Builds the tsunami wave wall (hidden until the wave) and the runaway wheel.
function WorldBuilder.buildThreats()
	local wave = Instance.new("Part")
	wave.Name = "TsunamiWave"
	wave.Size = Vector3.new(340, 18, 6)
	wave.Position = Vector3.new(0, 6, -160)
	wave.Color = Color3.fromRGB(0, 140, 255)
	wave.Material = Enum.Material.Glass
	wave.Transparency = 1
	wave.Anchored = true
	wave.CanCollide = false
	wave.Parent = Workspace
	local wheel = Instance.new("Part")
	wheel.Name = "RunawayWheel"
	wheel.Shape = Enum.PartType.Cylinder
	wheel.Size = Vector3.new(4, 24, 24)
	wheel.Position = Vector3.new(-150, 12, 40)
	wheel.Color = Color3.fromRGB(200, 60, 200)
	wheel.Material = Enum.Material.Metal
	wheel.Transparency = 1
	wheel.Anchored = true
	wheel.CanCollide = false
	wheel.Parent = Workspace
end

--- Builds the climbable scrap piles (tsunami high ground) and the leaderboard board.
function WorldBuilder.buildScrapPilesAndBoard()
	local piles = Instance.new("Folder")
	piles.Name = "ScrapPiles"
	piles.Parent = Workspace
	local spots = { { -60, -60 }, { 60, -60 }, { -60, 60 }, { 60, 60 }, { 0, 90 }, { -90, 0 }, { 90, 0 } }
	for i, spot in ipairs(spots) do
		for level = 1, 3 do
			local pile = Instance.new("Part")
			pile.Name = "ScrapPile" .. i .. "L" .. level
			pile.Size = Vector3.new(14 - level * 3, 5, 14 - level * 3)
			pile.Position = Vector3.new(spot[1], 2.5 + (level - 1) * 5, spot[2])
			pile.Color = Color3.fromRGB(120 + level * 20, 110, 100)
			pile.Material = Enum.Material.Metal
			pile.Anchored = true
			pile.Parent = piles
		end
	end
	local board = Instance.new("Part")
	board.Name = "LeaderboardBoard"
	board.Size = Vector3.new(24, 16, 1)
	board.Position = Vector3.new(0, 10, -150)
	board.Color = Color3.fromRGB(30, 30, 40)
	board.Anchored = true
	board.Parent = Workspace
	local gui = Instance.new("SurfaceGui")
	gui.Name = "BoardGui"
	gui.Face = Enum.NormalId.Front
	gui.Parent = board
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0.12, 0)
	title.BackgroundTransparency = 1
	title.Text = "RICHEST SCRAPPERS"
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.TextScaled = true
	title.Font = Enum.Font.FredokaOne
	title.Parent = gui
	for i = 1, Config.LEADERBOARD_TOP do
		local row = Instance.new("TextLabel")
		row.Name = "Row" .. i
		row.Size = UDim2.new(1, 0, 0.085, 0)
		row.Position = UDim2.new(0, 0, 0.12 + (i - 1) * 0.085, 0)
		row.BackgroundTransparency = 1
		row.Text = i .. ". —"
		row.TextColor3 = Color3.new(1, 1, 1)
		row.TextScaled = true
		row.Font = Enum.Font.GothamBold
		row.Parent = gui
	end
end

--- Builds everything dynamic, once, at server start.
function WorldBuilder.buildAll()
	WorldBuilder.buildBases()
	WorldBuilder.buildThreats()
	WorldBuilder.buildScrapPilesAndBoard()
end

return WorldBuilder
