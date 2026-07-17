extends Control

## Small crosshair drawn at the mouse position, desktop/mouse-aim only. Hidden
## entirely in touch mode (InputManager.use_mouse_aim() == false), where
## there is no mouse position to draw at anyway.

const RADIUS: float = 10.0
const GAP: float = 4.0
const ARM_LENGTH: float = 6.0
const LINE_WIDTH: float = 2.0
const COLOR := Color(1.0, 1.0, 1.0, 0.85)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)


func _process(_delta: float) -> void:
	var show_crosshair := InputManager.use_mouse_aim()
	if visible != show_crosshair:
		visible = show_crosshair
	if visible:
		queue_redraw()


func _draw() -> void:
	var center := get_viewport().get_mouse_position()
	# Four short arms with a gap in the middle, plus a small ring -- reads
	# clearly against both the light ground and darker cover/zombies.
	draw_line(center + Vector2(0, -GAP - ARM_LENGTH), center + Vector2(0, -GAP), COLOR, LINE_WIDTH)
	draw_line(center + Vector2(0, GAP), center + Vector2(0, GAP + ARM_LENGTH), COLOR, LINE_WIDTH)
	draw_line(center + Vector2(-GAP - ARM_LENGTH, 0), center + Vector2(-GAP, 0), COLOR, LINE_WIDTH)
	draw_line(center + Vector2(GAP, 0), center + Vector2(GAP + ARM_LENGTH, 0), COLOR, LINE_WIDTH)
	draw_arc(center, RADIUS, 0.0, TAU, 24, COLOR, LINE_WIDTH, true)
