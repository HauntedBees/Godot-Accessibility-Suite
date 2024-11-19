class_name GASVirtualKeyboardButtonBase extends Button

signal virtual_keyboard_key_pressed(keycode: Key)
signal virtual_keyboard_custom_action_pressed(action: String)

@export var key_info: GASVirtualKeyboardKey

func _on_hovered() -> void:
	pass

func _on_pressed() -> void:
	if key_info.custom_signal_value != "":
		virtual_keyboard_custom_action_pressed.emit(key_info.custom_signal_value)
	else:
		virtual_keyboard_key_pressed.emit(key_info.custom_keycode)
