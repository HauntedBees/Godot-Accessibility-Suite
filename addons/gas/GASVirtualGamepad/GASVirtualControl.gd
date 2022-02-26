tool
extends Control
class_name GASVirtualControl

## This should be set by the developer; when true, players can make this
## input toggle-able, which is desirable for movement controls and buttons
## that are likely to be held down or pressed repeatedly. It is not recommended
## for actions that should not be executed repeatedly, like a Pause button or
## a "talk to the character in front of you or advance the dialog" button.
export(bool) var can_be_toggled := true

## A default value can be set by the developer but this will be configurable
## by players in Edit Mode if can_be_toggled is true.
## TODO: make this editable in edit mode
export(bool) var is_toggle := false

var gizmo:GASVirtualGizmo = null
var edit_mode := false setget _set_edit_mode
func _set_edit_mode(e:bool):
	edit_mode = e
	visible = true
	gizmo.visible = e
	_post_edit()

func _add_gizmo():
	gizmo = GASVirtualGizmo.new()
	add_child(gizmo)
	gizmo.visible = edit_mode
func _post_edit(): pass

var config setget _set_config, _get_config
func _get_config() -> Dictionary:
	var d := {
		"anchor": [anchor_top, anchor_left, anchor_right, anchor_bottom],
		"margin": [margin_top, margin_left, margin_right, margin_bottom],
		"position": rect_position,
		"scale": rect_scale,
		"toggle": is_toggle,
		"can_be_toggled": can_be_toggled
	}
	return _inner_get_config(d)
func _inner_get_config(d:Dictionary) -> Dictionary: return d
func _set_config(c:Dictionary):
	if c == null: return
	anchor_top = c["anchor"][0]
	anchor_left = c["anchor"][1]
	anchor_right = c["anchor"][2]
	anchor_bottom = c["anchor"][3]
	margin_top = c["margin"][0]
	margin_left = c["margin"][1]
	margin_right = c["margin"][2]
	margin_bottom = c["margin"][3]
	rect_position = c["position"]
	rect_scale = c["scale"]
	is_toggle = c["toggle"]
	can_be_toggled = c["can_be_toggled"]
	_inner_set_config(c)
func _inner_set_config(c:Dictionary): pass

func _on_input(i:InputEvent): pass
## Sometimes lifting the finger doesn't work quite right and things get fucky,
## so this _unhandled_input is to ensure that lifting a finger up always registers.
## TODO: figure out a better way of handling this? or maybe this IS how to handle it.
func _unhandled_input(i:InputEvent):
	if !(i is InputEventScreenTouch): return
	if i.pressed: return
	_on_input(i)
