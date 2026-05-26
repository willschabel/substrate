class_name TravelSystem
extends Node

const TRAVEL_DURATION: float = 2.0
const SKY_MATERIAL_PATH: String = "res://materials/grid_sky.tres"

var _base: Base
var _sky_material: ShaderMaterial
var _destination: Vector3i
var _tween: Tween
var _scene_loaded: bool = false
var _animation_done: bool = false
var _pending_scene: String = ""

func _ready() -> void:
	_sky_material = load(SKY_MATERIAL_PATH)
	_base = get_parent() as Base
	assert(_base != null, "TravelSystem must be a child of Base")
	_base.travel_started.connect(_on_travel_started)

func _on_travel_started(destination: Vector3i) -> void:
	_destination = destination
	_scene_loaded = false
	_animation_done = false
	_start_animation(destination)
	_start_scene_load(destination)

func _start_animation(destination: Vector3i) -> void:
	var delta: Vector3i = destination - _base.grid_position
	var offset_target: Vector3 = Vector3(delta.x, delta.y, delta.z) * 3.0

	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_method(
		func(v: Vector3) -> void: _sky_material.set_shader_parameter("travel_offset", v),
		Vector3.ZERO,
		offset_target,
		TRAVEL_DURATION
	)
	_tween.tween_callback(func() -> void:
		_sky_material.set_shader_parameter("travel_offset", Vector3.ZERO)
		_animation_done = true
		_try_complete()
	)

func _start_scene_load(destination: Vector3i) -> void:
	# Stub: resolve destination to a scene path and async-load it.
	# Phase 2 will populate real scene paths; for now mark loaded immediately.
	_pending_scene = _resolve_scene(destination)
	if _pending_scene.is_empty():
		_scene_loaded = true
		_try_complete()
		return
	ResourceLoader.load_threaded_request(_pending_scene)
	set_process(true)

func _process(_delta: float) -> void:
	if _pending_scene.is_empty() or _scene_loaded:
		set_process(false)
		return
	var status: ResourceLoader.ThreadLoadStatus = \
		ResourceLoader.load_threaded_get_status(_pending_scene)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		_scene_loaded = true
		set_process(false)
		_try_complete()
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		push_error("TravelSystem: failed to load scene '%s'" % _pending_scene)
		_scene_loaded = true
		set_process(false)
		_try_complete()

func _try_complete() -> void:
	# Both gates must clear before the door opens — animation covers the load,
	# but if the load finishes first the door stays sealed until animation ends.
	if _animation_done and _scene_loaded:
		_base._on_travel_complete(_destination)

func _resolve_scene(_destination: Vector3i) -> String:
	# Phase 2: populate a coordinate registry and return the scene path for the
	# destination. Returning "" skips async load and marks scene ready immediately.
	return ""
