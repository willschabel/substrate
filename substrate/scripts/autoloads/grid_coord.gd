extends Node

const UNIT_X: float = 12.0
const UNIT_Y: float = 5.0
const UNIT_Z: float = 12.0

func to_world(coord: Vector3i) -> Vector3:
	return Vector3(coord.x * UNIT_X, coord.y * UNIT_Y, coord.z * UNIT_Z)

func to_grid(world_pos: Vector3) -> Vector3i:
	return Vector3i(
		roundi(world_pos.x / UNIT_X),
		roundi(world_pos.y / UNIT_Y),
		roundi(world_pos.z / UNIT_Z)
	)

func to_world_floor(coord: Vector3i) -> Vector3:
	return Vector3(coord.x * UNIT_X, coord.y * UNIT_Y, coord.z * UNIT_Z)

func are_adjacent(a: Vector3i, b: Vector3i) -> bool:
	var d := b - a
	return abs(d.x) + abs(d.y) + abs(d.z) == 1

func neighbors(coord: Vector3i) -> Array[Vector3i]:
	return [
		coord + Vector3i( 1,  0,  0),
		coord + Vector3i(-1,  0,  0),
		coord + Vector3i( 0,  0,  1),
		coord + Vector3i( 0,  0, -1),
		coord + Vector3i( 0,  1,  0),
		coord + Vector3i( 0, -1,  0),
	]

func cell_size() -> Vector3:
	return Vector3(UNIT_X, UNIT_Y, UNIT_Z)
