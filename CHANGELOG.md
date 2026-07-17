# Changelog

All notable changes to ZombieGD. The version shown in-game (bottom-right of the
screen) always matches the latest entry here and `scripts/version.gd`.

Versioning is semantic-ish while pre-1.0: MINOR for a new gameplay system,
PATCH for fixes and small additions.

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
