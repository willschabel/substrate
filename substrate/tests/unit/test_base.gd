extends GutTest

var _base_scene: PackedScene
var _base: Base

func before_each() -> void:
	_base_scene = load("res://scenes/base.tscn")
	_base = _base_scene.instantiate()
	add_child(_base)

func after_each() -> void:
	_base.queue_free()

# --- Door state ---

func test_all_doors_closed_on_start() -> void:
	for dir: Door.Direction in Door.Direction.values():
		assert_false(_base.is_door_open(dir), "Door %d should start closed" % dir)

func test_open_door_changes_state() -> void:
	_base.open_door(Door.Direction.NORTH)
	assert_true(_base.is_door_open(Door.Direction.NORTH))

func test_close_door_changes_state() -> void:
	_base.open_door(Door.Direction.SOUTH)
	_base.close_door(Door.Direction.SOUTH)
	assert_false(_base.is_door_open(Door.Direction.SOUTH))

func test_open_door_emits_signal() -> void:
	watch_signals(_base)
	_base.open_door(Door.Direction.EAST)
	assert_signal_emitted_with_parameters(_base, "door_state_changed", [Door.Direction.EAST, true])

func test_close_door_emits_signal() -> void:
	_base.open_door(Door.Direction.WEST)
	watch_signals(_base)
	_base.close_door(Door.Direction.WEST)
	assert_signal_emitted_with_parameters(_base, "door_state_changed", [Door.Direction.WEST, false])

func test_open_already_open_door_does_not_double_emit() -> void:
	_base.open_door(Door.Direction.NORTH)
	watch_signals(_base)
	_base.open_door(Door.Direction.NORTH)
	assert_signal_emit_count(_base, "door_state_changed", 0)

func test_all_four_doors_independent() -> void:
	_base.open_door(Door.Direction.NORTH)
	assert_true(_base.is_door_open(Door.Direction.NORTH))
	assert_false(_base.is_door_open(Door.Direction.SOUTH))
	assert_false(_base.is_door_open(Door.Direction.EAST))
	assert_false(_base.is_door_open(Door.Direction.WEST))

# --- Travel ---

func test_not_traveling_on_start() -> void:
	assert_false(_base.is_traveling)

func test_travel_to_sets_traveling() -> void:
	_base.travel_to(Vector3i(1, 0, 0))
	assert_true(_base.is_traveling)

func test_travel_to_emits_travel_started() -> void:
	watch_signals(_base)
	_base.travel_to(Vector3i(2, 0, 0))
	assert_signal_emitted_with_parameters(_base, "travel_started", [Vector3i(2, 0, 0)])

func test_travel_ignored_while_traveling() -> void:
	_base.travel_to(Vector3i(1, 0, 0))
	watch_signals(_base)
	_base.travel_to(Vector3i(2, 0, 0))
	assert_signal_emit_count(_base, "travel_started", 0)

func test_on_travel_complete_updates_grid_position() -> void:
	_base.travel_to(Vector3i(3, 1, -2))
	_base._on_travel_complete(Vector3i(3, 1, -2))
	assert_eq(_base.grid_position, Vector3i(3, 1, -2))

func test_on_travel_complete_clears_traveling() -> void:
	_base.travel_to(Vector3i(1, 0, 0))
	_base._on_travel_complete(Vector3i(1, 0, 0))
	assert_false(_base.is_traveling)

func test_on_travel_complete_emits_signal() -> void:
	_base.travel_to(Vector3i(5, 0, 0))
	watch_signals(_base)
	_base._on_travel_complete(Vector3i(5, 0, 0))
	assert_signal_emitted_with_parameters(_base, "travel_completed", [Vector3i(5, 0, 0)])

# --- Location base class ---

func test_location_type_is_base() -> void:
	assert_eq(_base.location_type, Location.Type.BASE)

func test_grid_size_is_one_unit() -> void:
	assert_eq(_base.grid_size, Vector2i(1, 1))

func test_base_is_safe_zone() -> void:
	assert_true(_base.is_safe_zone)
