extends GutTest

var _loc: Location

func before_each() -> void:
	_loc = Location.new()
	add_child(_loc)

func after_each() -> void:
	_loc.queue_free()

# --- Safe zone classification ---

func test_combat_is_not_safe_zone() -> void:
	_loc.location_type = Location.Type.COMBAT
	assert_false(_loc.is_safe_zone)

func test_open_world_is_not_safe_zone() -> void:
	_loc.location_type = Location.Type.OPEN_WORLD
	assert_false(_loc.is_safe_zone)

func test_markets_and_guild_are_safe_zones() -> void:
	for t: Location.Type in [Location.Type.SAFE, Location.Type.MARKET_NPC, \
			Location.Type.MARKET_PLAYER, Location.Type.GUILD_HALL, Location.Type.BASE]:
		_loc.location_type = t
		assert_true(_loc.is_safe_zone, "Type %d should be a safe zone" % t)

# --- New Phase 2 types ---

func test_mission_type_exists_and_flags() -> void:
	_loc.location_type = Location.Type.MISSION
	assert_true(_loc.is_mission)
	assert_false(_loc.is_safe_zone)

func test_pvp_zone_type_exists() -> void:
	_loc.location_type = Location.Type.PVP_ZONE
	assert_false(_loc.is_safe_zone)

# --- PvP activation rules ---

func test_combat_no_pvp_by_default() -> void:
	_loc.location_type = Location.Type.COMBAT
	assert_false(_loc.pvp_active)

func test_combat_pvp_when_enabled() -> void:
	_loc.location_type = Location.Type.COMBAT
	_loc.pvp_enabled = true
	assert_true(_loc.pvp_active)

func test_pvp_zone_always_active() -> void:
	_loc.location_type = Location.Type.PVP_ZONE
	_loc.pvp_enabled = false
	assert_true(_loc.pvp_active)

func test_safe_zone_never_has_pvp() -> void:
	_loc.location_type = Location.Type.BASE
	_loc.pvp_enabled = true  # even if mistakenly enabled
	assert_false(_loc.pvp_active)

# --- Extraction cap default ---

func test_extraction_cap_defaults_to_uncapped() -> void:
	assert_eq(_loc.extraction_point_cap, -1)

# --- Entry point binding ---

func test_entry_point_defaults_to_self() -> void:
	assert_eq(_loc.get_entry_point(), _loc)

func test_entry_point_resolves_marker() -> void:
	var marker := Node3D.new()
	marker.name = "EntryMarker"
	_loc.add_child(marker)
	_loc.entry_point_path = _loc.get_path_to(marker)
	assert_eq(_loc.get_entry_point(), marker)
