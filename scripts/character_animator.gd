class_name CharacterAnimator
extends Node3D

## Reusable animator wrapper for an imported rigged character (character.glb):
## applies a skin texture, normalizes clip looping, corrects facing, and
## switches between "Idle"/"Run" based on planar movement speed. Attach to a
## Node3D that holds the GLB instance as a child. Used by the player now and
## by zombies in a later pass -- no autoload references, so it stays usable
## from any context (including headless probes).

## Albedo texture applied to the skinned mesh's material_override at _ready.
@export var skin: Texture2D

## Y rotation (degrees) to correct the model's facing relative to this node.
## The model faces along +/-Z but which sign was not measured -- if the
## character ends up facing away from its aim/movement in-game, set this to
## 180. Kept as a single obvious export for quick correction.
@export var facing_offset_degrees: float = 0.0

## Planar speed (units/sec) above which locomotion switches from Idle to Run.
@export var move_speed_threshold: float = 0.3

## Playback-speed multiplier applied to the Run animation (zombies will set
## this below 1.0 to shamble).
@export var run_anim_speed_scale: float = 1.0

var _anim_player: AnimationPlayer
var _mesh: MeshInstance3D


func _ready() -> void:
	rotation_degrees.y = facing_offset_degrees
	_anim_player = _find_animation_player(self)
	_mesh = _find_skinned_mesh(self)
	if _anim_player == null or _mesh == null:
		push_warning("CharacterAnimator: could not resolve AnimationPlayer and/or skinned MeshInstance3D under %s; animation/skin will not work." % name)
		return
	if skin != null:
		var material := StandardMaterial3D.new()
		material.albedo_texture = skin
		_mesh.material_override = material
	_set_loop(&"Idle")
	_set_loop(&"Run")
	_anim_player.play(&"Idle")


func update_locomotion(planar_speed: float) -> void:
	if _anim_player == null:
		return
	if planar_speed > move_speed_threshold:
		if _anim_player.current_animation != &"Run":
			_anim_player.play(&"Run", 0.15)
		_anim_player.speed_scale = run_anim_speed_scale
	else:
		if _anim_player.current_animation != &"Idle":
			_anim_player.play(&"Idle", 0.15)
		_anim_player.speed_scale = 1.0


func _set_loop(anim_name: StringName) -> void:
	var anim := _anim_player.get_animation(anim_name)
	if anim != null:
		anim.loop_mode = Animation.LOOP_LINEAR


func _find_animation_player(node: Node) -> AnimationPlayer:
	for child in node.get_children():
		if child is AnimationPlayer:
			return child
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null


func _find_skinned_mesh(node: Node) -> MeshInstance3D:
	for child in node.get_children():
		if child is MeshInstance3D:
			return child
		var found := _find_skinned_mesh(child)
		if found != null:
			return found
	return null
