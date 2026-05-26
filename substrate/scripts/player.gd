extends CharacterBody3D

const SPEED = 5.0
const SPRINT_SPEED = 9.0
const JUMP_VELOCITY = 4.5
const DODGE_VELOCITY = 12.0
const DODGE_DURATION = 0.25
const MOUSE_SENSITIVITY = 0.003

@onready var camera: Camera3D = $Camera3D  # First-person — camera IS the player's eyes; no third-person body rendered locally

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _dodging := false
var _dodge_timer := 0.0
var _dodge_dir := Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("dodge") and is_on_floor() and not _dodging:
		_start_dodge()
	if event.is_action_pressed("attack_primary"):
		_attack_primary()
	if event.is_action_pressed("attack_secondary"):
		_attack_secondary()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not _dodging:
		velocity.y = JUMP_VELOCITY

	if _dodging:
		_dodge_timer -= delta
		velocity.x = _dodge_dir.x * DODGE_VELOCITY
		velocity.z = _dodge_dir.z * DODGE_VELOCITY
		if _dodge_timer <= 0.0:
			_dodging = false
	else:
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

func _start_dodge() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# Dodge backward if no input
	var raw := Vector3(input_dir.x, 0, input_dir.y) if input_dir.length() > 0.1 else Vector3(0, 0, 1)
	_dodge_dir = (transform.basis * raw).normalized()
	_dodging = true
	_dodge_timer = DODGE_DURATION

func _attack_primary() -> void:
	pass # TODO Phase 2: melee swing

func _attack_secondary() -> void:
	pass # TODO Phase 2: ranged attack
