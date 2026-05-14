extends GutTest

var _network: Node
var _offline: OfflineNetworkProvider

func before_each() -> void:
	_offline = OfflineNetworkProvider.new()
	_network = load("res://scripts/autoloads/network.gd").new()
	_network._provider = _offline
	add_child(_network)

func after_each() -> void:
	_network.queue_free()

# -- OfflineNetworkProvider --

func test_offline_is_connected() -> void:
	assert_true(_offline.is_connected_to_service(),
		"Offline provider should report connected so single-player works")

func test_offline_local_peer_id_is_nonzero() -> void:
	assert_gt(_offline.get_local_peer_id(), 0,
		"Local peer ID must be a positive integer")

func test_offline_party_contains_local_peer() -> void:
	var members := _offline.get_party_members()
	assert_has(members, _offline.get_local_peer_id(),
		"Party should always contain the local player in offline mode")

func test_offline_loot_roll_returns_granted() -> void:
	var result := _offline.request_loot_roll("test_location", "test_enemy")
	assert_true(result.get("granted", false),
		"Offline loot roll should always be granted")

func test_offline_loot_roll_has_expected_keys() -> void:
	var result := _offline.request_loot_roll("loc", "enemy")
	assert_has(result, "granted")
	assert_has(result, "items")
	assert_has(result, "currency")

func test_offline_economy_transaction_succeeds() -> void:
	assert_true(_offline.submit_economy_transaction({"amount": 10}))

func test_offline_progression_always_valid() -> void:
	assert_true(_offline.validate_progression("smithing", 1))
	assert_true(_offline.validate_progression("smithing", 99))

# -- Network autoload facade --

func test_network_delegates_is_connected() -> void:
	assert_true(_network.is_connected_to_service())

func test_network_delegates_get_local_peer_id() -> void:
	assert_eq(_network.get_local_peer_id(), _offline.get_local_peer_id())

func test_network_delegates_get_party_members() -> void:
	assert_eq(_network.get_party_members(), _offline.get_party_members())

func test_network_loot_roll_emits_signal() -> void:
	watch_signals(_network)
	_network.request_loot_roll("loc", "enemy")
	assert_signal_emitted(_network, "loot_roll_result")

func test_network_connect_emits_connection_changed() -> void:
	watch_signals(_network)
	_network.connect_to_service()
	assert_signal_emitted(_network, "connection_changed")

func test_network_disconnect_emits_connection_changed_false() -> void:
	watch_signals(_network)
	_network.disconnect_from_service()
	assert_signal_emitted_with_parameters(_network, "connection_changed", [false])

func test_network_provider_can_be_swapped() -> void:
	var new_provider := OfflineNetworkProvider.new()
	_network.use_provider(new_provider)
	assert_eq(_network._provider, new_provider,
		"use_provider should replace the active backend")
