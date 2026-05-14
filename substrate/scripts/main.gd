extends Node3D

@onready var _base: Base = $Base
@onready var _nav: NavController = $NavController

func _ready() -> void:
	_nav.bind(_base)
