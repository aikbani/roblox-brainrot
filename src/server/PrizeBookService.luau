-- PrizeBookService: milestones that pay out.
-- The Prize Book is a stamp book of 12 achievements, from the first catch to
-- surviving three tsunamis. Each one pays cash the moment it is earned and
-- stamps the book in the Prize Book GUI. Finishing all 12 pays a $100,000
-- jackpot and the "Scrap Royalty" title. Checks run after every tick, buy,
-- steal and event, so a prize lands the second it is earned.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameService = require(script.Parent.GameService)

local PrizeBookService = {}

-- player -> set of earned prize ids
PrizeBookService.Earned = {}

PrizeBookService.PRIZES = {
	{ id = "first_catch", name = "First Catch", desc = "Buy your first brainrot", cash = 100, check = function(s) return #s.collection >= 1 end },
	{ id = "full_shelf", name = "Full Shelf", desc = "Own 5 brainrots at once", cash = 500, check = function(s) return #s.collection >= 5 end },
	{ id = "base_full", name = "Base Full", desc = "Fill all 10 base slots", cash = 2000, check = function(s) return #s.collection >= 10 end },
	{ id = "first_steal", name = "Sticky Fingers", desc = "Steal a brainrot and get it home", cash = 1000, check = function(s) return s.stolenCount >= 1 end },
	{ id = "thief_trio", name = "Thief Trio", desc = "Complete 3 successful steals", cash = 5000, check = function(s) return s.stolenCount >= 3 end },
	{ id = "rich_10k", name = "Ten Grand", desc = "Hold $10,000 at once", cash = 1000, check = function(s) return s.cash >= 10000 end },
	{ id = "rich_100k", name = "Six Figures", desc = "Hold $100,000 at once", cash = 10000, check = function(s) return s.cash >= 100000 end },
	{ id = "million_earned", name = "Millionaire Scrapper", desc = "Earn $1,000,000 in total", cash = 25000, check = function(s) return s.earnedTotal >= 1000000 end },
	{ id = "first_rebirth", name = "Born Again", desc = "Rebirth for the first time", cash = 5000, check = function(s) return s.rebirths >= 1 end },
	{ id = "survivor", name = "Tsunami Survivor", desc = "Survive 3 tsunamis on high ground", cash = 3000, check = function(s) return s.survivedTsunamis >= 3 end },
	{ id = "collector_20", name = "Half the Yard", desc = "Own 20 different brainrots", cash = 8000, check = function(s)
		local n = 0
		for _ in pairs(s.ownedIds) do n += 1 end
		return n >= 20
	end },
	{ id = "collector_all", name = "Scrap Royalty", desc = "Own all 48 brainrots at least once", cash = 100000, check = function(s)
		local n = 0
		for _ in pairs(s.ownedIds) do n += 1 end
		return n >= 48
	end },
}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PrizeEarned = Remotes:WaitForChild("PrizeEarned")
local Announce = Remotes:WaitForChild("Announce")

--- Checks every unearned prize for a player and pays out the ones now earned.
function PrizeBookService.checkPrizes(player: Player)
	local state = GameService.Players[player]
	if not state then
		return
	end
	local earned = PrizeBookService.Earned[player]
	if not earned then
		earned = {}
		PrizeBookService.Earned[player] = earned
	end
	for _, prize in ipairs(PrizeBookService.PRIZES) do
		if not earned[prize.id] then
			local ok, passed = pcall(prize.check, state)
			if ok and passed then
				earned[prize.id] = true
				state.cash += prize.cash
				PrizeEarned:FireClient(player, prize.id, prize.name, prize.cash)
				Announce:FireClient(player, "PRIZE BOOK: " .. prize.name .. " — $" .. prize.cash .. "!")
				if prize.id == "collector_all" then
					Announce:FireAllClients(player.DisplayName .. " completed the Prize Book and is now SCRAP ROYALTY!")
				end
			end
		end
	end
end

--- The prize loop: re-checks everyone every 5 seconds (cheap; 12 checks each).
function PrizeBookService.startCheckLoop()
	task.spawn(function()
		while true do
			task.wait(5)
			for player in pairs(GameService.Players) do
				PrizeBookService.checkPrizes(player)
			end
		end
	end)
end

return PrizeBookService
