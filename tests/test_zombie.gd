extends TestCase

## Zombie itself (scripts/zombie.gd) is a CharacterBody3D that chases live
## player position via get_tree().get_first_node_in_group and moves via
## move_and_slide() every physics frame — not meaningfully testable
## headlessly, and per the task's testing convention we do not contrive a
## hollow test around it. That live behavior (chase + hitscan-hits-zombie
## wiring on collision layer 2) is verified separately by a temporary
## headless probe script (see task-6-report.md), not by a unit test here.
##
## The genuinely pure part — fast-variant speed/points derivation and the
## damage/death-threshold arithmetic the brief specifies for setup()/
## take_damage() — has been extracted into scripts/zombie_combat.gd
## (ZombieCombat), which has no autoload or scene-tree references and is
## tested directly below, following the same pattern as PlayerHealth in
## tests/test_player.gd.

const ZombieCombat := preload("res://scripts/zombie_combat.gd")


func run() -> void:
	check_approx(
		ZombieCombat.effective_speed(3.5, false), 3.5, "normal variant keeps base speed"
	)
	check_approx(
		ZombieCombat.effective_speed(3.5, true), 5.075, "fast variant is 1.45x base speed"
	)

	check_eq(ZombieCombat.points_value(false), 5, "normal variant is worth 5 points")
	check_eq(ZombieCombat.points_value(true), 8, "fast variant is worth 8 points")

	check_approx(ZombieCombat.apply_damage(30.0, 10.0), 20.0, "apply_damage(30, 10) = 20")
	check_approx(
		ZombieCombat.apply_damage(5.0, 1000.0), 0.0, "damage clamps at 0, never negative"
	)
	check_approx(ZombieCombat.apply_damage(0.0, 5.0), 0.0, "damage on already-0 hp stays 0")

	check_eq(ZombieCombat.is_dead(0.0), true, "hp == 0 is dead")
	check_eq(ZombieCombat.is_dead(-5.0), true, "hp < 0 is dead")
	check_eq(ZombieCombat.is_dead(0.01), false, "hp > 0 is alive")
