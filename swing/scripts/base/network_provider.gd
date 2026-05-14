class_name NetworkProvider
extends RefCounted

# -- Connection --

func connect_to_service() -> void:
	pass

func disconnect_from_service() -> void:
	pass

func is_connected_to_service() -> bool:
	return false

# -- Party (P2P) --

func create_lobby() -> int:
	return 0

func join_lobby(_lobby_id: int) -> void:
	pass

func leave_lobby() -> void:
	pass

func get_party_members() -> Array[int]:
	return []

func get_local_peer_id() -> int:
	return 0

# -- Character sync (P2P) --

func send_position(_pos: Vector3, _yaw: float) -> void:
	pass

func send_combat_action(_action: Dictionary) -> void:
	pass

# -- Server-authoritative --

func request_loot_roll(_location_id: String, _enemy_id: String) -> Dictionary:
	return {}

func submit_economy_transaction(_transaction: Dictionary) -> bool:
	return false

func validate_progression(_skill: String, _level: int) -> bool:
	return false
