class_name MeleeWeapon
extends Node3D

# Directional first-person melee, modelled on Mordhau's "240" system: the
# player picks a slash direction with mouse movement, plus a faster thrust.
# Feel is everything here — every timing is exported so it can be tuned live.
#
# Swing lifecycle: IDLE -> WINDUP -> ACTIVE (hitbox live) -> RECOVERY -> IDLE.
# Commitment comes from RECOVERY: once you swing you are locked out until it
# finishes. No cancelling, no dodge — spacing and timing keep you alive.

signal swing_started(kind: String)
signal hit_landed(target: Node)
signal state_changed(state: int)

enum Slash { LEFT, RIGHT, OVERHEAD }
enum State { IDLE, WINDUP, ACTIVE, RECOVERY }

# -- Slash (LMB) --
@export var slash_damage: float = 34.0
@export var slash_windup: float = 0.18
@export var slash_active: float = 0.13
@export var slash_recovery: float = 0.34
@export var slash_hitstun: float = 0.35

# -- Stab / thrust (RMB) -- faster and longer reach, less damage
@export var stab_damage: float = 22.0
@export var stab_windup: float = 0.10
@export var stab_active: float = 0.10
@export var stab_recovery: float = 0.28
@export var stab_hitstun: float = 0.25

var state: State = State.IDLE
var _timer: float = 0.0
var _phase_damage: float = 0.0
var _phase_hitstun: float = 0.0
var _active_time: float = 0.0
var _recovery_time: float = 0.0
var _hit_this_swing: Array[Node] = []
var _owner_body: Node = null   # never damage our own wielder

@onready var _pivot: Node3D = $BladePivot
@onready var _hitbox: Area3D = $BladePivot/Hitbox
var _rest_transform: Transform3D
var _tween: Tween

func _ready() -> void:
	_hitbox.monitoring = false
	_rest_transform = _pivot.transform
	_owner_body = _find_owner_body()

func is_busy() -> bool:
	return state != State.IDLE

# -- Inputs --

func slash(dir: Slash) -> bool:
	if state != State.IDLE:
		return false
	_phase_damage = slash_damage
	_phase_hitstun = slash_hitstun
	_active_time = slash_active
	_recovery_time = slash_recovery
	_begin(slash_windup)
	_animate_slash(dir)
	swing_started.emit("slash")
	return true

func stab() -> bool:
	if state != State.IDLE:
		return false
	_phase_damage = stab_damage
	_phase_hitstun = stab_hitstun
	_active_time = stab_active
	_recovery_time = stab_recovery
	_begin(stab_windup)
	_animate_stab()
	swing_started.emit("stab")
	return true

# -- State machine --

func _begin(windup: float) -> void:
	_hit_this_swing.clear()
	state = State.WINDUP
	_timer = windup
	state_changed.emit(state)

func _physics_process(delta: float) -> void:
	if state == State.IDLE:
		return
	_timer -= delta

	if state == State.ACTIVE:
		_scan_hits()

	if _timer > 0.0:
		return

	match state:
		State.WINDUP:
			state = State.ACTIVE
			_timer = _active_time
			_hitbox.monitoring = true
			state_changed.emit(state)
		State.ACTIVE:
			state = State.RECOVERY
			_timer = _recovery_time
			_hitbox.monitoring = false
			state_changed.emit(state)
		State.RECOVERY:
			state = State.IDLE
			state_changed.emit(state)

func _scan_hits() -> void:
	for body: Node3D in _hitbox.get_overlapping_bodies():
		if body == _owner_body or body in _hit_this_swing:
			continue
		if body.is_in_group("damageable") and body.has_method("apply_damage"):
			_hit_this_swing.append(body)
			var hit_dir: Vector3 = (body.global_position - global_position).normalized()
			body.apply_damage(_phase_damage, hit_dir, _phase_hitstun)
			hit_landed.emit(body)

func _find_owner_body() -> Node:
	var n: Node = get_parent()
	while n != null:
		if n is CharacterBody3D:
			return n
		n = n.get_parent()
	return null

# -- Viewmodel animation (placeholder tweens; real anims come in Phase 7) --

func _animate_slash(dir: Slash) -> void:
	var total: float = slash_windup + slash_active + slash_recovery
	var start_rot := Vector3.ZERO
	var end_rot := Vector3.ZERO
	match dir:
		Slash.LEFT:
			start_rot = Vector3(0, deg_to_rad(55), deg_to_rad(35))
			end_rot = Vector3(0, deg_to_rad(-55), deg_to_rad(-35))
		Slash.RIGHT:
			start_rot = Vector3(0, deg_to_rad(-55), deg_to_rad(-35))
			end_rot = Vector3(0, deg_to_rad(55), deg_to_rad(35))
		Slash.OVERHEAD:
			start_rot = Vector3(deg_to_rad(-70), 0, 0)
			end_rot = Vector3(deg_to_rad(45), 0, 0)
	_play_swing(start_rot, end_rot, Vector3.ZERO, total)

func _animate_stab() -> void:
	var total: float = stab_windup + stab_active + stab_recovery
	# Pull back slightly, then thrust forward along -Z.
	_play_swing(Vector3(deg_to_rad(8), 0, 0), Vector3.ZERO, Vector3(0, 0, -0.6), total)

func _play_swing(start_rot: Vector3, end_rot: Vector3, thrust: Vector3, total: float) -> void:
	if _tween:
		_tween.kill()
	var windup_frac := 0.35
	_pivot.transform = _rest_transform
	_tween = create_tween().set_trans(Tween.TRANS_QUAD)
	# Windup: ease into the cocked pose.
	_tween.tween_property(_pivot, "rotation", start_rot, total * windup_frac).set_ease(Tween.EASE_OUT)
	# Strike: snap through the arc + thrust.
	var strike := _tween.parallel()
	strike.tween_property(_pivot, "rotation", end_rot, total * 0.25).set_ease(Tween.EASE_IN)
	strike.tween_property(_pivot, "position", _rest_transform.origin + thrust, total * 0.25).set_ease(Tween.EASE_IN)
	# Recovery: settle back to rest.
	var settle := _tween.parallel()
	settle.tween_property(_pivot, "rotation", Vector3.ZERO, total * 0.40).set_ease(Tween.EASE_OUT)
	settle.tween_property(_pivot, "position", _rest_transform.origin, total * 0.40).set_ease(Tween.EASE_OUT)
