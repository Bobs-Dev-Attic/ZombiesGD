# ZombieGD — Top-Down Zombie Survival Shooter (Design)

**Date:** 2026-07-16  
**Status:** Approved for planning  
**Engine:** Godot 4.x (3D)  
**Approach:** Procedural / CSG low-poly (no external art kit)

## Summary

A landscape-orientation, top-down zombie survival shooter for **web and mobile**. True 3D low-poly graphics with a fixed orthographic camera. Desktop uses keyboard + mouse; mobile uses on-screen controls. Core loop is a **wave arena** with a **between-wave upgrade shop** funded by kill points.

## Goals

- Playable in browser (HTML5) and on mobile (touch), always landscape.
- Readable low-poly 3D look without an asset pipeline.
- One clear loop: fight wave → shop → next wave → death / retry.
- Shared input abstraction so gameplay code does not branch on platform.

## Non-goals (v1)

- Multiplayer
- Multiple weapon types / inventory / ammo management
- Story, cutscenes, or large open world
- ~~Imported GLTF character kits~~ — **revised in v0.7.0**: the player now uses an
  imported CC0 rigged character (Kenney, GLB). This non-goal was a deliberate v1 scoping
  choice; it was lifted once the wave loop and combat were complete.
- iOS-specific polish beyond generic mobile touch (Android/web first)

## Architecture

### Autoloads

| Autoload | Responsibility |
|----------|----------------|
| `InputManager` | Normalize keyboard/mouse and touch into `move_vector`, `aim_vector`, `fire_held` |
| `GameManager` | Run state (playing / shop / game_over), wave index, points, player HP hooks, signals for UI |

### World

- **Arena:** Bounded rectangular yard; perimeter walls; a few static box cover pieces (`StaticBody3D` / CSG).
- **Camera:** Fixed orthographic `Camera3D` above the arena (optional slight pitch for depth). Landscape only.
- **Player:** `CharacterBody3D` + simple mesh (capsule body, box “gun”). Movement on XZ; aim on XZ.
- **Zombies:** `CharacterBody3D` + simple mesh; chase player; contact damage.
- **Combat:** Hitscan (raycast) from player for reliability on web/mobile. Infinite ammo in v1; power comes from upgrades.

### Data flow

```
InputManager → Player (move / aim / fire)
Player hitscan → Zombie (damage / death)
Zombie death → GameManager (points)
GameManager → ZombieSpawner (wave spawn)
GameManager → Shop UI (between waves)
Shop purchases → Player stats (damage, fire rate, move speed, max HP)
```

### `.clauderc` conventions

Update project guidance to Godot 4.x **3D**:

- `CharacterBody3D` for moving entities
- `await` for signals
- Godot 4.x Tween system

## Gameplay

### Waves

- Wave *N* spawns `base_count + N * scale` zombies at perimeter points.
- Wave clears when live zombie count reaches zero.
- Difficulty also scales zombie HP and move speed with wave index.
- Optional from mid-game: one “fast” zombie variant (same mesh, different speed/HP tint). No further enemy types in v1.

### Player

- Move with WASD (desktop) or left virtual joystick (mobile).
- Aim: mouse world position (desktop); on mobile, face move direction when firing (no separate aim stick in v1).
- Fire: LMB hold (desktop) or right fire button (mobile).
- Contact damage from zombies; HP reaches 0 → game over overlay with retry.

### Economy & upgrades

- Kills grant points; unspent points carry across waves within a run.
- Between waves, shop offers repeatable upgrades, for example:
  - **Damage** — hitscan damage per shot
  - **Fire rate** — reduces shot cooldown
  - **Move speed** — player velocity
  - **Max HP** — increases max HP (and heals toward new max or full between waves)
- Costs are flat per tier or mild escalating cost; “Next Wave” closes shop and starts the next spawn.

### HUD

- HP, points, current wave.
- Shop panel only between waves.
- Touch controls visible only when touch/mobile input is active; hidden on pure desktop.

## Controls

| Action | Desktop | Mobile |
|--------|---------|--------|
| Move | WASD | Left virtual joystick |
| Aim | Mouse cursor on ground plane | Face move direction while firing |
| Fire | LMB (hold) | Right fire button (hold) |

`InputManager` exposes a single API; Player never reads raw InputMap vs touch separately.

## Visual style

- Flat, untextured (or solid-color) low-poly materials.
- Muted ground; desaturated zombie greens; distinct player accent color.
- No heavy bloom/glow; keep mobile GPU cost low.
- Orthographic top-down composition; one clear playfield.

## Project layout

```
project.godot
.clauderc
scenes/
  main.tscn
  player.tscn
  zombie.tscn
  ui/
    hud.tscn
    shop.tscn
    touch_controls.tscn
scripts/
  game_manager.gd
  input_manager.gd
  player.gd
  zombie.gd
  zombie_spawner.gd
  upgrades.gd
docs/superpowers/specs/
  2026-07-16-zombie-survival-shooter-design.md
```

## Export & verification

- Project configured for HTML5 export and mobile-capable display (landscape, touch).
- Smoke checklist:
  1. Start run, move and shoot on desktop.
  2. Clear wave 1, open shop, buy one upgrade, start wave 2.
  3. Die and retry.
  4. In editor, emulate touch: joystick moves, fire button shoots.

## Success criteria

- A complete run loop works on desktop and touch without changing scenes.
- Upgrades visibly affect combat (damage and/or fire rate noticeable by wave 3–4).
- Web and mobile builds are viable targets from the same project (export presets present; game remains playable at phone landscape resolution).
