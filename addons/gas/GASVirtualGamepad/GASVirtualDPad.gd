tool
extends GASVirtualMovementControl
class_name GASVirtualDPad

export(Texture) var left_texture:Texture = preload("res://addons/gas/GASVirtualGamepad/Parts/dpad1.png") setget _set_left_texture
func _set_left_texture(t:Texture):
	left_texture = t
	if left != null: left.texture = t
export(Texture) var right_texture:Texture = preload("res://addons/gas/GASVirtualGamepad/Parts/dpad2.png") setget _set_right_texture
func _set_right_texture(t:Texture):
	right_texture = t
	if right != null: right.texture = t
export(Texture) var up_texture:Texture = preload("res://addons/gas/GASVirtualGamepad/Parts/dpad0.png") setget _set_up_texture
func _set_up_texture(t:Texture):
	up_texture = t
	if up != null: up.texture = t
export(Texture) var down_texture:Texture = preload("res://addons/gas/GASVirtualGamepad/Parts/dpad3.png") setget _set_down_texture
func _set_down_texture(t:Texture):
	down_texture = t
	if down != null: down.texture = t

export(String) var action_left := "ui_left"
export(String) var action_right := "ui_right"
export(String) var action_up := "ui_up"
export(String) var action_down := "ui_down"

export(float) var button_distance := 5.0 setget _set_button_distance
func _set_button_distance(b:float):
	button_distance = b
	_position_directions()

## The color the button should be tinted when it's pressed
export(Color) var pressed_tint := Color.darkgray

var left:TextureRect = null
var right:TextureRect = null
var up:TextureRect = null
var down:TextureRect = null
var pressed := false
var press_idx := 0
var center := Vector2.ZERO
var initial_position := Vector2.ZERO
var radius := 1.0

func _ready():
	left = TextureRect.new()
	if left_texture != null: left.texture = left_texture
	add_child(left)
	
	right = TextureRect.new()
	if right_texture != null: right.texture = right_texture
	add_child(right)
	
	up = TextureRect.new()
	if up_texture != null: up.texture = up_texture
	add_child(up)
	
	down = TextureRect.new()
	if down_texture != null: down.texture = down_texture
	add_child(down)

	connect("gui_input", self, "_on_input")
	yield(get_tree(), "idle_frame")
	
	_position_directions()
	_post_edit()
	_add_gizmo()

func _position_directions():
	if left == null: return
	left.rect_position = Vector2(-left.rect_size.x - button_distance, -left.rect_size.y / 2.0)
	right.rect_position = Vector2(button_distance, -right.rect_size.y / 2.0)
	up.rect_position = Vector2(-up.rect_size.x / 2.0, -up.rect_size.y - button_distance)
	down.rect_position = Vector2(-down.rect_size.x / 2.0, button_distance)
	rect_size = Vector2(left.rect_size.x + right.rect_size.x + 2.0 * button_distance, up.rect_size.y + down.rect_size.y + 2.0 * button_distance)
	center = rect_size / 2.0
	radius = center.x # TODO?: better support for rectangle d-pads
	for i in [left, right, up, down]: i.rect_position += rect_size / 2.0

func _post_edit():
	pass
	#if back == null || front == null: return
#	center = back.rect_position + (back.rect_size - front.rect_size) / 2.0
#	front.rect_position = center
#	radius = back.rect_size.x / 2.0 # TODO?: better support for oval wheels
#	if !edit_mode: visible = fixed_position

func _on_input(i:InputEvent):
	if edit_mode: pass
	else: _standard_input(i)
func _standard_input(i:InputEvent):
	if i is InputEventScreenDrag || i is InputEventMouseMotion: _handle_dragging(i)
	if !(i is InputEventScreenTouch || i is InputEventMouseButton): return
	var is_pressed:bool = i.pressed
	var my_idx:int = i.index if i is InputEventScreenTouch else 0
	if is_pressed: press_idx = my_idx
	elif press_idx != my_idx: return
	
#	if is_toggle:
#		if is_pressed: ## For toggle buttons, pressing the button will toggle its pressed state
#			pressed = !pressed
#		else: return
#	else: ## For regular buttons, pressing/releasing the button will set the pressed state accordingly
	pressed = is_pressed
	
	if pressed:
		press_idx = my_idx
		initial_position = center
		if !fixed_position: visible = true
		_handle_dragging(i)
	else:
		#front.rect_position = center
		Input.action_release(action_left)
		Input.action_release(action_right)
		Input.action_release(action_up)
		Input.action_release(action_down)
		for i in [left, right, up, down]: i.modulate = Color.white
		if !fixed_position: visible = false

func _handle_dragging(i:InputEvent):
	var my_idx:int = i.index if (i is InputEventScreenTouch || i is InputEventScreenDrag) else 0
	if !pressed || my_idx != press_idx: return
	var delta:Vector2 = i.position - initial_position# - front.rect_size / 2.0
	var adjusted_dead_zone := dead_zone * radius
	#front.rect_position = center + delta
	
	for i in [left, right, up, down]: i.modulate = Color.white
	if delta.x >= adjusted_dead_zone:
		Input.action_release(action_left)
		Input.action_press(action_right)
		right.modulate = pressed_tint
	elif delta.x <= -adjusted_dead_zone:
		Input.action_press(action_left)
		Input.action_release(action_right)
		left.modulate = pressed_tint
	else:
		Input.action_release(action_left)
		Input.action_release(action_right)
	
	if delta.y >= adjusted_dead_zone:
		Input.action_release(action_up)
		Input.action_press(action_down)
		down.modulate = pressed_tint
	elif delta.y <= -adjusted_dead_zone:
		Input.action_press(action_up)
		Input.action_release(action_down)
		up.modulate = pressed_tint
	else:
		Input.action_release(action_down)
		Input.action_release(action_up)
