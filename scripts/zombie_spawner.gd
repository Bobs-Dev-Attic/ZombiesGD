extends Node3D

## Spawns each wave's zombies evenly around the arena perimeter, well inside
## the walls (arena_radius 18.0 vs. the ground's 20-unit half-extent and
## walls just outside that), at the same rest height the player capsule uses
## (spawn_height 1.4, matching scenes/main.tscn's Player transform) so
## zombies neither clip into geometry nor fall through the floor.
##
## Perimeter angle math lives in WaveState.spawn_position (pure, unit tested
## in tests/test_wave_state.gd). This script's only job is instancing zombies
## into the scene tree, applying this wave's WaveMath-derived stats via
## setup(), and forwarding each zombie's `killed` signal to GameManager —
## which is why this script (unlike WaveState) is NOT covered by a `-s` unit
## test: it references the GameManager autoload directly, and autoloads
## never register under that runner. It's exercised by the task-7
## integration probe instead.

@export var zombie_scene: PackedScene = preload("res://scenes/zombie.tscn")
@export var arena_radius: float = 18.0
@export var spawn_height: float = 1.4


func _ready() -> void:
	add_to_group("spawner")


func spawn_wave(wave: int) -> void:
	var count := WaveMath.zombie_count(wave)
	for i in count:
		var z: CharacterBody3D = zombie_scene.instantiate()
		add_child(z)
		z.global_position = WaveState.spawn_position(i, count, arena_radius, spawn_height)
		var fast := WaveMath.is_fast_variant(wave, i)
		z.setup(WaveMath.zombie_max_hp(wave), WaveMath.zombie_speed(wave), fast)
		z.killed.connect(_on_killed)


## Removes every zombie from the current wave. Disconnects `killed` BEFORE
## freeing: queue_free() is deferred, so a zombie could otherwise take a
## killing hit between this call and its actual removal and still decrement
## GameManager's alive count for the NEW wave.
func clear_wave() -> void:
	for child in get_children():
		if child.has_signal("killed") and child.killed.is_connected(_on_killed):
			child.killed.disconnect(_on_killed)
		child.queue_free()


func _on_killed(points: int) -> void:
	GameManager.notify_zombie_killed(points)
