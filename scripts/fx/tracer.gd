extends "res://scripts/fx/fx_lifetime.gd"

## Thin bright line from `from` to `to`, oriented as a long/thin BoxMesh.
## Caller: instantiate, add_child to get_tree().current_scene, then call
## setup(from, to) (which positions/orients/sizes the mesh and starts the
## fade -- unlike the other fx nodes, this one packs everything into a single
## call since it needs both endpoints up front).

const DURATION: float = 0.05
const THICKNESS: float = 0.03
const MIN_LENGTH: float = 0.05

@onready var _mesh: MeshInstance3D = $MeshInstance3D


func setup(from: Vector3, to: Vector3) -> void:
	var delta := to - from
	var length: float = maxf(delta.length(), MIN_LENGTH)
	global_position = from + delta * 0.5
	if delta.length() > 0.001:
		var direction := delta.normalized()
		# Guard the near-vertical case where look_at's default up vector is
		# parallel to the look direction (would produce a degenerate basis).
		var up := Vector3.UP if absf(direction.dot(Vector3.UP)) < 0.999 else Vector3.FORWARD
		look_at(global_position + direction, up)
	var box := BoxMesh.new()
	box.size = Vector3(THICKNESS, THICKNESS, length)
	_mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1.0, 0.95, 0.6, 0.9)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.9, 0.5)
	mat.emission_energy_multiplier = 3.0
	_mesh.material_override = mat
	_play(DURATION, [mat])
