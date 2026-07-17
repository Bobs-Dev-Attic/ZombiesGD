class_name WaveState
extends RefCounted

## Pure wave-loop arithmetic extracted out of GameManager (autoload) so it
## stays unit-testable under the `-s` headless runner, which never
## registers autoloads. GameManager owns the scene-tree wiring (groups,
## signals); this class owns the numbers.


## Applies one zombie kill: increments points, decrements the alive count
## (never below 0, defensively, in case of a double-notify), and reports
## whether the wave is now cleared (alive count hit 0).
static func apply_kill(alive_zombies: int, points: int, kill_points: int) -> Dictionary:
	return {
		"alive_zombies": maxi(0, alive_zombies - 1),
		"points": points + kill_points,
		"wave_cleared": maxi(0, alive_zombies - 1) == 0,
	}


## Wave numbers are 1-based; start_run() begins at wave 0 so the first call
## produces wave 1.
static func next_wave(wave: int) -> int:
	return wave + 1


## A spawn point on the arena perimeter circle of the given radius, at the
## given rest height, evenly divided among `count` zombies by index. Index 0
## sits at +X; angles proceed counter-clockwise around Y.
static func spawn_position(index: int, count: int, radius: float, height: float) -> Vector3:
	var angle := TAU * float(index) / float(maxi(count, 1))
	return Vector3(cos(angle) * radius, height, sin(angle) * radius)
