extends ExampleSceneRoot

var _base_bird_pos: Vector2

@onready var _bird: TextureRect = %Bird

func _ready() -> void:
	_base_bird_pos = _bird.position

func _on_mouse_sens_value_changed(value: float) -> void:
	GASInput.mouse_sensitivity = value

func _on_joy_sens_value_changed(value: float) -> void:
	GASInput.joy_axis_sensitivity = value

func _process(delta: float) -> void:
	var dir := Vector2(
		GASInput.get_joy_axis(0, JOY_AXIS_LEFT_X),
		GASInput.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)
	_bird.position += dir * delta * 500.0

func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion := GASInput.mouse_motion_get_relative(event)
		_bird.position += motion

func _on_color_rect_mouse_exited() -> void:
	_bird.position = _base_bird_pos
