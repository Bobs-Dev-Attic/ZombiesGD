extends Node3D


func _ready() -> void:
	_build_arena_if_needed()


func _build_arena_if_needed() -> void:
	if has_node("Ground"):
		return
	# Arena is authored directly in scenes/main.tscn.
	pass
