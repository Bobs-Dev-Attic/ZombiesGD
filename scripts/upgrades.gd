class_name Upgrades
extends RefCounted

## Pure-logic upgrade model: tracks levels per player stat and per-role weapon
## stat, plus each role's current weapon tier, and derives player/weapon
## stats from them. No scene tree, no nodes, no UI, no autoload references
## (must stay preloadable under the `-s` headless test runner).

const WeaponStats := preload("res://scripts/weapon_stats.gd")

enum PlayerStat { MOVE_SPEED, MAX_HP }
enum WeaponStat { DAMAGE, RATE }

const _ROLES: Array = [
	WeaponStats.Role.RANGED,
	WeaponStats.Role.MELEE,
	WeaponStats.Role.THROWN,
]

var player_levels: Dictionary = {
	PlayerStat.MOVE_SPEED: 0,
	PlayerStat.MAX_HP: 0,
}

var weapon_levels: Dictionary = {}

var tiers: Dictionary = {}


func _init() -> void:
	reset()


func reset() -> void:
	for stat in player_levels.keys():
		player_levels[stat] = 0
	weapon_levels = {}
	tiers = {}
	for role in _ROLES:
		weapon_levels[role] = {
			WeaponStat.DAMAGE: 0,
			WeaponStat.RATE: 0,
		}
		tiers[role] = WeaponStats.TIER_MIN


func player_cost(stat: PlayerStat) -> int:
	return 15 + int(player_levels[stat]) * 10


func weapon_cost(role: WeaponStats.Role, stat: WeaponStat) -> int:
	return 15 + int(weapon_levels[role][stat]) * 10


## Flat cost to advance a role from tier 1 to tier 2. 0 once already at TIER_MAX.
func tier_cost(role: WeaponStats.Role) -> int:
	if tiers[role] >= WeaponStats.TIER_MAX:
		return 0
	return 120


func try_buy_player(stat: PlayerStat, points: int) -> int:
	var c := player_cost(stat)
	if points < c:
		return points
	player_levels[stat] = int(player_levels[stat]) + 1
	return points - c


func try_buy_weapon(role: WeaponStats.Role, stat: WeaponStat, points: int) -> int:
	var c := weapon_cost(role, stat)
	if points < c:
		return points
	weapon_levels[role][stat] = int(weapon_levels[role][stat]) + 1
	return points - c


## No-op (unchanged points) if the role is already at TIER_MAX.
func try_buy_tier(role: WeaponStats.Role, points: int) -> int:
	if tiers[role] >= WeaponStats.TIER_MAX:
		return points
	var c := tier_cost(role)
	if points < c:
		return points
	tiers[role] = int(tiers[role]) + 1
	return points - c


func move_speed() -> float:
	return 6.0 + float(player_levels[PlayerStat.MOVE_SPEED]) * 0.75


func max_hp() -> float:
	return 100.0 + float(player_levels[PlayerStat.MAX_HP]) * 25.0


func damage(role: WeaponStats.Role) -> float:
	return WeaponStats.damage(role, tiers[role], weapon_levels[role][WeaponStat.DAMAGE])


func cooldown(role: WeaponStats.Role) -> float:
	return WeaponStats.cooldown(role, tiers[role], weapon_levels[role][WeaponStat.RATE])
