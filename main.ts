// Scrapyard Brainrots — roblox-brainrot-01 entry program (agent-written, 2026-11-19).
// Hands in the game: copies game.rbxl, src/, screenshots/ and PLAY.json from beside
// this file to /output and writes /output/dossier.json with the vendored make.fun
// library. The game itself is a Rojo project (default.project.json) built with:
//   rojo build default.project.json --output game.rbxl
// Before the program runs, PLAY.json must name the published Public experience
// (place_id + universe_id); a zero id is refused by the gate, so publish first.
// Screenshots: 4 images, first by name (1-thumbnail.png) is the Roblox thumbnail.
// Every name under /output starts with a letter, a digit or _ and holds only
// letters, digits, . _ and -: the grader fails an entry whose output holds any
// other, so src/ and screenshots/ are copied without any name that starts with
// a dot (.gitkeep, .DS_Store, .git).
//
// Outside the grader's container, MAKEFUN_OUTPUT_DIR stands in for /output:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
// The program refuses to run when a screenshot is over the 256 KiB cap or when
// PLAY.json still holds the starter's zeros, so a bad bundle fails loudly here
// instead of silently on the server.

import { copyFileSync, cpSync, existsSync, mkdirSync, readFileSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

// Agent-written pre-flight: refuse a bundle the gate would refuse, loudly.
// PLAY.json must name a real published place (both ids positive whole numbers);
// every screenshot must fit the 256 KiB cap the gate enforces.
const play = JSON.parse(readFileSync(join(here, 'PLAY.json'), 'utf8')) as { place_id: number; universe_id: number; url: string };
if (!Number.isInteger(play.place_id) || play.place_id <= 0 || !Number.isInteger(play.universe_id) || play.universe_id <= 0) {
  throw new Error(`PLAY.json is not filled in yet: place_id=${play.place_id} universe_id=${play.universe_id}. Publish the experience first, then re-run.`);
}
if (play.url !== `https://www.roblox.com/games/${play.place_id}` && !play.url.startsWith(`https://www.roblox.com/games/${play.place_id}/`)) {
  throw new Error(`PLAY.json url ${play.url} does not name place ${play.place_id}.`);
}
const shots = readdirSync(join(here, 'screenshots')).filter((n) => !n.startsWith('.')).sort();
if (shots.length < 3 || shots.length > 4) throw new Error(`screenshots/ must hold 3 or 4 images, found ${shots.length}.`);
for (const shot of shots) {
  const size = statSync(join(here, 'screenshots', shot)).size;
  if (size > 262144) throw new Error(`screenshots/${shot} is ${size} bytes, over the 256 KiB cap.`);
}
console.log(`Scrapyard Brainrots: handing in ${shots.length} screenshots, place ${play.place_id}, universe ${play.universe_id}.`);

/** cpSync's filter: leave out every file and directory whose name starts with a dot (.gitkeep, .DS_Store, .git). */
const notDotted = (path: string): boolean => !basename(path).startsWith('.');

copyFileSync(join(here, 'game.rbxl'), join(out, 'game.rbxl'));
copyFileSync(join(here, 'PLAY.json'), join(out, 'PLAY.json'));
cpSync(join(here, 'src'), join(out, 'src'), { recursive: true, filter: notDotted });
mkdirSync(join(out, 'screenshots'), { recursive: true });
if (existsSync(join(here, 'screenshots'))) cpSync(join(here, 'screenshots'), join(out, 'screenshots'), { recursive: true, filter: notDotted });

// The scorer's own caps (reference/gate.json): only text_max_bytes shapes the bytes; the others refuse an entry the
// scorer would refuse (more than 4 screenshots or one over 256 KiB; a place of more than 500000 instances, whose
// scripts' sources come to over 8 MiB or whose scripts' paths come to over 1048576 characters, in all).
writeFileSync(
  join(out, 'dossier.json'),
  buildDossier(out, { text_max_bytes: 65536, screenshots: { max: 4, max_bytes: 262144 }, max_instances: 500000, scripts_max_source_bytes: 8388608, scripts_max_path_chars: 1048576 }),
);
