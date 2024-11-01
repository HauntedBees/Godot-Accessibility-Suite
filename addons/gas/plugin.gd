@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("GASConfig", "res://addons/gas/gas_config.gd")
	add_autoload_singleton("GASInput", "res://addons/gas/gas_input.gd")
	add_autoload_singleton("GASText", "res://addons/gas/gas_text.gd")
	add_autoload_singleton("GASTime", "res://addons/gas/gas_time.gd")
	add_autoload_singleton("GASUtils", "res://addons/gas/gas_utils.gd")
	add_custom_type(
		"AccessibleRichTextLabel", "RichTextLabel",
		load("res://addons/gas/gas_richtextlabel.gd"),
		load("res://addons/gas/icons/gas_rich_text_label.svg")
	)
	add_custom_type(
		"AccessibleLabel", "Label",
		load("res://addons/gas/gas_label.gd"),
		load("res://addons/gas/icons/gas_label.svg")
	)
	add_custom_type(
		"AccessibleScrollContainer", "ScrollContainer",
		load("res://addons/gas/gas_scroll_container.gd"),
		load("res://addons/gas/icons/gas_scroll_container.svg")
	)
	InputMap.add_action("gas_scroll_down")
	InputMap.action_add_event("gas_scroll_down", _get_keypress(KEY_K))
	InputMap.add_action("gas_scroll_up")
	InputMap.action_add_event("gas_scroll_up", _get_keypress(KEY_I))

func _exit_tree():
	remove_autoload_singleton("GASInput")
	remove_autoload_singleton("GASConfig")
	remove_autoload_singleton("GASText")
	remove_autoload_singleton("GASTime")
	remove_autoload_singleton("GASUtils")
	remove_custom_type("AccessibleRichTextLabel")
	remove_custom_type("AccessibleLabel")
	remove_custom_type("AccessibleScrollContainer")
	InputMap.erase_action("gas_scroll_down")
	InputMap.erase_action("gas_scroll_up")

func _get_keypress(keycode: Key) -> InputEventKey:
	var iek := InputEventKey.new()
	iek.keycode = keycode
	return iek
