# ZombieGD Wave Survival Shooter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a Godot 4.x top-down 3D wave-arena zombie shooter with between-wave upgrades, desktop keyboard/mouse, and mobile on-screen controls, exportable to web and mobile.

**Architecture:** Autoload `InputManager` + `GameManager` feed a single `main.tscn` arena. Player and zombies are `CharacterBody3D` with procedural meshes. Hitscan combat; `Upgrades` / `WaveMath` hold pure logic covered by headless tests. UI layers (HUD, shop, touch) react to `GameManager` signals.

**Tech Stack:** Godot 4.x (GDScript), CharacterBody3D, orthographic Camera3D, CSG/PrimitiveMesh, HTML5 + Android export presets.

## Global Constraints

- Engine: Godot 4.x strict syntax (`await` signals, Godot 4 Tween API).
- Moving entities: `CharacterBody3D` only (not CharacterBody2D).
- Graphics: procedural / CSG low-poly only — no imported GLTF kits in v1.
- Orientation: landscape only; playable on web and mobile.
- Combat v1: single hitscan gun, infinite ammo, power via upgrades.
- Loop: wave clear → shop → next wave; death → retry.
- Spec: `docs/superpowers/specs/2026-07-16-zombie-survival-shooter-design.md`.

---

## File Structure

| Path | Responsibility |
|------|----------------|
| `project.godot` | Project settings, autoloads, input map, display |
| `.clauderc` | Godot 4.x 3D coding conventions |
| `scripts/wave_math.gd` | Pure wave spawn count / zombie stat scaling |
| `scripts/upgrades.gd` | Upgrade levels, costs, stat derivation |
| `scripts/input_manager.gd` | Autoload: move/aim/fire from KB+mouse or touch |
| `scripts/game_manager.gd` | Autoload: run state, wave, points, signals |
| `scripts/player.gd` | Move, aim, hitscan fire, HP, apply upgrades |
| `scripts/zombie.gd` | Chase player, contact damage, take damage |
| `scripts/zombie_spawner.gd` | Spawn wave along perimeter |
| `scenes/player.tscn` | Player scene |
| `scenes/zombie.tscn` | Zombie scene |
| `scenes/main.tscn` | Arena, camera, spawner, UI roots |
| `scenes/ui/hud.tscn` | HP / points / wave labels |
| `scenes/ui/shop.tscn` | Between-wave upgrade buttons + Next Wave |
| `scenes/ui/touch_controls.tscn` | Joystick + fire button |
| `scenes/ui/game_over.tscn` | Retry overlay |
| `tests/run_tests.gd` | Headless test runner |
| `tests/test_wave_math.gd` | WaveMath assertions |
| `tests/test_upgrades.gd` | Upgrades assertions |
| `export_presets.cfg` | Web + Android presets (stubs OK if templates missing) |

---

### Task 1: Project scaffold + WaveMath (testable core)

**Files:**
- Create: `project.godot`
- Create: `.clauderc`
- Create: `scripts/wave_math.gd`
- Create: `tests/test_wave_math.gd`
- Create: `tests/run_tests.gd`

**Interfaces:**
- Consumes: nothing
- Produces:
  - `class_name WaveMath`
  - `static func zombie_count(wave: int, base_count: int = 4, scale: int = 2) -> int`
  - `static func zombie_max_hp(wave: int, base_hp: float = 30.0, per_wave: float = 8.0) -> float`
  - `static func zombie_speed(wave: int, base_speed: float = 3.5, per_wave: float = 0.15) -> float`
  - `static func is_fast_variant(wave: int, index: int) -> bool` — true when `wave >= 4` and `index % 4 == 0`

- [ ] **Step 1: Write failing tests**

Create `tests/test_wave_math.gd`:

```gdscript
extends RefCounted


func run() -> void:
	assert(WaveMath.zombie_count(1) == 6)  # 4 + 1*2
	assert(WaveMath.zombie_count(3) == 10)
	assert(is_equal_approx(WaveMath.zombie_max_hp(1), 38.0))
	assert(is_equal_approx(WaveMath.zombie_speed(1), 3.65))
	assert(WaveMath.is_fast_variant(3, 0) == false)
	assert(WaveMath.is_fast_variant(4, 0) == true)
	assert(WaveMath.is_fast_variant(4, 1) == false)
	print("test_wave_math: PASS")
```

Create `tests/run_tests.gd`:

```gdscript
extends SceneTree


func _init() -> void:
	var failures := 0
	for path in ["res://tests/test_wave_math.gd"]:
		var test: RefCounted = load(path).new()
		test.run()
	quit(failures)
```

- [ ] **Step 2: Run tests — expect fail**

Run (adjust Godot path if needed):

```bash
godot --headless -s res://tests/run_tests.gd
```

Expected: FAIL / parse error — `WaveMath` not found / `project.godot` missing.

- [ ] **Step 3: Create project + WaveMath**

Write `.clauderc`:

```
Always use strict Godot 4.x syntax. Use await for signals, CharacterBody3D for moving entities, and the new 4.x Tween system. Prefer orthographic Camera3D for top-down 3D. Keep gameplay input behind InputManager autoload.
```

Write `scripts/wave_math.gd`:

```gdscript
class_name WaveMath
extends RefCounted


static func zombie_count(wave: int, base_count: int = 4, scale: int = 2) -> int:
	return base_count + wave * scale


static func zombie_max_hp(wave: int, base_hp: float = 30.0, per_wave: float = 8.0) -> float:
	return base_hp + wave * per_wave


static func zombie_speed(wave: int, base_speed: float = 3.5, per_wave: float = 0.15) -> float:
	return base_speed + wave * per_wave


static func is_fast_variant(wave: int, index: int) -> bool:
	return wave >= 4 and index % 4 == 0
```

Minimal `project.godot` (Godot 4.x):

```ini
; Engine configuration file.
config_version=5

[application]
config/name="ZombieGD"
run/main_scene="res://scenes/main.tscn"
config/features=PackedStringArray("4.3", "Forward Plus")

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
window/handheld/orientation=0

[input]
move_left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":65,"key_label":0,"unicode":97,"location":0,"echo":false,"script":null)
]
}
move_right={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":68,"key_label":0,"unicode":100,"location":0,"echo":false,"script":null)
]
}
move_up={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":87,"key_label":0,"unicode":119,"location":0,"echo":false,"script":null)
]
}
move_down={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":83,"key_label":0,"unicode":115,"location":0,"echo":false,"script":null)
]
}
fire={
"deadzone": 0.5,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":0,"position":Vector2(0, 0),"global_position":Vector2(0, 0),"factor":1.0,"button_index":1,"canceled":false,"pressed":false,"double_click":false,"script":null)
]
}

[rendering]
renderer/rendering_method="forward_plus"
```

Note: Prefer creating `project.godot` + Input Map via Godot Editor (Project → Project Settings → Input Map) if hand-authored key objects fail to parse. Required action names: `move_left`, `move_right`, `move_up`, `move_down`, `fire`.

Also set display orientation to landscape in Project Settings → Display → Window → Handheld → Orientation = Landscape.

Temporarily set `run/main_scene` empty or to a stub until Task 3, OR create empty `scenes/main.tscn` Node3D placeholder so the project opens.

- [ ] **Step 4: Run tests — expect pass**

```bash
godot --headless -s res://tests/run_tests.gd
```

Expected: stdout contains `test_wave_math: PASS`, exit code 0.

- [ ] **Step 5: Commit**

```bash
git add project.godot .clauderc scripts/wave_math.gd tests/
git commit -m "feat: scaffold Godot 4 project and WaveMath"
```

---

### Task 2: Upgrades model

**Files:**
- Create: `scripts/upgrades.gd`
- Create: `tests/test_upgrades.gd`
- Modify: `tests/run_tests.gd`

**Interfaces:**
- Consumes: nothing
- Produces:
  - `class_name Upgrades`
  - `enum Kind { DAMAGE, FIRE_RATE, MOVE_SPEED, MAX_HP }`
  - `var levels: Dictionary` — Kind → int
  - `func reset() -> void`
  - `func cost(kind: Kind) -> int` — `15 + levels[kind] * 10`
  - `func try_buy(kind: Kind, points: int) -> int` — returns new points balance, or same points if unaffordable; increments level on success
  - `func damage() -> float` — `10.0 + levels[DAMAGE] * 5.0`
  - `func fire_cooldown() -> float` — `max(0.12, 0.45 - levels[FIRE_RATE] * 0.04)`
  - `func move_speed() -> float` — `6.0 + levels[MOVE_SPEED] * 0.75`
  - `func max_hp() -> float` — `100.0 + levels[MAX_HP] * 25.0`

- [ ] **Step 1: Write failing test**

`tests/test_upgrades.gd`:

```gdscript
extends RefCounted


func run() -> void:
	var u := Upgrades.new()
	assert(u.cost(Upgrades.Kind.DAMAGE) == 15)
	assert(is_equal_approx(u.damage(), 10.0))
	var left := u.try_buy(Upgrades.Kind.DAMAGE, 20)
	assert(left == 5)
	assert(u.levels[Upgrades.Kind.DAMAGE] == 1)
	assert(is_equal_approx(u.damage(), 15.0))
	assert(u.cost(Upgrades.Kind.DAMAGE) == 25)
	var same := u.try_buy(Upgrades.Kind.DAMAGE, 10)
	assert(same == 10)
	assert(u.levels[Upgrades.Kind.DAMAGE] == 1)
	assert(u.fire_cooldown() <= 0.45)
	assert(u.move_speed() >= 6.0)
	assert(u.max_hp() >= 100.0)
	print("test_upgrades: PASS")
```

Update `tests/run_tests.gd` paths array to include `res://tests/test_upgrades.gd`.

- [ ] **Step 2: Run — expect fail**

```bash
godot --headless -s res://tests/run_tests.gd
```

Expected: error loading `Upgrades`.

- [ ] **Step 3: Implement Upgrades**

`scripts/upgrades.gd`:

```gdscript
class_name Upgrades
extends RefCounted

enum Kind { DAMAGE, FIRE_RATE, MOVE_SPEED, MAX_HP }

var levels: Dictionary = {
	Kind.DAMAGE: 0,
	Kind.FIRE_RATE: 0,
	Kind.MOVE_SPEED: 0,
	Kind.MAX_HP: 0,
}


func reset() -> void:
	for k in levels.keys():
		levels[k] = 0


func cost(kind: Kind) -> int:
	return 15 + int(levels[kind]) * 10


func try_buy(kind: Kind, points: int) -> int:
	var c := cost(kind)
	if points < c:
		return points
	levels[kind] = int(levels[kind]) + 1
	return points - c


func damage() -> float:
	return 10.0 + float(levels[Kind.DAMAGE]) * 5.0


func fire_cooldown() -> float:
	return maxf(0.12, 0.45 - float(levels[Kind.FIRE_RATE]) * 0.04)


func move_speed() -> float:
	return 6.0 + float(levels[Kind.MOVE_SPEED]) * 0.75


func max_hp() -> float:
	return 100.0 + float(levels[Kind.MAX_HP]) * 25.0
```

- [ ] **Step 4: Run — expect pass**

```bash
godot --headless -s res://tests/run_tests.gd
```

Expected: both PASS lines, exit 0.

- [ ] **Step 5: Commit**

```bash
git add scripts/upgrades.gd tests/
git commit -m "feat: add Upgrades model with unit tests"
```

---

### Task 3: Arena scene + orthographic camera

**Files:**
- Create: `scenes/main.tscn` (and build via editor or `.tscn` text)
- Create: `scripts/arena_builder.gd` (optional helper called from main) — prefer building arena nodes in `main.gd`

**Interfaces:**
- Consumes: nothing
- Produces: `Main` root `Node3D` with:
  - `Ground` StaticBody3D (box ~40x1x40)
  - `Walls` four StaticBody3D boxes
  - 3–5 cover StaticBody3D boxes inside
  - `Camera3D` orthographic, size ~22, position `(0, 28, 0)`, rotation looking down (`rotation_degrees = Vector3(-90, 0, 0)` or `-70` pitch for slight depth)
  - `WorldEnvironment` with simple ambient light + `DirectionalLight3D`

- [ ] **Step 1: Create main scene script**

`scripts/main.gd`:

```gdscript
extends Node3D


func _ready() -> void:
	_build_arena_if_needed()


func _build_arena_if_needed() -> void:
	if has_node("Ground"):
		return
	# If building purely in editor, leave empty.
	pass
```

Prefer constructing the arena in the Godot editor:

1. Root `Node3D` named `Main`, script `scripts/main.gd`.
2. `StaticBody3D` Ground: `CollisionShape3D` BoxShape3D size `(40, 1, 40)`, `MeshInstance3D` BoxMesh same size, material albedo `Color(0.35, 0.38, 0.32)`.
3. Four wall `StaticBody3D` along edges (height ~2.5).
4. Cover boxes at e.g. `(-8, 1, -6)`, `(10, 1, 4)`, `(0, 1, 10)`.
5. `Camera3D`: `projection = PROJECTION_ORTHOGONAL`, `size = 22`, `current = true`, transform above center.
6. `DirectionalLight3D` angled; `WorldEnvironment` with ambient energy ~0.35.

- [ ] **Step 2: Manual verify**

Open project in Godot, press F5. Expected: top-down muted green-gray arena with walls/cover, no errors.

- [ ] **Step 3: Commit**

```bash
git add scenes/main.tscn scripts/main.gd
git commit -m "feat: add low-poly arena and orthographic camera"
```

---

### Task 4: InputManager autoload

**Files:**
- Create: `scripts/input_manager.gd`
- Modify: `project.godot` — add autoload `InputManager="*res://scripts/input_manager.gd"`

**Interfaces:**
- Consumes: Input Map actions; optional touch overrides set by UI
- Produces:
  - `var touch_enabled: bool`
  - `var touch_move: Vector2` — set by joystick (x=X, y=Z plane)
  - `var touch_fire: bool`
  - `func get_move_vector() -> Vector2` — keyboard if not touch, else touch_move; normalized
  - `func get_aim_screen_position() -> Vector2` — mouse position
  - `func is_fire_held() -> bool` — mouse/button or touch_fire
  - `func use_mouse_aim() -> bool` — `not touch_enabled`

- [ ] **Step 1: Implement InputManager**

```gdscript
extends Node

var touch_enabled: bool = false
var touch_move: Vector2 = Vector2.ZERO
var touch_fire: bool = false


func _ready() -> void:
	# Enable touch path when a touch screen is present or when UI forces it.
	touch_enabled = DisplayServer.is_touchscreen_available()


func set_touch_move(v: Vector2) -> void:
	touch_move = v
	if v.length() > 0.05:
		touch_enabled = true


func set_touch_fire(held: bool) -> void:
	touch_fire = held
	if held:
		touch_enabled = true


func get_move_vector() -> Vector2:
	if touch_enabled:
		if touch_move.length() > 1.0:
			return touch_move.normalized()
		return touch_move
	var v := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return v


func get_aim_screen_position() -> Vector2:
	return get_viewport().get_mouse_position()


func is_fire_held() -> bool:
	if touch_enabled:
		return touch_fire
	return Input.is_action_pressed("fire")


func use_mouse_aim() -> bool:
	return not touch_enabled
```

Register autoload in Project Settings → Autoload: Name `InputManager`, path `res://scripts/input_manager.gd`.

- [ ] **Step 2: Verify**

Run main scene; in remote debugger or temporary print in `_process`, confirm WASD changes `get_move_vector()`.

- [ ] **Step 3: Commit**

```bash
git add scripts/input_manager.gd project.godot
git commit -m "feat: add InputManager autoload for KB/mouse and touch"
```

---

### Task 5: Player movement, aim, hitscan

**Files:**
- Create: `scenes/player.tscn`
- Create: `scripts/player.gd`
- Modify: `scenes/main.tscn` — instance Player at origin `(0, 1, 0)`

**Interfaces:**
- Consumes: `InputManager.get_move_vector()`, `is_fire_held()`, `use_mouse_aim()`, `get_aim_screen_position()`; later `Upgrades` via GameManager
- Produces:
  - signal `died`
  - `var upgrades: Upgrades`
  - `func apply_upgrades(u: Upgrades) -> void` — refresh max_hp/speed; heal to full when max_hp increases between waves
  - `func take_damage(amount: float) -> void`
  - `func get_hp() -> float` / `func get_max_hp() -> float`
  - Groups: add player to group `"player"`
  - Collision layers: player on layer 1; mask world + enemies as needed

- [ ] **Step 1: Implement player.gd**

```gdscript
extends CharacterBody3D

signal died
signal hp_changed(current: float, maximum: float)

var upgrades: Upgrades = Upgrades.new()
var hp: float = 100.0
var _fire_timer: float = 0.0
@onready var _muzzle: Marker3D = $Muzzle


func _ready() -> void:
	add_to_group("player")
	hp = upgrades.max_hp()
	hp_changed.emit(hp, upgrades.max_hp())


func apply_upgrades(u: Upgrades) -> void:
	upgrades = u
	hp = upgrades.max_hp()
	hp_changed.emit(hp, upgrades.max_hp())


func get_hp() -> float:
	return hp


func get_max_hp() -> float:
	return upgrades.max_hp()


func take_damage(amount: float) -> void:
	if hp <= 0.0:
		return
	hp = maxf(0.0, hp - amount)
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
	_update_aim()
	_fire_timer = maxf(0.0, _fire_timer - delta)
	if InputManager.is_fire_held() and _fire_timer <= 0.0:
		_fire()
		_fire_timer = upgrades.fire_cooldown()


func _update_aim() -> void:
	if InputManager.use_mouse_aim():
		var cam := get_viewport().get_camera_3d()
		if cam == null:
			return
		var from := cam.project_ray_origin(InputManager.get_aim_screen_position())
		var dir := cam.project_ray_normal(InputManager.get_aim_screen_position())
		if absf(dir.y) < 0.0001:
			return
		var t := -from.y / dir.y
		var hit := from + dir * t
		var look := Vector3(hit.x, global_position.y, hit.z)
		if look.distance_to(global_position) > 0.1:
			look_at(look, Vector3.UP)
	else:
		var move2: Vector2 = InputManager.get_move_vector()
		if move2.length() > 0.1:
			var look := global_position + Vector3(move2.x, 0.0, move2.y)
			look_at(look, Vector3.UP)


func _fire() -> void:
	var space := get_world_3d().direct_space_state
	var origin := _muzzle.global_position
	var toward := -global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(origin, origin + toward * 40.0)
	query.collide_with_areas = false
	query.collision_mask = 2  # zombies on layer 2
	var result := space.intersect_ray(query)
	# visual tracer: short MeshInstance or ImmediateMesh optional
	if result.is_empty():
		return
	var collider = result.collider
	if collider and collider.has_method("take_damage"):
		collider.take_damage(upgrades.damage())
```

Player scene nodes:

- `CharacterBody3D` (script)
  - `CollisionShape3D` CapsuleShape3D
  - `MeshInstance3D` CapsuleMesh — albedo accent e.g. `Color(0.2, 0.55, 0.95)`
  - `MeshInstance3D` Gun — BoxMesh parented forward
  - `Marker3D` Muzzle at gun tip
  - collision_layer = 1, collision_mask = 1 (world); ray uses mask 2 for zombies

Instance into `main.tscn` as child `Player`.

- [ ] **Step 2: Manual verify**

F5: WASD moves player on XZ; mouse rotates player; LMB prints/hits empty space without error.

- [ ] **Step 3: Commit**

```bash
git add scenes/player.tscn scripts/player.gd scenes/main.tscn
git commit -m "feat: add player movement, aim, and hitscan"
```

---

### Task 6: Zombie + contact damage

**Files:**
- Create: `scenes/zombie.tscn`
- Create: `scripts/zombie.gd`

**Interfaces:**
- Consumes: player via `get_tree().get_first_node_in_group("player")`
- Produces:
  - signal `killed(points: int)`
  - `func setup(max_hp: float, speed: float, fast: bool) -> void`
  - `func take_damage(amount: float) -> void`
  - collision_layer = 2, collision_mask = 1
  - Contact: when overlapping player (Area3D hurtbox OR distance check in `_physics_process`), call `player.take_damage(10 * delta)` or tick every 0.5s for 12 damage

- [ ] **Step 1: Implement zombie.gd**

```gdscript
extends CharacterBody3D

signal killed(points: int)

var max_hp: float = 30.0
var hp: float = 30.0
var move_speed: float = 3.5
var points_value: int = 5
var _contact_cooldown: float = 0.0


func setup(p_max_hp: float, p_speed: float, fast: bool) -> void:
	max_hp = p_max_hp
	hp = p_max_hp
	move_speed = p_speed * (1.45 if fast else 1.0)
	points_value = 8 if fast else 5
	if fast:
		$Body.material_override = StandardMaterial3D.new()
		$Body.material_override.albedo_color = Color(0.55, 0.15, 0.15)


func take_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0.0:
		killed.emit(points_value)
		queue_free()


func _physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
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
	if _contact_cooldown <= 0.0 and global_position.distance_to(player.global_position) < 1.6:
		if player.has_method("take_damage"):
			player.take_damage(12.0)
		_contact_cooldown = 0.5
```

Zombie scene: capsule mesh green `Color(0.35, 0.55, 0.28)`, CollisionShape3D, layer 2.

- [ ] **Step 2: Manual verify**

Temporarily instance one zombie in main; confirm it chases and damages player; shooting kills it.

- [ ] **Step 3: Commit**

```bash
git add scenes/zombie.tscn scripts/zombie.gd
git commit -m "feat: add zombie chase, contact damage, and death"
```

---

### Task 7: GameManager + ZombieSpawner + wave loop

**Files:**
- Create: `scripts/game_manager.gd` (autoload)
- Create: `scripts/zombie_spawner.gd`
- Modify: `scenes/main.tscn` — add `ZombieSpawner` node
- Modify: `project.godot` — autoload GameManager
- Modify: `scripts/player.gd` — connect died → GameManager

**Interfaces:**
- Consumes: `WaveMath`, `Upgrades`, zombie scene, player
- Produces GameManager:
  - `enum State { PLAYING, SHOP, GAME_OVER }`
  - `var state: State`
  - `var wave: int`
  - `var points: int`
  - `var upgrades: Upgrades`
  - `var alive_zombies: int`
  - signals: `state_changed`, `wave_changed`, `points_changed`, `shop_opened`, `run_reset`
  - `func start_run() -> void`
  - `func add_points(n: int) -> void`
  - `func notify_zombie_killed(n: int) -> void`
  - `func buy_upgrade(kind: Upgrades.Kind) -> void`
  - `func begin_next_wave() -> void`
  - `func on_player_died() -> void`
- Produces ZombieSpawner:
  - `func spawn_wave(wave: int) -> void` — instances zombies, calls `setup`, connects `killed`

- [ ] **Step 1: Implement GameManager**

```gdscript
extends Node

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


func start_run() -> void:
	upgrades.reset()
	points = 0
	wave = 0
	alive_zombies = 0
	points_changed.emit(points)
	run_reset.emit()
	begin_next_wave()


func add_points(n: int) -> void:
	points += n
	points_changed.emit(points)


func notify_zombie_killed(n: int) -> void:
	add_points(n)
	alive_zombies = maxi(0, alive_zombies - 1)
	if state == State.PLAYING and alive_zombies == 0:
		_enter_shop()


func buy_upgrade(kind: Upgrades.Kind) -> void:
	if state != State.SHOP:
		return
	points = upgrades.try_buy(kind, points)
	points_changed.emit(points)
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("apply_upgrades"):
		player.apply_upgrades(upgrades)


func begin_next_wave() -> void:
	wave += 1
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
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("apply_upgrades"):
		player.apply_upgrades(upgrades)
```

- [ ] **Step 2: Implement ZombieSpawner**

```gdscript
extends Node3D

@export var zombie_scene: PackedScene
@export var arena_half_extent: float = 18.0


func _ready() -> void:
	add_to_group("spawner")


func spawn_wave(wave: int) -> void:
	var count := WaveMath.zombie_count(wave)
	for i in count:
		var z: CharacterBody3D = zombie_scene.instantiate()
		var angle := TAU * float(i) / float(count)
		var pos := Vector3(cos(angle) * arena_half_extent, 1.0, sin(angle) * arena_half_extent)
		add_child(z)
		z.global_position = pos
		var fast := WaveMath.is_fast_variant(wave, i)
		z.setup(WaveMath.zombie_max_hp(wave), WaveMath.zombie_speed(wave), fast)
		z.killed.connect(_on_killed)


func _on_killed(points: int) -> void:
	GameManager.notify_zombie_killed(points)
```

Wire: Main `_ready` connects player `died` → `GameManager.on_player_died`, calls `GameManager.start_run()` after one frame.

- [ ] **Step 3: Manual verify**

Clear wave 1 (or set count low temporarily); confirm state becomes SHOP (print); call `begin_next_wave` from debugger; wave 2 spawns.

- [ ] **Step 4: Commit**

```bash
git add scripts/game_manager.gd scripts/zombie_spawner.gd scenes/main.tscn project.godot scripts/player.gd scripts/main.gd
git commit -m "feat: add wave loop via GameManager and ZombieSpawner"
```

---

### Task 8: HUD + Shop + Game Over UI

**Files:**
- Create: `scenes/ui/hud.tscn`, `scripts/ui/hud.gd`
- Create: `scenes/ui/shop.tscn`, `scripts/ui/shop.gd`
- Create: `scenes/ui/game_over.tscn`, `scripts/ui/game_over.gd`
- Modify: `scenes/main.tscn` — CanvasLayer UI

**Interfaces:**
- Consumes: GameManager signals; player `hp_changed`
- Produces: shop buttons call `GameManager.buy_upgrade`; Next Wave → `begin_next_wave`; Retry → reload scene or `start_run` after resetting player

- [ ] **Step 1: HUD**

Labels for HP, Points, Wave. Connect in `_ready`:

```gdscript
GameManager.points_changed.connect(_on_points)
GameManager.wave_changed.connect(_on_wave)
# player.hp_changed.connect(...)
```

- [ ] **Step 2: Shop**

Panel hidden by default; show on `shop_opened` / `state_changed == SHOP`. Four buy buttons (Damage, Fire Rate, Move Speed, Max HP) showing `Upgrades.cost`. Next Wave button calls `GameManager.begin_next_wave` and hides panel. While SHOP, optionally pause zombie spawn only (already none alive); do not freeze player movement unless desired — keep movement allowed in shop for feel, or set `Engine.time_scale` — **v1: allow movement, disable firing while shop open** by checking `GameManager.state != PLAYING` in player `_fire`.

Add to player `_physics_process` fire gate:

```gdscript
if GameManager.state != GameManager.State.PLAYING:
	return  # after movement, skip fire — or skip both; prefer: allow move, skip fire
```

Actually: still process movement; only skip fire block when not PLAYING.

- [ ] **Step 3: Game Over**

Full-rect ColorRect + “You died” + Retry button → `get_tree().reload_current_scene()`.

- [ ] **Step 4: Manual verify**

Full loop: wave → shop buy → next wave → die → retry.

- [ ] **Step 5: Commit**

```bash
git add scenes/ui/ scripts/ui/ scenes/main.tscn scripts/player.gd
git commit -m "feat: add HUD, between-wave shop, and game over"
```

---

### Task 9: Touch controls

**Files:**
- Create: `scenes/ui/touch_controls.tscn`, `scripts/ui/touch_controls.gd`
- Modify: `scenes/main.tscn`

**Interfaces:**
- Consumes: touch events
- Produces: calls `InputManager.set_touch_move`, `set_touch_fire`; visibility when `DisplayServer.is_touchscreen_available()` OR always show with modulate when ProjectSettings feature tag `mobile`, plus editor toggle `@export var force_show: bool`

- [ ] **Step 1: Implement virtual joystick + fire**

Left half: TouchScreenButton or Control with `_gui_input` / drag tracking → normalized Vector2 to `InputManager.set_touch_move`. On release → `Vector2.ZERO`.

Right: large Button / TouchScreenButton — `button_down` / `button_up` → `set_touch_fire`.

Hide when `not touch_enabled and not force_show`. For editor testing set `force_show = true` temporarily.

- [ ] **Step 2: Manual verify**

Emulate touch in editor (or force_show): joystick moves player; fire button shoots; mouse aim disabled when touch_enabled.

- [ ] **Step 3: Commit**

```bash
git add scenes/ui/touch_controls.tscn scripts/ui/touch_controls.gd scenes/main.tscn
git commit -m "feat: add on-screen joystick and fire for mobile"
```

---

### Task 10: Export presets + polish pass

**Files:**
- Create: `export_presets.cfg` (via Editor → Manage Export Templates / Export)
- Modify: materials/colors if needed; optional muzzle flash Tween
- Modify: `project.godot` — ensure landscape, stretch mode

**Interfaces:** none new

- [ ] **Step 1: Export configuration**

In Godot: Project → Export:

1. Add **Web** preset (name `Web`).
2. Add **Android** preset (name `Android`) — package name `com.zombiegd.app`, landscape orientation.
3. Save `export_presets.cfg`.

If export templates are missing, still commit preset file structure and document: install templates before CI/local export.

- [ ] **Step 2: Smoke checklist (manual)**

1. Desktop: move, aim, shoot, clear wave 1.
2. Buy Damage once; confirm higher damage / shop points decrease.
3. Next wave starts; fast variant appears from wave 4.
4. Die → Retry works.
5. Touch controls (force_show): move + fire.

- [ ] **Step 3: Re-run unit tests**

```bash
godot --headless -s res://tests/run_tests.gd
```

Expected: all PASS.

- [ ] **Step 4: Commit**

```bash
git add export_presets.cfg project.godot
git commit -m "chore: add web/android export presets and polish"
```

---

## Spec Coverage Self-Review

| Spec requirement | Task |
|------------------|------|
| True 3D CharacterBody3D + ortho camera | 3, 5, 6 |
| Procedural low-poly | 3, 5, 6 |
| Wave arena + scaling | 1, 7 |
| Fast variant from mid-game | 1, 7 |
| Hitscan infinite ammo | 5 |
| Between-wave upgrades | 2, 7, 8 |
| InputManager KB+mouse + touch | 4, 9 |
| HUD / shop / game over | 8 |
| Landscape web + mobile exports | 3, 10 |
| `.clauderc` 3D conventions | 1 |
| Design doc path | already exists |

## Placeholder / consistency check

- No TBD steps; APIs named consistently: `notify_zombie_killed`, `begin_next_wave`, `apply_upgrades`, `WaveMath.*`, `Upgrades.Kind`.
- Player fire gated on `GameManager.State.PLAYING`.
- Zombie collision_layer `2` matches player ray `collision_mask = 2`.
