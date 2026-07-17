class_name ZombieCombat
extends RefCounted

## Pure zombie combat/stat arithmetic, extracted out of Zombie (same pattern
## as PlayerHealth for scripts/player.gd) so it can be unit tested headlessly
## without instancing a live CharacterBody3D / touching scene-tree state.


## Fast variants move 45% faster than their wave's base speed.
static func effective_speed(base_speed: float, fast: bool) -> float:
	return base_speed * (1.45 if fast else 1.0)


## Fast variants are worth more kill points.
static func points_value(fast: bool) -> int:
	return 8 if fast else 5


## Damage clamps at 0, never negative.
static func apply_damage(hp: float, amount: float) -> float:
	return maxf(0.0, hp - amount)


static func is_dead(hp: float) -> bool:
	return hp <= 0.0
