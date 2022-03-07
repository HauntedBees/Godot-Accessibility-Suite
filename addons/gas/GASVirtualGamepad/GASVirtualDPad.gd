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

func _standard_input(i:InputEvent):
	._standard_input(i)
	if !pressed:
		for i in [left, right, up, down]: i.modulate = Color.white

func _handle_dragging(i:InputEvent):
	._handle_dragging(i)
	var delta := _get_delta(i)
	var adjusted_dead_zone := dead_zone * radius
	for i in [left, right, up, down]: i.modulate = Color.white
	if diagonals_enabled:
		if delta.x >= adjusted_dead_zone:
			right.modulate = pressed_tint
		elif delta.x <= -adjusted_dead_zone:
			left.modulate = pressed_tint
		if delta.y >= adjusted_dead_zone:
			down.modulate = pressed_tint
		elif delta.y <= -adjusted_dead_zone:
			up.modulate = pressed_tint
	else:
		if delta.x >= adjusted_dead_zone:
			right.modulate = pressed_tint
		elif delta.x <= -adjusted_dead_zone:
			left.modulate = pressed_tint
		elif delta.y >= adjusted_dead_zone:
			down.modulate = pressed_tint
		elif delta.y <= -adjusted_dead_zone:
			up.modulate = pressed_tint

func _get_strength(amount:float, adjusted_dead_zone:float, adjusted_max_zone:float) -> float:
	return 1.0
