@tool
class_name GASVirtualControl extends Control

## This should be set by the developer; when true, players can make this
## input toggle-able, which is desirable for movement controls and buttons
## that are likely to be held down or pressed repeatedly. It is not recommended
## for actions that should not be executed repeatedly, like a Pause button or
## a "talk to the character in front of you or advance the dialog" button.
@export var can_be_toggled := true

## A default value can be set by the developer but this will be configurable
## by players in Edit Mode if can_be_toggled is true.
@export var is_toggle := false

var is_mobile := OS.has_feature("mobile")
var gizmo:GASVirtualGizmo = null
var edit_mode := false:
	set(e):
		edit_mode = e
		if e:
			visible = true
		gizmo.visible = e
		_post_edit()

func _is_valid_press_release(i: InputEvent) -> bool:
	if is_mobile: return i is InputEventScreenTouch
	else: return i is InputEventMouseButton
func _is_valid_drag(i: InputEvent) -> bool:
	if is_mobile: return i is InputEventScreenDrag
	else: return i is InputEventMouseMotion
func _get_index(i: InputEvent) -> int:
	return i.index if (i is InputEventScreenTouch || i is InputEventScreenDrag) else 0

func _add_gizmo() -> void:
	gizmo = GASVirtualGizmo.new()
	add_child(gizmo)
	gizmo.visible = edit_mode
func _post_edit() -> void: pass

var config:
	get:
		var d := {
			"anchor": [anchor_top, anchor_left, anchor_right, anchor_bottom],
			"margin": [offset_top, offset_left, offset_right, offset_bottom],
			"position": position,
			"scale": scale,
			"toggle": is_toggle,
			"can_be_toggled": can_be_toggled
		}
		return _inner_get_config(d)
	set(c):
		if c == null:
			return
		anchor_top = c["anchor"][0]
		anchor_left = c["anchor"][1]
		anchor_right = c["anchor"][2]
		anchor_bottom = c["anchor"][3]
		offset_top = c["margin"][0]
		offset_left = c["margin"][1]
		offset_right = c["margin"][2]
		offset_bottom = c["margin"][3]
		position = c["position"]
		scale = c["scale"]
		is_toggle = c["toggle"]
		can_be_toggled = c["can_be_toggled"]
		_inner_set_config(c)

func _inner_get_config(d: Dictionary) -> Dictionary: return d
func _inner_set_config(c: Dictionary) -> void: pass

func _on_input(i: InputEvent) -> void: pass

## Sometimes lifting the finger doesn't work quite right and things get fucky,
## so this _unhandled_input is to ensure that lifting a finger up always registers.
## TODO: figure out a better way of handling this? or maybe this IS how to handle it.
func _unhandled_input(i: InputEvent) -> void:
	if i is not InputEventScreenTouch:
		return
	if i.pressed:
		return
	_on_input(i)
