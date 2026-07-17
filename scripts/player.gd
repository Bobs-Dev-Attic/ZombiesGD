extends CharacterBody3D

## Player: WASD/gamepad movement, mouse aim (or touch-stick aim when in touch
## mode), and a single hitscan gun. Combat power is entirely derived from
## `upgrades` (Upgrades) — this script has no damage/speed constants of its
## own beyond the muzzle ray's max range.

signal died
signal hp_changed(current: float, maximum: float)

var upgrades: Upgrades = Upgrades.new()
var hp: float = 100.0
var _fire_timer: float = 0.0
var _melee_timer: float = 0.0

@onready var _muzzle: Marker3D = $Gun/Muzzle

const RAY_RANGE: float = 40.0
const ZOMBIE_MASK: int = 2


func _ready() -> void:
	add_to_group("player")
	hp = upgrades.max_hp()
	hp_changed.emit(hp, upgrades.max_hp())


## Refresh derived stats from a new Upgrades snapshot. Per design: healing to
## full only happens when max_hp increases between waves (i.e. a MAX_HP
## upgrade was purchased) — buying other upgrade kinds must not top off HP.
## Arithmetic lives in PlayerHealth (tests/test_player.gd) so it's covered
## headlessly without needing this InputManager-referencing script to load.
func apply_upgrades(u: Upgrades) -> void:
	var old_max := upgrades.max_hp()
	upgrades = u
	var new_max := upgrades.max_hp()
	hp = PlayerHealth.apply_upgrades_hp(hp, old_max, new_max)
	hp_changed.emit(hp, new_max)


func get_hp() -> float:
	return hp


func get_max_hp() -> float:
	return upgrades.max_hp()


func take_damage(amount: float) -> void:
	if hp <= 0.0:
		return
	hp = PlayerHealth.damage(hp, amount)
	hp_changed.emit(hp, upgrades.max_hp())
	if hp <= 0.0:
		died.emit()


func _physics_process(delta: float) -> void:
	var move2: Vector2 = InputManager.get_move_vector()
	var speed: float = upgrades.move_speed()
	velocity.x = move2.x * speed
	velocity.z = move2.y * speed
	velocity.y = 0.0
	move_and_slide()
	_update_aim(move2)
	_fire_timer = maxf(0.0, _fire_timer - delta)
	if InputManager.is_fire_held() and _fire_timer <= 0.0:
		_fire()
		_fire_timer = upgrades.cooldown(WeaponStats.Role.RANGED)
	_melee_timer = maxf(0.0, _melee_timer - delta)
	if _melee_timer <= 0.0:
		_try_melee_swing()


func _update_aim(move2: Vector2) -> void:
	if InputManager.use_mouse_aim():
		var cam := get_viewport().get_camera_3d()
		if cam == null:
			return
		var screen_pos := InputManager.get_aim_screen_position()
		var from := cam.project_ray_origin(screen_pos)
		var dir := cam.project_ray_normal(screen_pos)
		if absf(dir.y) < 0.0001:
			return
		var t := -(from.y - global_position.y) / dir.y
		if t < 0.0:
			return
		var hit := from + dir * t
		var look := Vector3(hit.x, global_position.y, hit.z)
		if look.distance_to(global_position) > 0.1:
			look_at(look, Vector3.UP)
	else:
		if move2.length() > 0.1:
			var look := global_position + Vector3(move2.x, 0.0, move2.y)
			look_at(look, Vector3.UP)


func _fire() -> void:
	var space := get_world_3d().direct_space_state
	var origin := _muzzle.global_position
	var toward := -global_transform.basis.z
	var tier: int = upgrades.tiers[WeaponStats.Role.RANGED]
	for angle_degrees in RangedWeapon.pellet_angles(tier):
		var pellet_dir := toward.rotated(Vector3.UP, deg_to_rad(angle_degrees))
		var query := PhysicsRayQueryParameters3D.create(origin, origin + pellet_dir * RAY_RANGE)
		query.collide_with_areas = false
		query.collision_mask = ZOMBIE_MASK
		var result := space.intersect_ray(query)
		if result.is_empty():
			continue
		var collider = result.collider
		if collider and collider.has_method("take_damage"):
			collider.take_damage(upgrades.damage(WeaponStats.Role.RANGED))


## Automatic melee: swings by itself (no button) when a zombie is within
## reach and inside the swing arc centred on the player's aim direction.
## Independent of the ranged cooldown. Only resets its own cooldown when a
## swing actually connects with at least one zombie — a swing at nothing
## should not penalize the player with a wasted cooldown.
func _try_melee_swing() -> void:
	var tier: int = upgrades.tiers[WeaponStats.Role.MELEE]
	var reach: float = MeleeWeapon.reach(tier)
	var space := get_world_3d().direct_space_state
	var shape := SphereShape3D.new()
	shape.radius = reach
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(), global_position)
	query.collision_mask = ZOMBIE_MASK
	query.collide_with_areas = false
	var results := space.intersect_shape(query)
	var facing := -global_transform.basis.z
	var facing_xz := Vector2(facing.x, facing.z)
	var hit_any := false
	for result in results:
		var collider = result.collider
		if collider == null or not collider.has_method("take_damage"):
			continue
		var to_target: Vector3 = collider.global_position - global_position
		# intersect_shape's narrow-phase can report false positives for a
		# sphere query against capsule targets well beyond its radius, so
		# the distance is re-verified explicitly here rather than trusting
		# the shape query alone for the reach cutoff.
		if to_target.length() > reach:
			continue
		var to_target_xz := Vector2(to_target.x, to_target.z)
		if MeleeWeapon.is_in_arc(to_target_xz, facing_xz, tier):
			collider.take_damage(upgrades.damage(WeaponStats.Role.MELEE))
			hit_any = true
	if hit_any:
		_melee_timer = upgrades.cooldown(WeaponStats.Role.MELEE)
