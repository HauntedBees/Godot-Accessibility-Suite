class_name GASVirtualKeyboardKey extends Resource

## The text that will display for the virtual keyboard key.
@export var display_text: String:
	set(value):
		display_text = value
		if custom_keycode == KEY_NONE && custom_signal_value == "" && display_text != "":
			custom_keycode = display_text.unicode_at(0)

## The keycode that will be submitted to the Input singleton when this virtual keyboard key is pressed.
@export var custom_keycode := KEY_NONE:
	set(v):
		if v == KEY_NONE:
			return
		custom_keycode = v

## The custom message that will be emitted with the virtual keyboard's [code]keyboard_signal_emitted[/code]
## signal. The following values are pre-defined:
## - "shift_layout": will switch the layout on the keyboard to the next one.
## - "action:XXXXX": will trigger an Input Map defined action, where "XXXXX" is the action name.
@export var custom_signal_value := ""
