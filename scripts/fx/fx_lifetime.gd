extends Node3D

## Shared base for short-lived cosmetic fx nodes (muzzle flash, tracer,
## impact, death puff). Subclasses build their own mesh/material in an
## explicit setup-style method (called by the spawner right after
## add_child(), matching grenade.gd's launch() convention -- NOT in _ready(),
## so @onready children and any caller-supplied transform are ready first)
## and then call _play() to fade+scale the node out over `duration` seconds
## before it frees itself.
##
## Pure cosmetics only: no gameplay state, no autoload references, nothing
## here is unit-tested (see tests note in the juice brief).


## Tweens `scale` up/down to `end_scale` (relative to the node's current
## scale) and fades every material in `materials` (their albedo alpha and, if
## present, emission energy) to zero, then frees this node. `materials` may
## be empty if a subclass fades some other way.
func _play(duration: float, materials: Array, end_scale: float = 1.0) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	if end_scale != 1.0:
		var target_scale := scale * end_scale
		tween.tween_property(self, "scale", target_scale, duration)
	for mat in materials:
		if mat is StandardMaterial3D:
			var start_color: Color = mat.albedo_color
			tween.tween_property(mat, "albedo_color", Color(start_color.r, start_color.g, start_color.b, 0.0), duration)
			if mat.emission_enabled:
				tween.tween_property(mat, "emission_energy_multiplier", 0.0, duration)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
