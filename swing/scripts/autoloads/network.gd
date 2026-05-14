extends Node

# Single entry point for all network operations.
# Game code calls Network.* only — never touch a provider directly.
# Swap _provider at startup to change the backend (offline → Steam → dedicated).

signal connection_changed(connected: bool)
signal party_member_joined(peer_id: int)
signal party_member_left(peer_id: int)
signal received_position(peer_id: int, pos: Vector3, yaw: float)
signal received_combat_action(peer_id: int, action: Dictionary)
signal loot_roll_result(result: Dictionary)

var _provider: NetworkProvider

func _ready() -> void:
	_provider = OfflineNetworkProvider.new()

func use_provider(provider: NetworkProvider) -> void:
	_provider = provider

# -- Connection --

func connect_to_service() -> void:
	_provider.connect_to_service()
	connection_changed.emit(_provider.is_connected_to_service())

func disconnect_from_service() -> void:
	_provider.disconnect_from_service()
	connection_changed.emit(false)

func is_connected_to_service() -> bool:
	return _provider.is_connected_to_service()

# -- Party --

func create_lobby() -> int:
	return _provider.create_lobby()

func join_lobby(lobby_id: int) -> void:
	_provider.join_lobby(lobby_id)

func leave_lobby() -> void:
	_provider.leave_lobby()

func get_party_members() -> Array[int]:
	return _provider.get_party_members()

func get_local_peer_id() -> int:
	return _provider.get_local_peer_id()

# -- Character sync --

func send_position(pos: Vector3, yaw: float) -> void:
	_provider.send_position(pos, yaw)

func send_combat_action(action: Dictionary) -> void:
	_provider.send_combat_action(action)

# -- Server-authoritative --

func request_loot_roll(location_id: String, enemy_id: String) -> Dictionary:
	var result := _provider.request_loot_roll(location_id, enemy_id)
	loot_roll_result.emit(result)
	return result

func submit_economy_transaction(transaction: Dictionary) -> bool:
	return _provider.submit_economy_transaction(transaction)

func validate_progression(skill: String, level: int) -> bool:
	return _provider.validate_progression(skill, level)
