@tool
class_name GASVirtualKeyboardThreeColumn extends GASVirtualKeyboardBase

func _init() -> void:
	theme = preload("res://addons/gas/virtual_keyboard/defaults/keyboard_theme.tres")
	layouts = [
		preload("res://addons/gas/virtual_keyboard/defaults/layouts/abc_lowercase.tres"),
		preload("res://addons/gas/virtual_keyboard/defaults/layouts/abc_uppercase.tres"),
		preload("res://addons/gas/virtual_keyboard/defaults/layouts/abc_numpunc.tres")
	]
	columns_per_section = 5
	layouts_to_show = 3
