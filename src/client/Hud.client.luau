-- Hud (client): the cash counter, the event banners and the announcements.
-- Top-cent: cash (ticking every second) and $/s rate, big enough to read at a
-- glance. Top-right: the leaderboard panel. Centre: the event banner — tsunami
-- and ferris-wheel warnings with a live countdown, then a full-width "RUN!"
-- flash while the event sweeps the yard. Bottom: the announcement toast feed.
-- Nothing is drawn over the top-left corner: Roblox's own menu buttons live there.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CashTick = Remotes:WaitForChild("CashTick")
local StateChanged = Remotes:WaitForChild("StateChanged")
local Announce = Remotes:WaitForChild("Announce")
local EventWarn = Remotes:WaitForChild("EventWarn")
local EventStart = Remotes:WaitForChild("EventStart")
local EventEnd = Remotes:WaitForChild("EventEnd")
local LeaderboardChanged = Remotes:WaitForChild("LeaderboardChanged")

local gui = Instance.new("ScreenGui")
gui.Name = "ScrapyardHud"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Cash counter, top-cent.
local cashFrame = Instance.new("Frame")
cashFrame.Name = "CashFrame"
cashFrame.Size = UDim2.new(0, 320, 0, 90)
cashFrame.Position = UDim2.new(0.5, -160, 0, 12)
cashFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
cashFrame.BackgroundTransparency = 0.2
cashFrame.BorderSizePixel = 0
cashFrame.Parent = gui
local cashLabel = Instance.new("TextLabel")
cashLabel.Name = "CashLabel"
cashLabel.Size = UDim2.new(1, 0, 0.6, 0)
cashLabel.BackgroundTransparency = 1
cashLabel.Text = "$100"
cashLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
cashLabel.TextScaled = true
cashLabel.Font = Enum.Font.FredokaOne
cashLabel.Parent = cashFrame
local rateLabel = Instance.new("TextLabel")
rateLabel.Name = "RateLabel"
rateLabel.Size = UDim2.new(1, 0, 0.4, 0)
rateLabel.Position = UDim2.new(0, 0, 0.6, 0)
rateLabel.BackgroundTransparency = 1
rateLabel.Text = "+$0/s  |  Rebirth x1"
rateLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
rateLabel.TextScaled = true
rateLabel.Font = Enum.Font.GothamBold
rateLabel.Parent = cashFrame

-- Event banner, centre screen.
local banner = Instance.new("Frame")
banner.Name = "EventBanner"
banner.Size = UDim2.new(0, 560, 0, 110)
banner.Position = UDim2.new(0.5, -280, 0, 120)
banner.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
banner.BackgroundTransparency = 0.15
banner.Visible = false
banner.Parent = gui
local bannerTitle = Instance.new("TextLabel")
bannerTitle.Name = "BannerTitle"
bannerTitle.Size = UDim2.new(1, 0, 0.5, 0)
bannerTitle.BackgroundTransparency = 1
bannerTitle.Text = "TSUNAMI WARNING"
bannerTitle.TextColor3 = Color3.new(1, 1, 1)
bannerTitle.TextScaled = true
bannerTitle.Font = Enum.Font.FredokaOne
bannerTitle.Parent = banner
local bannerSub = Instance.new("TextLabel")
bannerSub.Name = "BannerSub"
bannerSub.Size = UDim2.new(1, 0, 0.5, 0)
bannerSub.Position = UDim2.new(0, 0, 0.5, 0)
bannerSub.BackgroundTransparency = 1
bannerSub.Text = "Climb high! 12s"
bannerSub.TextColor3 = Color3.new(1, 1, 1)
bannerSub.TextScaled = true
bannerSub.Font = Enum.Font.GothamBold
bannerSub.Parent = banner

-- Leaderboard panel, top-right.
local boardFrame = Instance.new("Frame")
boardFrame.Name = "LeaderboardFrame"
boardFrame.Size = UDim2.new(0, 260, 0, 300)
boardFrame.Position = UDim2.new(1, -276, 0, 12)
boardFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
boardFrame.BackgroundTransparency = 0.2
boardFrame.BorderSizePixel = 0
boardFrame.Parent = gui
local boardTitle = Instance.new("TextLabel")
boardTitle.Name = "BoardTitle"
boardTitle.Size = UDim2.new(1, 0, 0, 30)
boardTitle.BackgroundTransparency = 1
boardTitle.Text = "RICHEST SCRAPPERS"
boardTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
boardTitle.TextScaled = true
boardTitle.Font = Enum.Font.FredokaOne
boardTitle.Parent = boardFrame

-- Announcement toasts, bottom-cent.
local toast = Instance.new("TextLabel")
toast.Name = "Toast"
toast.Size = UDim2.new(0, 640, 0, 40)
toast.Position = UDim2.new(0.5, -320, 1, -60)
toast.BackgroundTransparency = 1
toast.Text = ""
toast.TextColor3 = Color3.new(1, 1, 1)
toast.TextScaled = true
toast.Font = Enum.Font.GothamBold
toast.Parent = gui

local function setCash(amount: number)
	cashLabel.Text = "$" .. math.floor(amount)
end

CashTick.OnClientEvent:Connect(function(gained: number, total: number)
	setCash(total)
	rateLabel.Text = "+$" .. gained .. "/s ticking"
end)

StateChanged.OnClientEvent:Connect(function(state)
	setCash(state.cash)
	rateLabel.Text = "+$" .. state.totalRate .. "/s  |  Rebirth x" .. (2 ^ state.rebirths) .. "  |  Base #" .. tostring(state.baseId)
end)

local toastUntil = 0
Announce.OnClientEvent:Connect(function(message: string)
	toast.Text = message
	toastUntil = os.clock() + 4
	task.delay(4, function()
		if os.clock() >= toastUntil then
			toast.Text = ""
		end
	end)
end)

local countdownThread = nil
EventWarn.OnClientEvent:Connect(function(kind: string, seconds: number, message: string)
	banner.Visible = true
	bannerTitle.Text = kind == "TSUNAMI" and "TSUNAMI WARNING" or "RUNAWAY FERRIS WHEEL"
	banner.BackgroundColor3 = kind == "TSUNAMI" and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(200, 30, 200)
	if countdownThread then
		task.cancel(countdownThread)
	end
	countdownThread = task.spawn(function()
		for left = seconds, 1, -1 do
			bannerSub.Text = message .. "  " .. left .. "s"
			task.wait(1)
		end
	end)
end)

EventStart.OnClientEvent:Connect(function(kind: string, _seconds: number)
	bannerTitle.Text = kind == "TSUNAMI" and "TSUNAMI! RUN HIGH!" or "FERRIS WHEEL! CLEAR THE ROAD!"
	bannerSub.Text = "Hold on!"
end)

EventEnd.OnClientEvent:Connect(function(_kind: string)
	banner.Visible = false
end)

LeaderboardChanged.OnClientEvent:Connect(function(top)
	for _, old in ipairs(boardFrame:GetChildren()) do
		if old.Name:match("^Row") then
			old:Destroy()
		end
	end
	for i, row in ipairs(top) do
		local label = Instance.new("TextLabel")
		label.Name = "Row" .. i
		label.Size = UDim2.new(1, 0, 0, 26)
		label.Position = UDim2.new(0, 0, 0, 30 + (i - 1) * 26)
		label.BackgroundTransparency = 1
		label.Text = i .. ". " .. row.name .. " — $" .. row.cash
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = boardFrame
	end
end)

print("[Scrapyard Brainrots] HUD ready.")
