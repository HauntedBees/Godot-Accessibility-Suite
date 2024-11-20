@tool
class_name GASDaisyPetalButton extends Sprite2D

@export var button_active := false

@export var pressed_color := Color.AQUAMARINE:
	set(value):
		pressed_color = value
		if is_inside_tree():
			_set_color()

@export var text := "":
	set(value):
		text = value
		if is_inside_tree():
			_text.text = text

@export var button_color := Color.REBECCA_PURPLE:
	set(value):
		button_color = value
		if is_inside_tree():
			_set_color()

@export var button_alpha := 0.0:
	set(value):
		button_alpha = value
		if is_inside_tree():
			_set_color()

@export var pressed := false:
	set(value):
		pressed = value
		if is_inside_tree():
			_set_color()

@export var label_settings: LabelSettings:
	set(value):
		label_settings = value
		if is_inside_tree() && label_settings != null:
			_text.label_settings = label_settings

@onready var _text: Label = %Label

func _ready():
	_text.text = text
	_set_color()

func _set_color() -> void:
	self_modulate = Color(pressed_color if pressed else button_color, 0.0 if text == "" else button_alpha)
