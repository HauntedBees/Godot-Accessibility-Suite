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
var dynamic_control_handler:Control = null
func _ready():
	if mobile_only && !OS.has_feature("mobile"): visible = false
	yield(get_tree(), "idle_frame")
	for c in get_children():
		default_values[c.name] = c.config
	load_setup()
	dynamic_control_handler = Control.new()
	dynamic_control_handler.rect_size = rect_size
	dynamic_control_handler.connect("gui_input", self, "_on_unhandled_input")
	add_child(dynamic_control_handler)
	move_child(dynamic_control_handler, 0)

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

## For handling dynamic analog sticks and directional pads
func _on_unhandled_input(i:InputEvent):
	if !(i is InputEventScreenTouch || i is InputEventMouseButton): return
	if !i.pressed: return
	for c in get_children():
		if c is GASVirtualAnalogStick && !c.fixed_position:
			c.rect_position = i.position - c.rect_size / 2.0
			i.position = c.rect_size / 2.0
			c._standard_input(i) # TODO: ????
			return
