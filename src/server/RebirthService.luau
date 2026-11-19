-- RebirthService: trade everything for a permanent multiplier.
-- A rebirth costs cash (25,000 for the first, doubling each time) and wipes the
-- whole collection — every brainrot goes back into the scrap. In return the
-- scrapper keeps a permanent x2 earnings multiplier per rebirth (x1024 at 10),
-- a Rebirth Crown over their base, and a new title. Five rebirths unlock the
-- Secret spawn on the conveyor. The Rebirth GUI shows the cost, the multiplier
-- and exactly what is lost, and asks for a confirm click: no accidental wipes.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local GameService = require(script.Parent.GameService)

local RebirthService = {}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DoRebirth = Remotes:WaitForChild("DoRebirth")
local Announce = Remotes:WaitForChild("Announce")

--- Cash cost of the NEXT rebirth for a player with `rebirths` already done.
function RebirthService.costFor(rebirths: number): number
	return Config.REBIRTH_BASE_COST * (2 ^ rebirths)
end

--- The earnings multiplier a player with `rebirths` rebirths enjoys.
function RebirthService.multiplierFor(rebirths: number): number
	return Config.REBIRTH_MULTIPLIER ^ rebirths
end

--- Performs a rebirth. Returns ok, message.
function RebirthService.doRebirth(player: Player): (boolean, string)
	local state = GameService.Players[player]
	if not state then
		return false, "No state yet."
	end
	if state.rebirths >= Config.REBIRTH_MAX then
		return false, "You are at max rebirth (x" .. RebirthService.multiplierFor(state.rebirths) .. "). The yard bows to you."
	end
	local cost = RebirthService.costFor(state.rebirths)
	if state.cash < cost then
		return false, "Rebirth costs $" .. cost .. ". You have $" .. state.cash .. "."
	end
	if state.carrying then
		return false, "Drop off what you are carrying first."
	end
	local lost = #state.collection
	state.cash -= cost
	state.collection = {}
	state.rebirths += 1
	GameService.pushState(player)
	Announce:FireAllClients(player.DisplayName .. " REBIRTHED! " .. lost .. " brainrots traded for a permanent x"
		.. RebirthService.multiplierFor(state.rebirths) .. " multiplier!")
	if state.rebirths == Config.REBIRTH_SECRET_UNLOCK then
		Announce:FireClient(player, "SECRET UNLOCKED: Secret brainrots can now roll on your conveyor!")
	end
	return true, "Rebirth " .. state.rebirths .. " complete! All earnings x" .. RebirthService.multiplierFor(state.rebirths) .. " forever."
end

DoRebirth.OnServerInvoke = function(player)
	return RebirthService.doRebirth(player)
end

return RebirthService
