-- Config: every tuning number of Scrapyard Brainrots in one place.
-- GameService, ShopService, StealService, EventService and RebirthService all
-- read from here, so a balance change is one edit, not a hunt through scripts.

local Config = {}

-- Money
Config.START_CASH = 100 -- every scrapper starts with $100, enough for a Common
Config.BASE_SLOTS = 10 -- brainrot slots on each base
Config.BASE_COUNT = 8 -- scrap bases around the yard
Config.BASE_PRICE = 0 -- bases are free to claim; the fight is over what is on them
Config.SELL_FRACTION = 0.5 -- selling a brainrot back pays half its price
Config.TICK_SECONDS = 1 -- earnings tick every second

-- Stealing
Config.LOCK_SECONDS = 60 -- a base lock lasts 60 seconds
Config.LOCK_COOLDOWN = 90 -- seconds before the same base can lock again
Config.STEAL_SLOW = 0.55 -- carrying a stolen brainrot cuts walk speed to 55%
Config.STEAL_TAG_SECONDS = 20 -- the STEALER tag (and its bounty glow) lasts 20s
Config.STEAL_COOLDOWN = 30 -- seconds between steal attempts per player

-- Events: the two map threats
Config.TSUNAMI_PERIOD = 150 -- seconds between tsunami warnings (2.5 minutes)
Config.TSUNAMI_WARN_SECONDS = 12 -- siren + banner before the wave hits
Config.TSUNAMI_WASH_SECONDS = 8 -- the wave sweeps the yard for 8 seconds
Config.TSUNAMI_SAFE_HEIGHT = 14 -- standing above this height survives the wave
Config.FERRIS_PERIOD = 210 -- seconds between ferris-wheel breakaways (3.5 minutes)
Config.FERRIS_WARN_SECONDS = 10 -- klaxon + shadow warning before it rolls
Config.FERRIS_ROLL_SECONDS = 12 -- the wheel rolls across the yard for 12 seconds
Config.EVENT_DROP_CARRY = true -- a hit event makes you drop what you carry

-- Rebirth
Config.REBIRTH_BASE_COST = 25000 -- cash cost of rebirth 1; doubles each rebirth
Config.REBIRTH_MULTIPLIER = 2 -- each rebirth doubles ALL earnings, forever
Config.REBIRTH_MAX = 10 -- ten rebirths, x1024 at the top
Config.REBIRTH_SECRET_UNLOCK = 5 -- Secret brainrots only spawn after 5 rebirths
Config.REBIRTH_CLEAR_COLLECTION = true -- rebirth trades the whole collection away

-- Conveyor (the shop)
Config.CONVEYOR_SLOTS = 6 -- brainrots on the belt at once
Config.CONVEYOR_RESTOCK = 20 -- seconds between new brainrots rolling out
Config.CONVEYOR_DESPAWN = 90 -- an unbought brainrot rolls into the crusher after 90s

-- Prize Book
Config.PRIZE_BOOK_CASH_TITLE = "Scrap Royalty" -- title for finishing the book

-- Leaderboard
Config.LEADERBOARD_TOP = 10 -- richest scrappers shown on the board
Config.LEADERBOARD_REFRESH = 15 -- seconds between board refreshes

-- Sounds (Roblox asset ids; the client falls back to a beep when one fails)
Config.SOUND_BUY = "rbxassetid://131961136"
Config.SOUND_STEAL = "rbxassetid://130776150"
Config.SOUND_LOCK = "rbxassetid://131961136"
Config.SOUND_TSUNAMI = "rbxassetid://9068077058"
Config.SOUND_FERRIS = "rbxassetid://9068077058"
Config.SOUND_REBIRTH = "rbxassetid://138186576"
Config.SOUND_COIN = "rbxassetid://131961136"

-- The yard
Config.MAP_NAME = "The Rustyard"
Config.MAP_SIZE_STUDS = 320 -- the fenced playfield, edge to edge
Config.SPAWN_NAME = "Scrap Spawn"

return Config
