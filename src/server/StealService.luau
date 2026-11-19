-- StealService: steal-from-rivals, the heart of the tension.
-- Walk onto a rival's base, grab one of their brainrots, and dash home with it.
-- The catch: carrying a stolen brainrot slows you to 55% walk speed, slaps a
-- flashing STEALER tag over your head for 20 seconds, and sounds the victim's
-- base alarm so the whole yard knows. Reach your own base and the brainrot is
-- yours; get tagged by a tsunami or the ferris wheel on the way and you drop it.
-- Locked bases cannot be stolen from at all — that is what the lock is for.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local GameService = require(script.Parent.GameService)

local StealService = {}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StealBrainrot = Remotes:WaitForChild("StealBrainrot")
local CarryDropped = Remotes:WaitForChild("CarryDropped")
local Announce = Remotes:WaitForChild("Announce")

--- Steals one brainrot (by uid) off a victim's base. Returns ok, message.
function StealService.stealBrainrot(thief: Player, victim: Player, uid: number): (boolean, string)
	local thiefState = GameService.Players[thief]
	local victimState = GameService.Players[victim]
	if not thiefState or not victimState then
		return false, "Someone left the yard."
	end
	if thief == victim then
		return false, "That is your own brainrot. Nice try."
	end
	if thiefState.carrying then
		return false, "Your hands are full already. Drop it off first."
	end
	if os.time() < thiefState.stealCooldownUntil then
		return false, "Steal is on cooldown. Wait a few seconds."
	end
	if GameService.isBaseLocked(victim) then
		return false, victim.DisplayName .. "'s base is LOCKED. Come back later."
	end
	local stolen = nil
	for _, entry in ipairs(victimState.collection) do
		if entry.uid == uid then
			stolen = entry
			break
		end
	end
	if not stolen then
		return false, "That brainrot is gone already."
	end
	GameService.removeBrainrot(victim, uid)
	thiefState.carrying = stolen
	thiefState.stealCooldownUntil = os.time() + Config.STEAL_COOLDOWN
	-- Slow the thief down: the dash home is the whole game.
	local character = thief.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16 * Config.STEAL_SLOW
		end
	end
	Announce:FireAllClients("STEALER! " .. thief.DisplayName .. " grabbed " .. victim.DisplayName .. "'s brainrot! Chase them!")
	Announce:FireClient(victim, thief.DisplayName .. " is stealing your brainrot! Stop them!")
	GameService.pushState(thief)
	GameService.pushState(victim)
	-- The STEALER tag fades after 20s; the slow walk stays until the drop-off.
	task.delay(Config.STEAL_TAG_SECONDS, function()
		Announce:FireAllClients(thief.DisplayName .. "'s stealer tag faded.")
	end)
	return true, "Run! Get it to your base!"
end

--- Delivers a carried brainrot onto the thief's own base: it is theirs now.
function StealService.deliverCarry(player: Player): (boolean, string)
	local state = GameService.Players[player]
	if not state or not state.carrying then
		return false, "You are not carrying anything."
	end
	if #state.collection >= Config.BASE_SLOTS then
		return false, "Your base is full! Sell something first."
	end
	local carried = state.carrying
	state.carrying = nil
	GameService.addBrainrot(player, carried.defId, carried.mutation)
	state.stolenCount += 1
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16
		end
	end
	Announce:FireAllClients(player.DisplayName .. " got away with the steal! The brainrot is theirs now.")
	GameService.pushState(player)
	return true, "Stolen brainrot secured on your base!"
end

--- Forces a player to drop what they carry (tsunami / ferris wheel hit).
function StealService.dropCarry(player: Player, reason: string)
	local state = GameService.Players[player]
	if not state or not state.carrying then
		return
	end
	local dropped = state.carrying
	state.carrying = nil
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16
		end
	end
	CarryDropped:FireClient(player, reason)
	Announce:FireAllClients(player.DisplayName .. " dropped the stolen brainrot — " .. reason .. "!")
	GameService.pushState(player)
end

StealBrainrot.OnServerInvoke = function(player, victim, uid)
	return StealService.stealBrainrot(player, victim, uid)
end

return StealService
