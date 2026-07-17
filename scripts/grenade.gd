extends Node3D

## Grenade projectile for the THROWN role (Grenade -> Cluster Grenade). Pure
## flight + explosion behaviour, driven entirely by the parameters the
## thrower passes to launch() -- no autoload references, no reaching for the
## player or Upgrades, so this stays independent of player.gd. (It still
## can't be preloaded under the `-s` test runner because it's a Node3D scene
## script relying on the live scene tree/physics world, same as player.gd;
## the pure blast-shape math it calls into lives in ThrownWeapon instead,
## which IS unit-tested.)
##
## No RigidBody3D: position is interpolated by hand every physics frame
## (straight-line XZ + a parabolic vertical arc) so the grenade visibly lobs
## without needing physics simulation.

const ThrownWeapon := preload("res://scripts/thrown_weapon.gd")
const WeaponStats := preload("res://scripts/weapon_stats.gd")
const ExplosionScene := preload("res://scenes/fx/explosion.tscn")

const ARC_HEIGHT: float = 1.5

var _origin: Vector3 = Vector3.ZERO
var _target: Vector3 = Vector3.ZERO
var _tier: int = WeaponStats.TIER_MIN
var _full_damage: float = 0.0
var _fuse: float = 1.2
var _elapsed: float = 0.0
var _launched: bool = false


## Called by the thrower right after instancing+adding this node to the
## tree. tier and full_damage are supplied by the caller (player.gd reading
## Upgrades) -- this script never looks either up itself.
func launch(origin: Vector3, target: Vector3, tier: int, full_damage: float) -> void:
	_origin = origin
	_target = target
	_tier = tier
	_full_damage = full_damage
	_fuse = ThrownWeapon.fuse_seconds(tier)
	_elapsed = 0.0
	_launched = true
	global_position = _origin


func _physics_process(delta: float) -> void:
	if not _launched:
		return
	_elapsed += delta
	var t: float = 1.0 if _fuse <= 0.0 else clampf(_elapsed / _fuse, 0.0, 1.0)
	var flat := _origin.lerp(_target, t)
	# Simple parabolic arc peaking at the midpoint of the flight, purely
	# cosmetic -- explosion timing/position use _target, not this arc.
	var arc := ARC_HEIGHT * 4.0 * t * (1.0 - t)
	global_position = Vector3(flat.x, flat.y + arc, flat.z)
	if t >= 1.0:
		_explode()


func _explode() -> void:
	_launched = false
	var space := get_world_3d().direct_space_state
	_damage_in_radius(space, _target, ThrownWeapon.blast_radius(_tier), _full_damage)
	_spawn_explosion(_target, ThrownWeapon.blast_radius(_tier))
	if ThrownWeapon.bomblet_count(_tier) > 0:
		var bomblet_damage := _full_damage * ThrownWeapon.bomblet_damage_fraction()
		var bomblet_radius := ThrownWeapon.bomblet_radius(_tier)
		for offset in ThrownWeapon.bomblet_offsets(_tier):
			var bomblet_center := _target + Vector3(offset.x, 0.0, offset.y)
			_damage_in_radius(space, bomblet_center, bomblet_radius, bomblet_damage)
			_spawn_explosion(bomblet_center, bomblet_radius)
	queue_free()


## Cosmetic only -- spawned into the current scene, not as a child of this
## node, so the effect outlives the grenade's queue_free() right after this
## returns. Uses get_tree().current_scene (not an autoload/player reference)
## to keep grenade.gd independent, same as the rest of this script.
func _spawn_explosion(at_point: Vector3, radius: float) -> void:
	var fx := ExplosionScene.instantiate()
	get_tree().current_scene.add_child(fx)
	fx.global_position = at_point
	fx.setup(radius)


## Shared shape-query + centre-to-centre distance/falloff logic for both the
## main blast and each bomblet, mirroring player.gd::_try_melee_swing's
## approach: intersect_shape matches on capsule overlap, so measuring
## centre-to-centre keeps the blast radius uniform per target regardless of
## a zombie's collision capsule size.
func _damage_in_radius(
	space: PhysicsDirectSpaceState3D, center: Vector3, radius: float, full_damage: float
) -> void:
	if radius <= 0.0:
		return
	var shape := SphereShape3D.new()
	shape.radius = radius
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(), center)
	query.collision_mask = WeaponStats.ZOMBIE_COLLISION_MASK
	query.collide_with_areas = false
	var results := space.intersect_shape(query)
	for result in results:
		var collider = result.collider
		if collider == null or not collider.has_method("take_damage"):
			continue
		var distance: float = collider.global_position.distance_to(center)
		if distance > radius:
			continue
		var dealt := ThrownWeapon.damage_at(distance, radius, full_damage)
		if dealt > 0.0:
			collider.take_damage(dealt)
