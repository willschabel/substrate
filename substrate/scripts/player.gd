extends CharacterBody3D

# First-person player controller + combat. Movement is deliberate; there is no
# dodge (cut in Phase 2) — survival is spacing, reading attacks, and the
# commitment cost of every swing. See docs/vision.md Combat.

const SPEED = 5.0
const SPRINT_SPEED = 9.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

# Directional-slash read: mouse movement just before the swing picks the angle.
const SLASH_DIR_THRESHOLD = 4.0   # min recent mouse travel to override default
const MOUSE_DECAY = 14.0          # how fast the recent-mouse sample falls off

enum Weapon { MELEE, RANGED }

signal died

@onready var camera: Camera3D = $Camera3D  # First-person — camera IS the player's eyes
@onready var health: Health = $Health
@onready var _melee: MeleeWeapon = $Camera3D/Viewmodel/Shortsword
@onready var _ranged: RangedWeapon = $Camera3D/Viewmodel/Shotgun

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _active := Weapon.MELEE
var _recent_mouse := Vector2.ZERO
var _spawn_transform: Transform3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("damageable")
	add_to_group("player")
	_spawn_transform = global_transform
	health.died.connect(_on_died)
	_equip(Weapon.MELEE)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)
		_recent_mouse += event.relative
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("weapon_melee"):
		_equip(Weapon.MELEE)
	if event.is_action_pressed("weapon_ranged"):
		_equip(Weapon.RANGED)
	if event.is_action_pressed("attack_primary"):
		_attack_primary()
	if event.is_action_pressed("attack_secondary"):
		_attack_secondary()

func _process(delta: float) -> void:
	# Recent-mouse sample decays toward zero so only fresh motion sets the slash.
	_recent_mouse = _recent_mouse.lerp(Vector2.ZERO, clampf(MOUSE_DECAY * delta, 0.0, 1.0))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var sprinting := Input.is_action_pressed("sprint")
	var top_speed := SPRINT_SPEED if sprinting else SPEED
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * top_speed
		velocity.z = direction.z * top_speed
	else:
		velocity.x = move_toward(velocity.x, 0, top_speed)
		velocity.z = move_toward(velocity.z, 0, top_speed)

	move_and_slide()

# -- Combat --

func _attack_primary() -> void:
	match _active:
		Weapon.MELEE:
			_melee.slash(_read_slash_direction())
		Weapon.RANGED:
			_ranged.fire(camera)

func _attack_secondary() -> void:
	if _active == Weapon.MELEE:
		_melee.stab()

# Picks a slash angle from the direction of recent mouse movement (Mordhau-style).
func _read_slash_direction() -> int:
	var m := _recent_mouse
	if m.length() < SLASH_DIR_THRESHOLD:
		return MeleeWeapon.Slash.RIGHT  # default horizontal when the mouse is still
	if absf(m.y) > absf(m.x) and m.y > 0.0:
		return MeleeWeapon.Slash.OVERHEAD  # mouse pulled down -> downward chop
	return MeleeWeapon.Slash.RIGHT if m.x >= 0.0 else MeleeWeapon.Slash.LEFT

func _equip(weapon: Weapon) -> void:
	_active = weapon
	_melee.visible = weapon == Weapon.MELEE
	_ranged.visible = weapon == Weapon.RANGED

# Damageable contract — weapons call this on whatever they hit.
func apply_damage(amount: float, _hit_dir: Vector3, _hitstun: float = 0.0) -> void:
	health.take_damage(amount)

func _on_died() -> void:
	died.emit()
	_respawn()

# Instant cut back to base (Phase 2 decision). Real base-return travel is a
# later Phase 2 item; for now respawn at the spawn point with a full restore.
func _respawn() -> void:
	velocity = Vector3.ZERO
	global_transform = _spawn_transform
	health.restore_full()
