extends CanvasLayer

## Death overlay: shown when GameManager enters GAME_OVER, hidden otherwise
## (including on retry, since start_run() emits state_changed(PLAYING) via
## begin_next_wave()). The Retry button re-enters via GameManager.start_run()
## — the same verified reset path used everywhere else, not a scene reload.

@onready var _retry_button: Button = $RetryButton
@onready var _backdrop: ColorRect = $Backdrop


func _ready() -> void:
	_set_visible(false)
	GameManager.state_changed.connect(_on_state_changed)
	_retry_button.pressed.connect(_on_retry_pressed)


func _on_state_changed(state: GameManager.State) -> void:
	_set_visible(state == GameManager.State.GAME_OVER)


func _on_retry_pressed() -> void:
	GameManager.start_run()


## A hidden overlay must not eat clicks meant for gameplay/UI beneath it, so
## visibility is paired with MOUSE_FILTER_IGNORE on the full-rect backdrop and
## the button (visible Controls still block clicks under them by default).
func _set_visible(is_visible: bool) -> void:
	visible = is_visible
	var backdrop_filter := Control.MOUSE_FILTER_STOP if is_visible else Control.MOUSE_FILTER_IGNORE
	_backdrop.mouse_filter = backdrop_filter
	_retry_button.mouse_filter = Control.MOUSE_FILTER_STOP if is_visible else Control.MOUSE_FILTER_IGNORE
	_retry_button.disabled = not is_visible
