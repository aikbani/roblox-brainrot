-- EventService: the two map threats that force the dash home.
-- 1) THE TSUNAMI WAVE — every ~2.5 minutes a siren sounds and a 12-second
--    banner counts down. Then a wall of water sweeps the whole yard for 8
--    seconds. Anyone below 14 studs is washed back to spawn and drops whatever
--    they are carrying. Climb a scrap pile, a base roof or the crane to survive.
-- 2) THE RUNAWAY FERRIS WHEEL — every ~3.5 minutes the derelict wheel at the
--    heart of the yard breaks loose with a klaxon. It rolls in a straight line
--    across the yard for 12 seconds, crushing (knocking back) anything in its
--    path and making its carrier drop their steal. Its shadow is the warning.
-- Both events are telegraphed: siren/klaxon, a full-screen banner with a
-- countdown, and a coloured light over the yard — never a surprise kill.
-- startTsunami() is the TOUR.json hook reviewers use to reach the event screen.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)
local GameService = require(script.Parent.GameService)
local StealService = require(script.Parent.StealService)

local EventService = {}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local EventWarn = Remotes:WaitForChild("EventWarn")
local EventStart = Remotes:WaitForChild("EventStart")
local EventEnd = Remotes:WaitForChild("EventEnd")
local Announce = Remotes:WaitForChild("Announce")

local tsunamiRunning = false
local ferrisRunning = false

--- Everyone below the safe height gets washed back to spawn (and drops cargo).
function EventService.washPlayers()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if not character then
			continue
		end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then
			continue
		end
		if root.Position.Y < Config.TSUNAMI_SAFE_HEIGHT then
			StealService.dropCarry(player, "the tsunami washed them away")
			local state = GameService.Players[player]
			if state then
				state.survivedTsunamis += 0 -- washed players do NOT count a survive
			end
			character:SetPrimaryPartCFrame(CFrame.new(0, 6, -140))
			Announce:FireClient(player, "The tsunami washed you back to spawn!")
		else
			local state = GameService.Players[player]
			if state then
				state.survivedTsunamis += 1
			end
			Announce:FireClient(player, "You survived the tsunami on high ground!")
		end
	end
end

--- Runs one tsunami: warn, sweep, end. Guards against overlapping waves.
function EventService.startTsunami()
	if tsunamiRunning then
		return
	end
	tsunamiRunning = true
	EventWarn:FireAllClients("TSUNAMI", Config.TSUNAMI_WARN_SECONDS, "A wave is coming! Climb high or get washed away!")
	Announce:FireAllClients("TSUNAMI WARNING: climb the scrap piles! The wave hits in " .. Config.TSUNAMI_WARN_SECONDS .. " seconds!")
	task.wait(Config.TSUNAMI_WARN_SECONDS)
	EventStart:FireAllClients("TSUNAMI", Config.TSUNAMI_WASH_SECONDS)
	-- The wave itself: a moving wall part sweeps the yard (built by WorldBuilder).
	local wave = Workspace:FindFirstChild("TsunamiWave")
	if wave then
		wave.Transparency = 0.3
		for step = 1, 40 do
			wave.Position = Vector3.new(0, 6, -160 + step * 8)
			task.wait(Config.TSUNAMI_WASH_SECONDS / 40)
		end
		wave.Transparency = 1
	end
	EventService.washPlayers()
	EventEnd:FireAllClients("TSUNAMI")
	Announce:FireAllClients("The tsunami has passed. The yard is soaked. The scrap remains.")
	tsunamiRunning = false
end

--- Runs one ferris-wheel breakaway: warn, roll, end.
function EventService.startFerrisWheel()
	if ferrisRunning then
		return
	end
	ferrisRunning = true
	EventWarn:FireAllClients("FERRIS", Config.FERRIS_WARN_SECONDS, "The ferris wheel broke loose! Clear the road!")
	Announce:FireAllClients("FERRIS WHEEL WARNING: it broke loose! Get out of the road in " .. Config.FERRIS_WARN_SECONDS .. " seconds!")
	task.wait(Config.FERRIS_WARN_SECONDS)
	EventStart:FireAllClients("FERRIS", Config.FERRIS_ROLL_SECONDS)
	local wheel = Workspace:FindFirstChild("RunawayWheel")
	if wheel then
		wheel.Transparency = 0
		for step = 1, 48 do
			wheel.Position = Vector3.new(-150 + step * 6.5, 12, 40)
			wheel.CFrame = wheel.CFrame * CFrame.Angles(0, 0, -0.13)
			-- Anyone in the wheel's path gets knocked back and drops their carry.
			for _, player in ipairs(Players:GetPlayers()) do
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if root and (root.Position - wheel.Position).Magnitude < 16 then
					StealService.dropCarry(player, "the runaway ferris wheel flattened them")
					root.AssemblyLinearVelocity = Vector3.new(0, 30, 60)
				end
			end
			task.wait(Config.FERRIS_ROLL_SECONDS / 48)
		end
		wheel.Transparency = 1
	end
	EventEnd:FireAllClients("FERRIS")
	Announce:FireAllClients("The ferris wheel rolled off into the scrap. It will be back.")
	ferrisRunning = false
end

--- The event scheduler: tsunamis and breakaways alternate on their own clocks.
function EventService.startScheduler()
	task.spawn(function()
		while true do
			task.wait(Config.TSUNAMI_PERIOD)
			EventService.startTsunami()
		end
	end)
	task.spawn(function()
		task.wait(60) -- first breakaway one minute in, so the yard settles first
		while true do
			task.wait(Config.FERRIS_PERIOD)
			EventService.startFerrisWheel()
		end
	end)
end

return EventService
