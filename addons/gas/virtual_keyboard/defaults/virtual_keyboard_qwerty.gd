@tool
class_name GASVirtualKeyboardQwerty extends GASVirtualKeyboardBase

func _init() -> void:
	theme = preload("res://addons/gas/virtual_keyboard/defaults/keyboard_theme.tres")
	layouts = [
		preload("res://addons/gas/virtual_keyboard/defaults/layouts/qwerty_lowercase.tres"),
		preload("res://addons/gas/virtual_keyboard/defaults/layouts/qwerty_uppercase.tres"),
		preload("res://addons/gas/virtual_keyboard/defaults/layouts/qwerty_numpunc.tres")
	]
	show_empty_buttons = false
	expand_buttons = false
	horizontal_alignment = BoxContainer.AlignmentMode.ALIGNMENT_CENTER
	columns_per_section = 10
