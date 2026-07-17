extends "res://scripts/fx/fx_lifetime.gd"

## Quick burst spawned where a zombie died, so a kill reads instead of the
## zombie just vanishing. Caller: instantiate, add_child to
## get_tree().current_scene, set global_position to the zombie's last
## position, then call play(). NOT parented to the zombie -- it is about to
## queue_free() itself.

const DURATION: float = 0.25

@onready var _mesh: MeshInstance3D = $MeshInstance3D


func play() -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(0.65, 0.2, 0.15, 0.9)
	mat.emission_enabled = true
	mat.emission = Color(0.6, 0.15, 0.1)
	mat.emission_energy_multiplier = 1.5
	_mesh.material_override = mat
	_play(DURATION, [mat], 3.0)
