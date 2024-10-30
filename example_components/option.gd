@tool
class_name Option extends MarginContainer

const _EMPTY_COLOR := Color(0.0, 0.0, 0.0, 0.0)
const _HOVERED_COLOR := Color(0.0, 0.0, 0.0, 0.5)

@export var text := "Value":
	set(value):
		text = value
		if !is_inside_tree():
			await ready
		_label.text = text

@export var link := ""

@export var scene: PackedScene

@onready var _bg: ColorRect = %ColorRect
@onready var _label: AccessibleLabel = %Label

func _ready() -> void:
	mouse_entered.connect(_on_entered)
	mouse_exited.connect(_on_exited)

func _on_entered() -> void:
	_bg.color = _HOVERED_COLOR

func _on_exited() -> void:
	_bg.color = _EMPTY_COLOR

func _on_gui_input(event: InputEvent) -> void:
	if GASInput.is_click(event):
		(get_tree().current_scene as FullExample).change_scene(scene, text, link)
