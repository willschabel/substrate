class_name Construct
extends CharacterBody3D

# Corrupted agricultural maintenance construct (Harvesting Grounds). It was
# built to tend crops, not to fight — its aggression is broken purpose, not
# malice (see docs/lore_rules.md). Slow, readable telegraph; lethal if it
# connects. Patrol -> chase -> telegraphed strike.

signal died

enum State { PATROL, CHASE, WINDUP, STRIKE, RECOVER, HURT, DEAD }

@export var patrol_speed: float = 2.2
@export var chase_speed: float = 4.0
@export var aggro_range: float = 12.0
@export var lose_range: float = 18.0
@export var attack_range: float = 2.3
@export var attack_damage: float = 30.0
@export var attack_windup: float = 0.55   # slow, readable telegraph
@export var attack_strike: float = 0.12
@export var attack_recover: float = 0.9
@export var turn_speed: float = 7.0
@export var patrol_radius: float = 6.0

@onready var health: Health = $Health
@onready var _body: MeshInstance3D = $Body

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _state: State = State.PATROL
var _timer: float = 0.0
var _player: Node3D
var _home: Vector3
var _patrol_target: Vector3
var _material: StandardMaterial3D
var _base_albedo: Color = Color(0.45, 0.5, 0.4)

func _ready() -> void:
	add_to_group("damageable")
	add_to_group("construct")
	_home = global_position
	_pick_patrol_target()
	health.died.connect(_on_died)
	_setup_material()

func _setup_material() -> void:
	_material = StandardMaterial3D.new()
	_material.albedo_color = _base_albedo
	_material.emission_enabled = true
	_material.emission = Color(0.0, 0.35, 0.4)   # faint teal tech glow
	_material.emission_energy_multiplier = 0.4
	if _body:
		_body.material_override = _material

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	match _state:
		State.PATROL: _do_patrol(delta)
		State.CHASE: _do_chase(delta)
		State.WINDUP, State.STRIKE, State.RECOVER: _do_attack(delta)
		State.HURT: _do_hurt(delta)
		State.DEAD: velocity.x = 0; velocity.z = 0

	move_and_slide()

# -- States --

func _do_patrol(delta: float) -> void:
	if _can_see_player():
		_state = State.CHASE
		return
	var to_target := _patrol_target - global_position
	to_target.y = 0
	if to_target.length() < 0.6:
		_pick_patrol_target()
	else:
		_move_toward(to_target.normalized(), patrol_speed, delta)

func _do_chase(delta: float) -> void:
	if _player == null or _dist_to_player() > lose_range:
		_state = State.PATROL
		_pick_patrol_target()
		return
	var to_player := _player.global_position - global_position
	to_player.y = 0
	if to_player.length() <= attack_range:
		_begin_attack()
	else:
		_move_toward(to_player.normalized(), chase_speed, delta)

func _begin_attack() -> void:
	velocity.x = 0
	velocity.z = 0
	_state = State.WINDUP
	_timer = attack_windup
	_flash(Color(1.0, 0.85, 0.3), attack_windup)  # telegraph glow ramp

func _do_attack(delta: float) -> void:
	velocity.x = 0
	velocity.z = 0
	if _player:
		_face(_player.global_position, delta)
	_timer -= delta
	if _timer > 0.0:
		return
	match _state:
		State.WINDUP:
			_state = State.STRIKE
			_timer = attack_strike
			_resolve_strike()
		State.STRIKE:
			_state = State.RECOVER
			_timer = attack_recover
		State.RECOVER:
			_state = State.CHASE

func _resolve_strike() -> void:
	if _player and _dist_to_player() <= attack_range * 1.25:
		if _player.has_method("apply_damage"):
			var dir := (_player.global_position - global_position).normalized()
			_player.apply_damage(attack_damage, dir, 0.0)

func _do_hurt(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 20.0 * delta)
	velocity.z = move_toward(velocity.z, 0, 20.0 * delta)
	_timer -= delta
	if _timer <= 0.0:
		_state = State.CHASE if _can_see_player() else State.PATROL

# -- Movement helpers --

func _move_toward(dir: Vector3, speed: float, delta: float) -> void:
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	_face(global_position + dir, delta)

func _face(target: Vector3, delta: float) -> void:
	var flat := Vector3(target.x, global_position.y, target.z)
	if flat.is_equal_approx(global_position):
		return
	var desired := Transform3D(global_transform).looking_at(flat, Vector3.UP)
	global_transform.basis = global_transform.basis.slerp(desired.basis, clampf(turn_speed * delta, 0.0, 1.0))

func _pick_patrol_target() -> void:
	var angle := randf() * TAU
	var r := randf() * patrol_radius
	_patrol_target = _home + Vector3(cos(angle) * r, 0, sin(angle) * r)

# -- Perception --

func _can_see_player() -> bool:
	_ensure_player()
	return _player != null and _dist_to_player() <= aggro_range

func _dist_to_player() -> float:
	if _player == null:
		return INF
	var a := global_position
	var b := _player.global_position
	a.y = 0; b.y = 0
	return a.distance_to(b)

func _ensure_player() -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node3D

# -- Damage contract --

func apply_damage(amount: float, _hit_dir: Vector3, hitstun: float = 0.0) -> void:
	if _state == State.DEAD:
		return
	health.take_damage(amount)
	_flash(Color(1, 1, 1), 0.12)
	if health.is_alive() and hitstun > 0.0:
		_state = State.HURT
		_timer = hitstun
		_ensure_player()

func _on_died() -> void:
	_state = State.DEAD
	velocity = Vector3.ZERO
	set_collision_layer_value(2, false)
	if _material:
		_material.emission_energy_multiplier = 0.0
	died.emit()
	# Brief settle, then remove. Loot drop hooks in at the inventory step.
	var t := create_tween()
	t.tween_interval(0.15)
	t.tween_property(self, "scale", Vector3(1, 0.05, 1), 0.25)
	t.tween_callback(queue_free)

# -- Hit / telegraph flash --

func _flash(color: Color, duration: float) -> void:
	if _material == null:
		return
	var t := create_tween()
	t.tween_property(_material, "albedo_color", color, duration * 0.4)
	t.tween_property(_material, "albedo_color", _base_albedo, duration * 0.6)
