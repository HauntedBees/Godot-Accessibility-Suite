@tool
class_name GASDaisywheel extends Node2D

signal key_press(key: String)
signal backspace()

const _BASE_POSITION := Vector2(0.0, -320.0)
const _QTR_PI := PI / 4.0
const _PETAL_NODE := preload("res://addons/gas/virtual_keyboard/daisywheel/petal.tscn")
const _INFO_NODE := preload("res://addons/gas/virtual_keyboard/daisywheel/daisy_info.tscn")

enum { MAIN_MODE, CAPITAL_MODE, NUMERIC_MODE }

@export var gamepad_index := 0

@export var joystick_dead_zone := 0.5

@export var trigger_dead_zone := 0.5

@export var active := true:
	set(value):
		if active == value:
			return
		active = value
		visible = value
		_active_petal = null
		for p in _petals:
			p.deactivate()

@export_category("Values")

@export var main_set := "abcdefghijklmnopqrstuvwxyz?!.,-_":
	set(value):
		main_set = value
		_redraw()

@export var capital_set := "ABCDEFGHIJKLMNOPQRSTUVWXYZ;\\&@#+":
	set(value):
		capital_set = value
		_redraw()

@export var numeric_set := "0123456789*'=\":%(){}[]<>~`":
	set(value):
		numeric_set = value
		_redraw()

@export_category("Visuals")

@export var petal_texture: Texture2D:
	set(value):
		petal_texture = value
		_redraw()

@export var button_text_settings: LabelSettings:
	set(value):
		button_text_settings = value
		_redraw()

@export var button_texture: Texture2D:
	set(value):
		button_texture = value
		_redraw()

@export var button_left_color := Color.BLUE:
	set(value):
		button_left_color = value
		_redraw()

@export var button_top_color := Color.YELLOW:
	set(value):
		button_top_color = value
		_redraw()

@export var button_right_color := Color.RED:
	set(value):
		button_right_color = value
		_redraw()

@export var button_bottom_color := Color.GREEN:
	set(value):
		button_bottom_color = value
		_redraw()

@export var button_pressed_color := Color.AQUAMARINE:
	set(value):
		button_pressed_color = value
		_redraw()

@export var info_position_offset := Vector2.ZERO:
	set(value):
		info_position_offset = value
		_redraw()

var _mode := MAIN_MODE
var _petals: Array[GASDaisyPetal] = []
var _active_petal: GASDaisyPetal
var _redraw_queued := false
var _left_bumper_pressed := false
var _right_bumper_pressed := false
var _info_panel: Node2D

func _ready() -> void:
	_redraw()

func _redraw() -> void:
	if _redraw_queued:
		return
	_redraw_queued = true
	if !is_inside_tree():
		await ready
	_redraw_queued = false
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_petals = []
	for i in range(8):
		var p: GASDaisyPetal = _PETAL_NODE.instantiate()
		var my_angle := _QTR_PI * i
		p.position = _BASE_POSITION.rotated(my_angle)
		p.rotation = my_angle
		p.set_button_colors(button_left_color, button_top_color, button_right_color, button_bottom_color, button_pressed_color)
		if petal_texture:
			p.texture = petal_texture
		if button_texture:
			p.set_button_textures(button_texture)
		if button_text_settings:
			p.set_button_text_settings(button_text_settings)
		p.button_rotation = -my_angle
		p.pressed.connect(_on_receive_key)
		_petals.append(p)
		add_child(p)
	_set_characters(MAIN_MODE, true)
	_info_panel = _INFO_NODE.instantiate()
	_info_panel.position = Vector2(0.0, 550.0) + info_position_offset
	add_child(_info_panel)

func _on_receive_key(key: String) -> void:
	if !active:
		return
	GASInput.simulate_keycode_press(key.unicode_at(0))
	key_press.emit(key)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if !active || event is not InputEventJoypadButton:
		return
	match (event as InputEventJoypadButton).button_index:
		JOY_BUTTON_LEFT_SHOULDER:
			_set_characters(NUMERIC_MODE if event.pressed else MAIN_MODE)
		JOY_BUTTON_RIGHT_SHOULDER:
			_set_characters(CAPITAL_MODE if event.pressed else MAIN_MODE)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_handle_bumpers()
	var coords := Vector2(
		Input.get_joy_axis(gamepad_index, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(gamepad_index, JOY_AXIS_LEFT_Y)
	)
	coords.x = 0.0 if (abs(coords.x) < joystick_dead_zone) else (sign(coords.x) * 1.0)
	coords.y = 0.0 if (abs(coords.y) < joystick_dead_zone) else (sign(coords.y) * 1.0)
	var new_active_petal: GASDaisyPetal = null
	if coords.length() > 0:
		var angle := -coords.angle_to(Vector2(0, -1))
		var angle_idx := floori(angle / _QTR_PI)
		if angle_idx < 0:
			angle_idx = 9 + angle_idx
		if angle_idx >= 0 && angle_idx < _petals.size():
			new_active_petal = _petals[angle_idx]
	if _active_petal == new_active_petal:
		return
	if _active_petal != null:
		_active_petal.deactivate()
	_active_petal = new_active_petal
	if _active_petal != null:
		_active_petal.activate()

func _handle_bumpers() -> void:
	var backspace_pressed := Input.get_joy_axis(gamepad_index, JOY_AXIS_TRIGGER_LEFT)
	if backspace_pressed >= trigger_dead_zone:
		if !_left_bumper_pressed:
			_left_bumper_pressed = true
			GASInput.simulate_keycode_press(KEY_BACKSPACE)
			backspace.emit()
	else:
		_left_bumper_pressed = false
	var space_pressed := Input.get_joy_axis(gamepad_index, JOY_AXIS_TRIGGER_RIGHT)
	if space_pressed >= trigger_dead_zone:
		if !_right_bumper_pressed:
			_right_bumper_pressed = true
			GASInput.simulate_keycode_press(KEY_SPACE)
			key_press.emit(" ")
	else:
		_right_bumper_pressed = false

func _set_characters(new_mode: int, force := false):
	if _mode == new_mode && !force:
		return
	_mode = new_mode
	var arr := ""
	match _mode:
		MAIN_MODE: arr = main_set
		CAPITAL_MODE: arr = capital_set
		NUMERIC_MODE: arr = numeric_set
	var arr_size := arr.length()
	for i in range(8):
		var inner_arr: Array[String] = []
		for j in range(4):
			var idx := i * 4 + j
			if idx < arr_size:
				inner_arr.append(arr[idx])
			else:
				inner_arr.append("")
		_petals[i].button_characters = inner_arr
