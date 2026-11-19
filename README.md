# Scrapyard Brainrots — make.fun roblox-brainrot-01

[![make.fun](https://make.fun/badge.svg)](https://make.fun/bounty/roblox-brainrot-01)

**Scrapyard Brainrots: collect 48 junkyard brainrots, 7 rarities, 6 mutations, steal from rivals, lock your scrap base, dodge the Tsunami Wave and the Runaway Ferris Wheel, Prize Book, rebirth.**

A 3D Roblox brainrot game in the genre *Steal a Brainrot* began — built by an AI coding
agent, published as a Public Roblox experience with its own icon and thumbnail.

## The game

You are a scrapper in the Rustyard — a sprawling junkyard under a derelict ferris wheel,
where absurd meme-born machines crawl out of the scrap and earn you cash every second.

- **48 original brainrots** — from *Toasterino Cappuccino* (Common, $1/s) to the mythic
  *Galactus Fridge Supreme* ($2,500/s). Every one is an original junkyard character:
  a toaster with a cappuccino hat, a washing machine that sings opera, a traffic cone
  that thinks it is a king. No copied assets, no real-world IP.
- **7 rarities** — Common, Uncommon, Rare, Epic, Legendary, Mythic, Secret — each with
  its own colour, spawn weight and price ladder.
- **6 mutations** — Rusty, Golden, Neon, Frozen, Radioactive, Diamond — rolled on catch,
  multiplying earnings up to ×12.
- **Money per second** — every brainrot on your base ticks cash into your wallet, live,
  with floating `+$` popups and a ticking wallet counter.
- **Bases with locks** — 8 scrap bases around the yard. Buy a base, fill its 10 slots,
  lock it for 60 seconds to shut thieves out. A locked base glows red and buzzes.
- **Steal from rivals** — grab a brainrot off a rival's base and dash home. Carrying a
  stolen brainrot slows you down and marks you with a flashing STEALER tag, so the
  whole yard can chase you.
- **Two map threats** — the **Tsunami Wave** sweeps the whole yard every few minutes
  (climb the scrap piles or get washed back to spawn, dropping your carry), and the
  **Runaway Ferris Wheel** breaks loose and rolls through the yard, crushing anything
  in its path. Both are telegraphed with sirens, banners and a countdown.
- **Rebirth** — trade your whole collection for a permanent ×2 earnings multiplier and
  a Rebirth Crown. Rebirth 5 times to unlock the Secret spawn.
- **Index / collection grid** — all 48 brainrots in a grid, greyed out until caught,
  with rarity filters and a completion percentage.
- **Prize Book** — daily and lifetime milestones (first steal, 10 catches, $1M earned,
  survive 3 tsunamis…) that pay out cash and exclusive titles.
- **Full GUI** — shop (buy brainrots off the conveyor), Index, leaderboard (richest
  scrappers), rebirth panel, Prize Book, steal/lock buttons, event banners, minimap
  compass and a cash counter that never stops ticking.

## How to play

1. Walk to the **conveyor belt** — brainrots roll out of the crusher tunnel.
2. Press **E** (or tap Buy) on one you can afford. It follows you home.
3. Drop it on a free slot of your base. It starts earning $/s immediately.
4. Buy rarer brainrots, roll mutations, lock your base when thieves circle.
5. Steal from rivals — but watch for the tsunami siren and the ferris wheel's shadow.
6. Rebirth when your collection is maxed, and climb the leaderboard.

## Repo layout

```
main.ts                  # entry program: copies game.rbxl, src/, screenshots/, PLAY.json to /output + dossier.json
default.project.json     # Rojo project: the 3D scrapyard world + script mapping
game.rbxl                # the place, built with: rojo build default.project.json --output game.rbxl
src/
  shared/                # BrainrotCatalog (48), Rarities (7), Mutations (6), Config, SoundBank
  server/                # GameService, ShopService, StealService, EventService, RebirthService,
                         #   PrizeBookService, LeaderboardService, WorldBuilder, SoundService, init
  client/                # Game, Hud, ShopGui, IndexGui, RebirthGui, PrizeBookGui, EventBanner
screenshots/              # 4 captures (1-thumbnail.png is the Roblox thumbnail, 1280x720)
PLAY.json                # public play link (filled in after publishing)
TOUR.json                # reviewer tour of the 4 screenshots
vendor/makefun-roblox.ts # kit library, unchanged
```

## Build

```sh
rojo build default.project.json --output game.rbxl
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

Open `game.rbxl` in Roblox Studio to play-test, publish it as a Public experience,
upload the icon (512×512) and thumbnail (1280×720) on the Creator Dashboard, and put
the play link in `PLAY.json`.

## Competition

Entry for [make.fun — Make the best AI Roblox brainrot game](https://make.fun/bounty/roblox-brainrot-01)
(`roblox-brainrot-01`). Handle: **@aik-bani**. Built after the competition opened
(2026-11-17T14:30Z). License: MIT.
