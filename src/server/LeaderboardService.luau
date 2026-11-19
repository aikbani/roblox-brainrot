-- LeaderboardService: the richest scrappers, on the big board by the spawn.
-- Every 15 seconds the server ranks every player by cash, takes the top 10,
-- and pushes the board to every client (the HUD leaderboard panel) and to the
-- physical board model in the yard (WorldBuilder's LeaderboardBoard, whose
-- SurfaceGui text labels are rewritten in place).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local GameService = require(script.Parent.GameService)

local LeaderboardService = {}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local LeaderboardChanged = Remotes:WaitForChild("LeaderboardChanged")

--- Returns the top N players as { {name, cash, rebirths} }, richest first.
function LeaderboardService.topPlayers(count: number)
	local rows = {}
	for player, state in pairs(GameService.Players) do
		table.insert(rows, { name = player.DisplayName, cash = state.cash, rebirths = state.rebirths })
	end
	table.sort(rows, function(a, b)
		return a.cash > b.cash
	end)
	while #rows > count do
		table.remove(rows)
	end
	return rows
end

--- Pushes the board to clients and rewrites the physical board's labels.
function LeaderboardService.refreshBoard()
	local top = LeaderboardService.topPlayers(Config.LEADERBOARD_TOP)
	LeaderboardChanged:FireAllClients(top)
	local board = Workspace:FindFirstChild("LeaderboardBoard")
	if board then
		local gui = board:FindFirstChildOfClass("SurfaceGui")
		if gui then
			for i, row in ipairs(top) do
				local label = gui:FindFirstChild("Row" .. i)
				if label and label:IsA("TextLabel") then
					label.Text = i .. ". " .. row.name .. " — $" .. row.cash .. " (R" .. row.rebirths .. ")"
				end
			end
		end
	end
end

--- The refresh loop: a fresh board every 15 seconds.
function LeaderboardService.startRefreshLoop()
	task.spawn(function()
		while true do
			task.wait(Config.LEADERBOARD_REFRESH)
			LeaderboardService.refreshBoard()
		end
	end)
end

return LeaderboardService
