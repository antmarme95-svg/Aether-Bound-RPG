# AETHER BOUND — Aetherpunk Open-World Action RPG

*Formerly **Vanguards & Voidcores** / **BORISAWA** (repo folder name and some
internal identifiers retain the old name). The living design truth is the
Vault: `Aether Bound/` (see `CLAUDE.md`); `docs/GDD.md` v2.2 is frozen.*

An original open-world Action RPG: **Vox Machina** irreverence × **Breath of
the Wild** cel-shaded exploration. You are not a chosen one — you are a
mercenary with a freshly signed **Conqueror's Contract** and three bad ideas
about loyalty.

The slice delivers: full **character creation** (Origin Factions → live
phenotype editor → Class) and a playable **~10-minute narrative arc**
(Contract Signing → frontier deployment → The Wilds → a Core of the Dead Gods
encounter → the three-path Conqueror's Choice).

---

## ▶ Two builds, two launchers

### Web prototype (reference build)
**Double-click `Start-Game.bat`.**

That launches `tools/serve.ps1` — a dependency-free PowerShell static server
on `http://localhost:8420` — and opens your browser. Three.js loads from a
pinned CDN; everything else (3D models, textures, audio) is generated
procedurally at runtime. Internet is required on first load for the CDN.
Zero-install, frozen as the behavioral reference.

> ES modules can't load over `file://`, which is the only reason a local
> server exists at all.

### Godot 4 build (active development)
**Double-click `Start-Godot.bat`** (requires **Godot 4.6.3**, installed via
`winget install GodotEngine.GodotEngine`).

This is where all new work lands. Same slice content plus the native
BotW-style graphics pass: bloom, soft sun shadows, aerial-perspective ridges,
20,000-blade grass fields, and the full toon shader + parametric character
rig (466 FPS uncapped on the dev machine — RTX 2060).

### Controls

| Input | Action |
|---|---|
| WASD / arrows | Move |
| Shift (hold) | Sprint — drains the stamina wheel |
| Space | Jump |
| Click (canvas) | Capture mouse (pointer lock) · Esc to release |
| Mouse move (captured) | Look around |
| Mouse wheel | Camera zoom |
| Left click (captured) / F | Attack (class-flavored: greatblade / bolt / bow) |
| C | Crouch / sneak |
| E | Interact (talk · sign · shatter) |
| Q (hold) | **Mana-Overload** (Aether-Born passive) |
| N | **Night-vision** (Mist-Stalker passive) |

### Debug fast-forward (both builds)

**Web**: `?origin=aetherborn|ironblooded|miststalker&cls=warrior|mage|thief&name=X&skip=office|exit|wilds`  
e.g. `http://localhost:8420/?origin=miststalker&cls=thief&skip=wilds`  
`window.__BORISAWA` exposes `{ director, bus, THREE }` in the console.

**Godot**: CLI args mirror the web URL params:  
`godot --path godot -- --origin=aetherborn --cls=mage --name=X --skip=wilds`  
F12 in-game saves a screenshot.

---

## Architecture

```
src/
├── main.js                  boot, render loop, debug hooks
├── core/                    ENGINE-AGNOSTIC (no three.js imports)
│   ├── StateMachine.js      generic FSM
│   ├── GameDirector.js      top FSM: CREATION → OFFICE → CITY_EXIT → WILDS → CHOICE → FREE_ROAM
│   │                        + nested CharacterCreationState FSM (origin/body/face/class)
│   ├── EventBus.js          pub/sub: creation:complete, contract:signed, core:destroyed…
│   ├── SaveState.js         unified player record (origin, class, phenotype, path)
│   └── Sfx.js               zero-asset WebAudio synth
├── data/                    PURE DATA — ports to Godot Resources verbatim
│   ├── origins.js           3 factions: passives, cities, rivals, scene themes
│   ├── classes.js           Warrior/Mage/Thief attribute + skill tables
│   ├── phenotype.js         slider/pick definitions (single source of truth for UI + rig)
│   ├── palette.js           neon-adjacent cel palettes
│   ├── paths.js             path allegiance buffs + HUD chips (Kingdom / Betrayal / Rogue)
│   └── dialogue/contract.js recruiter dialogue trees + contract clauses
├── character/
│   ├── CharacterRig.js      parametric humanoid; applyPhenotype() live-edits transforms,
│   │                        materials, hair/beard swaps, mana veins, prosthetics
│   ├── HairLibrary.js       10 procedural anime hairstyles + 4 beards
│   └── WarpaintAtlas.js     canvas-generated cel warpaint head textures
├── rendering/
│   ├── ToonMaterials.js     shared stepped-ramp MeshToonMaterial factory + wind sway
│   └── OutlinePass.js       inverted-hull outlines (inherit phenotype scaling)
├── scenes/                  each: { scene, playerSpawn, getHeight, clampPosition,
│   │                                interactables, triggers, update }
│   ├── props.js             shared prop kit (pipes, lamps, banners, gears, ribs, trees)
│   ├── CreationStage.js     turntable viewport, origin-retinted 3-point lighting
│   ├── RecruitmentOffice.js one interior kit, three kingdom themes
│   ├── CityExit.js          guarded street + rising frontier gate
│   └── TheWilds.js          analytic terrain, instanced wind grass, the red Core site
├── gameplay/
│   ├── PlayerController.js  3rd-person movement, stamina sprint/jump, attacks, projectiles
│   ├── Stats.js             health/magicka/stamina pools, BotW exhaustion, skill bonuses
│   ├── Passives.js          Mana-Overload / Colossus Stance / Feral Instinct
│   ├── EnemyAI.js           Maddened Gloomfang FSM: roam→chase→windup→lunge→recover
│   └── QuestTracker.js      objectives + the Path A/B/C macro-freedom branch
└── ui/
    ├── CreationUI.js        split layout: left tab rail (Origin/Body/Face/Class), right viewport
    ├── HUD.js               compass bar, vitals, stamina wheel, prompts, hit FX
    ├── DialogueUI.js        letterboxed dialogue + hold-to-sign contract parchment
    └── QuestUI.js           tracker widget, Choice overlay, end card
```

### Flow of the slice

1. **CREATION** — nested FSM drives the four tabs; every slider tick calls
   `CharacterRig.applyPhenotype()` so the model updates the same frame.
   "Sign On" freezes the `SaveState` and emits `creation:complete`.
2. **OFFICE** — the director reads `SelectedOrigin` and spawns the matching
   themed Recruitment Office; `Stats` + `Passives` attach the origin passive
   to the player entity. Talk to the recruiter, read the Conqueror's
   Contract, hold-to-sign → `contract:signed` → the doors slide open.
3. **CITY_EXIT** — walk the last secure street; the frontier portcullis
   rises; crossing the boundary fades into…
4. **WILDS** — quest *PURGE ORDER 001* activates. A red **Core of the Dead
   Gods** pulses on the compass; three maddened beasts (red crystal
   corruption, stealth-aware aggro) guard it. Purge them, shatter the Core.
5. **CHOICE** — the tracker branches: **Path A** serve your kingdom ·
   **Path B** court the rival power · **Path C** go rogue. The pick grants
   a permanent buff + colored allegiance chip in the HUD:
   - **Path A (Kingdom)** — "Crown's Aegis": +25 max health, +10% physical resist
   - **Path B (Betrayal)** — "Double Ledger": +30 max magicka, +15 max stamina
   - **Path C (Rogue)** — "Unbound Fury": +15% attack damage, +20 max stamina
6. **END CARD** — the quest tracker and the save record are rewritten per your
   path choice, and the slice stats roll (field time · kills · cores).
7. **SECOND CORE** — dismissing the card opens quest *Amendment 001-B*: a second
   Core of the Dead Gods pulses to the west of The Wilds, guarded by three more
   maddened guardians. Shatter it to quiet the frontier, then free roam.

---

## Godot 4 port status

The port boundary is enforced by the import graph: `core/`, `data/`, and
`gameplay/QuestTracker|Stats|Passives` have **no three.js imports**. The
Godot archive mirrors the JS architecture under `godot/` (core/, data/,
character/, scenes/, gameplay/, ui/, rendering/).

| Phase | Status | Scope |
|---|---|---|
| **P0** | ✓ Done | Foundation + test harness |
| **P1** | ✓ Done | Core, data, EventBus (24-assert parity suite) |
| **P2** | ✓ Done | Toon shaders + parametric character rig |
| **P3** | ✓ Done | World scenes (3 offices, CityExit, TheWilds + 3 reclaimed-ruins zones) |
| **P4** | ✓ Done | Gameplay (full slice headless-verified: 6 kills, 2 cores) |
| **P5** | ✓ Done | UI layer (creation split-screen, HUD, dialogue+contract, quest overlays) |
| **P6** | ✓ Done | BotW graphics pass (466 FPS: bloom, soft shadows, aerial perspective, grass) |

**JS reference mapping** (web build only):

| Here | In Godot 4 |
|---|---|
| `src/data/*.js` tables | `Resource` scripts (.tres) |
| `src/EventBus` | autoload singleton with signals |
| `src/StateMachine` / `GameDirector` | node-based FSM (or `LimboHSM`) |
| `src/SaveState` | `Resource` + `FileAccess` JSON |
| `src/scenes/*` classes | `.tscn` scenes; `getHeight` → `HeightMapShape3D`/raycast |
| `src/ToonMaterials` ramp | one toon `.gdshader` (stepped ramp + rim) |
| `src/OutlinePass` inverted hull | second material pass, `cull_front` grow shader |
| `src/CharacterRig` primitives | rigged mesh + blendshapes; sliders → blendshape weights |
| `src/PlayerController` | `CharacterBody3D` + spring-arm camera |
| DOM UI | `Control` nodes; compass = scrolling `TextureRect` |
| `src/Sfx` synth | `AudioStreamGenerator` or baked .wav |

## Test harness

**Logic tests** (core parity suite):
```
godot --headless --path godot --script res://tests/test_core.gd
```

**Visual & flow autotests** (write PNGs + JSON to `godot/test_out/`):
```
godot --path godot -- --autotest=res://tests/autotest_rig.gd
godot --path godot -- --autotest=res://tests/autotest_scenes.gd
godot --path godot -- --autotest=res://tests/autotest_slice.gd
godot --path godot -- --autotest=res://tests/autotest_ui.gd
```

---

## Roadmap — companion-system expansion (HISTORICAL — superseded)

> Superseded by the AETHER BOUND design (GDD v2.2 → Vault, 2026-07).
> Kept as prototype history only.

The companion-system expansion unlocks the Role Matrix and crew-based story beats:

- **Role Matrix**: Warrior → 🛡️ **Vanguard** · Thief → ⚔️ **Duelist** · Mage → 🔮 **Strategist**
- **Guild roster**: 5 companion NPCs with friction-based matchmaking (loyalty + bond values)
- **Squad play**: player + 2 companions with per-role companion AI
- **Reciprocal puzzles**: It-Takes-Two-style co-op traversal in the Wilds ruins zones
- **Loyalty Tracker**: Contract Value vs. Companion Bond; buffs/debuffs based on tension
- **Fractured Alignments climax**: the Aether-Beast Grand Decision branches into three endgame scenarios:
  - **2v3 loyalist fight** (Crown's champions vs. the beast; Vanguard + ally squad)
  - **Sacrifice escape** (Duelist solo stealth; leave your bond behind)
  - **Empire villain route** (Strategist + corrupted beast; betray the kingdom)

---

## Known prototype cut-lines

- Recruitment Offices share one interior kit (data-themed), not full cities.
- Skills are stored/displayed; combat hooks use the key skill per class
  (+ Sneak affecting detection). The rest is progression scaffolding.
- Persistence = `localStorage` snapshot only (web) or `Resource` snapshot (Godot).
- No save/load menu, no map screen, no inventory — out of slice scope.
