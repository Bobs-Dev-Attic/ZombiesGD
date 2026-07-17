extends TestCase

## InputManager itself is an autoload that reads live Input/DisplayServer
## state, which is not meaningfully testable headlessly. The one piece of
## pure logic it contains -- clamping a touch-joystick vector to unit
## length without rescaling shorter vectors -- is extracted as a static
## function so it can be tested directly here. The rest of the autoload's
## behavior is verified by the project loading and running without script
## errors (see task-4-report.md).


# The InputManager autoload singleton isn't reachable as a global identifier
# from a script run outside the main scene tree, so load its script
# directly and call the static helper on it.
const InputManagerScript := preload("res://scripts/input_manager.gd")


func run() -> void:
	var full_deflect: Vector2 = InputManagerScript.normalize_move_vector(Vector2(2, 0))
	check_approx(full_deflect.length(), 1.0, "over-length vector is clamped to length 1")
	check(full_deflect.is_equal_approx(Vector2(1, 0)), "over-length vector keeps its direction")

	var partial_deflect: Vector2 = InputManagerScript.normalize_move_vector(Vector2(0.3, 0.4))
	check(partial_deflect.is_equal_approx(Vector2(0.3, 0.4)), "under-length vector is left unscaled")

	var zero_deflect: Vector2 = InputManagerScript.normalize_move_vector(Vector2.ZERO)
	check(zero_deflect.is_equal_approx(Vector2.ZERO), "zero vector stays zero")
