extends ExampleSceneRoot

var _base_bird_pos: Vector2

@onready var _bird: TextureRect = %Bird

func _ready() -> void:
	_base_bird_pos = _bird.position

func _on_mouse_sens_value_changed(value: float) -> void:
	GASInput.mouse_sensitivity = value

func _on_joy_sens_value_changed(value: float) -> void:
	GASInput.joy_axis_sensitivity = value

# TODO: get_action_raw_strength, get_action_strength, get_axis, get_joy_axis
# get_last_mouse_screen_velocity, get_last_mouse_velocity, get_vector

#func _input(event: InputEvent) -> void:
	#if event is InputEventJoypadMotion:
		#var motion := 10.0 * GASInput.joypad_motion_get_axis_value(event)
		#match (event as InputEventJoypadMotion).axis:
			#JOY_AXIS_LEFT_X: _bird.position.x += motion
			#JOY_AXIS_LEFT_Y: _bird.position.y += motion

func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion := GASInput.mouse_motion_get_relative(event)
		_bird.position += motion

func _on_color_rect_mouse_exited() -> void:
	_bird.position = _base_bird_pos
