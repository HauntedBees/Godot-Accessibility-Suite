extends GASVirtualKeyboardButtonBase

@onready var _rect: ColorRect = %ColorRect
@onready var _label: AccessibleLabel = %AccessibleLabel

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_hovered)
	_label.text = "" if key_info == null else key_info.display_text
	disabled = key_info == null || key_info.display_text == ""
	if key_info.custom_signal_value:
		_rect.color = Color.RED
	else:
		_rect.color = Color.BLUE
	_rect.color.a = 0.25
