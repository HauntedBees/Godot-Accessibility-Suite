@tool
class_name GASVirtualButton extends GASVirtualControl

@export var action := "ui_accept"

@export var texture: Texture2D = preload("res://addons/gas/virtual_gamepad/parts/button0.png"):
	set(v):
		texture = v
		if button != null:
			button.texture = v

# TODO: should non-rectangular shapes be supported? buttons are generally circles; we
# can math that away for now, but would click masks like TextureButtons have be better?
@export var is_circle := true

## If non-zero, every repeat_frequency seconds the action will be released and pressed again.
## If you have calls to Input.is_action_just_pressed in your code, this will ensure that that
## they return true regularly as the button is held down. If you only ever use Input.is_action_pressed,
## this is not needed, as the action will be pressed as long as the button is held down regardless.
@export var repeat_frequency := 0.0

## The color the button should be tinted when it's pressed
@export var pressed_tint := Color.DARK_GRAY

var button:TextureRect = null
var pressed := false
var press_idx := 0
var press_delay := 0.0

func _ready():
	button = TextureRect.new()
	if texture != null: button.texture = texture
	button.gui_input.connect(_on_input)
	add_child(button)
	await get_tree().process_frame
	size = button.size
	_add_gizmo()

func _inner_get_config(d:Dictionary) -> Dictionary:
	d["is_circle"] = is_circle
	return d
func _inner_set_config(c:Dictionary):
	is_circle = c["is_circle"]

func _process(delta:float):
	if !pressed || repeat_frequency <= 0.0: return
	press_delay -= delta
	if press_delay <= 0.0:
		press_delay += repeat_frequency
		Input.action_release(action)
		await get_tree().process_frame
		Input.action_press(action)

func _on_input(i:InputEvent):
	if edit_mode: pass
	else: _standard_input(i)

func _standard_input(i:InputEvent):
	if !_is_valid_press_release(i):
		return
	var is_pressed: bool = i.pressed
	var my_idx := _get_index(i)
	if is_pressed:
		press_idx = my_idx
	elif press_idx != my_idx:
		return
	# TODO: circle check
	if is_toggle:
		if is_pressed: ## For toggle buttons, pressing the button will toggle its pressed state
			pressed = !pressed
		else:
			return
	else: ## For regular buttons, pressing/releasing the button will set the pressed state accordingly
		pressed = is_pressed
	button.modulate = pressed_tint if pressed else Color.WHITE
	if pressed:
		press_idx = my_idx
		press_delay = repeat_frequency
		Input.action_press(action)
	else:
		Input.action_release(action)
		if GASInput.input_toggle_actions.find(action) >= 0:
			GASInput.active_toggle_actions.erase(action)
