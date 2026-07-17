extends "res://scripts/fx/fx_lifetime.gd"

## Brief slash sweep shown in front of the player when a melee swing
## connects. Caller: instantiate, add_child to get_tree().current_scene, set
## global_transform to the player's (so the arc matches facing), then call
## setup(reach, arc_degrees) -- which sizes/positions the mesh from
## MeleeWeapon.reach()/arc_degrees() and starts the fade. NOT parented to the
## player -- it is about to queue_free() itself.

const DURATION: float = 0.12
const THICKNESS: float = 0.05

@onready var _mesh: MeshInstance3D = $MeshInstance3D


## width is the chord spanned by the arc at full reach, so a wider
## arc_degrees (axe, 120) visibly reads as a wider slash than a narrow one
## (knife, 60), matching MeleeWeapon.arc_degrees(tier).
func setup(reach: float, arc_degrees: float) -> void:
	var half_arc_rad := deg_to_rad(arc_degrees / 2.0)
	var width: float = 2.0 * reach * sin(half_arc_rad)
	var box := BoxMesh.new()
	box.size = Vector3(maxf(width, 0.1), THICKNESS, maxf(reach, 0.1))
	_mesh.mesh = box
	# Box is centred on this node's origin by default; shift it forward
	# (local -Z, matching player facing) so it spans from the player out to
	# reach instead of half in front / half behind.
	_mesh.position = Vector3(0.0, 0.0, -reach / 2.0)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(0.85, 0.95, 1.0, 0.85)
	mat.emission_enabled = true
	mat.emission = Color(0.75, 0.9, 1.0)
	mat.emission_energy_multiplier = 3.0
	_mesh.material_override = mat
	_play(DURATION, [mat], 1.15)
