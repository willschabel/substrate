class_name NavController
extends CanvasLayer

const TOGGLE_ACTION: String = "nav_open"

@onready var _panel: PanelContainer = $Panel
@onready var _x_spin: SpinBox = $Panel/VBox/CoordRow/XSpin
@onready var _y_spin: SpinBox = $Panel/VBox/CoordRow/YSpin
@onready var _z_spin: SpinBox = $Panel/VBox/CoordRow/ZSpin
@onready var _travel_btn: Button = $Panel/VBox/TravelButton
@onready var _status_label: Label = $Panel/VBox/StatusLabel
@onready var _current_label: Label = $Panel/VBox/CurrentLabel

var _base: Base

func _ready() -> void:
	_panel.visible = false
	_travel_btn.pressed.connect(_on_travel_pressed)

func bind(base: Base) -> void:
	_base = base
	_base.travel_started.connect(_on_travel_started)
	_base.travel_completed.connect(_on_travel_completed)
	_update_current_label()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(TOGGLE_ACTION):
		_panel.visible = not _panel.visible
		if _panel.visible:
			_update_current_label()
		get_viewport().set_input_as_handled()

func _on_travel_pressed() -> void:
	if _base == null or _base.is_traveling:
		return
	var dest := Vector3i(
		int(_x_spin.value),
		int(_y_spin.value),
		int(_z_spin.value)
	)
	if dest == _base.grid_position:
		_status_label.text = "Already at this location."
		return
	_panel.visible = false
	_base.travel_to(dest)

func _on_travel_started(_dest: Vector3i) -> void:
	_travel_btn.disabled = true
	_status_label.text = "Traveling..."

func _on_travel_completed(dest: Vector3i) -> void:
	_travel_btn.disabled = false
	_status_label.text = "Arrived."
	_x_spin.value = dest.x
	_y_spin.value = dest.y
	_z_spin.value = dest.z
	_update_current_label()

func _update_current_label() -> void:
	if _base == null:
		return
	var p: Vector3i = _base.grid_position
	_current_label.text = "Current: [%d, %d, %d]" % [p.x, p.y, p.z]
