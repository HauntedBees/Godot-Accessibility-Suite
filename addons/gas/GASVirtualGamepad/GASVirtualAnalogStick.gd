@tool
extends GASVirtualMovementControl
class_name GASVirtualAnalogStick

@export var front_texture: Texture2D = preload("res://addons/gas/GASVirtualGamepad/Parts/analog_front.png"):
	set(v):
		front_texture = v
		if front != null:
			front.texture = v
@export var back_texture: Texture2D = preload("res://addons/gas/GASVirtualGamepad/Parts/analog_back.png"):
	set(v):
		back_texture = v
		if back != null:
			back.texture = v

var back:TextureRect = null
var front:TextureRect = null

func _ready():
	back = TextureRect.new()
	if back_texture != null: back.texture = back_texture
	add_child(back)
	front = TextureRect.new()
	front.mouse_filter = MOUSE_FILTER_IGNORE
	if front_texture != null: front.texture = front_texture
	back.gui_input.connect(_on_input)
	add_child(front)
	await get_tree().process_frame
	size = back.size
	_post_edit()
	_add_gizmo()
func _post_edit():
	if back == null || front == null: return
	center = back.position + (back.size - front.size) / 2.0
	front.position = center
	radius = back.size.x / 2.0 # TODO?: better support for oval wheels
	if edit_mode || Engine.is_editor_hint():
		visible = true
	else:
		visible = fixed_position

func _get_delta(i:InputEvent) -> Vector2: return i.position - initial_position - front.size / 2.0

func _standard_input(i:InputEvent):
	super._standard_input(i)
	if !pressed:
		front.position = center

func _handle_dragging(i:InputEvent):
	super._handle_dragging(i)
	var delta := _get_delta(i)
	var adjusted_max_zone := max_zone * radius
	if delta.length() > adjusted_max_zone: delta = delta.normalized() * adjusted_max_zone
	front.position = center + delta
