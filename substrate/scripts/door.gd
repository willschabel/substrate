class_name Door
extends Node3D

enum Direction { NORTH, SOUTH, EAST, WEST }

const DIRECTION_VECTORS: Dictionary = {
	Direction.NORTH: Vector3i(0, 0, -1),
	Direction.SOUTH: Vector3i(0, 0, 1),
	Direction.EAST:  Vector3i(1, 0, 0),
	Direction.WEST:  Vector3i(-1, 0, 0),
}

@export var direction: Direction = Direction.NORTH
var is_open: bool = false

signal state_changed(is_open: bool)

func open() -> void:
	if is_open:
		return
	is_open = true
	state_changed.emit(true)

func close() -> void:
	if not is_open:
		return
	is_open = false
	state_changed.emit(false)

func get_direction_vector() -> Vector3i:
	return DIRECTION_VECTORS[direction]
