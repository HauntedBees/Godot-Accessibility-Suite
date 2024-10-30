@tool
class_name Heading extends HBoxContainer

@export var text := "Heading":
	set(value):
		text = value
		if !is_inside_tree():
			await ready
		_label.text = text

@export var container: VBoxContainer

@export var opened := false:
	set(value):
		opened = value
		if !is_inside_tree():
			await ready
		_toggle()

@onready var _label: AccessibleLabel = %AccessibleLabel
@onready var _caret: TextureButton = %ExpandCaret

func _ready() -> void:
	_caret.pressed.connect(func() -> void: opened = !opened)

func _toggle() -> void:
	_caret.flip_v = !opened
	for c in container.get_children():
		if c == self:
			continue
		c.visible = opened
