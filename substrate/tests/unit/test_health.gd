extends GutTest

var _h: Health

func before_each() -> void:
	_h = Health.new()
	_h.max_health = 100.0
	_h.max_shield = 50.0
	add_child(_h)  # triggers _ready -> restore_full

func after_each() -> void:
	_h.queue_free()

# --- Initial state ---

func test_starts_full() -> void:
	assert_eq(_h.current_health, 100.0)
	assert_eq(_h.current_shield, 50.0)

func test_starts_alive() -> void:
	assert_true(_h.is_alive())

# --- Shield absorbs first ---

func test_damage_within_shield_spares_health() -> void:
	_h.take_damage(30.0)
	assert_eq(_h.current_shield, 20.0)
	assert_eq(_h.current_health, 100.0)

func test_damage_exceeding_shield_spills_to_health() -> void:
	_h.take_damage(70.0)  # 50 shield + 20 health
	assert_eq(_h.current_shield, 0.0)
	assert_eq(_h.current_health, 80.0)

func test_damage_with_no_shield_hits_health_directly() -> void:
	_h.current_shield = 0.0
	_h.take_damage(25.0)
	assert_eq(_h.current_health, 75.0)

# --- No regen ---

func test_no_regen_over_time() -> void:
	_h.take_damage(40.0)
	var shield_after := _h.current_shield
	# simulate frames passing — Health has no _process, nothing should change
	await wait_frames(10)
	assert_eq(_h.current_shield, shield_after)

# --- Death ---

func test_dies_at_zero_health() -> void:
	_h.take_damage(1000.0)
	assert_false(_h.is_alive())
	assert_eq(_h.current_health, 0.0)

func test_emits_died_once() -> void:
	watch_signals(_h)
	_h.take_damage(1000.0)
	assert_signal_emit_count(_h, "died", 1)

func test_damage_after_death_is_ignored() -> void:
	_h.take_damage(1000.0)
	watch_signals(_h)
	var taken := _h.take_damage(10.0)
	assert_eq(taken, 0.0)
	assert_signal_emit_count(_h, "died", 0)

# --- Signals ---

func test_shield_changed_emitted_on_damage() -> void:
	watch_signals(_h)
	_h.take_damage(10.0)
	assert_signal_emitted_with_parameters(_h, "shield_changed", [40.0, 50.0])

func test_health_unchanged_when_shield_absorbs_all() -> void:
	watch_signals(_h)
	_h.take_damage(10.0)
	assert_signal_emit_count(_h, "health_changed", 0)

# --- Negative / zero guards ---

func test_zero_damage_does_nothing() -> void:
	var taken := _h.take_damage(0.0)
	assert_eq(taken, 0.0)
	assert_eq(_h.current_shield, 50.0)

func test_negative_damage_does_nothing() -> void:
	_h.take_damage(-50.0)
	assert_eq(_h.current_shield, 50.0)
	assert_eq(_h.current_health, 100.0)

# --- Restoration ---

func test_restore_full_after_death_revives() -> void:
	_h.take_damage(1000.0)
	_h.restore_full()
	assert_true(_h.is_alive())
	assert_eq(_h.current_health, 100.0)
	assert_eq(_h.current_shield, 50.0)

func test_heal_clamps_to_max() -> void:
	_h.take_damage(60.0)  # health now 90
	_h.heal(1000.0)
	assert_eq(_h.current_health, 100.0)

func test_restore_shield_clamps_to_max() -> void:
	_h.take_damage(30.0)  # shield now 20
	_h.restore_shield(1000.0)
	assert_eq(_h.current_shield, 50.0)

# --- Gear hook ---

func test_configure_sets_maxima_and_refills() -> void:
	_h.take_damage(40.0)
	_h.configure(200.0, 80.0)
	assert_eq(_h.max_health, 200.0)
	assert_eq(_h.max_shield, 80.0)
	assert_eq(_h.current_health, 200.0)
	assert_eq(_h.current_shield, 80.0)
