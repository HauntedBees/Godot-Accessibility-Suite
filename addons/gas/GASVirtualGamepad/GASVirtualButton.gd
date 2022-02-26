tool
extends GASVirtualControl
class_name GASVirtualButton

export(String) var action := "ui_accept"

export(Texture) var texture:Texture = preload("res://addons/gas/GASVirtualGamepad/Parts/button0.png") setget _set_texture
func _set_texture(t:Texture):
	texture = t
	if button != null: button.texture = t

# TODO: should non-rectangular shapes be supported? buttons are generally circles; we
# can math that away for now, but would click masks like TextureButtons have be better?
export(bool) var is_circle := true

## If non-zero, every repeat_frequency seconds the action will be released and pressed again.
## If you have calls to Input.is_action_just_pressed in your code, this will ensure that that
## they return true regularly as the button is held down. If you only ever use Input.is_action_pressed,
## this is not needed, as the action will be pressed as long as the button is held down regardless.
export(float) var repeat_frequency := 0.0

## The color the button should be tinted when it's pressed
export(Color) var pressed_tint := Color.darkgray

var button:TextureRect = null
var pressed := false
var press_idx := 0
var press_delay := 0.0

func _ready():
	button = TextureRect.new()
	if texture != null: button.texture = texture
	button.connect("gui_input", self, "_on_input")
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(button)
	yield(get_tree(), "idle_frame")
	rect_size = button.rect_size
	_add_gizmo()

func _inner_get_config(d:Dictionary) -> Dictionary:
	d["texture"] = texture.resource_path
	d["is_circle"] = is_circle
	return d
func _inner_set_config(c:Dictionary):
	texture = load(c["texture"])
	is_circle = c["is_circle"]

func _process(delta:float):
	if !pressed || repeat_frequency <= 0.0: return
	press_delay -= delta
	if press_delay <= 0.0:
		press_delay += repeat_frequency
		Input.action_release(action)
		yield(get_tree(), "idle_frame")
		Input.action_press(action)

func _on_input(i:InputEvent):
	if edit_mode: pass
	else: _standard_input(i)
## Sometimes lifting the finger doesn't work quite right and things get fucky,
## so this _unhandled_input is to ensure that lifting a finger up always registers.
## TODO: figure out a better way of handling this? or maybe this IS how to handle it.
func _unhandled_input(i:InputEvent):
	if !(i is InputEventScreenTouch): return
	if i.pressed: return
	_on_input(i)

func _standard_input(i:InputEvent):
	if !(i is InputEventScreenTouch || i is InputEventMouseButton): return
	var is_pressed:bool = i.pressed
	var my_idx:int = i.index if i is InputEventScreenTouch else 0
	if is_pressed: press_idx = my_idx
	elif press_idx != my_idx: return
	# TODO: circle check
	if is_toggle:
		if is_pressed: ## For toggle buttons, pressing the button will toggle its pressed state
			pressed = !pressed
		else: return
	else: ## For regular buttons, pressing/releasing the button will set the pressed state accordingly
		pressed = is_pressed
	button.modulate = pressed_tint if pressed else Color.white
	if pressed:
		press_idx = my_idx
		press_delay = repeat_frequency
		Input.action_press(action)
	else:
		Input.action_release(action)
