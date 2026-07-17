class_name WeaponStats
extends RefCounted

## Pure static weapon roster data + derivation. Three roles, each a sidegrade
## with two tiers of progression. No autoload references (must be preloadable
## under the `-s` headless test runner). NO weapon behavior lives here —
## firing/swinging/throwing come in later tasks. Per design, RANGED tier 2's
## base_damage is PER PELLET (pellet count belongs to ranged behavior later);
## MELEE arc and THROWN blast radius are likewise out of scope here.

enum Role { RANGED, MELEE, THROWN }

const TIER_MIN := 1
const TIER_MAX := 2

## Shared physics collision mask for zombies (collision_layer = 2 in
## scenes/zombie.tscn). Centralised here so ranged hitscan, melee swings, and
## thrown blasts all query the same layer instead of each hardcoding a
## private "2" constant.
const ZOMBIE_COLLISION_MASK := 2

const _BASE_DAMAGE := {
	Role.RANGED: {1: 10.0, 2: 6.0},
	Role.MELEE: {1: 15.0, 2: 30.0},
	Role.THROWN: {1: 60.0, 2: 40.0},
}

const _BASE_COOLDOWN := {
	Role.RANGED: {1: 0.45, 2: 0.80},
	Role.MELEE: {1: 0.50, 2: 0.80},
	Role.THROWN: {1: 7.00, 2: 9.00},
}

const _DAMAGE_PER_LEVEL := {
	Role.RANGED: 5.0,
	Role.MELEE: 7.0,
	Role.THROWN: 15.0,
}

const _COOLDOWN_PER_LEVEL := {
	Role.RANGED: 0.04,
	Role.MELEE: 0.04,
	Role.THROWN: 0.40,
}

const _COOLDOWN_FLOOR := {
	Role.RANGED: 0.12,
	Role.MELEE: 0.20,
	Role.THROWN: 3.00,
}

const _NAMES := {
	Role.RANGED: {1: "Pistol", 2: "Shotgun"},
	Role.MELEE: {1: "Knife", 2: "Axe"},
	Role.THROWN: {1: "Grenade", 2: "Cluster Grenade"},
}


## Out-of-range tiers clamp into [TIER_MIN, TIER_MAX] rather than silently
## returning 0.0 — an invalid tier is a caller bug, not a valid "no weapon"
## state, so we fall back to the nearest real tier instead of masking it.
static func _clamp_tier(tier: int) -> int:
	return clampi(tier, TIER_MIN, TIER_MAX)


static func base_damage(role: Role, tier: int) -> float:
	return _BASE_DAMAGE[role][_clamp_tier(tier)]


static func base_cooldown(role: Role, tier: int) -> float:
	return _BASE_COOLDOWN[role][_clamp_tier(tier)]


static func damage_per_level(role: Role) -> float:
	return _DAMAGE_PER_LEVEL[role]


static func cooldown_per_level(role: Role) -> float:
	return _COOLDOWN_PER_LEVEL[role]


static func cooldown_floor(role: Role) -> float:
	return _COOLDOWN_FLOOR[role]


static func damage(role: Role, tier: int, level: int) -> float:
	return base_damage(role, tier) + level * damage_per_level(role)


static func cooldown(role: Role, tier: int, level: int) -> float:
	return maxf(
		cooldown_floor(role), base_cooldown(role, tier) - level * cooldown_per_level(role)
	)


static func weapon_name(role: Role, tier: int) -> String:
	return _NAMES[role][_clamp_tier(tier)]
