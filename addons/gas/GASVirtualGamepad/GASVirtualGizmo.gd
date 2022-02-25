tool
class_name GASVirtualGizmo
extends Control

const EPSILON := 2.0
const SCALE_RATIO := 0.01
const MIN_SCALE := 0.5
var size_texture:Texture = preload("res://addons/gas/GASVirtualGamepad/Parts/resize.png")
var move_texture:Texture = preload("res://addons/gas/GASVirtualGamepad/Parts/reposition.png")

onready var p:Control = get_parent()
var resize_x:TextureButton
var resize_y:TextureButton
var move:TextureButton
var border:ReferenceRect

enum { NONE, MOVE, SCALE_X, SCALE_Y }
var cursor_state := NONE

var button_just_pressed := false
var cursor_index := 0
var cursor_offset := Vector2.ZERO

func _ready():
	border = ReferenceRect.new()
	border.border_color = Color.purple
	border.border_width = 3.0
	border.editor_only = false
	border.rect_position = Vector2.ZERO
	border.rect_size = p.rect_size # TODO: probably won't work with scaling innit
	add_child(border)
	
	resize_x = TextureButton.new()
	resize_x.texture_normal = size_texture
	resize_x.rect_size = Vector2(48, 48)
	resize_x.rect_pivot_offset = resize_x.rect_size / 2
	resize_x.rect_rotation = 90
	resize_x.connect("button_down", self, "_begin_action", [SCALE_X])
	resize_x.connect("button_up", self, "_end_action")
	add_child(resize_x)
	
	resize_y = TextureButton.new()
	resize_y.texture_normal = size_texture
	resize_y.rect_size = Vector2(48, 48)
	resize_y.rect_pivot_offset = resize_y.rect_size / 2
	resize_y.connect("button_down", self, "_begin_action", [SCALE_Y])
	resize_y.connect("button_up", self, "_end_action")
	add_child(resize_y)
	
	move = TextureButton.new()
	move.texture_normal = move_texture
	move.rect_size = Vector2(64, 64)
	move.rect_pivot_offset = resize_x.rect_size / 2
	move.connect("button_down", self, "_begin_action", [MOVE])
	move.connect("button_up", self, "_end_action")
	add_child(move)
	
	_align_gizmo()

func _align_gizmo():
	move.rect_scale = Vector2(1, 1) / p.rect_scale
	resize_x.rect_scale = Vector2(1, 1) / Vector2(p.rect_scale.y, p.rect_scale.x)
	resize_y.rect_scale = Vector2(1, 1) / p.rect_scale
	resize_x.rect_position = Vector2(p.rect_size.x, p.rect_size.y / 2.0) - resize_x.rect_size / 2.0
	resize_y.rect_position = Vector2(p.rect_size.x / 2.0, p.rect_size.y) - resize_y.rect_size / 2.0
	# TODO: move.rect_position does NOT appear in the center when scaled
	move.rect_position = Vector2(p.rect_size.x / 2.0, p.rect_size.y / 2.0) - move.rect_size / 2.0

func _begin_action(action):
	button_just_pressed = true
	cursor_state = action
func _end_action(): cursor_state = NONE

func _input(event):
	match cursor_state:
		MOVE: _handle_move(event)
		SCALE_X, SCALE_Y: _handle_scale(event, cursor_state)

func _handle_move(event):
	if !(event is InputEventMouseMotion || event is InputEventScreenTouch): return
	if !_configure_on_just_pressed_and_return_if_valid(event): return
	var delta:Vector2 = event.position - cursor_offset
	if delta.length() < EPSILON: return # don't move things around for tiny finger wiggles
	p.rect_position += delta
	cursor_offset = event.position

func _handle_scale(event, dir):
	if !(event is InputEventMouseMotion || event is InputEventScreenTouch): return
	if !_configure_on_just_pressed_and_return_if_valid(event): return
	var delta:Vector2 = event.position - cursor_offset
	var delta_dir := Vector2(delta.x if cursor_state == SCALE_X else 0, delta.y if cursor_state == SCALE_Y else 0)
	if delta_dir.length() < EPSILON: return # don't move things around for tiny finger wiggles
	p.rect_scale += delta_dir * SCALE_RATIO
	if p.rect_scale.x < MIN_SCALE: p.rect_scale.x = MIN_SCALE
	if p.rect_scale.y < MIN_SCALE: p.rect_scale.y = MIN_SCALE
	cursor_offset = event.position
	_align_gizmo()

func _configure_on_just_pressed_and_return_if_valid(event) -> bool:
	if button_just_pressed:
		button_just_pressed = false
		cursor_offset = event.position
		if event is InputEventScreenTouch:
			cursor_index = event.index
		return false
	elif event is InputEventScreenTouch && event.index != cursor_index:
		return false
	return true
