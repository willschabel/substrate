extends CanvasLayer

# Combat HUD — health bar + shield bar only. No damage numbers, no minimap,
# no markers (vision.md HUD spec). Binds to the local player's Health.

@onready var _health_bar: ProgressBar = $Root/Bars/HealthBar
@onready var _shield_bar: ProgressBar = $Root/Bars/ShieldBar

func _ready() -> void:
	# Defer so the player and its Health have finished _ready (sibling order
	# is not guaranteed) before we read current values and connect.
	_bind.call_deferred()

func _bind() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null or player.health == null:
		push_warning("HUD: no player/health found to bind")
		return
	var h: Health = player.health
	h.health_changed.connect(_on_health_changed)
	h.shield_changed.connect(_on_shield_changed)
	_on_health_changed(h.current_health, h.max_health)
	_on_shield_changed(h.current_shield, h.max_shield)

func _on_health_changed(current: float, maximum: float) -> void:
	_health_bar.max_value = maximum
	_health_bar.value = current

func _on_shield_changed(current: float, maximum: float) -> void:
	_shield_bar.max_value = maximum
	_shield_bar.value = current
