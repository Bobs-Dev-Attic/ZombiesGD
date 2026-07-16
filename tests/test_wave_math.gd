extends RefCounted


func run() -> void:
	assert(WaveMath.zombie_count(1) == 6)  # 4 + 1*2
	assert(WaveMath.zombie_count(3) == 10)
	assert(is_equal_approx(WaveMath.zombie_max_hp(1), 38.0))
	assert(is_equal_approx(WaveMath.zombie_speed(1), 3.65))
	assert(WaveMath.is_fast_variant(3, 0) == false)
	assert(WaveMath.is_fast_variant(4, 0) == true)
	assert(WaveMath.is_fast_variant(4, 1) == false)
	print("test_wave_math: PASS")
