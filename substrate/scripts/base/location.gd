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
	MISSION,    # Phase 2: structured objectives, can seal the exit until complete
	PVP_ZONE,   # Phase 2: open PvP, players are threats
}

# BASE is safe because dueling requires mutual consent — it is never open PvP.
const SAFE_TYPES := [Type.SAFE, Type.MARKET_NPC, Type.MARKET_PLAYER, Type.GUILD_HALL, Type.BASE]

@export var location_type: Type = Type.COMBAT
@export var grid_size: Vector2i = Vector2i(1, 1)
@export var grid_position: Vector3i = Vector3i.ZERO

# --- Per-location rule flags ---
# Each location declares its own terms (see vision.md "Location Rules & Session Shape").
@export var pvp_enabled: bool = false             # open PvP allowed here (forced on for PVP_ZONE)
@export var extraction_point_cap: int = -1        # max loot points extractable; -1 = no cap
@export var locks_until_complete: bool = false    # mission locations seal the exit until an objective is met

# --- Entry/exit binding ---
# The base's main (NORTH) door locks to this marker on arrival. If unset, the
# location's origin is used.
@export var entry_point_path: NodePath

var is_safe_zone: bool:
	get: return location_type in SAFE_TYPES

var is_mission: bool:
	get: return location_type == Type.MISSION

# PvP is never active in a safe zone, and always active in a PVP_ZONE.
var pvp_active: bool:
	get: return not is_safe_zone and (pvp_enabled or location_type == Type.PVP_ZONE)

signal player_entered
signal player_exited

# Returns the transform the base's main door binds to on arrival, or this
# location's own transform if no entry point is declared.
func get_entry_point() -> Node3D:
	if not entry_point_path.is_empty():
		var node := get_node_or_null(entry_point_path)
		if node is Node3D:
			return node
	return self
