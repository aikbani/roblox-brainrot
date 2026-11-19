-- SoundService: plays world sounds and routes UI cues.
-- Server-side: sirens, crashes and the klaxon, played from parts in the yard
-- so every player hears them from the right direction. Client-side: the UI
-- cues (buy, coin tick, lock click) are played by the client's own SoundService
-- copy — this module only handles the world sounds, plus a helper the client
-- reuses to build a Sound instance from a SoundBank cue.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local SoundBank = require(ReplicatedStorage.Shared.SoundBank)

local SoundService = {}

--- Builds a Sound instance from a cue name (SoundBank), parented to `parent`.
function SoundService.buildSound(cueName: string, parent: Instance): Sound
	local cue = SoundBank.getCue(cueName)
	local sound = Instance.new("Sound")
	sound.SoundId = cue.id
	sound.Volume = cue.volume
	sound.PlaybackSpeed = cue.pitch
	sound.Parent = parent
	return sound
end

--- Plays a one-shot world sound from a position in the yard.
function SoundService.playWorldSound(cueName: string, position: Vector3)
	local anchor = Instance.new("Part")
	anchor.Name = "SoundAnchor"
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Position = position
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.Transparency = 1
	anchor.Parent = Workspace
	local sound = SoundService.buildSound(cueName, anchor)
	sound.Ended:Connect(function()
		anchor:Destroy()
	end)
	sound:Play()
	task.delay(10, function()
		if anchor.Parent then
			anchor:Destroy()
		end
	end)
end

--- The tsunami siren, heard across the whole yard.
function SoundService.playTsunamiSiren()
	SoundService.playWorldSound("tsunamiSiren", Vector3.new(0, 20, 0))
end

--- The ferris wheel klaxon, heard across the whole yard.
function SoundService.playFerrisKlaxon()
	SoundService.playWorldSound("ferrisKlaxon", Vector3.new(0, 20, 40))
end

--- The rebirth fanfare, played at the rebirthing player's base.
function SoundService.playRebirthFanfare(position: Vector3)
	SoundService.playWorldSound("rebirth", position)
end

return SoundService
