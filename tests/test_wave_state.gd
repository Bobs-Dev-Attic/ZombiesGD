extends TestCase

## GameManager's pure arithmetic (kill bookkeeping, wave increment, perimeter
## spawn-position math), extracted into WaveState so it's testable without
## the GameManager autoload (see scripts/wave_state.gd).


func run() -> void:
	# --- apply_kill ---
	var r1 := WaveState.apply_kill(3, 10, 5)
	check_eq(r1["alive_zombies"], 2, "apply_kill(3, 10, 5) alive_zombies")
	check_eq(r1["points"], 15, "apply_kill(3, 10, 5) points")
	check_eq(r1["wave_cleared"], false, "apply_kill(3, 10, 5) wave not cleared")

	var r2 := WaveState.apply_kill(1, 20, 8)
	check_eq(r2["alive_zombies"], 0, "apply_kill(1, 20, 8) alive_zombies hits 0")
	check_eq(r2["points"], 28, "apply_kill(1, 20, 8) points")
	check_eq(r2["wave_cleared"], true, "apply_kill(1, 20, 8) wave cleared")

	var r3 := WaveState.apply_kill(0, 5, 5)
	check_eq(r3["alive_zombies"], 0, "apply_kill(0, ...) alive_zombies clamps at 0, never negative")
	check_eq(r3["wave_cleared"], true, "apply_kill(0, ...) reports cleared")

	# --- next_wave ---
	check_eq(WaveState.next_wave(0), 1, "next_wave(0) == 1 (first wave)")
	check_eq(WaveState.next_wave(3), 4, "next_wave(3) == 4")

	# --- spawn_position ---
	var p0 := WaveState.spawn_position(0, 4, 18.0, 1.4)
	check_approx(p0.x, 18.0, "spawn_position index 0 sits at +X on the radius")
	check_approx(p0.y, 1.4, "spawn_position uses the given rest height")
	check_approx(p0.z, 0.0, "spawn_position index 0 has z == 0")

	var p1 := WaveState.spawn_position(1, 4, 18.0, 1.4)
	check_approx(p1.x, 0.0, "spawn_position index 1 of 4 is a quarter turn (x == 0)")
	check_approx(p1.z, 18.0, "spawn_position index 1 of 4 is a quarter turn (z == radius)")

	# every spawn point lands exactly on the perimeter circle, regardless of index
	for i in range(6):
		var p := WaveState.spawn_position(i, 6, 18.0, 1.4)
		var flat := Vector2(p.x, p.z)
		check_approx(flat.length(), 18.0, "spawn_position index %d of 6 lands on the radius" % i)
		check_approx(p.y, 1.4, "spawn_position index %d of 6 keeps rest height" % i)
