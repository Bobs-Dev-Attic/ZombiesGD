extends CharacterBody3D

## Zombie: chases the player (group "player"), deals contact damage on a
## cooldown, and dies when its HP (set via setup()) reaches zero. Per-wave
## stats (max_hp, speed, fast-variant flag) are supplied by the spawner
## (Task 7) via setup() — this script owns no wave-progression math itself.
## Pure stat/damage arithmetic lives in ZombieCombat so it's unit-testable
## headlessly (see tests/test_zombie.gd), following the PlayerHealth pattern
## in scripts/player_health.gd.

signal killed(points: int)

const ZombieCombat := preload("res://scripts/zombie_combat.gd")

const CONTACT_DAMAGE: float = 12.0
const CONTACT_INTERVAL: float = 0.5
const CONTACT_RANGE: float = 1.6

var max_hp: float = 30.0
var hp: float = 30.0
var move_speed: float = 3.5
var points_value: int = 5
var _contact_cooldown: float = 0.0

@onready var _body: MeshInstance3D = $Body


## Called by the spawner with this wave's derived stats (WaveMath.zombie_max_hp,
## WaveMath.zombie_speed, WaveMath.is_fast_variant).
func setup(p_max_hp: float, p_speed: float, fast: bool) -> void:
	max_hp = p_max_hp
	hp = p_max_hp
	move_speed = ZombieCombat.effective_speed(p_speed, fast)
	points_value = ZombieCombat.points_value(fast)
	if fast and _body != null:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.55, 0.15, 0.15)
		_body.material_override = mat


## Called by the player's hitscan ray (layer 2) via collider.take_damage(...).
func take_damage(amount: float) -> void:
	hp = ZombieCombat.apply_damage(hp, amount)
	if ZombieCombat.is_dead(hp):
		killed.emit(points_value)
		queue_free()


func _physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		velocity = Vector3.ZERO
		move_and_slide()
		return
	var to_player := player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() > 0.1:
		var dir := to_player.normalized()
		velocity = dir * move_speed
		look_at(global_position + dir, Vector3.UP)
	else:
		velocity = Vector3.ZERO
	move_and_slide()
	_contact_cooldown = maxf(0.0, _contact_cooldown - delta)
	if _contact_cooldown <= 0.0 and global_position.distance_to(player.global_position) < CONTACT_RANGE:
		if player.has_method("take_damage"):
			player.take_damage(CONTACT_DAMAGE)
		_contact_cooldown = CONTACT_INTERVAL
