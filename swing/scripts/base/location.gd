class_name Location
extends Node3D

enum Type {
	COMBAT,
	SAFE,
	MARKET_NPC,
	MARKET_PLAYER,
	GUILD_HALL,
	BASE,
	OPEN_WORLD,
}

const SAFE_TYPES := [Type.SAFE, Type.MARKET_NPC, Type.MARKET_PLAYER, Type.GUILD_HALL, Type.BASE]

@export var location_type: Type = Type.COMBAT
@export var grid_size: Vector2i = Vector2i(1, 1)
@export var grid_position: Vector3i = Vector3i.ZERO

var is_safe_zone: bool:
	get: return location_type in SAFE_TYPES

signal player_entered
signal player_exited
