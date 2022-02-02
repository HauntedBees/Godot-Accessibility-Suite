tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("GASInput", "res://addons/gas/GASInput.gd")

func _exit_tree():
	remove_autoload_singleton("GASInput")
