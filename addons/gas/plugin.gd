@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("GASConfig", "res://addons/gas/GASConfig.gd")
	add_autoload_singleton("GASInput", "res://addons/gas/GASInput.gd")
	add_autoload_singleton("GASText", "res://addons/gas/gas_text.gd")
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


func _exit_tree():
	remove_autoload_singleton("GASInput")
	remove_autoload_singleton("GASConfig")
	remove_autoload_singleton("GASText")
	remove_custom_type("AccessibleRichTextLabel")
	remove_custom_type("AccessibleLabel")
	remove_custom_type("AccessibleScrollContainer")
