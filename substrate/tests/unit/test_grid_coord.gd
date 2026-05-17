extends GutTest

var _gc: Node

func before_each() -> void:
	_gc = load("res://scripts/autoloads/grid_coord.gd").new()
	add_child(_gc)

func after_each() -> void:
	_gc.queue_free()

# --- to_world ---

func test_to_world_origin() -> void:
	assert_eq(_gc.to_world(Vector3i.ZERO), Vector3.ZERO,
		"Origin coord should map to world zero")

func test_to_world_positive_coord() -> void:
	assert_eq(_gc.to_world(Vector3i(1, 1, 1)), Vector3(12.0, 5.0, 12.0),
		"(1,1,1) should map to one full grid unit in each axis")

func test_to_world_negative_coord() -> void:
	assert_eq(_gc.to_world(Vector3i(-2, -1, -3)), Vector3(-24.0, -5.0, -36.0),
		"Negative coords should produce negative world positions")

func test_to_world_mixed_coord() -> void:
	assert_eq(_gc.to_world(Vector3i(3, 0, -2)), Vector3(36.0, 0.0, -24.0))

# --- to_grid ---

func test_to_grid_origin() -> void:
	assert_eq(_gc.to_grid(Vector3.ZERO), Vector3i.ZERO)

func test_to_grid_exact_unit() -> void:
	assert_eq(_gc.to_grid(Vector3(12.0, 5.0, 12.0)), Vector3i(1, 1, 1),
		"Exact unit boundary should map cleanly")

func test_to_grid_rounds_up_past_midpoint() -> void:
	# 6.4 / 12.0 = 0.533 — rounds to 1
	assert_eq(_gc.to_grid(Vector3(6.4, 2.6, 6.4)), Vector3i(1, 1, 1))

func test_to_grid_rounds_down_below_midpoint() -> void:
	# 5.9 / 12.0 = 0.491 — rounds to 0
	assert_eq(_gc.to_grid(Vector3(5.9, 2.4, 5.9)), Vector3i(0, 0, 0))

func test_to_grid_negative_rounds() -> void:
	assert_eq(_gc.to_grid(Vector3(-6.4, -2.6, -6.4)), Vector3i(-1, -1, -1))

# --- round-trip ---

func test_round_trip_positive() -> void:
	var coord := Vector3i(3, 1, 2)
	assert_eq(_gc.to_grid(_gc.to_world(coord)), coord,
		"to_grid(to_world(coord)) should return the original coord")

func test_round_trip_negative() -> void:
	var coord := Vector3i(-4, -2, 1)
	assert_eq(_gc.to_grid(_gc.to_world(coord)), coord)

# --- are_adjacent ---

func test_adjacent_plus_x() -> void:
	assert_true(_gc.are_adjacent(Vector3i(0,0,0), Vector3i(1,0,0)))

func test_adjacent_minus_x() -> void:
	assert_true(_gc.are_adjacent(Vector3i(0,0,0), Vector3i(-1,0,0)))

func test_adjacent_plus_y() -> void:
	assert_true(_gc.are_adjacent(Vector3i(0,0,0), Vector3i(0,1,0)))

func test_adjacent_minus_y() -> void:
	assert_true(_gc.are_adjacent(Vector3i(0,0,0), Vector3i(0,-1,0)))

func test_adjacent_plus_z() -> void:
	assert_true(_gc.are_adjacent(Vector3i(0,0,0), Vector3i(0,0,1)))

func test_adjacent_minus_z() -> void:
	assert_true(_gc.are_adjacent(Vector3i(0,0,0), Vector3i(0,0,-1)))

func test_not_adjacent_diagonal_xz() -> void:
	assert_false(_gc.are_adjacent(Vector3i(0,0,0), Vector3i(1,0,1)),
		"Diagonal should not be adjacent")

func test_not_adjacent_diagonal_xy() -> void:
	assert_false(_gc.are_adjacent(Vector3i(0,0,0), Vector3i(1,1,0)))

func test_not_adjacent_two_steps() -> void:
	assert_false(_gc.are_adjacent(Vector3i(0,0,0), Vector3i(2,0,0)))

func test_not_adjacent_same_cell() -> void:
	assert_false(_gc.are_adjacent(Vector3i(1,1,1), Vector3i(1,1,1)),
		"A cell is not adjacent to itself")

func test_adjacency_is_symmetric() -> void:
	var a := Vector3i(3, -1, 2)
	var b := Vector3i(3, -1, 3)
	assert_eq(_gc.are_adjacent(a, b), _gc.are_adjacent(b, a),
		"Adjacency should be symmetric")

# --- neighbors ---

func test_neighbors_returns_six() -> void:
	assert_eq(_gc.neighbors(Vector3i.ZERO).size(), 6,
		"Every cell has exactly 6 face-adjacent neighbors")

func test_all_neighbors_are_adjacent() -> void:
	var coord := Vector3i(2, 3, -1)
	for neighbor in _gc.neighbors(coord):
		assert_true(_gc.are_adjacent(coord, neighbor),
			"Every returned neighbor must be adjacent to the source")

func test_neighbors_no_duplicates() -> void:
	var seen: Array = []
	for neighbor in _gc.neighbors(Vector3i(1, 1, 1)):
		assert_false(seen.has(neighbor), "Neighbor list must have no duplicates")
		seen.append(neighbor)

func test_neighbors_does_not_include_self() -> void:
	var coord := Vector3i(0, 0, 0)
	assert_does_not_have(_gc.neighbors(coord), coord,
		"Neighbors should not include the cell itself")

# --- cell_size ---

func test_cell_size_matches_constants() -> void:
	assert_eq(_gc.cell_size(), Vector3(_gc.UNIT_X, _gc.UNIT_Y, _gc.UNIT_Z))

func test_cell_size_values() -> void:
	var s: Vector3 = _gc.cell_size()
	assert_eq(s.x, 12.0)
	assert_eq(s.y, 5.0)
	assert_eq(s.z, 12.0)
