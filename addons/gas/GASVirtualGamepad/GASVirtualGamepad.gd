tool
class_name GASVirtualGamepad
extends Control

export(bool) var mobile_only := true

var edit_mode := false setget _set_edit_mode
func _set_edit_mode(m:bool):
	edit_mode = m
	for c in get_children():
		c.edit_mode = m

var default_values := {}
func _ready():
	if mobile_only && !OS.has_feature("mobile"): visible = false
	yield(get_tree(), "idle_frame")
	for c in get_children():
		default_values[c.name] = c.config
	load_setup()

func restore_defaults():
	for c in get_children():
		c.config = default_values[c.name]

func load_setup():
	var config := ConfigFile.new()
	var err := config.load("user://gas_virtualgamepad_%s.cfg" % name)
	if err != OK: return
	for c in get_children():
		var loaded_config:Dictionary = config.get_value("controls", c.name, {})
		if !loaded_config.empty(): c.config = loaded_config
func save_setup():
	var config := ConfigFile.new()
	for c in get_children():
		config.set_value("controls", c.name, c.config)
	config.save("user://gas_virtualgamepad_%s.cfg" % name)
