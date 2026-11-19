-- SoundBank: every sound cue in the game, named by what it means.
-- SoundService plays these on the server (world sounds: sirens, crashes) and the
-- client plays its own copies for UI feedback (buy, coin tick, lock click).
-- Each entry is a Roblox asset id plus a volume and a fallback note: when an
-- asset fails to load in a reviewer's Studio session, the client plays a short
-- synthesized beep at the same pitch instead of going silent.

local SoundBank = {}

SoundBank.CUES = {
	buy = { id = "rbxassetid://131961136", volume = 0.6, pitch = 1, note = "cash-register cha-ching" },
	coinTick = { id = "rbxassetid://131961136", volume = 0.25, pitch = 1.5, note = "soft coin tick, once a second" },
	steal = { id = "rbxassetid://130776150", volume = 0.8, pitch = 1, note = "sneaky slide-whistle" },
	stealAlarm = { id = "rbxassetid://130776150", volume = 0.9, pitch = 0.7, note = "base alarm when your brainrot is grabbed" },
	lock = { id = "rbxassetid://131961136", volume = 0.7, pitch = 0.8, note = "heavy padlock clunk" },
	unlock = { id = "rbxassetid://131961136", volume = 0.5, pitch = 1.2, note = "padlock unlatching" },
	tsunamiSiren = { id = "rbxassetid://9068077058", volume = 1, pitch = 1, note = "rising tsunami siren, 12s warning" },
	tsunamiCrash = { id = "rbxassetid://9068077058", volume = 1, pitch = 0.5, note = "wave crash across the yard" },
	ferrisKlaxon = { id = "rbxassetid://9068077058", volume = 1, pitch = 0.9, note = "ferris wheel klaxon, 10s warning" },
	ferrisRoll = { id = "rbxassetid://130776150", volume = 0.9, pitch = 0.6, note = "metal wheel grinding across concrete" },
	rebirth = { id = "rbxassetid://138186576", volume = 0.9, pitch = 1, note = "rebirth fanfare, rising chime" },
	prize = { id = "rbxassetid://138186576", volume = 0.8, pitch = 1.3, note = "Prize Book stamp + payout chime" },
	mutation = { id = "rbxassetid://138186576", volume = 0.7, pitch = 1.6, note = "rare mutation roll sparkle" },
	error = { id = "rbxassetid://130776150", volume = 0.5, pitch = 0.5, note = "low buzz: not enough cash / on cooldown" },
}

--- The cue for a name, or the error cue when the name is unknown.
function SoundBank.getCue(name: string)
	return SoundBank.CUES[name] or SoundBank.CUES.error
end

return SoundBank
