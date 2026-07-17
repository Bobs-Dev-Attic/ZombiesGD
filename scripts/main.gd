extends Node3D

## Wires the always-there scene pieces (player, GameManager) together and
## kicks off the run. Wave spawning itself lives in ZombieSpawner
## (scenes/main.tscn), which finds GameManager via the "spawner"/"player"
## groups rather than this script passing references around.


func _ready() -> void:
	_build_arena_if_needed()
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_signal("died"):
		player.died.connect(GameManager.on_player_died)
	# One frame so the Player and ZombieSpawner have both run their own
	# _ready() (and so joined their groups) before GameManager looks for
	# them via begin_next_wave().
	await get_tree().process_frame
	GameManager.start_run()


func _build_arena_if_needed() -> void:
	if has_node("Ground"):
		return
	# Arena is authored directly in scenes/main.tscn.
	pass
