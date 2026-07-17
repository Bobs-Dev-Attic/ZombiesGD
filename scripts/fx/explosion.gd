extends "res://scripts/fx/fx_lifetime.gd"

## Expanding blast sphere spawned where a grenade (or bomblet) detonates, so
## the boom reads instead of the grenade just vanishing. Caller: instantiate,
## add_child to get_tree().current_scene, set global_position to the blast
## centre, then call setup(radius) -- which sizes the mesh to match
## ThrownWeapon.blast_radius()/bomblet_radius(), starts the node small, and
## tweens it up to full size while fading. NOT parented to the grenade -- it
## must outlive it (grenade.gd calls queue_free() on itself right after).

const DURATION: float = 0.3
const START_SCALE: float = 0.1

@onready var _mesh: MeshInstance3D = $MeshInstance3D


func setup(radius: float) -> void:
	var safe_radius: float = maxf(radius, 0.05)
	var sphere := SphereMesh.new()
	sphere.radius = safe_radius
	sphere.height = safe_radius * 2.0
	_mesh.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1.0, 0.6, 0.15, 0.7)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.45, 0.1)
	mat.emission_energy_multiplier = 3.5
	_mesh.material_override = mat
	scale = Vector3.ONE * START_SCALE
	_play(DURATION, [mat], 1.0 / START_SCALE)
