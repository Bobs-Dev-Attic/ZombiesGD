extends TestCase

## Player itself (scripts/player.gd) is a CharacterBody3D that reads live
## Input/mouse/physics state every frame — not meaningfully testable
## headlessly, and per the task's testing convention we do not contrive a
## hollow test around it.
##
## It ALSO cannot even be preloaded/instantiated from this test runner:
## player.gd references the InputManager autoload as a bare identifier
## (in _physics_process), and GDScript resolves that at compile time. When
## `tests/run_tests.gd` preloads a test script via `-s`, autoloads have not
## been registered yet (that happens later, during the normal main-scene
## bootstrap), so preloading player.gd here fails with
## "SCRIPT ERROR: Compile Error: Identifier not found: InputManager" and
## `PlayerScript.new()` silently returns null — every check() call downstream
## would then either error out or, worse, quietly never run, reporting a
## false PASS. (This was confirmed while writing this test: an earlier
## version of this file did exactly that.)
##
## The genuinely pure part — the take_damage clamp-at-zero arithmetic and the
## "heal to full only when max_hp increases between waves" rule the brief
## specifies for apply_upgrades — has been extracted into
## scripts/player_health.gd (PlayerHealth), which has no autoload references
## and is tested directly below. Player.take_damage/apply_upgrades are thin
## wrappers around these two functions plus signal emission; that wiring is
## verified only by the headless `--quit-after` run showing no script/parse
## errors, not by a unit test.

const PlayerHealth := preload("res://scripts/player_health.gd")


func run() -> void:
	check_approx(PlayerHealth.damage(100.0, 30.0), 70.0, "damage(100, 30) = 70")
	check_approx(
		PlayerHealth.damage(20.0, 1000.0), 0.0, "damage clamps at 0, never negative"
	)
	check_approx(PlayerHealth.damage(0.0, 5.0), 0.0, "damage on already-0 hp stays 0")

	check_approx(
		PlayerHealth.apply_upgrades_hp(60.0, 100.0, 125.0),
		125.0,
		"hp heals to full when max_hp increases (100 -> 125)"
	)
	check_approx(
		PlayerHealth.apply_upgrades_hp(40.0, 100.0, 100.0),
		40.0,
		"hp is untouched when max_hp does not change"
	)
	check_approx(
		PlayerHealth.apply_upgrades_hp(90.0, 125.0, 100.0),
		90.0,
		"hp is left alone (not clamped down) when max_hp decreases and hp is already below it"
	)
	check_approx(
		PlayerHealth.apply_upgrades_hp(110.0, 125.0, 100.0),
		100.0,
		"hp is clamped down when max_hp decreases below current hp"
	)
