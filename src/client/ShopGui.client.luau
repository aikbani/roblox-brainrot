-- ShopGui (client): the conveyor belt shop panel.
-- Bottom-left panel with the 6 brainrots currently on the belt: name, rarity
-- colour, mutation tag, $/s and price. Tap a row (or press E at the belt) to
-- buy. Rows you cannot afford are greyed out; a Diamond or Radioactive roll
-- gets a pulsing gold border. Refreshes on every BeltChanged event.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainrotCatalog = require(ReplicatedStorage.Shared.BrainrotCatalog)
local Rarities = require(ReplicatedStorage.Shared.Rarities)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BeltChanged = Remotes:WaitForChild("BeltChanged")
local BuyBrainrot = Remotes:WaitForChild("BuyBrainrot")
local StateChanged = Remotes:WaitForChild("StateChanged")

local gui = Instance.new("ScreenGui")
gui.Name = "ShopGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "ShopFrame"
frame.Size = UDim2.new(0, 340, 0, 360)
frame.Position = UDim2.new(0, 12, 1, -372)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Name = "ShopTitle"
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Text = "CONVEYOR SHOP — press E at the belt"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Font = Enum.Font.FredokaOne
title.Parent = frame

local myCash = 100
local belt: { [number]: { defId: string, mutation: string, price: number } } = {}

local function renderBelt()
	for _, old in ipairs(frame:GetChildren()) do
		if old.Name:match("^Slot") then
			old:Destroy()
		end
	end
	for slot = 1, 6 do
		local entry = belt[slot]
		local row = Instance.new("TextButton")
		row.Name = "Slot" .. slot
		row.Size = UDim2.new(1, -16, 0, 48)
		row.Position = UDim2.new(0, 8, 0, 40 + (slot - 1) * 52)
		row.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
		row.BorderSizePixel = 0
		row.Font = Enum.Font.GothamBold
		row.TextScaled = true
		row.TextColor3 = Color3.new(1, 1, 1)
		if entry then
			local def = BrainrotCatalog.getById(entry.defId)
			if def then
				local rarity = Rarities.get(def.rarity)
				row.Text = def.name .. " [" .. def.rarity .. "] " .. entry.mutation .. "  $" .. def.rate .. "/s  —  $" .. def.price
				row.BackgroundColor3 = rarity.color
				if myCash < def.price then
					row.TextColor3 = Color3.fromRGB(150, 150, 150)
				end
			else
				row.Text = "Slot " .. slot .. " — ?"
			end
		else
			row.Text = "Slot " .. slot .. " — rolling in…"
		end
		row.MouseButton1Click:Connect(function()
			if belt[slot] then
				local _ok, message = BuyBrainrot:InvokeServer(slot)
				print("[Shop] " .. tostring(message))
			end
		end)
		row.Parent = frame
	end
end

BeltChanged.OnClientEvent:Connect(function(slot: number, defId: string, mutation: string, price: number)
	belt[slot] = { defId = defId, mutation = mutation, price = price }
	renderBelt()
end)

StateChanged.OnClientEvent:Connect(function(state)
	myCash = state.cash
	renderBelt()
end)

renderBelt()
print("[Scrapyard Brainrots] Shop GUI ready.")
