class_name MeleeWeapon
extends RefCounted

## Pure static helpers for the MELEE role's per-tier reach/arc (Knife -> Axe).
## No autoload references, no scene-tree access — must stay preloadable
## under the `-s` headless test runner, same reason WeaponStats/RangedWeapon
## exist as pure data/logic. The live physics query and swing timing belong
## to player.gd's melee tick, not here.

const WeaponStats := preload("res://scripts/weapon_stats.gd")

const _REACH := {1: 1.8, 2: 2.2}
const _ARC_DEGREES := {1: 60.0, 2: 120.0}


static func _clamp_tier(tier: int) -> int:
	return clampi(tier, WeaponStats.TIER_MIN, WeaponStats.TIER_MAX)


static func reach(tier: int) -> float:
	return _REACH[_clamp_tier(tier)]


static func arc_degrees(tier: int) -> float:
	return _ARC_DEGREES[_clamp_tier(tier)]


## Pure angle-only predicate on the XZ plane (Vector2 here is (x, z)). Reach
## (distance) is NOT checked here — that is the caller's job, kept separate
## so both are independently testable. Neither input needs to be
## pre-normalized; normalization happens internally.
static func is_in_arc(to_target: Vector2, facing: Vector2, tier: int) -> bool:
	if to_target.length_squared() <= 0.0:
		return true
	if facing.length_squared() <= 0.0:
		return false
	var half_arc := arc_degrees(tier) / 2.0
	var angle_degrees := absf(rad_to_deg(to_target.normalized().angle_to(facing.normalized())))
	return angle_degrees <= half_arc or is_equal_approx(angle_degrees, half_arc)
