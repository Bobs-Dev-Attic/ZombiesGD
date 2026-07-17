extends TestCase


func run() -> void:
	var u := Upgrades.new()

	# --- player stats ---
	check_eq(u.player_cost(Upgrades.PlayerStat.MOVE_SPEED), 15, "player_cost(MOVE_SPEED) at level 0")
	check_approx(u.move_speed(), 6.0, "move_speed() starts at 6.0")
	check_approx(u.max_hp(), 100.0, "max_hp() starts at 100.0")

	var left := u.try_buy_player(Upgrades.PlayerStat.MOVE_SPEED, 20)
	check_eq(left, 5, "try_buy_player(MOVE_SPEED, 20) leaves 5 points")
	check_eq(
		u.player_levels[Upgrades.PlayerStat.MOVE_SPEED], 1, "MOVE_SPEED level after buy"
	)
	check_approx(u.move_speed(), 6.75, "move_speed() at level 1")
	check_eq(u.player_cost(Upgrades.PlayerStat.MOVE_SPEED), 25, "player_cost(MOVE_SPEED) at level 1")

	var same := u.try_buy_player(Upgrades.PlayerStat.MOVE_SPEED, 10)
	check_eq(same, 10, "try_buy_player fails when unaffordable, points unchanged")
	check_eq(
		u.player_levels[Upgrades.PlayerStat.MOVE_SPEED],
		1,
		"MOVE_SPEED level unchanged after failed buy"
	)

	var hp_left := u.try_buy_player(Upgrades.PlayerStat.MAX_HP, 100)
	check_eq(hp_left, 85, "try_buy_player(MAX_HP, 100) leaves 85 points")
	check_approx(u.max_hp(), 125.0, "max_hp() at level 1")

	# --- per-role weapon stats ---
	check_eq(
		u.weapon_cost(WeaponStats.Role.RANGED, Upgrades.WeaponStat.DAMAGE),
		15,
		"weapon_cost(RANGED, DAMAGE) at level 0"
	)
	check_approx(
		u.damage(WeaponStats.Role.RANGED), 10.0, "RANGED damage() at level 0 tier 1 = base"
	)
	check_approx(
		u.cooldown(WeaponStats.Role.RANGED), 0.45, "RANGED cooldown() at level 0 tier 1 = base"
	)

	var wleft := u.try_buy_weapon(WeaponStats.Role.RANGED, Upgrades.WeaponStat.DAMAGE, 20)
	check_eq(wleft, 5, "try_buy_weapon(RANGED, DAMAGE, 20) leaves 5 points")
	check_eq(
		u.weapon_levels[WeaponStats.Role.RANGED][Upgrades.WeaponStat.DAMAGE],
		1,
		"RANGED DAMAGE level after buy"
	)
	check_approx(u.damage(WeaponStats.Role.RANGED), 15.0, "RANGED damage() at level 1")

	var wsame := u.try_buy_weapon(WeaponStats.Role.RANGED, Upgrades.WeaponStat.DAMAGE, 10)
	check_eq(wsame, 10, "try_buy_weapon fails when unaffordable, points unchanged")
	check_eq(
		u.weapon_levels[WeaponStats.Role.RANGED][Upgrades.WeaponStat.DAMAGE],
		1,
		"RANGED DAMAGE level unchanged after failed buy"
	)

	# a different role's levels are independent
	check_approx(
		u.damage(WeaponStats.Role.MELEE), 15.0, "MELEE damage() untouched by RANGED buys"
	)

	# RATE upgrades affect cooldown, cooldown floors correctly
	for i in range(20):
		u.try_buy_weapon(WeaponStats.Role.RANGED, Upgrades.WeaponStat.RATE, 1000)
	check_approx(
		u.cooldown(WeaponStats.Role.RANGED), 0.12, "RANGED cooldown() floors at 0.12"
	)

	# --- tiers ---
	check_eq(u.tiers[WeaponStats.Role.MELEE], WeaponStats.TIER_MIN, "MELEE starts at TIER_MIN")
	check_eq(u.tier_cost(WeaponStats.Role.MELEE), 120, "tier_cost is flat 120 below TIER_MAX")

	var tleft := u.try_buy_tier(WeaponStats.Role.MELEE, 100)
	check_eq(tleft, 100, "try_buy_tier fails when unaffordable, points unchanged")
	check_eq(u.tiers[WeaponStats.Role.MELEE], WeaponStats.TIER_MIN, "tier unchanged after failed buy")

	tleft = u.try_buy_tier(WeaponStats.Role.MELEE, 150)
	check_eq(tleft, 30, "try_buy_tier(MELEE, 150) leaves 30 points")
	check_eq(u.tiers[WeaponStats.Role.MELEE], WeaponStats.TIER_MAX, "MELEE tier advances to TIER_MAX")
	check_eq(u.tier_cost(WeaponStats.Role.MELEE), 0, "tier_cost is 0 once at TIER_MAX")

	var noop := u.try_buy_tier(WeaponStats.Role.MELEE, 1000)
	check_eq(noop, 1000, "try_buy_tier at TIER_MAX is a no-op, does not charge points")
	check_eq(u.tiers[WeaponStats.Role.MELEE], WeaponStats.TIER_MAX, "tier stays at TIER_MAX")

	# damage()/cooldown() delegate to the new tier's base stats
	check_approx(
		u.damage(WeaponStats.Role.MELEE), 30.0, "MELEE damage() reflects tier 2 base (Axe)"
	)

	# --- reset() ---
	u.reset()
	check_eq(u.player_levels[Upgrades.PlayerStat.MOVE_SPEED], 0, "reset() zeroes MOVE_SPEED level")
	check_eq(u.player_levels[Upgrades.PlayerStat.MAX_HP], 0, "reset() zeroes MAX_HP level")
	check_eq(
		u.weapon_levels[WeaponStats.Role.RANGED][Upgrades.WeaponStat.DAMAGE],
		0,
		"reset() zeroes RANGED DAMAGE level"
	)
	check_eq(
		u.weapon_levels[WeaponStats.Role.RANGED][Upgrades.WeaponStat.RATE],
		0,
		"reset() zeroes RANGED RATE level"
	)
	check_eq(
		u.tiers[WeaponStats.Role.MELEE], WeaponStats.TIER_MIN, "reset() restores tier to TIER_MIN, not 0"
	)
	check_approx(u.move_speed(), 6.0, "move_speed() back to base after reset()")
	check_approx(u.max_hp(), 100.0, "max_hp() back to base after reset()")
	check_approx(u.damage(WeaponStats.Role.MELEE), 15.0, "MELEE damage() back to tier 1 base after reset()")
