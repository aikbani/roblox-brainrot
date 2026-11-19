-- PrizeBookGui (client): the 12-prize stamp book.
-- Toggle with P. Lists all 12 prizes with their description and cash payout;
-- earned ones are stamped gold with a checkmark, unearned ones are grey. The
-- book also shows the jackpot: finish all 12 for $100,000 and the
-- "Scrap Royalty" title. PrizeEarned events stamp the book live with a chime.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PrizeEarned = Remotes:WaitForChild("PrizeEarned")

local PRIZES = {
	{ id = "first_catch", name = "First Catch", desc = "Buy your first brainrot", cash = 100 },
	{ id = "full_shelf", name = "Full Shelf", desc = "Own 5 brainrots at once", cash = 500 },
	{ id = "base_full", name = "Base Full", desc = "Fill all 10 base slots", cash = 2000 },
	{ id = "first_steal", name = "Sticky Fingers", desc = "Steal a brainrot and get it home", cash = 1000 },
	{ id = "thief_trio", name = "Thief Trio", desc = "Complete 3 successful steals", cash = 5000 },
	{ id = "rich_10k", name = "Ten Grand", desc = "Hold $10,000 at once", cash = 1000 },
	{ id = "rich_100k", name = "Six Figures", desc = "Hold $100,000 at once", cash = 10000 },
	{ id = "million_earned", name = "Millionaire Scrapper", desc = "Earn $1,000,000 in total", cash = 25000 },
	{ id = "first_rebirth", name = "Born Again", desc = "Rebirth for the first time", cash = 5000 },
	{ id = "survivor", name = "Tsunami Survivor", desc = "Survive 3 tsunamis on high ground", cash = 3000 },
	{ id = "collector_20", name = "Half the Yard", desc = "Own 20 different brainrots", cash = 8000 },
	{ id = "collector_all", name = "Scrap Royalty", desc = "Own all 48 brainrots at least once", cash = 100000 },
}

local earned: { [string]: boolean } = {}

local gui = Instance.new("ScreenGui")
gui.Name = "PrizeBookGui"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "PrizeFrame"
frame.Size = UDim2.new(0, 480, 0, 520)
frame.Position = UDim2.new(0.5, -240, 0.5, -260)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Name = "PrizeTitle"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "PRIZE BOOK — finish all 12 for $100,000"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Font = Enum.Font.FredokaOne
title.Parent = frame

local function renderBook()
	for _, old in ipairs(frame:GetChildren()) do
		if old.Name:match("^Prize") then
			old:Destroy()
		end
	end
	for i, prize in ipairs(PRIZES) do
		local row = Instance.new("Frame")
		row.Name = "Prize" .. prize.id
		row.Size = UDim2.new(1, -16, 0, 36)
		row.Position = UDim2.new(0, 8, 0, 44 + (i - 1) * 38)
		row.BackgroundColor3 = earned[prize.id] and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(40, 40, 52)
		row.BackgroundTransparency = earned[prize.id] and 0.2 or 0.4
		row.BorderSizePixel = 0
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -8, 1, 0)
		label.Position = UDim2.new(0, 4, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = (earned[prize.id] and "✓ " or "○ ") .. prize.name .. " — " .. prize.desc .. "  ($" .. prize.cash .. ")"
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = row
		row.Parent = frame
	end
end

PrizeEarned.OnClientEvent:Connect(function(id: string, name: string, cash: number)
	earned[id] = true
	renderBook()
	print("[Prize Book] Earned: " .. name .. " (+$" .. cash .. ")")
end)

local function togglePrizeBook(_action: string, state: EnumItem, _input: InputObject)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	gui.Enabled = not gui.Enabled
	if gui.Enabled then
		renderBook()
	end
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("TogglePrizeBook", togglePrizeBook, false, Enum.KeyCode.P)
renderBook()
print("[Scrapyard Brainrots] Prize Book ready: press P.")
