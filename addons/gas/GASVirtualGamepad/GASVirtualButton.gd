tool
extends GASVirtualControl
class_name GASVirtualButton

export(Texture) var texture:Texture = preload("res://addons/gas/GASVirtualGamepad/Parts/button0.png") setget _set_texture
func _set_texture(t:Texture):
	texture = t
	if button != null: button.texture = t

# TODO: should non-rectangular shapes be supported? buttons are generally circles; we
# can math that away for now, but would click masks like TextureButtons have be better?
export(bool) var is_circle := true

## If non-zero, the action will be emitted every repeat_frequency seconds as long as the button is pressed;
## this should never be 0 if can_be_toggled is true.
export(float) var repeat_frequency := 0.0

## The action to be executed when pressing the button
export(String) var action := "ui_accept"

## The color the button should be tinted when it's pressed
export(Color) var pressed_tint := Color.darkgray

var button:TextureRect = null
var pressed := false
var press_delay := 0.0

func _ready():
	assert(!(can_be_toggled && repeat_frequency == 0.0)) ## toggles require a repeat_frequency
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
		_simulate_action_press()

func _on_input(i:InputEvent):
	if edit_mode: pass
	else: _standard_input(i)

func _standard_input(i:InputEvent):
	if !(i is InputEventScreenTouch || i is InputEventMouseButton): return
	var is_pressed:bool = i.pressed
	## TODO: circle check
	if is_toggle:
		if is_pressed: ## For toggle buttons, pressing the button will toggle its pressed state
			pressed = !pressed
		else: return
	else: ## For regular buttons, pressing/releasing the button will set the pressed state accordingly
		pressed = is_pressed
	button.modulate = pressed_tint if pressed else Color.white
	if pressed:
		press_delay = repeat_frequency
		_simulate_action_press() ## When you first press the button, always emit the event!

func _simulate_action_press():
	print("WOH")
	Input.action_press(action)
