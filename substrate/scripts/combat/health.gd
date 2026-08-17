class_name Health
extends Node

# Health + shield pool for any combatant (player or enemy).
# Shield is a separate buffer that absorbs damage before health.
# Neither health nor shield regenerates — both are run resources, restored
# only by items or by returning to base (see vision.md Player Stats).
# Max values are gear-driven; until gear exists they come from the exports.

signal health_changed(current: float, maximum: float)
signal shield_changed(current: float, maximum: float)
signal damaged(amount: float)
signal died

@export var max_health: float = 100.0
@export var max_shield: float = 50.0

var current_health: float
var current_shield: float

var _dead: bool = false

func _ready() -> void:
	restore_full()

# -- Queries --

func is_alive() -> bool:
	return not _dead

# -- Damage --

# Applies damage: shield absorbs first, overflow spills into health.
# Returns the actual damage taken (clamped — never more than was available).
func take_damage(amount: float) -> float:
	if amount <= 0.0 or _dead:
		return 0.0

	var remaining := amount
	if current_shield > 0.0:
		var absorbed: float = min(current_shield, remaining)
		current_shield -= absorbed
		remaining -= absorbed
		shield_changed.emit(current_shield, max_shield)

	if remaining > 0.0:
		current_health = max(current_health - remaining, 0.0)
		health_changed.emit(current_health, max_health)

	damaged.emit(amount)

	if current_health <= 0.0:
		_dead = true
		died.emit()

	return amount

# -- Restoration --

func restore_full() -> void:
	# Used on respawn at base and by full-restore items.
	current_health = max_health
	current_shield = max_shield
	_dead = false
	health_changed.emit(current_health, max_health)
	shield_changed.emit(current_shield, max_shield)

func heal(amount: float) -> void:
	if amount <= 0.0 or _dead:
		return
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func restore_shield(amount: float) -> void:
	if amount <= 0.0 or _dead:
		return
	current_shield = min(current_shield + amount, max_shield)
	shield_changed.emit(current_shield, max_shield)

# Gear hook: set the pool maxima (and refill). Called when equipment changes.
func configure(new_max_health: float, new_max_shield: float) -> void:
	max_health = new_max_health
	max_shield = new_max_shield
	restore_full()
