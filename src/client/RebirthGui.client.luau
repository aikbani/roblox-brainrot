-- RebirthGui (client): trade everything for a permanent multiplier.
-- Toggle with R. Shows the current rebirth count, the current multiplier, the
-- cost of the next rebirth (25,000 doubling each time), and exactly what is
-- lost (the whole collection, listed by count). The big REBIRTH button asks
-- for a confirm click — the second click is the one that spends. At 5
-- rebirths the panel shows the SECRET UNLOCKED badge.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DoRebirth = Remotes:WaitForChild("DoRebirth")
local StateChanged = Remotes:WaitForChild("StateChanged")

local gui = Instance.new("ScreenGui")
gui.Name = "RebirthGui"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "RebirthFrame"
frame.Size = UDim2.new(0, 420, 0, 320)
frame.Position = UDim2.new(0.5, -210, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Name = "RebirthTitle"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "REBIRTH"
title.TextColor3 = Color3.fromRGB(255, 170, 0)
title.TextScaled = true
title.Font = Enum.Font.FredokaOne
title.Parent = frame

local info = Instance.new("TextLabel")
info.Name = "RebirthInfo"
info.Size = UDim2.new(1, -20, 0, 140)
info.Position = UDim2.new(0, 10, 0, 48)
info.BackgroundTransparency = 1
info.Text = "Rebirths: 0\nMultiplier: x1\nNext cost: $25,000\nCollection: 0 brainrots (all will be traded away)"
info.TextColor3 = Color3.new(1, 1, 1)
info.TextScaled = true
info.Font = Enum.Font.GothamBold
info.Parent = frame

local secretBadge = Instance.new("TextLabel")
secretBadge.Name = "SecretBadge"
secretBadge.Size = UDim2.new(1, -20, 0, 30)
secretBadge.Position = UDim2.new(0, 10, 0, 196)
secretBadge.BackgroundTransparency = 1
secretBadge.Text = "Reach 5 rebirths to unlock SECRET brainrots!"
secretBadge.TextColor3 = Color3.fromRGB(0, 230, 220)
secretBadge.TextScaled = true
secretBadge.Font = Enum.Font.GothamBold
secretBadge.Parent = frame

local confirmArmed = false
local button = Instance.new("TextButton")
button.Name = "RebirthButton"
button.Size = UDim2.new(1, -20, 0, 56)
button.Position = UDim2.new(0, 10, 0, 240)
button.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
button.Text = "REBIRTH — trade my collection for x2 forever"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.FredokaOne
button.MouseButton1Click:Connect(function()
	if not confirmArmed then
		confirmArmed = true
		button.Text = "ARE YOU SURE? Click again to rebirth!"
		task.delay(5, function()
			confirmArmed = false
			button.Text = "REBIRTH — trade my collection for x2 forever"
		end)
		return
	end
	confirmArmed = false
	button.Text = "REBIRTH — trade my collection for x2 forever"
	local _ok, message = DoRebirth:InvokeServer()
	print("[Rebirth] " .. tostring(message))
end)
button.Parent = frame

StateChanged.OnClientEvent:Connect(function(state)
	local nextCost = 25000 * (2 ^ state.rebirths)
	info.Text = "Rebirths: " .. state.rebirths .. "\nMultiplier: x" .. (2 ^ state.rebirths)
		.. "\nNext cost: $" .. nextCost
		.. "\nCollection: " .. #state.collection .. " brainrots (all will be traded away)"
	if state.rebirths >= 5 then
		secretBadge.Text = "SECRET UNLOCKED: Secret brainrots roll on your conveyor!"
	else
		secretBadge.Text = "Reach 5 rebirths to unlock SECRET brainrots! (" .. state.rebirths .. "/5)"
	end
end)

local function toggleRebirth(_action: string, state: EnumItem, _input: InputObject)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	gui.Enabled = not gui.Enabled
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("ToggleRebirth", toggleRebirth, false, Enum.KeyCode.R)
print("[Scrapyard Brainrots] Rebirth GUI ready: press R.")
