extends "res://scripts/fx/fx_lifetime.gd"

## Small bright flash at the gun muzzle. Caller: instantiate, add_child to
## get_tree().current_scene, set global_position to the muzzle, then call
## play().

const DURATION: float = 0.06

@onready var _mesh: MeshInstance3D = $MeshInstance3D


func play() -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1.0, 0.92, 0.55, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.85, 0.35)
	mat.emission_energy_multiplier = 5.0
	_mesh.material_override = mat
	_play(DURATION, [mat], 1.8)
