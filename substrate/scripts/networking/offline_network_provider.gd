class_name OfflineNetworkProvider
extends NetworkProvider

# Single-player stub. All P2P calls are no-ops; loot rolls are resolved
# locally so the game loop works without a server.

const LOCAL_PEER_ID := 1

func is_connected_to_service() -> bool:
	return true

func get_local_peer_id() -> int:
	return LOCAL_PEER_ID

func get_party_members() -> Array[int]:
	return [LOCAL_PEER_ID]

func validate_progression(_skill: String, _level: int) -> bool:
	return true

func request_loot_roll(_location_id: String, _enemy_id: String) -> Dictionary:
	# Local loot resolution — replaced by server call in SteamNetworkProvider.
	return {
		"granted": true,
		"items": [],
		"currency": 0,
	}

func submit_economy_transaction(_transaction: Dictionary) -> bool:
	return true
