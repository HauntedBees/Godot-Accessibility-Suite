tool
extends GASVirtualMovementControl
class_name GASVirtualAnalogStick

export(Texture) var front_texture:Texture = preload("res://addons/gas/GASVirtualGamepad/Parts/analog_front.png") setget _set_front_texture
func _set_front_texture(t:Texture):
	front_texture = t
	if front != null: front.texture = t
export(Texture) var back_texture:Texture = preload("res://addons/gas/GASVirtualGamepad/Parts/analog_back.png") setget _set_back_texture
func _set_back_texture(t:Texture):
	back_texture = t
	if back != null: back.texture = t

var back:TextureRect = null
var front:TextureRect = null

func _ready():
	back = TextureRect.new()
	if back_texture != null: back.texture = back_texture
	add_child(back)
	front = TextureRect.new()
	front.mouse_filter = MOUSE_FILTER_IGNORE
	if front_texture != null: front.texture = front_texture
	back.connect("gui_input", self, "_on_input")
	add_child(front)
	yield(get_tree(), "idle_frame")
	rect_size = back.rect_size
	_post_edit()
	_add_gizmo()
func _post_edit():
	if back == null || front == null: return
	center = back.rect_position + (back.rect_size - front.rect_size) / 2.0
	front.rect_position = center
	radius = back.rect_size.x / 2.0 # TODO?: better support for oval wheels
	if edit_mode || Engine.editor_hint:
		visible = true
	else:
		visible = fixed_position

func _get_delta(i:InputEvent) -> Vector2: return i.position - initial_position - front.rect_size / 2.0

func _standard_input(i:InputEvent):
	._standard_input(i)
	if !pressed:
		front.rect_position = center

func _handle_dragging(i:InputEvent):
	._handle_dragging(i)
	var delta := _get_delta(i)
	var adjusted_max_zone := max_zone * radius
	if delta.length() > adjusted_max_zone: delta = delta.normalized() * adjusted_max_zone
	front.rect_position = center + delta
