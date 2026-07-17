extends SceneTree

const TESTS: PackedStringArray = [
	"res://tests/test_wave_math.gd",
	"res://tests/test_weapon_stats.gd",
	"res://tests/test_upgrades.gd",
	"res://tests/test_ranged_weapon.gd",
	"res://tests/test_melee_weapon.gd",
	"res://tests/test_thrown_weapon.gd",
	"res://tests/test_input_manager.gd",
	"res://tests/test_player.gd",
	"res://tests/test_zombie.gd",
]


func _init() -> void:
	var failures := 0
	for path in TESTS:
		var test: TestCase = load(path).new()
		var test_name := path.get_file().get_basename()
		test.run()
		if test.failures.is_empty():
			print("%s: PASS" % test_name)
		else:
			for failure in test.failures:
				printerr("%s: FAIL - %s" % [test_name, failure])
			failures += test.failures.size()
	if failures > 0:
		printerr("%d assertion(s) failed" % failures)
	else:
		print("All tests passed.")
	quit(1 if failures > 0 else 0)
