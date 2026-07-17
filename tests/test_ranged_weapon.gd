extends TestCase


func run() -> void:
	# pellet_count / spread_degrees per tier
	check_eq(RangedWeapon.pellet_count(1), 1, "tier1 pellet_count")
	check_approx(RangedWeapon.spread_degrees(1), 0.0, "tier1 spread_degrees")
	check_eq(RangedWeapon.pellet_count(2), 5, "tier2 pellet_count")
	check_approx(RangedWeapon.spread_degrees(2), 20.0, "tier2 spread_degrees")

	# tier 1 divide-by-zero case: exactly [0.0]
	var angles1 := RangedWeapon.pellet_angles(1)
	check_eq(angles1.size(), 1, "tier1 pellet_angles size")
	check_approx(angles1[0], 0.0, "tier1 pellet_angles[0]")

	# tier 2: exactly [-10.0, -5.0, 0.0, 5.0, 10.0], in order
	var angles2 := RangedWeapon.pellet_angles(2)
	check_eq(angles2.size(), 5, "tier2 pellet_angles size")
	check_approx(angles2[0], -10.0, "tier2 pellet_angles[0]")
	check_approx(angles2[1], -5.0, "tier2 pellet_angles[1]")
	check_approx(angles2[2], 0.0, "tier2 pellet_angles[2]")
	check_approx(angles2[3], 5.0, "tier2 pellet_angles[3]")
	check_approx(angles2[4], 10.0, "tier2 pellet_angles[4]")

	# symmetric about 0 and span exactly spread_degrees
	check_approx(angles2[0] + angles2[4], 0.0, "tier2 angles symmetric about 0 (first+last)")
	check_approx(angles2[1] + angles2[3], 0.0, "tier2 angles symmetric about 0 (second+fourth)")
	check_approx(
		angles2[4] - angles2[0], RangedWeapon.spread_degrees(2), "tier2 angles span exactly spread_degrees"
	)

	# tier clamping for out-of-range tiers
	check_eq(RangedWeapon.pellet_count(0), 1, "tier 0 clamps to tier 1 pellet_count")
	check_approx(RangedWeapon.spread_degrees(0), 0.0, "tier 0 clamps to tier 1 spread_degrees")
	check_eq(RangedWeapon.pellet_count(99), 5, "tier 99 clamps to tier 2 pellet_count")
	check_approx(RangedWeapon.spread_degrees(99), 20.0, "tier 99 clamps to tier 2 spread_degrees")
	var angles0 := RangedWeapon.pellet_angles(0)
	check_eq(angles0.size(), 1, "tier 0 pellet_angles clamps to tier1 shape")
	check_approx(angles0[0], 0.0, "tier 0 pellet_angles[0] clamps to tier1 value")
