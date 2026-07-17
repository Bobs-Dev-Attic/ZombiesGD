extends CanvasLayer

## Live HUD readout: HP / Points / Wave. Reads GameManager's autoload signals
## for points/wave, and the player's hp_changed signal for HP (found via the
## "player" group since this HUD has no scene reference to the player).

@onready var _hp_label: Label = $HPLabel
@onready var _points_label: Label = $PointsLabel
@onready var _wave_label: Label = $WaveLabel


func _ready() -> void:
	GameManager.points_changed.connect(_on_points_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	_on_points_changed(GameManager.points)
	_on_wave_changed(GameManager.wave)
	await _connect_to_player()


## The player may not have joined the "player" group yet when this runs
## (node order in the scene tree), so defer one frame and try again before
## giving up.
func _connect_to_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	player.hp_changed.connect(_on_hp_changed)
	if player.has_method("get_hp") and player.has_method("get_max_hp"):
		_on_hp_changed(player.get_hp(), player.get_max_hp())


func _on_hp_changed(current: float, maximum: float) -> void:
	_hp_label.text = "HP: %d / %d" % [roundi(current), roundi(maximum)]


func _on_points_changed(points: int) -> void:
	_points_label.text = "Points: %d" % points


func _on_wave_changed(wave: int) -> void:
	_wave_label.text = "Wave: %d" % wave
