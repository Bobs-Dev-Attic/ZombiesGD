extends TestCase

## ThrownWeapon holds the pure per-tier blast data/derivation for the THROWN
## role (Grenade -> Cluster Grenade). The live flight, the explosion physics
## query, and the input edge are not meaningfully testable headlessly (see
## grenade.gd / player.gd) -- those are covered by the integration probe
## documented in the task report, not by hollow tests here.

const ThrownWeapon := preload("res://scripts/thrown_weapon.gd")


func run() -> void:
	# blast_radius per tier
	check_approx(ThrownWeapon.blast_radius(1), 3.5, "tier1 blast_radius")
	check_approx(ThrownWeapon.blast_radius(2), 3.0, "tier2 blast_radius")

	# fuse_seconds per tier
	check_approx(ThrownWeapon.fuse_seconds(1), 1.2, "tier1 fuse_seconds")
	check_approx(ThrownWeapon.fuse_seconds(2), 1.2, "tier2 fuse_seconds")

	# bomblet_count per tier
	check_eq(ThrownWeapon.bomblet_count(1), 0, "tier1 bomblet_count")
	check_eq(ThrownWeapon.bomblet_count(2), 4, "tier2 bomblet_count")

	# bomblet_radius per tier
	check_approx(ThrownWeapon.bomblet_radius(1), 0.0, "tier1 bomblet_radius")
	check_approx(ThrownWeapon.bomblet_radius(2), 2.0, "tier2 bomblet_radius")

	# bomblet_damage_fraction is a flat constant, not per-tier
	check_approx(ThrownWeapon.bomblet_damage_fraction(), 0.5, "bomblet_damage_fraction")

	# bomblet_offsets(1) is empty
	var offsets1 := ThrownWeapon.bomblet_offsets(1)
	check_eq(offsets1.size(), 0, "tier1 bomblet_offsets is empty")

	# bomblet_offsets(2) is exactly the four expected points
	var offsets2 := ThrownWeapon.bomblet_offsets(2)
	check_eq(offsets2.size(), 4, "tier2 bomblet_offsets has 4 entries")
	check(offsets2[0].is_equal_approx(Vector2(2.5, 0.0)), "tier2 bomblet offset 0 = (2.5, 0)")
	check(offsets2[1].is_equal_approx(Vector2(0.0, 2.5)), "tier2 bomblet offset 1 = (0, 2.5)")
	check(offsets2[2].is_equal_approx(Vector2(-2.5, 0.0)), "tier2 bomblet offset 2 = (-2.5, 0)")
	check(offsets2[3].is_equal_approx(Vector2(0.0, -2.5)), "tier2 bomblet offset 3 = (0, -2.5)")

	# all offsets are exactly 2.5 from origin and mutually 90 degrees apart
	for offset in offsets2:
		check_approx(offset.length(), 2.5, "bomblet offset is exactly 2.5 from origin")
	for i in range(offsets2.size()):
		var a: Vector2 = offsets2[i]
		var b: Vector2 = offsets2[(i + 1) % offsets2.size()]
		check_approx(
			rad_to_deg(a.angle_to(b)), 90.0, "adjacent bomblet offsets are 90 degrees apart"
		)

	# damage_at at distance 0 -> full damage
	check_approx(ThrownWeapon.damage_at(0.0, 3.5, 60.0), 60.0, "damage_at distance 0 is full")

	# damage_at at exactly radius -> exactly 0.0
	check_approx(ThrownWeapon.damage_at(3.5, 3.5, 60.0), 0.0, "damage_at at exactly radius is 0")

	# damage_at beyond radius -> 0.0, never negative
	check_approx(ThrownWeapon.damage_at(10.0, 3.5, 60.0), 0.0, "damage_at beyond radius is 0")

	# damage_at at half radius -> exactly half damage (pins LINEAR falloff)
	check_approx(ThrownWeapon.damage_at(1.75, 3.5, 60.0), 30.0, "damage_at at half radius is half")

	# damage_at with distance <= 0.0 -> exactly full_damage
	check_approx(
		ThrownWeapon.damage_at(-1.0, 3.5, 60.0), 60.0, "damage_at with negative distance is full"
	)

	# damage_at with radius = 0.0 -> 0.0, no divide-by-zero
	check_approx(ThrownWeapon.damage_at(0.0, 0.0, 60.0), 0.0, "damage_at with radius 0 is 0")
	check_approx(ThrownWeapon.damage_at(1.0, 0.0, 60.0), 0.0, "damage_at with radius 0 is 0 (dist 1)")

	# tier clamping for out-of-range tier
	check_approx(
		ThrownWeapon.blast_radius(0), ThrownWeapon.blast_radius(1), "tier 0 clamps to tier1"
	)
	check_approx(
		ThrownWeapon.blast_radius(99), ThrownWeapon.blast_radius(2), "tier 99 clamps to tier2"
	)
	check_eq(
		ThrownWeapon.bomblet_count(0), ThrownWeapon.bomblet_count(1), "tier 0 clamps bomblet_count"
	)
	check_eq(
		ThrownWeapon.bomblet_count(99), ThrownWeapon.bomblet_count(2), "tier 99 clamps bomblet_count"
	)
