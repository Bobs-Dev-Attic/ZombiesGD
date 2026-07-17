extends TestCase


func run() -> void:
	var u := Upgrades.new()
	check_eq(u.cost(Upgrades.Kind.DAMAGE), 15, "cost(DAMAGE) at level 0")
	check_approx(u.damage(), 10.0, "damage() at level 0")

	var left := u.try_buy(Upgrades.Kind.DAMAGE, 20)
	check_eq(left, 5, "try_buy(DAMAGE, 20) leaves 5 points")
	check_eq(u.levels[Upgrades.Kind.DAMAGE], 1, "DAMAGE level after buy")
	check_approx(u.damage(), 15.0, "damage() at level 1")
	check_eq(u.cost(Upgrades.Kind.DAMAGE), 25, "cost(DAMAGE) at level 1")

	var same := u.try_buy(Upgrades.Kind.DAMAGE, 10)
	check_eq(same, 10, "try_buy fails when unaffordable, points unchanged")
	check_eq(u.levels[Upgrades.Kind.DAMAGE], 1, "DAMAGE level unchanged after failed buy")

	check(u.fire_cooldown() <= 0.45, "fire_cooldown() starts at 0.45")
	check(u.move_speed() >= 6.0, "move_speed() starts at 6.0")
	check(u.max_hp() >= 100.0, "max_hp() starts at 100.0")

	# reset() zeroes all levels
	u.reset()
	check_eq(u.levels[Upgrades.Kind.DAMAGE], 0, "reset() zeroes DAMAGE level")
	check_approx(u.damage(), 10.0, "damage() back to base after reset()")

	# fire_cooldown floor
	for i in range(20):
		u.try_buy(Upgrades.Kind.FIRE_RATE, 1000)
	check_approx(u.fire_cooldown(), 0.12, "fire_cooldown() floors at 0.12")
