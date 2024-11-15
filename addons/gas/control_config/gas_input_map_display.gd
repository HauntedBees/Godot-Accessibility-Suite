@tool
class_name GASInputMapDisplay extends GASInputMapDisplayBase

var _btn_tex: AtlasTexture

@onready var _label: AccessibleLabel = %AccessibleLabel
@onready var _button: Button = %Button

func _ready() -> void:
	_btn_tex = _button.icon.duplicate()
	_button.icon = _btn_tex

func get_texture() -> Texture2D:
	return _btn_tex.duplicate()

func _set_display_name(v: String) -> void:
	display_name = v
	if !is_inside_tree():
		await ready
	_label.text = v

func _set_input_action(v: String) -> void:
	input_action = v
	if !is_inside_tree():
		await ready
	_btn_tex.region.position = _get_icon(v)

func _on_button_pressed() -> void:
	selected.emit(self)
