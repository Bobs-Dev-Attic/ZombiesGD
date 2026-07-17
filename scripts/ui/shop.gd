extends CanvasLayer

## Between-wave shop: shown when GameManager enters SHOP, hidden otherwise.
## Player/weapon/tier buy buttons are built data-driven from the role/stat
## enums (see _ROLES/_PLAYER_STATS/_WEAPON_STATS below) rather than
## hand-wired one-off handlers, so adding a role or stat later is a data
## change, not 11 copy-pasted callbacks. Every purchase (and points_changed
## in general) triggers a full panel refresh so costs/disabled states stay
## live as the player spends.

const WeaponStats := preload("res://scripts/weapon_stats.gd")
const Upgrades := preload("res://scripts/upgrades.gd")
const ShopHelpers := preload("res://scripts/ui/shop_helpers.gd")

const _PLAYER_STATS: Array = [
	{"stat": Upgrades.PlayerStat.MOVE_SPEED, "label": "Move Speed"},
	{"stat": Upgrades.PlayerStat.MAX_HP, "label": "Max HP"},
]

const _WEAPON_STATS: Array = [
	{"stat": Upgrades.WeaponStat.DAMAGE, "label": "Damage"},
	{"stat": Upgrades.WeaponStat.RATE, "label": "Fire Rate"},
]

const _ROLES: Array = [
	{"role": WeaponStats.Role.RANGED, "label": "Ranged"},
	{"role": WeaponStats.Role.MELEE, "label": "Melee"},
	{"role": WeaponStats.Role.THROWN, "label": "Thrown"},
]

@onready var _header_label: Label = $Panel/VBoxContainer/HeaderLabel
@onready var _sections_container: VBoxContainer = $Panel/VBoxContainer/Sections
@onready var _next_wave_button: Button = $Panel/VBoxContainer/NextWaveButton

## Populated in _ready(): player-stat buy buttons keyed by PlayerStat.
var _player_buttons: Dictionary = {}
## Populated in _ready(): {role: {weapon_stat: Button}}.
var _weapon_buttons: Dictionary = {}
## Populated in _ready(): tier buy button per role.
var _tier_buttons: Dictionary = {}
## Populated in _ready(): section header Label per role (shows weapon name).
var _role_headers: Dictionary = {}


func _ready() -> void:
	_build_ui()
	visible = false
	GameManager.state_changed.connect(_on_state_changed)
	GameManager.points_changed.connect(_on_points_changed)
	_next_wave_button.pressed.connect(_on_next_wave_pressed)
	_refresh()


func _build_ui() -> void:
	var player_section := _make_section("Player")
	for entry in _PLAYER_STATS:
		var stat: Upgrades.PlayerStat = entry["stat"]
		var button := Button.new()
		button.pressed.connect(_on_player_button_pressed.bind(stat))
		player_section.add_child(button)
		_player_buttons[stat] = button

	for role_entry in _ROLES:
		var role: WeaponStats.Role = role_entry["role"]
		var role_label: String = role_entry["label"]
		var section := _make_section(role_label)
		_role_headers[role] = section.get_node("Header")

		var role_weapon_buttons: Dictionary = {}
		for entry in _WEAPON_STATS:
			var stat: Upgrades.WeaponStat = entry["stat"]
			var label: String = entry["label"]
			var button := Button.new()
			button.pressed.connect(_on_weapon_button_pressed.bind(role, stat))
			section.add_child(button)
			role_weapon_buttons[stat] = button
		_weapon_buttons[role] = role_weapon_buttons

		var tier_button := Button.new()
		tier_button.pressed.connect(_on_tier_button_pressed.bind(role))
		section.add_child(tier_button)
		_tier_buttons[role] = tier_button


## Builds a labelled section (header + buttons) inside _sections_container
## and returns it so callers can add_child their buttons to it.
func _make_section(header_text: String) -> VBoxContainer:
	var section := VBoxContainer.new()
	var header := Label.new()
	header.name = "Header"
	header.text = header_text
	section.add_child(header)
	_sections_container.add_child(section)
	return section


func _on_state_changed(state: GameManager.State) -> void:
	visible = state == GameManager.State.SHOP
	if visible:
		_refresh()


func _on_points_changed(_points: int) -> void:
	_refresh()


func _on_player_button_pressed(stat: Upgrades.PlayerStat) -> void:
	GameManager.buy_upgrade_player(stat)


func _on_weapon_button_pressed(role: WeaponStats.Role, stat: Upgrades.WeaponStat) -> void:
	GameManager.buy_upgrade_weapon(role, stat)


func _on_tier_button_pressed(role: WeaponStats.Role) -> void:
	GameManager.buy_upgrade_tier(role)


func _on_next_wave_pressed() -> void:
	GameManager.begin_next_wave()


## Refreshes the header, every buy button's label/disabled state, and each
## role's section header (weapon name). Called after every purchase and on
## every points_changed so the panel always reflects current affordability.
func _refresh() -> void:
	var upgrades: Upgrades = GameManager.upgrades
	var points: int = GameManager.points
	_header_label.text = "SHOP — Points: %d" % points

	for entry in _PLAYER_STATS:
		var stat: Upgrades.PlayerStat = entry["stat"]
		var label: String = entry["label"]
		var cost := upgrades.player_cost(stat)
		var button: Button = _player_buttons[stat]
		button.text = "%s  (%d)" % [label, cost]
		button.disabled = cost > points

	for role_entry in _ROLES:
		var role: WeaponStats.Role = role_entry["role"]
		var role_label: String = role_entry["label"]
		var tier: int = upgrades.tiers[role]
		var weapon_name := WeaponStats.weapon_name(role, tier)
		_role_headers[role].text = "%s — %s" % [role_label, weapon_name]

		for entry in _WEAPON_STATS:
			var stat: Upgrades.WeaponStat = entry["stat"]
			var label: String = entry["label"]
			var cost := upgrades.weapon_cost(role, stat)
			var button: Button = _weapon_buttons[role][stat]
			button.text = "%s  (%d)" % [label, cost]
			button.disabled = cost > points

		var tier_button: Button = _tier_buttons[role]
		var label_and_disabled := ShopHelpers.tier_button_state(role, upgrades, points)
		tier_button.text = label_and_disabled["label"]
		tier_button.disabled = label_and_disabled["disabled"]
