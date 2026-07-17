extends TestCase


func run() -> void:
	# reach / arc_degrees per tier
	check_approx(MeleeWeapon.reach(1), 1.8, "tier1 reach")
	check_approx(MeleeWeapon.arc_degrees(1), 60.0, "tier1 arc_degrees")
	check_approx(MeleeWeapon.reach(2), 2.2, "tier2 reach")
	check_approx(MeleeWeapon.arc_degrees(2), 120.0, "tier2 arc_degrees")

	# dead ahead -> true, both tiers
	check(
		MeleeWeapon.is_in_arc(Vector2(0.0, 1.0), Vector2(0.0, 1.0), 1),
		"tier1 dead ahead is_in_arc"
	)
	check(
		MeleeWeapon.is_in_arc(Vector2(0.0, 1.0), Vector2(0.0, 1.0), 2),
		"tier2 dead ahead is_in_arc"
	)

	# directly behind -> false, both tiers
	check(
		not MeleeWeapon.is_in_arc(Vector2(0.0, -1.0), Vector2(0.0, 1.0), 1),
		"tier1 directly behind is_in_arc"
	)
	check(
		not MeleeWeapon.is_in_arc(Vector2(0.0, -1.0), Vector2(0.0, 1.0), 2),
		"tier2 directly behind is_in_arc"
	)

	# 45 degrees off-aim: outside knife's 60-degree arc (30 either side),
	# inside axe's 120-degree arc (60 either side). Proves tiers differ.
	var facing := Vector2(0.0, 1.0)
	var off_45 := Vector2(1.0, 1.0)  # 45 degrees from facing
	check(
		not MeleeWeapon.is_in_arc(off_45, facing, 1),
		"45 degrees off-aim outside knife arc"
	)
	check(
		MeleeWeapon.is_in_arc(off_45, facing, 2),
		"45 degrees off-aim inside axe arc"
	)

	# boundary inclusivity: exactly 30 degrees off-aim -> true for knife
	var off_30 := Vector2(1.0, 1.0).rotated(0.0)
	off_30 = Vector2(0.0, 1.0).rotated(deg_to_rad(30.0))
	check(
		MeleeWeapon.is_in_arc(off_30, facing, 1),
		"exactly 30 degrees off-aim is inclusive for knife"
	)

	# just outside boundary: 31 degrees off-aim -> false for knife
	var off_31 := Vector2(0.0, 1.0).rotated(deg_to_rad(31.0))
	check(
		not MeleeWeapon.is_in_arc(off_31, facing, 1),
		"31 degrees off-aim is outside knife arc"
	)

	# zero-length to_target -> true
	check(
		MeleeWeapon.is_in_arc(Vector2.ZERO, facing, 1),
		"zero-length to_target is true"
	)

	# zero-length facing -> false
	check(
		not MeleeWeapon.is_in_arc(Vector2(0.0, 1.0), Vector2.ZERO, 1),
		"zero-length facing is false"
	)

	# un-normalized inputs give same answer as normalized
	check(
		MeleeWeapon.is_in_arc(Vector2(0.0, 5.0), Vector2(0.0, 3.0), 1),
		"un-normalized dead ahead is_in_arc"
	)
	check(
		MeleeWeapon.is_in_arc(off_30 * 10.0, facing * 4.0, 1),
		"un-normalized boundary matches normalized"
	)

	# tier clamping for out-of-range tier
	check_approx(MeleeWeapon.reach(0), MeleeWeapon.reach(1), "tier 0 clamps reach to tier1")
	check_approx(
		MeleeWeapon.arc_degrees(0), MeleeWeapon.arc_degrees(1), "tier 0 clamps arc_degrees to tier1"
	)
	check_approx(MeleeWeapon.reach(99), MeleeWeapon.reach(2), "tier 99 clamps reach to tier2")
	check_approx(
		MeleeWeapon.arc_degrees(99), MeleeWeapon.arc_degrees(2), "tier 99 clamps arc_degrees to tier2"
	)
