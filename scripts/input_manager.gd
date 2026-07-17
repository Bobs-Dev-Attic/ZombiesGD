extends Node

## Autoload (singleton) abstracting movement/aim/fire input across
## keyboard+mouse (desktop) and touch (mobile). Gameplay code should read
## input exclusively through this node rather than polling Input directly.

var touch_enabled: bool = false
var touch_move: Vector2 = Vector2.ZERO
var touch_fire: bool = false


func _ready() -> void:
	# Enable touch path when a touch screen is present or when UI forces it.
	touch_enabled = DisplayServer.is_touchscreen_available()


func set_touch_move(v: Vector2) -> void:
	touch_move = v
	if v.length() > 0.05:
		touch_enabled = true


func set_touch_fire(held: bool) -> void:
	touch_fire = held
	if held:
		touch_enabled = true


func get_move_vector() -> Vector2:
	if touch_enabled:
		return normalize_move_vector(touch_move)
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func get_aim_screen_position() -> Vector2:
	return get_viewport().get_mouse_position()


func is_fire_held() -> bool:
	if touch_enabled:
		return touch_fire
	return Input.is_action_pressed("fire")


func use_mouse_aim() -> bool:
	return not touch_enabled


## Pure helper: clamps a raw touch-joystick vector to unit length without
## rescaling shorter vectors (so partial joystick deflection is preserved).
## Extracted so it can be unit-tested headlessly.
static func normalize_move_vector(v: Vector2) -> Vector2:
	if v.length() > 1.0:
		return v.normalized()
	return v
