@tool
class_name GASInputMapDisplayBase extends MarginContainer

signal selected(me: GASInputMapDisplayBase)

@export var display_name: String: set = _set_display_name
@export var input_action: String: set = _set_input_action

var display_type: GASActionConfig.DisplayType


func _ready() -> void:
	GASInput.input_method_changed.connect(refresh_icon)

func refresh_icon() -> void:
	_set_input_action(input_action)

func get_texture() -> Texture2D:
	printerr("You should implement this if you're making your own input display!")
	return PlaceholderTexture2D.new()

func _set_display_name(v: String) -> void:
	display_name = v

func _set_input_action(v: String) -> void:
	input_action = v

func _get_icon(action_key: String) -> Vector2:
	var action: InputEvent = _get_appropriate_input_event(action_key)
	return get_offset_from_input(action)

func get_offset_from_input(action: InputEvent) -> Vector2:
	var idx := 0
	if action == null:
		idx = 208
	elif action is InputEventMouseButton:
		var am := action as InputEventMouseButton
		if am.button_index > 8:
			idx = 10
		else:
			idx = 2 + am.button_index
	elif action is InputEventKey:
		var ak := action as InputEventKey
		if ak.keycode >= 4194304:
			idx = 68 + ak.keycode - 4194304
		else:
			idx = ak.keycode - 32
	elif action is InputEventJoypadButton:
		var ab := action as InputEventJoypadButton
		if ab.button_index > 15:
			idx = 31
		else:
			var joy_name := Input.get_joy_name(0).to_lower()
			idx = 128 + ab.button_index + _get_console_offset(joy_name, ab.button_index > 10)
	elif action is InputEventJoypadMotion:
		var am := action as InputEventJoypadMotion
		idx = 192
		var joy_name := Input.get_joy_name(0).to_lower()
		match am.axis:
			JOY_AXIS_LEFT_X: idx += 4 if sign(am.axis_value) < 0 else 6
			JOY_AXIS_LEFT_Y: idx += 5 if sign(am.axis_value) < 0 else 7
			JOY_AXIS_RIGHT_X: idx += 8 if sign(am.axis_value) < 0 else 10
			JOY_AXIS_RIGHT_Y: idx += 9 if sign(am.axis_value) < 0 else 11
			JOY_AXIS_TRIGGER_LEFT: idx += 12 + _get_console_offset(joy_name, false)
			JOY_AXIS_TRIGGER_RIGHT: idx += 13 + _get_console_offset(joy_name, false)
	return Vector2(128 * (idx % 16), 128 * floor(idx / 16.0))

func _get_first_action(action_key: String, prefer_gamepad: bool) -> InputEvent:
	var actions := InputMap.action_get_events(action_key)
	for a in actions:
		var is_gamepad := a is InputEventJoypadMotion || a is InputEventJoypadButton
		if (is_gamepad && prefer_gamepad) || (!is_gamepad && !prefer_gamepad):
			return a
	return null

func _get_appropriate_input_event(action_name: String) -> InputEvent:
	var actions := InputMap.action_get_events(action_name)
	if actions.size() == 0:
		return null
	var using_joypad := false
	match display_type:
		GASActionConfig.DisplayType.ForceJoypad: using_joypad = true
		GASActionConfig.DisplayType.ForceKeyboard: using_joypad = false
		_: using_joypad = Engine.is_editor_hint() || GASInput.get_last_input_method() == GASInput.InputMethodType.Joypad
	for a in actions:
		if using_joypad && (a is InputEventJoypadButton || a is InputEventJoypadMotion):
			return a
		elif !using_joypad && (a is InputEventKey || a is InputEventMouseButton):
			return a
	return actions[0]

func _get_console_offset(joy_name: String, joycon_different_icon: bool) -> int:
	if joy_name.begins_with("ps4") || joy_name.begins_with("ps5") || joy_name.find("sony") >= 0 || joy_name.find("dualshock") >= 0:
		return 16
	elif joy_name.find("nintendo") >= 0 || joy_name.find("pro controller") >= 0:
		return 32
	elif joy_name.find("joycon") >= 0:
		return 48 if joycon_different_icon else 32
	return 0
