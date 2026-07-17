class_name ThrownWeapon
extends RefCounted

## Pure static helpers for the THROWN role's per-tier blast shape and cluster
## behaviour (Grenade -> Cluster Grenade). No autoload references, no
## scene-tree access -- must stay preloadable under the `-s` headless test
## runner, same reason WeaponStats/RangedWeapon/MeleeWeapon exist as pure
## data/logic. Live flight, the explosion physics query, and the throw-button
## edge belong to grenade.gd / player.gd, not here.

const WeaponStats := preload("res://scripts/weapon_stats.gd")

const _BLAST_RADIUS := {1: 3.5, 2: 3.0}
const _FUSE_SECONDS := {1: 1.2, 2: 1.2}
const _BOMBLET_COUNT := {1: 0, 2: 4}
const _BOMBLET_RADIUS := {1: 0.0, 2: 2.0}
const _BOMBLET_DAMAGE_FRACTION := 0.5
const _BOMBLET_OFFSET_DISTANCE := 2.5


static func _clamp_tier(tier: int) -> int:
	return clampi(tier, WeaponStats.TIER_MIN, WeaponStats.TIER_MAX)


static func blast_radius(tier: int) -> float:
	return _BLAST_RADIUS[_clamp_tier(tier)]


static func fuse_seconds(tier: int) -> float:
	return _FUSE_SECONDS[_clamp_tier(tier)]


static func bomblet_count(tier: int) -> int:
	return _BOMBLET_COUNT[_clamp_tier(tier)]


static func bomblet_radius(tier: int) -> float:
	return _BOMBLET_RADIUS[_clamp_tier(tier)]


static func bomblet_damage_fraction() -> float:
	return _BOMBLET_DAMAGE_FRACTION


## Deterministic (no RNG, same rationale as the shotgun's fixed spread):
## four bomblets evenly spaced on a circle of radius 2.5 around the impact
## point, starting at +X and going counter-clockwise. Tier 1 has no bomblets
## and returns an empty array.
static func bomblet_offsets(tier: int) -> PackedVector2Array:
	var t := _clamp_tier(tier)
	var count := bomblet_count(t)
	var offsets := PackedVector2Array()
	if count <= 0:
		return offsets
	var step := TAU / float(count)
	for i in range(count):
		var angle := step * i
		offsets.append(
			Vector2(_BOMBLET_OFFSET_DISTANCE, 0.0).rotated(angle)
		)
	return offsets


## Linear falloff: full_damage at distance 0, scaling linearly to 0.0 at
## distance >= radius. Never returns negative.
static func damage_at(distance: float, radius: float, full_damage: float) -> float:
	if radius <= 0.0:
		return 0.0
	if distance <= 0.0:
		return full_damage
	if distance >= radius:
		return 0.0
	return full_damage * (1.0 - distance / radius)
