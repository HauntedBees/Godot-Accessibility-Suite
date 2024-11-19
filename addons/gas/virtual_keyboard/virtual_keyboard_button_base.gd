class_name GASVirtualKeyboardButtonBase extends Button

signal virtual_keyboard_key_hovered(button: GASVirtualKeyboardButtonBase)
signal virtual_keyboard_key_pressed(keycode: Key)
signal virtual_keyboard_custom_action_pressed(action: String)

@export var key_info: GASVirtualKeyboardKey

var key_position: Vector2i

func _on_hovered() -> void:
	virtual_keyboard_key_hovered.emit(self)

func _on_pressed() -> void:
	if key_info.custom_signal_value != "":
		virtual_keyboard_custom_action_pressed.emit(key_info.custom_signal_value)
	else:
		virtual_keyboard_key_pressed.emit(key_info.custom_keycode)
