class_name GASVirtualKeyboardButton extends GASVirtualKeyboardButtonBase

func _init(base_size: Vector2) -> void:
	text = "" if key_info == null else key_info.display_text
	size = base_size
	custom_minimum_size = base_size
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	focus_mode = Control.FOCUS_NONE
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_hovered)

func _ready() -> void:
	text = "" if key_info == null else key_info.display_text
	disabled = key_info == null || key_info.display_text == ""
