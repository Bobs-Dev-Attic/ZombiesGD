extends TestCase


func run() -> void:
	check_eq(WaveMath.zombie_count(1), 6, "zombie_count(1) = 4 + 1*2")
	check_eq(WaveMath.zombie_count(3), 10, "zombie_count(3) = 4 + 3*2")
	check_approx(WaveMath.zombie_max_hp(1), 38.0, "zombie_max_hp(1)")
	check_approx(WaveMath.zombie_speed(1), 3.65, "zombie_speed(1)")
	check_eq(WaveMath.is_fast_variant(3, 0), false, "no fast variants before wave 4")
	check_eq(WaveMath.is_fast_variant(4, 0), true, "every 4th zombie is fast from wave 4")
	check_eq(WaveMath.is_fast_variant(4, 1), false, "index 1 is not a fast variant")
