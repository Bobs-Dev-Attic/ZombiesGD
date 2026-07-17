# Changelog

All notable changes to ZombieGD. The version shown in-game (bottom-right of the
screen) always matches the latest entry here and `scripts/version.gd`.

Versioning is semantic-ish while pre-1.0: MINOR for a new gameplay system,
PATCH for fixes and small additions.

## [0.6.0] - 2026-07-17

### Added
- **Combat feedback ("juice")** — the mechanics always worked, but now you can see them:
  - **Crosshair** at the mouse (desktop), so you can tell where you're aiming.
  - **Ranged:** muzzle flash, a tracer per pellet (the shotgun spread now reads), and an
    impact spark at the hit point.
  - **Zombies:** flash white when hit, and burst in a death puff instead of silently
    vanishing.
  - **Melee:** a visible swing arc when a swing connects (wider for the Axe).
  - **Grenade:** an expanding explosion flash sized to the blast radius, plus a pop at
    each bomblet for the Cluster Grenade — throws now land with a visible boom.

### Notes
- Purely cosmetic: no combat logic, damage, or hit detection changed (verified — the fire
  and explosion code paths are byte-for-byte unchanged). All effects are procedural
  primitives; no imported assets.

## [0.5.0] - 2026-07-17

### Added
- **The loop is closed.** Full UI layer over the wave loop:
  - **HUD** (top-left): live HP, Points, and Wave.
  - **Between-wave shop:** opens on wave clear. Spend points on Move Speed, Max HP,
    and per-role Damage / Fire Rate / weapon-tier upgrades (Pistol→Shotgun,
    Knife→Axe, Grenade→Cluster). Buttons show live costs and grey out when
    unaffordable or maxed. "Next Wave" starts the next wave.
  - **Game Over overlay** with a Retry button that starts a fresh run.
- Weapons are disabled outside the PLAYING state (can't fire in the shop or after
  death); movement stays active.
- `HOW_TO_PLAY.md` — player-facing guide to controls, weapons, and the shop.

## [0.4.0] - 2026-07-17

### Added
- **Wave loop.** `GameManager` autoload runs the PLAYING -> SHOP -> next-wave
  state machine; `ZombieSpawner` spawns each wave around the arena perimeter with
  per-wave stats from `WaveMath`. Kills award points; clearing a wave opens the
  (not-yet-built) shop state; player death enters GAME_OVER.
- **On-screen version label** in the bottom-right corner, driven by the `Version`
  autoload so it can never drift from the code.

### Fixed
- `GameManager.start_run()` is now a genuine full reset, so the eventual Retry
  button starts clean: leftover zombies from the wave the player died in are
  freed (and disconnected first, before their deferred free), and player HP,
  position, points, wave, and upgrades all reset.
- Upgrade purchases no longer re-apply player stats when the purchase was
  rejected as unaffordable.

## [0.3.0] - 2026-07-17

### Added
- **Weapon system (v2): three simultaneous roles, two tiers each.**
  - Ranged: Pistol -> Shotgun (5-pellet fixed spread).
  - Melee: Knife -> Axe, auto-swings within reach and an aim-centred arc.
  - Thrown: Grenade -> Cluster Grenade, lobbed with linear-falloff AOE, on `G`.
  - Per-role upgrades (damage/rate) scale from each tier's base; cooldown-gated,
    no ammo.
- `WeaponStats` roster and a per-role rewrite of the `Upgrades` model.

## [0.2.0] - 2026-07-16

### Added
- **Zombies.** Chase the player, deal cooldown-gated contact damage, take
  hitscan damage on collision layer 2, die and award points.

## [0.1.0] - 2026-07-16

### Added
- Initial playable slice: Godot 4 project scaffold, `WaveMath`, arena with
  orthographic top-down camera, `InputManager` (keyboard/mouse + touch), and a
  player with WASD movement, mouse aim, and a single hitscan gun.
