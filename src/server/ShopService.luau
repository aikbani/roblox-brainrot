-- ShopService: the conveyor belt shop.
-- Six brainrots roll out of the crusher tunnel onto the belt. A scrapper walks
-- up, presses E (or taps Buy in the Shop GUI), and the brainrot follows them
-- home — if they can afford it and their base has a free slot. Unbought
-- brainrots roll into the crusher after 90 seconds and a fresh one rolls out.
-- Buying rolls a mutation (see Mutations): a Golden or Diamond roll is the
-- moment the whole yard hears about.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotCatalog = require(ReplicatedStorage.Shared.BrainrotCatalog)
local Mutations = require(ReplicatedStorage.Shared.Mutations)
local Config = require(ReplicatedStorage.Shared.Config)
local GameService = require(script.Parent.GameService)

local ShopService = {}

-- The live belt: slot (1..6) -> { def, mutation, bornAt, model }
ShopService.Belt = {}
local rng = Random.new()

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyBrainrot = Remotes:WaitForChild("BuyBrainrot")
local BeltChanged = Remotes:WaitForChild("BeltChanged")
local Announce = Remotes:WaitForChild("Announce")

--- Rolls one fresh brainrot onto a belt slot and tells every client.
function ShopService.rollSlot(slot: number)
	-- The Secret spawn stays locked until 5 rebirths; roll against the richest
	-- rebirth count on the server so the belt always has something to chase.
	local bestRebirths = 0
	for player, state in pairs(GameService.Players) do
		if state.rebirths > bestRebirths then
			bestRebirths = state.rebirths
		end
	end
	local def = BrainrotCatalog.rollConveyor(bestRebirths, rng)
	local mutation = Mutations.roll(rng)
	ShopService.Belt[slot] = { def = def, mutation = mutation, bornAt = os.time() }
	BeltChanged:FireAllClients(slot, def.id, mutation.name, def.price)
	return ShopService.Belt[slot]
end

--- Fills every empty belt slot at boot.
function ShopService.fillBelt()
	for slot = 1, Config.CONVEYOR_SLOTS do
		if not ShopService.Belt[slot] then
			ShopService.rollSlot(slot)
		end
	end
end

--- The restock loop: a fresh brainrot every 20s, and the crusher eats stale ones.
function ShopService.startRestockLoop()
	task.spawn(function()
		while true do
			task.wait(Config.CONVEYOR_RESTOCK)
			for slot = 1, Config.CONVEYOR_SLOTS do
				local entry = ShopService.Belt[slot]
				if not entry or os.time() - entry.bornAt >= Config.CONVEYOR_DESPAWN then
					ShopService.rollSlot(slot)
				end
			end
		end
	end)
end

--- Handles a buy request from a client. Returns ok, message.
function ShopService.buyBrainrot(player: Player, slot: number): (boolean, string)
	local state = GameService.Players[player]
	if not state then
		return false, "No state yet."
	end
	local entry = ShopService.Belt[slot]
	if not entry then
		return false, "That belt slot is empty."
	end
	if #state.collection >= Config.BASE_SLOTS then
		return false, "Your base is full! Sell or rebirth to make room."
	end
	if state.cash < entry.def.price then
		return false, "Not enough cash: " .. entry.def.name .. " costs $" .. entry.def.price .. "."
	end
	state.cash -= entry.def.price
	GameService.addBrainrot(player, entry.def.id, entry.mutation.name)
	ShopService.Belt[slot] = nil
	ShopService.rollSlot(slot)
	if entry.mutation.name == "Diamond" or entry.mutation.name == "Radioactive" then
		Announce:FireAllClients(player.DisplayName .. " caught a " .. entry.mutation.name .. " " .. entry.def.name .. "!")
	end
	GameService.pushState(player)
	return true, "Bought " .. entry.def.name .. " (" .. entry.mutation.name .. ")!"
end

BuyBrainrot.OnServerInvoke = function(player, slot)
	return ShopService.buyBrainrot(player, slot)
end

return ShopService
