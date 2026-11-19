# PUBLISH GUIDE — Scrapyard Brainrots (for Hendra)

You publish this one yourself in Roblox Studio — no passwords, no logins shared
with anyone. Everything below is your own clicks in Studio and on the Creator
Dashboard. Total time: about 15–20 minutes, plus Roblox's review of the icon and
thumbnail (usually minutes to a few hours — wait until both show on the game's page).

What you need before you start:
- Roblox Studio installed on a Windows or Mac computer, signed in to your Roblox
  account (the account must be at least 2 days old and past Roblox's age check —
  yours already is).
- The Rojo plugin in Studio (free, from the Creator Marketplace) — only if you
  want to sync the scripts live. You do NOT need it: the place file is already
  built and ready to open.
- Your make.fun play code for this bounty (4 codes, each `makefun-` + three words).
  The coordinator will hand you one — it goes in the experience description in
  step 3. Do not guess one; ask the coordinator for it if you don't have it yet.

## Files in this repo (on your computer)

- Place file: `game.rbxl` (repo root) — the whole game, already built with Rojo.
- Icon: `assets/icon.png` — 512×512, upload this as the experience icon.
- Thumbnail: `assets/thumbnail.png` — 1280×720, upload this as the first thumbnail.
  It is the same picture as `screenshots/1-thumbnail.jpg` (the cover screenshot).
- Project source (for reference/rebuilds): `default.project.json` + `src/` (Luau).

## Step 1 — Open the place in Roblox Studio

1. Open Roblox Studio.
2. Click **Open** (or File → Open from File) and pick `game.rbxl` from this repo.
3. The place opens: you should see the scrapyard — grey baseplate, fences, the
   conveyor belt at the back, the big purple ferris wheel, lamp posts and scrap piles.
4. Click **Play** (F5) to test it: your character spawns at the green spawn pad.
   Walk to the conveyor (press E near a brainrot to buy), check the cash counter
   ticks up top-cent, press I for the Index, R for Rebirth, P for the Prize Book.
5. Click **Stop** when you're happy. If anything looks wrong, tell the coordinator
   — do not edit scripts by hand (edits in Studio would no longer match `src/`).

## Step 2 — Publish as a NEW experience

1. In Studio: **File → Publish to Roblox As…**
2. Choose **Create new experience** (do NOT publish over any other game you own).
3. Fill in exactly:
   - **Name:** `Scrapyard Brainrots`
   - **Description:** paste this, with your play code on its own line at the end:
     ```
     Scrapyard Brainrots — collect 48 junkyard brainrots, 7 rarities, 6 mutations, steal from rivals, lock your scrap base, dodge the Tsunami Wave and the Runaway Ferris Wheel, Prize Book, rebirth. A 3D brainrot game built for the make.fun bounty.
     <YOUR PLAY CODE HERE — e.g. makefun-word-word-word>
     ```
     (Do not write the web address with a dot in the description — Roblox refuses
     descriptions that read as a web address.)
   - **Genre:** All (or Adventure) — pick whichever Roblox offers; any genre works.
4. Click **Create**. Studio uploads the place and opens the experience page.
5. Note the numbers Studio shows (or that you see in the URL):
   - **place_id** = the number in `https://www.roblox.com/games/<place_id>/...`
   - **universe_id** = the number after `experiences/` in the Creator Dashboard
     address, or `game.GameId` in Studio (game.PlaceId is the place id).
6. Send both numbers + the full experience URL back to the coordinator — they go
   into `PLAY.json` and the submission.

## Step 3 — Set the experience to PUBLIC

1. Go to the **Creator Dashboard**: https://create.roblox.com/dashboard/creations
2. Open **Scrapyard Brainrots** → **Audience** (left menu).
3. Set it to **Public** and save.
   - If Roblox asks its content questions first, answer them: this game has no
     age-restricted content — answering "No" to the age-restricted question ends
     the questionnaire there (Content May Vary rating).
   - If Roblox asks for the age check (facial age estimation or ID), that's a
     one-time account step — complete it, then set Public.
4. Check the public game page loads (open the URL from step 2 in a browser while
   logged out / in a private window if you want to be sure it's public).

## Step 4 — Upload the icon + thumbnail

1. In the Creator Dashboard, open **Scrapyard Brainrots** → **Configurations** →
   **Places** → choose its **start place** (marked with a star).
2. **Icon:** upload `assets/icon.png` (512×512, square). This is the square
   picture beside the game title.
3. **Thumbnails:** go to the **Experience Detail Page** tab → **Thumbnails** →
   upload `assets/thumbnail.png` (1280×720) as the **first** thumbnail.
   - It MUST be the first thumbnail, and it MUST be the same picture as
     `screenshots/1-thumbnail.jpg` in the repo (it is — same render).
4. Wait until the experience's page on Roblox actually shows both the icon and
   the thumbnail. Roblox reviews each upload — while either is still in review
   (or blocked), the entry is refused. Do not submit until both are visible.

## Step 5 — Hand back to the coordinator

Send the coordinator these three things:
1. The experience URL: `https://www.roblox.com/games/<place_id>/Scrapyard-Brainrots`
2. `place_id` and `universe_id` (from step 2).
3. Confirmation that the icon + thumbnail both show on the public page.

The coordinator then fills in `PLAY.json`, re-runs the checks, and submits.
You don't need to do anything else — no claim, no signature, no payment.

## If something goes wrong

- **Studio won't publish / "account too new":** the account must be 2+ days old
  and past the age check. If it's a brand-new account, wait — there is no workaround.
- **Description refused:** remove any web address (anything with a dot like
  `something.com`) and try again; try a different play code if the first is refused.
- **Icon/thumbnail stuck "in review" for hours:** wait — do not re-upload the same
  file repeatedly; Roblox reviews each upload once.
- **The game looks empty after publishing:** you published the wrong file. Make
  sure you opened THIS repo's `game.rbxl` (44,845 bytes, built 19 Nov 2026) and
  published it as a NEW experience — never over another game.
