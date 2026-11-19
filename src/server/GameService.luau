-- GameService: the single source of truth for player state.
-- Owns every scrapper's cash, collection, base, rebirths and carry slot, and the
-- one-second earnings tick that pays every brainrot on every base its $/s.
-- Other services ask GameService; they never touch a player's numbers directly.
-- State is kept in plain tables (not DataStores) so a Studio play-test runs
-- with zero setup; a production pass would swap savePlayer/loadPlayer for
-- DataStoreService without touching the callers.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotCatalog = require(ReplicatedStorage.Shared.BrainrotCatalog)
local Rarities = require(ReplicatedStorage.Shared.Rarities)
local Mutations = require(ReplicatedStorage.Shared.Mutations)
local Config = require(ReplicatedStorage.Shared.Config)

local GameService = {}

-- player -> { cash, rebirths, collection = { {defId, mutation, uid} }, baseId, carrying, lockedUntil, stealCooldownUntil }
GameService.Players = {}
-- baseId (1..8) -> userId that owns it, or nil
GameService.BaseOwners = {}
-- uid counter for placed brainrots (unique across the server)
local nextUid = 1

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StateChanged = Remotes:WaitForChild("StateChanged")
local CashTick = Remotes:WaitForChild("CashTick")
local Announce = Remotes:WaitForChild("Announce")

--- Cash per second of one owned brainrot, after rarity, mutation and rebirths.
function GameService.rateOf(entry, rebirths: number): number
	local def = BrainrotCatalog.getById(entry.defId)
	if not def then
		return 0
	end
	local rate = Rarities.rateFor(def)
	rate *= Mutations.multiplierFor(entry.mutation)
	rate *= (Config.REBIRTH_MULTIPLIER ^ rebirths)
	return rate
end

--- Total $/s of a player's whole collection.
function GameService.totalRate(player: Player): number
	local state = GameService.Players[player]
	if not state then
		return 0
	end
	local total = 0
	for _, entry in ipairs(state.collection) do
		total += GameService.rateOf(entry, state.rebirths)
	end
	return total
end

--- Creates a fresh state for a joining scrapper and gives them a free base.
function GameService.setupPlayer(player: Player)
	local state = {
		cash = Config.START_CASH,
		rebirths = 0,
		collection = {},
		baseId = nil,
		carrying = nil,
		lockedUntil = 0,
		stealCooldownUntil = 0,
		ownedIds = {},
		earnedTotal = 0,
		stolenCount = 0,
		survivedTsunamis = 0,
	}
	GameService.Players[player] = state
	-- First free base wins: the lowest-numbered unclaimed base is theirs.
	for baseId = 1, Config.BASE_COUNT do
		if GameService.BaseOwners[baseId] == nil then
			GameService.BaseOwners[baseId] = player.UserId
			state.baseId = baseId
			break
		end
	end
	GameService.pushState(player)
	return state
end

--- Frees a leaving player's base so the next scrapper can claim it.
function GameService.removePlayer(player: Player)
	local state = GameService.Players[player]
	if state and state.baseId then
		if GameService.BaseOwners[state.baseId] == player.UserId then
			GameService.BaseOwners[state.baseId] = nil
		end
	end
	GameService.Players[player] = nil
end

--- Adds one brainrot to a player's collection. Returns the entry (with uid).
function GameService.addBrainrot(player: Player, defId: string, mutation: string)
	local state = GameService.Players[player]
	if not state then
		return nil
	end
	local entry = { defId = defId, mutation = mutation, uid = nextUid }
	nextUid += 1
	table.insert(state.collection, entry)
	state.ownedIds[defId] = true
	GameService.pushState(player)
	return entry
end

--- Removes one brainrot entry (by uid) from a player's collection.
function GameService.removeBrainrot(player: Player, uid: number): boolean
	local state = GameService.Players[player]
	if not state then
		return false
	end
	for i, entry in ipairs(state.collection) do
		if entry.uid == uid then
			table.remove(state.collection, i)
			GameService.pushState(player)
			return true
		end
	end
	return false
end

--- True when a player's base is locked right now.
function GameService.isBaseLocked(player: Player): boolean
	local state = GameService.Players[player]
	if not state then
		return false
	end
	return os.time() < state.lockedUntil
end

--- Locks a player's base for Config.LOCK_SECONDS. Returns ok, message.
function GameService.lockBase(player: Player): (boolean, string)
	local state = GameService.Players[player]
	if not state then
		return false, "No state yet."
	end
	if not state.baseId then
		return false, "You have no base to lock."
	end
	if GameService.isBaseLocked(player) then
		return false, "Your base is already locked."
	end
	state.lockedUntil = os.time() + Config.LOCK_SECONDS
	GameService.pushState(player)
	Announce:FireAllClients(player.DisplayName .. " locked their scrap base! Thieves, back off!")
	return true, "Base locked for " .. Config.LOCK_SECONDS .. " seconds."
end

--- Sends the player's full state to their client (cash, collection, base, rebirths).
function GameService.pushState(player: Player)
	local state = GameService.Players[player]
	if not state then
		return
	end
	StateChanged:FireClient(player, {
		cash = state.cash,
		rebirths = state.rebirths,
		collection = state.collection,
		baseId = state.baseId,
		lockedUntil = state.lockedUntil,
		totalRate = GameService.totalRate(player),
		earnedTotal = state.earnedTotal,
	})
end

--- The earnings tick: every second, every brainrot on every base pays its $/s.
function GameService.startTickLoop()
	task.spawn(function()
		while true do
			task.wait(Config.TICK_SECONDS)
			for player, state in pairs(GameService.Players) do
				local gained = GameService.totalRate(player)
				if gained > 0 then
					state.cash += gained
					state.earnedTotal += gained
					CashTick:FireClient(player, gained, state.cash)
				end
			end
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	GameService.setupPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
	GameService.removePlayer(player)
end)

return GameService
