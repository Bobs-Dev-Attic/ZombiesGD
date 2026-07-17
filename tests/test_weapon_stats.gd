extends TestCase


func run() -> void:
	# base_damage / base_cooldown per role/tier (exact roster table)
	check_approx(WeaponStats.base_damage(WeaponStats.Role.RANGED, 1), 10.0, "RANGED t1 base_damage")
	check_approx(WeaponStats.base_cooldown(WeaponStats.Role.RANGED, 1), 0.45, "RANGED t1 base_cooldown")
	check_approx(WeaponStats.base_damage(WeaponStats.Role.RANGED, 2), 6.0, "RANGED t2 base_damage")
	check_approx(WeaponStats.base_cooldown(WeaponStats.Role.RANGED, 2), 0.80, "RANGED t2 base_cooldown")

	check_approx(WeaponStats.base_damage(WeaponStats.Role.MELEE, 1), 15.0, "MELEE t1 base_damage")
	check_approx(WeaponStats.base_cooldown(WeaponStats.Role.MELEE, 1), 0.50, "MELEE t1 base_cooldown")
	check_approx(WeaponStats.base_damage(WeaponStats.Role.MELEE, 2), 30.0, "MELEE t2 base_damage")
	check_approx(WeaponStats.base_cooldown(WeaponStats.Role.MELEE, 2), 0.80, "MELEE t2 base_cooldown")

	check_approx(WeaponStats.base_damage(WeaponStats.Role.THROWN, 1), 60.0, "THROWN t1 base_damage")
	check_approx(WeaponStats.base_cooldown(WeaponStats.Role.THROWN, 1), 7.00, "THROWN t1 base_cooldown")
	check_approx(WeaponStats.base_damage(WeaponStats.Role.THROWN, 2), 40.0, "THROWN t2 base_damage")
	check_approx(WeaponStats.base_cooldown(WeaponStats.Role.THROWN, 2), 9.00, "THROWN t2 base_cooldown")

	# per-level coefficients + floors
	check_approx(WeaponStats.damage_per_level(WeaponStats.Role.RANGED), 5.0, "RANGED damage_per_level")
	check_approx(WeaponStats.cooldown_per_level(WeaponStats.Role.RANGED), 0.04, "RANGED cooldown_per_level")
	check_approx(WeaponStats.cooldown_floor(WeaponStats.Role.RANGED), 0.12, "RANGED cooldown_floor")

	check_approx(WeaponStats.damage_per_level(WeaponStats.Role.MELEE), 7.0, "MELEE damage_per_level")
	check_approx(WeaponStats.cooldown_per_level(WeaponStats.Role.MELEE), 0.04, "MELEE cooldown_per_level")
	check_approx(WeaponStats.cooldown_floor(WeaponStats.Role.MELEE), 0.20, "MELEE cooldown_floor")

	check_approx(WeaponStats.damage_per_level(WeaponStats.Role.THROWN), 15.0, "THROWN damage_per_level")
	check_approx(WeaponStats.cooldown_per_level(WeaponStats.Role.THROWN), 0.40, "THROWN cooldown_per_level")
	check_approx(WeaponStats.cooldown_floor(WeaponStats.Role.THROWN), 3.00, "THROWN cooldown_floor")

	# damage()/cooldown() at level 0 (must equal base) AND at a non-zero level, every role.
	check_approx(
		WeaponStats.damage(WeaponStats.Role.RANGED, 1, 0), 10.0, "RANGED t1 damage@0 = base"
	)
	check_approx(
		WeaponStats.damage(WeaponStats.Role.RANGED, 1, 3), 25.0, "RANGED t1 damage@3 = 10 + 3*5"
	)
	check_approx(
		WeaponStats.cooldown(WeaponStats.Role.RANGED, 1, 0), 0.45, "RANGED t1 cooldown@0 = base"
	)
	check_approx(
		WeaponStats.cooldown(WeaponStats.Role.RANGED, 1, 2),
		0.37,
		"RANGED t1 cooldown@2 = 0.45 - 2*0.04"
	)

	check_approx(
		WeaponStats.damage(WeaponStats.Role.MELEE, 2, 0), 30.0, "MELEE t2 damage@0 = base"
	)
	check_approx(
		WeaponStats.damage(WeaponStats.Role.MELEE, 2, 4), 58.0, "MELEE t2 damage@4 = 30 + 4*7"
	)
	check_approx(
		WeaponStats.cooldown(WeaponStats.Role.MELEE, 2, 0), 0.80, "MELEE t2 cooldown@0 = base"
	)
	check_approx(
		WeaponStats.cooldown(WeaponStats.Role.MELEE, 2, 3),
		0.68,
		"MELEE t2 cooldown@3 = 0.80 - 3*0.04"
	)

	check_approx(
		WeaponStats.damage(WeaponStats.Role.THROWN, 1, 0), 60.0, "THROWN t1 damage@0 = base"
	)
	check_approx(
		WeaponStats.damage(WeaponStats.Role.THROWN, 1, 2), 90.0, "THROWN t1 damage@2 = 60 + 2*15"
	)
	check_approx(
		WeaponStats.cooldown(WeaponStats.Role.THROWN, 1, 0), 7.00, "THROWN t1 cooldown@0 = base"
	)
	check_approx(
		WeaponStats.cooldown(WeaponStats.Role.THROWN, 1, 5),
		5.00,
		"THROWN t1 cooldown@5 = 7.00 - 5*0.40"
	)

	# cooldown floor actually clamps (THROWN at a high level would go below 3.0 unclamped)
	check_approx(
		WeaponStats.cooldown(WeaponStats.Role.THROWN, 2, 100),
		3.00,
		"THROWN cooldown floors at 3.00, does not go negative"
	)
	check_approx(
		WeaponStats.cooldown(WeaponStats.Role.RANGED, 2, 100),
		0.12,
		"RANGED cooldown floors at 0.12"
	)
	check_approx(
		WeaponStats.cooldown(WeaponStats.Role.MELEE, 2, 100),
		0.20,
		"MELEE cooldown floors at 0.20"
	)

	# tier clamping for an out-of-range tier
	check_approx(
		WeaponStats.base_damage(WeaponStats.Role.RANGED, 0),
		10.0,
		"tier below TIER_MIN clamps to tier 1"
	)
	check_approx(
		WeaponStats.base_damage(WeaponStats.Role.RANGED, 5),
		6.0,
		"tier above TIER_MAX clamps to tier 2"
	)

	# weapon names
	check_eq(WeaponStats.weapon_name(WeaponStats.Role.RANGED, 1), "Pistol", "RANGED t1 name")
	check_eq(WeaponStats.weapon_name(WeaponStats.Role.RANGED, 2), "Shotgun", "RANGED t2 name")
	check_eq(WeaponStats.weapon_name(WeaponStats.Role.MELEE, 1), "Knife", "MELEE t1 name")
	check_eq(WeaponStats.weapon_name(WeaponStats.Role.MELEE, 2), "Axe", "MELEE t2 name")
	check_eq(WeaponStats.weapon_name(WeaponStats.Role.THROWN, 1), "Grenade", "THROWN t1 name")
	check_eq(
		WeaponStats.weapon_name(WeaponStats.Role.THROWN, 2), "Cluster Grenade", "THROWN t2 name"
	)
