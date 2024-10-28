@tool
class_name GASVirtualDPad extends GASVirtualMovementControl

@export var left_texture: Texture2D = preload("res://addons/gas/virtual_gamepad/parts/dpad1.png"):
	set(t):
		left_texture = t
		if left != null:
			left.texture = t
@export var right_texture: Texture2D = preload("res://addons/gas/virtual_gamepad/parts/dpad2.png"):
	set(t):
		right_texture = t
		if right != null:
			right.texture = t
@export var up_texture: Texture2D = preload("res://addons/gas/virtual_gamepad/parts/dpad0.png"):
	set(t):
		up_texture = t
		if up != null:
			up.texture = t
@export var down_texture: Texture2D = preload("res://addons/gas/virtual_gamepad/parts/dpad3.png"):
	set(t):
		down_texture = t
		if down != null:
			down.texture = t

@export var button_distance := 5.0:
	set(b):
		button_distance = b
		_position_directions()

## The color the button should be tinted when it's pressed
@export var pressed_tint := Color.DARK_GRAY

var left: TextureRect = null
var right: TextureRect = null
var up: TextureRect = null
var down: TextureRect = null

func _ready() -> void:
	left = TextureRect.new()
	if left_texture != null:
		left.texture = left_texture
	add_child(left)

	right = TextureRect.new()
	if right_texture != null:
		right.texture = right_texture
	add_child(right)

	up = TextureRect.new()
	if up_texture != null:
		up.texture = up_texture
	add_child(up)

	down = TextureRect.new()
	if down_texture != null:
		down.texture = down_texture
	add_child(down)

	gui_input.connect(_on_input)
	await get_tree().process_frame

	_position_directions()
	_post_edit()
	_add_gizmo()

func _position_directions() -> void:
	if left == null:
		return
	left.position = Vector2(-left.size.x - button_distance, -left.size.y / 2.0)
	right.position = Vector2(button_distance, -right.size.y / 2.0)
	up.position = Vector2(-up.size.x / 2.0, -up.size.y - button_distance)
	down.position = Vector2(-down.size.x / 2.0, button_distance)
	size = Vector2(left.size.x + right.size.x + 2.0 * button_distance, up.size.y + down.size.y + 2.0 * button_distance)
	center = size / 2.0
	radius = center.x # TODO?: better support for rectangle d-pads
	for i in [left, right, up, down]:
		i.position += size / 2.0

func _standard_input(i: InputEvent) -> void:
	super._standard_input(i)
	if !pressed:
		for d in [left, right, up, down]:
			d.modulate = Color.WHITE

func _handle_dragging(i: InputEvent) -> void:
	super._handle_dragging(i)
	var delta := _get_delta(i)
	var adjusted_dead_zone := dead_zone * radius
	for d in [left, right, up, down]:
		d.modulate = Color.WHITE
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

func _get_strength(amount: float, adjusted_dead_zone: float, adjusted_max_zone: float) -> float:
	return 1.0
