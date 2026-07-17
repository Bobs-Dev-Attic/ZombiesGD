class_name Upgrades
extends RefCounted

## Pure-logic upgrade model: tracks levels per upgrade kind and derives
## player-facing stats from them. No scene tree, no nodes, no UI.

enum Kind { DAMAGE, FIRE_RATE, MOVE_SPEED, MAX_HP }

var levels: Dictionary = {
	Kind.DAMAGE: 0,
	Kind.FIRE_RATE: 0,
	Kind.MOVE_SPEED: 0,
	Kind.MAX_HP: 0,
}


func reset() -> void:
	for k in levels.keys():
		levels[k] = 0


func cost(kind: Kind) -> int:
	return 15 + int(levels[kind]) * 10


func try_buy(kind: Kind, points: int) -> int:
	var c := cost(kind)
	if points < c:
		return points
	levels[kind] = int(levels[kind]) + 1
	return points - c


func damage() -> float:
	return 10.0 + float(levels[Kind.DAMAGE]) * 5.0


func fire_cooldown() -> float:
	return maxf(0.12, 0.45 - float(levels[Kind.FIRE_RATE]) * 0.04)


func move_speed() -> float:
	return 6.0 + float(levels[Kind.MOVE_SPEED]) * 0.75


func max_hp() -> float:
	return 100.0 + float(levels[Kind.MAX_HP]) * 25.0
