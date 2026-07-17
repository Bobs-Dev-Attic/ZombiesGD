class_name RangedWeapon
extends RefCounted

## Pure static helpers for the RANGED role's per-tier firing pattern (Pistol ->
## Shotgun). No autoload references, no scene-tree access — must stay
## preloadable under the `-s` headless test runner, same reason WeaponStats
## exists as pure data. NO raycasting lives here; that is live physics and
## belongs to player.gd's _fire().

const WeaponStats := preload("res://scripts/weapon_stats.gd")

const _PELLET_COUNT := {1: 1, 2: 5}
const _SPREAD_DEGREES := {1: 0.0, 2: 20.0}


static func _clamp_tier(tier: int) -> int:
	return clampi(tier, WeaponStats.TIER_MIN, WeaponStats.TIER_MAX)


static func pellet_count(tier: int) -> int:
	return _PELLET_COUNT[_clamp_tier(tier)]


static func spread_degrees(tier: int) -> float:
	return _SPREAD_DEGREES[_clamp_tier(tier)]


## Per-pellet angular offsets in degrees from the aim direction, evenly spaced
## across spread_degrees(tier) and centred on 0. Deterministic — no RNG, so
## the shotgun pattern is unit-testable and consistent shot to shot.
static func pellet_angles(tier: int) -> PackedFloat32Array:
	var t := _clamp_tier(tier)
	var count := pellet_count(t)
	var angles := PackedFloat32Array()
	if count <= 1:
		angles.append(0.0)
		return angles
	var spread := spread_degrees(t)
	var step := spread / float(count - 1)
	var start := -spread / 2.0
	for i in range(count):
		angles.append(start + step * i)
	return angles
