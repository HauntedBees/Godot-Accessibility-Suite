@tool
class_name GASDaisyPetal extends Sprite2D

const _INDICES: Array[int] = [JOY_BUTTON_X, JOY_BUTTON_Y, JOY_BUTTON_B, JOY_BUTTON_A]

signal pressed(key: String)

@export var button_characters: Array[String] = []:
	set(value):
		button_characters = value
		if !is_inside_tree():
			await ready
		while button_characters.size() < 4:
			button_characters.append("")
		_buttons[0].text = button_characters[0]
		_buttons[1].text = button_characters[1]
		_buttons[2].text = button_characters[2]
		_buttons[3].text = button_characters[3]

@export var button_rotation := 0.0:
	set(value):
		button_rotation = value
		if !is_inside_tree():
			await ready
		_button_set.rotation = value

@export var active := false: set = _set_active

@onready var _button_set: Node2D = %ButtonSet
@onready var _buttons: Array[GASDaisyPetalButton] = [%Left, %Top, %Right, %Bottom]

func _input(event: InputEvent) -> void:
	if !active || event is not InputEventJoypadButton:
		return
	var idx := _INDICES.find((event as InputEventJoypadButton).button_index)
	if idx < 0 || idx >= _buttons.size():
		return
	_buttons[idx].pressed = event.pressed
	if !event.pressed:
		return
	var val := button_characters[idx]
	if val != "":
		pressed.emit(val)

func set_button_colors(left: Color, top: Color, right: Color, bottom: Color, pressed_color: Color) -> void:
	if !is_inside_tree():
		await ready
	_buttons[0].button_color = left
	_buttons[1].button_color = top
	_buttons[2].button_color = right
	_buttons[3].button_color = bottom
	for b in _buttons:
		b.pressed_color = pressed_color

func set_button_textures(tex: Texture) -> void:
	if !is_inside_tree():
		await ready
	for b in _buttons:
		b.texture = tex

func set_button_text_settings(settings: LabelSettings) -> void:
	if !is_inside_tree():
		await ready
	for b in _buttons:
		b.label_settings = settings

func activate() -> void:
	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.25)
	tween.tween_property(self, "z_index", 10, 0.25)
	for b in _buttons:
		tween.tween_property(b, "button_alpha", 1.0, 0.25)
	tween.set_parallel(false)
	tween.tween_callback(_set_active.bind(true))

func deactivate() -> void:
	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.25)
	tween.tween_property(self, "z_index", 0, 0.25)
	for b in _buttons:
		tween.tween_property(b, "button_alpha", 0.0, 0.25)
	tween.set_parallel(false)
	tween.tween_callback(_set_active.bind(false))

func _set_active(value: bool) -> void:
	active = value
	if !is_inside_tree():
		await ready
	for bt in _buttons:
		bt.button_active = value
		if !active:
			bt.pressed = false
