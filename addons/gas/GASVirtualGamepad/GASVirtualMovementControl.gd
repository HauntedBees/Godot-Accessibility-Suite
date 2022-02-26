tool
extends GASVirtualControl
class_name GASVirtualMovementControl

export(String) var action_left := "ui_left"
export(String) var action_right := "ui_right"
export(String) var action_up := "ui_up"
export(String) var action_down := "ui_down"

export(float) var dead_zone := 0.15
export(float) var max_zone := 0.8
export(bool) var fixed_position := true setget _set_fixed_position
func _set_fixed_position(p:bool):
	fixed_position = p
	visible = Engine.editor_hint || fixed_position

var pressed := false
var press_idx := 0
var center := Vector2.ZERO
var initial_position := Vector2.ZERO
var radius := 1.0

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
		if !fixed_position: visible = false

func _handle_dragging(i:InputEvent):
	var my_idx:int = i.index if (i is InputEventScreenTouch || i is InputEventScreenDrag) else 0
	if !pressed || my_idx != press_idx: return
	var delta:Vector2 = _get_delta(i)#i.position - initial_position - front.rect_size / 2.0
	var adjusted_dead_zone := dead_zone * radius
	var adjusted_max_zone := max_zone * radius
	if delta.length() > adjusted_max_zone: delta = delta.normalized() * adjusted_max_zone
	#front.rect_position = center + delta
	
	if delta.x >= adjusted_dead_zone:
		Input.action_release(action_left)
		Input.action_press(action_right, _get_strength(delta.x, adjusted_dead_zone, adjusted_max_zone))
	elif delta.x <= -adjusted_dead_zone:
		Input.action_press(action_left, _get_strength(delta.x, adjusted_dead_zone, adjusted_max_zone))
		Input.action_release(action_right)
	else:
		Input.action_release(action_left)
		Input.action_release(action_right)
	
	if delta.y >= adjusted_dead_zone:
		Input.action_release(action_up)
		Input.action_press(action_down, _get_strength(delta.y, adjusted_dead_zone, adjusted_max_zone))
	elif delta.y <= -adjusted_dead_zone:
		Input.action_press(action_up, _get_strength(delta.y, adjusted_dead_zone, adjusted_max_zone))
		Input.action_release(action_down)
	else:
		Input.action_release(action_down)
		Input.action_release(action_up)

func _get_delta(i:InputEvent) -> Vector2: return i.position - initial_position
func _get_strength(amount:float, adjusted_dead_zone:float, adjusted_max_zone:float) -> float:
	var real_max := adjusted_max_zone - adjusted_dead_zone
	return min(1.0, (abs(amount) - adjusted_dead_zone) / real_max)
