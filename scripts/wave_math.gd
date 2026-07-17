class_name WaveMath
extends RefCounted


static func zombie_count(wave: int, base_count: int = 4, scale: int = 2) -> int:
	return base_count + wave * scale


static func zombie_max_hp(wave: int, base_hp: float = 30.0, per_wave: float = 8.0) -> float:
	return base_hp + wave * per_wave


static func zombie_speed(wave: int, base_speed: float = 3.5, per_wave: float = 0.15) -> float:
	return base_speed + wave * per_wave


static func is_fast_variant(wave: int, index: int) -> bool:
	return wave >= 4 and index % 4 == 0
