class_name Base
extends Location

signal travel_started(destination: Vector3i)
signal travel_completed(destination: Vector3i)
signal door_state_changed(direction: Door.Direction, is_open: bool)

var is_traveling: bool = false

@onready var _doors: Dictionary = {
	Door.Direction.NORTH: $Doors/DoorNorth,
	Door.Direction.SOUTH: $Doors/DoorSouth,
	Door.Direction.EAST:  $Doors/DoorEast,
	Door.Direction.WEST:  $Doors/DoorWest,
}

func _ready() -> void:
	location_type = Location.Type.BASE
	grid_size = Vector2i(1, 1)
	for dir: Door.Direction in _doors:
		var door: Door = _doors[dir]
		door.state_changed.connect(func(open: bool) -> void:
			door_state_changed.emit(dir, open)
		)

func open_door(direction: Door.Direction) -> void:
	_doors[direction].open()

func close_door(direction: Door.Direction) -> void:
	_doors[direction].close()

func is_door_open(direction: Door.Direction) -> bool:
	return _doors[direction].is_open

func travel_to(destination: Vector3i) -> void:
	if is_traveling:
		return
	is_traveling = true
	travel_started.emit(destination)

func _on_travel_complete(destination: Vector3i) -> void:
	grid_position = destination
	is_traveling = false
	travel_completed.emit(destination)
