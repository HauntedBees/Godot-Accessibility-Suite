@tool
class_name GASVirtualMovementControl extends GASVirtualControl

signal reset_dynamic_movement

@export var action_left := "ui_left"
@export var action_right := "ui_right"
@export var action_up := "ui_up"
@export var action_down := "ui_down"

## Probably not a good idea to set this to false for analog sticks. That's what d-pads are for.
@export var diagonals_enabled := true

@export var dead_zone := 0.15
@export var max_zone := 0.8
@export var fixed_position := true:
	set(p):
		fixed_position = p
		visible = Engine.is_editor_hint() || edit_mode || fixed_position
		if gizmo != null && gizmo.dynamic_toggle != null:
			gizmo.dynamic_toggle.button_pressed = !fixed_position

var pressed := false
var press_idx := 0
var center := Vector2.ZERO
var initial_position := Vector2.ZERO
var radius := 1.0
var current_action := "" # only used when diagonals_enabled == false

func _on_input(i: InputEvent) -> void:
	if !edit_mode:
		_standard_input(i)

func _standard_input(i: InputEvent) -> void:
	if _is_valid_drag(i):
		_handle_dragging(i)
	if !_is_valid_press_release(i):
		return
	var is_pressed := (i as InputEventMouseButton).pressed
	var my_idx := _get_index(i)
	if is_pressed: press_idx = my_idx
	elif press_idx != my_idx:
		return

	if is_toggle:
		if is_pressed: ## For toggle buttons, pressing the button will toggle its pressed state
			pressed = !pressed
		else:
			return
	else: ## For regular buttons, pressing/releasing the button will set the pressed state accordingly
		pressed = is_pressed

	if pressed:
		press_idx = my_idx
		initial_position = center
		if !fixed_position: visible = true
		_handle_dragging(i)
	else:
		Input.action_release(action_left)
		Input.action_release(action_right)
		Input.action_release(action_up)
		Input.action_release(action_down)
		if !fixed_position: visible = false

func _handle_dragging(i: InputEvent) -> void:
	var my_idx := _get_index(i)
	if !pressed || my_idx != press_idx:
		return
	var delta := _get_delta(i)
	var adjusted_dead_zone := dead_zone * radius
	var adjusted_max_zone := max_zone * radius
	if delta.length() > adjusted_max_zone: delta = delta.normalized() * adjusted_max_zone

	if diagonals_enabled:
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
	else:
		var highest_delta := 0.0
		var new_direction := ""
		if delta.x >= adjusted_dead_zone && delta.x > highest_delta:
			new_direction = action_right
			highest_delta = delta.x
		elif delta.x <= -adjusted_dead_zone && delta.x < -highest_delta:
			new_direction = action_left
			highest_delta = -delta.x
		elif delta.y >= adjusted_dead_zone && delta.y > highest_delta:
			new_direction = action_down
			highest_delta = delta.y
		elif delta.y <= -adjusted_dead_zone && delta.y < -highest_delta:
			new_direction = action_up
			highest_delta = -delta.y

		if current_action != "": Input.action_release(current_action)
		current_action = new_direction
		Input.action_press(current_action, _get_strength(highest_delta, adjusted_dead_zone, adjusted_max_zone))

func _get_delta(i: InputEvent) -> Vector2:
	return i.position - initial_position

func _get_strength(amount: float, adjusted_dead_zone: float, adjusted_max_zone: float) -> float:
	var real_max := adjusted_max_zone - adjusted_dead_zone
	return min(1.0, (abs(amount) - adjusted_dead_zone) / real_max)
