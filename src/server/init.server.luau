-- init: boots Scrapyard Brainrots.
-- Order matters, so it is written out here, not left to chance:
--   1. Create the Remotes folder every service waits on.
--   2. Build the dynamic world (bases, threats, scrap piles, board).
--   3. Fill the conveyor belt, then start the tick, restock, event, prize
--      and leaderboard loops.
--   4. Wire the client-facing RemoteFunctions (buy, steal, rebirth, lock).
-- A Studio play-test starts here with zero setup: no DataStores, no assets
-- to upload, no configuration. The whole game runs from this one boot.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. The Remotes folder: one RemoteEvent / RemoteFunction per client call.
local Remotes = Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = ReplicatedStorage

local eventNames = {
	"StateChanged", "CashTick", "Announce", "BeltChanged", "EventWarn",
	"EventStart", "EventEnd", "CarryDropped", "PrizeEarned", "LeaderboardChanged",
}
for _, name in ipairs(eventNames) do
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = Remotes
end

local functionNames = { "BuyBrainrot", "StealBrainrot", "DoRebirth", "LockBase" }
for _, name in ipairs(functionNames) do
	local remote = Instance.new("RemoteFunction")
	remote.Name = name
	remote.Parent = Remotes
end

-- 2. The world.
local WorldBuilder = require(script.WorldBuilder)
WorldBuilder.buildAll()

-- 3. The services, in dependency order.
local GameService = require(script.GameService)
local ShopService = require(script.ShopService)
local _StealService = require(script.StealService) -- required for its RemoteFunction handlers
local EventService = require(script.EventService)
local _RebirthService = require(script.RebirthService) -- required for its RemoteFunction handler
local PrizeBookService = require(script.PrizeBookService)
local LeaderboardService = require(script.LeaderboardService)
local SoundService = require(script.SoundService)

-- The lock RemoteFunction lives here (it is the one call no service owns).
local LockBase = Remotes:WaitForChild("LockBase")
LockBase.OnServerInvoke = function(player)
	return GameService.lockBase(player)
end

ShopService.fillBelt()
GameService.startTickLoop()
ShopService.startRestockLoop()
EventService.startScheduler()
PrizeBookService.startCheckLoop()
LeaderboardService.startRefreshLoop()

-- First board + first belt, immediately, so the first player sees a live yard.
LeaderboardService.refreshBoard()
SoundService.playWorldSound("buy", Vector3.new(0, 10, 0))

print("[Scrapyard Brainrots] Server booted: 48 brainrots, 7 rarities, 6 mutations, 8 bases, tsunami + ferris wheel armed.")
