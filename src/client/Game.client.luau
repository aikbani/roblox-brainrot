-- Game (client): the player's hands in the yard.
-- Owns movement keys (ContextActionService, so the arrow keys still drive the
-- default camera), the E-to-buy prompt on the conveyor, the click-to-steal
-- prompt on rival bases, and the walk-into-your-base delivery that banks a
-- stolen brainrot. Everything it does asks the server through a RemoteFunction;
-- the client never grants itself cash, a brainrot, or a lock.
-- HUD, shop, index, rebirth and prize book each live in their own LocalScript.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyBrainrot = Remotes:WaitForChild("BuyBrainrot")
local StealBrainrot = Remotes:WaitForChild("StealBrainrot")
local LockBase = Remotes:WaitForChild("LockBase")
local StateChanged = Remotes:WaitForChild("StateChanged")

local myBaseId = nil
local carrying = false

StateChanged.OnClientEvent:Connect(function(state)
	myBaseId = state.baseId
end)

--- The nearest belt slot to the player, or nil when far from the conveyor.
local function nearestBeltSlot(): number?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end
	local belt = Workspace:FindFirstChild("ConveyorBelt")
	if not belt then
		return nil
	end
	for slot = 1, 6 do
		local pad = belt:FindFirstChild("BeltPad" .. slot)
		if pad and (root.Position - pad.Position).Magnitude < 10 then
			return slot
		end
	end
	return nil
end

--- E: buy the brainrot on the belt slot in front of you.
local function onBuyKey(_action: string, state: EnumItem, _input: InputObject)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	local slot = nearestBeltSlot()
	if not slot then
		return Enum.ContextActionResult.Pass
	end
	local _ok, message = BuyBrainrot:InvokeServer(slot)
	print("[Shop] " .. tostring(message))
	return Enum.ContextActionResult.Sink
end

--- L: lock your own base for 60 seconds (thieves cannot steal from it).
local function onLockKey(_action: string, state: EnumItem, _input: InputObject)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	local _ok, message = LockBase:InvokeServer()
	print("[Lock] " .. tostring(message))
	return Enum.ContextActionResult.Sink
end

--- Click a brainrot on a rival's base to steal it (prompted by the HUD).
local function onStealClick(victim: Player, uid: number)
	if carrying then
		print("[Steal] Your hands are full already.")
		return
	end
	local ok, message = StealBrainrot:InvokeServer(victim, uid)
	print("[Steal] " .. tostring(message))
	if ok then
		carrying = true
	end
end

--- Walking onto your own base pad banks a carried brainrot.
local function watchBaseDelivery()
	while true do
		task.wait(0.5)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if carrying and root and myBaseId then
			local pad = Workspace:FindFirstChild("Bases") and Workspace.Bases:FindFirstChild("BasePad" .. myBaseId)
			if pad and (root.Position - pad.Position).Magnitude < 14 then
				carrying = false
				print("[Steal] Delivered! The brainrot is yours now.")
			end
		end
	end
end

ContextActionService:BindAction("BuyBrainrot", onBuyKey, false, Enum.KeyCode.E)
ContextActionService:BindAction("LockBase", onLockKey, false, Enum.KeyCode.L)
task.spawn(watchBaseDelivery)

-- Exposed for the HUD steal buttons.
_G.ScrapyardSteal = onStealClick

print("[Scrapyard Brainrots] Client ready: E to buy, L to lock your base.")
