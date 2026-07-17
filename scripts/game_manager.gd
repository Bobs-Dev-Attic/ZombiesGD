extends Node

## GameManager (autoload): owns the wave loop's run state — current wave,
## points, upgrades, alive-zombie count, and the PLAYING/SHOP/GAME_OVER state
## machine — and coordinates the player + ZombieSpawner via groups ("player",
## "spawner") rather than direct scene references, so this script has no
## compile-time dependency on either node.
##
## Pure arithmetic (kill bookkeeping, wave increment, perimeter spawn-position
## math) lives in WaveState (autoload-free, unit tested in
## tests/test_wave_state.gd) so it stays testable under the `-s` headless
## runner, which never registers autoloads — this script itself is NOT
## covered by a unit test for that reason; it's exercised by the task-7
## integration probe instead.
##
## Task 8 (shop UI) does not exist yet. This class only exposes the SHOP
## state plus `shop_opened`/`state_changed`/`points_changed` signals and the
## buy_upgrade_* methods for that UI to attach to later — no UI is built
## here.
##
## NOTE ON STALE BRIEF: task-7-brief.md's sample GameManager used a flat
## `Upgrades.Kind` enum and a single `buy_upgrade(kind)` entry point. Upgrades
## (scripts/upgrades.gd) was rewritten since the brief was authored: it is
## now per-role (PlayerStat / WeaponStat / tiers) with try_buy_player /
## try_buy_weapon / try_buy_tier. This GameManager targets that current API
## via three buy_upgrade_* methods instead of the brief's single one.

const WaveState := preload("res://scripts/wave_state.gd")

enum State { PLAYING, SHOP, GAME_OVER }

signal state_changed(state: State)
signal wave_changed(wave: int)
signal points_changed(points: int)
signal shop_opened
signal run_reset

var state: State = State.PLAYING
var wave: int = 0
var points: int = 0
var upgrades: Upgrades = Upgrades.new()
var alive_zombies: int = 0

## The player's starting transform, captured the first time a run starts (main.gd
## calls start_run() a frame after _ready, before the player can have moved).
## Captured rather than hardcoded so it tracks scenes/main.tscn instead of
## duplicating its spawn point here.
var _player_spawn: Vector3 = Vector3.ZERO
var _player_spawn_captured: bool = false


## Resets the run to a fresh state and starts wave 1. This is also the retry
## entry point after GAME_OVER, so it must leave nothing behind: zombies still
## alive from the previous run would otherwise stay parented to the spawner and
## decrement the NEW wave's alive count when killed, clearing it early.
func start_run() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player is Node3D:
		if not _player_spawn_captured:
			_player_spawn = (player as Node3D).global_position
			_player_spawn_captured = true
	var spawner := get_tree().get_first_node_in_group("spawner")
	if spawner and spawner.has_method("clear_wave"):
		spawner.clear_wave()
	upgrades.reset()
	points = 0
	wave = 0
	alive_zombies = 0
	if player and player.has_method("apply_upgrades"):
		player.apply_upgrades(upgrades)
	if player and player.has_method("reset_for_run"):
		player.reset_for_run(_player_spawn)
	points_changed.emit(points)
	run_reset.emit()
	begin_next_wave()


func add_points(n: int) -> void:
	points += n
	points_changed.emit(points)


## Called by ZombieSpawner-spawned zombies' `killed` signal. Awards points,
## decrements the alive count, and opens the shop once the wave is cleared.
func notify_zombie_killed(n: int) -> void:
	var result := WaveState.apply_kill(alive_zombies, points, n)
	alive_zombies = result["alive_zombies"]
	points = result["points"]
	points_changed.emit(points)
	if state == State.PLAYING and result["wave_cleared"]:
		_enter_shop()


## Current API: buy a player stat upgrade (Upgrades.PlayerStat).
func buy_upgrade_player(stat: Upgrades.PlayerStat) -> void:
	if state != State.SHOP:
		return
	var before := points
	points = upgrades.try_buy_player(stat, points)
	if points == before:
		return
	points_changed.emit(points)
	_apply_upgrades_to_player()


## Current API: buy a per-role weapon stat upgrade (Upgrades.WeaponStat).
func buy_upgrade_weapon(role: WeaponStats.Role, stat: Upgrades.WeaponStat) -> void:
	if state != State.SHOP:
		return
	var before := points
	points = upgrades.try_buy_weapon(role, stat, points)
	if points == before:
		return
	points_changed.emit(points)
	_apply_upgrades_to_player()


## Current API: buy the next weapon tier for a role.
func buy_upgrade_tier(role: WeaponStats.Role) -> void:
	if state != State.SHOP:
		return
	var before := points
	points = upgrades.try_buy_tier(role, points)
	if points == before:
		return
	points_changed.emit(points)
	_apply_upgrades_to_player()


## Advances to the next wave and asks the ZombieSpawner (found via the
## "spawner" group) to spawn it.
func begin_next_wave() -> void:
	wave = WaveState.next_wave(wave)
	wave_changed.emit(wave)
	state = State.PLAYING
	state_changed.emit(state)
	var spawner := get_tree().get_first_node_in_group("spawner")
	if spawner and spawner.has_method("spawn_wave"):
		alive_zombies = WaveMath.zombie_count(wave)
		spawner.spawn_wave(wave)


func on_player_died() -> void:
	state = State.GAME_OVER
	state_changed.emit(state)


func _enter_shop() -> void:
	state = State.SHOP
	state_changed.emit(state)
	shop_opened.emit()
	_apply_upgrades_to_player()


func _apply_upgrades_to_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("apply_upgrades"):
		player.apply_upgrades(upgrades)
