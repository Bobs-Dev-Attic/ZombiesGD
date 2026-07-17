class_name PlayerHealth
extends RefCounted

## Pure HP arithmetic extracted out of Player so it can be unit tested
## headlessly. Player itself references the InputManager autoload at the
## class-body level (in _physics_process), and GDScript resolves that
## identifier at compile time — when a test script preloads player.gd
## directly via `-s res://tests/run_tests.gd`, autoloads have not been
## registered yet (that only happens once the SceneTree's normal main-scene
## bootstrap runs), so the whole class fails to compile with
## "Identifier not found: InputManager". Keeping the pure math here, in a
## script with no autoload references, sidesteps that entirely.


## Damage clamps at 0, never negative.
static func damage(hp: float, amount: float) -> float:
	return maxf(0.0, hp - amount)


## Per design: HP heals to full only when max_hp increases (i.e. a MAX_HP
## upgrade was purchased between waves). Buying any other upgrade kind keeps
## current HP as-is (clamped down if max_hp ever decreased, which upgrades
## never do today, but keeps this total).
static func apply_upgrades_hp(hp: float, old_max_hp: float, new_max_hp: float) -> float:
	if new_max_hp > old_max_hp:
		return new_max_hp
	return minf(hp, new_max_hp)
