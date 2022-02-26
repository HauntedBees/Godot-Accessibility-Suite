tool
class_name GASVirtualGamepad
extends Control

export(bool) var mobile_only := true
export(String) var translation_prefix := ""

var edit_mode := false setget _set_edit_mode
func _set_edit_mode(m:bool):
	edit_mode = m
	for c in get_children():
		if c == dynamic_control_handler: continue
		c.edit_mode = m

var is_mobile := OS.has_feature("mobile")
var default_values := {}
var dynamic_control_handler:Control = null
var current_dynamic_control:GASVirtualControl = null
var current_dynamic_control_start := Vector2.ZERO
func _ready():
	if mobile_only && !is_mobile: visible = false
	yield(get_tree(), "idle_frame")
	for c in get_children():
		default_values[c.name] = c.config
		if c is GASVirtualMovementControl:
			c.connect("reset_dynamic_movement", self, "_on_reset_dynamic_movement", [c])
	load_setup()
	dynamic_control_handler = Control.new()
	dynamic_control_handler.rect_size = rect_size
	dynamic_control_handler.connect("gui_input", self, "_on_unhandled_input")
	add_child(dynamic_control_handler)
	move_child(dynamic_control_handler, 0)

func restore_defaults():
	for c in get_children():
		if c == dynamic_control_handler: continue
		c.config = default_values[c.name]
func load_setup():
	var config := ConfigFile.new()
	var err := config.load("user://gas_virtualgamepad_%s.cfg" % name)
	if err != OK: return
	for c in get_children():
		if c == dynamic_control_handler: continue
		var loaded_config:Dictionary = config.get_value("controls", c.name, {})
		if !loaded_config.empty(): c.config = loaded_config
func save_setup():
	var config := ConfigFile.new()
	for c in get_children():
		if c == dynamic_control_handler: continue
		config.set_value("controls", c.name, c.config)
	config.save("user://gas_virtualgamepad_%s.cfg" % name)

## For handling dynamic analog sticks and directional pads
func _on_unhandled_input(i:InputEvent):
	if edit_mode: return
	if _is_valid_drag(i) && current_dynamic_control != null:
		i.position = current_dynamic_control.rect_size / 2.0 + i.position - current_dynamic_control_start
		current_dynamic_control._standard_input(i)
	if !_is_valid_press_release(i): return
	if !i.pressed:
		if current_dynamic_control != null:
			current_dynamic_control._standard_input(i)
			current_dynamic_control = null
		return
	for c in get_children():
		if c is GASVirtualMovementControl && !c.fixed_position:
			c.rect_position = i.position - c.rect_size * c.rect_scale / 2.0
			current_dynamic_control_start = i.position
			i.position = c.rect_size / 2.0
			c._standard_input(i)
			current_dynamic_control = c
			return
func _is_valid_press_release(i:InputEvent) -> bool:
	if is_mobile: return i is InputEventScreenTouch
	else: return i is InputEventMouseButton
func _is_valid_drag(i:InputEvent) -> bool:
	if is_mobile: return i is InputEventScreenDrag
	else: return i is InputEventMouseMotion

func _on_reset_dynamic_movement(new_dynamic:GASVirtualMovementControl):
	for c in get_children():
		if c == new_dynamic ||  !(c is GASVirtualMovementControl): continue
		c.fixed_position = true
