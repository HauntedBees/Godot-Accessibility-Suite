extends Node

signal input_method_changed(new_method: InputMethodType)
signal virtual_mouse_toggled(enabled: bool)

enum InputMethodType { Joypad, Keyboard }

#var using_virtual_cursor := false:
	#set(value):
		#using_virtual_cursor = value
		#virtual_mouse_toggled.emit(using_virtual_cursor)
		#if using_virtual_cursor:
			#_previous_mouse_mode = DisplayServer.mouse_get_mode()
			#DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CONFINED)
		#else:
			#DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)

var _last_input := InputMethodType.Keyboard
var _previous_mouse_mode := DisplayServer.MOUSE_MODE_VISIBLE
var _canvas_item: CanvasItem

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joypads_changed)
	_canvas_item = Control.new()
	_canvas_item.name = "GASInputHelper"
	add_child(_canvas_item)
	_canvas_item.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas_item.offset_left = 0
	_canvas_item.offset_right = 0
	_canvas_item.offset_bottom = 0
	_canvas_item.offset_top = 0

func get_last_input_method() -> InputMethodType:
	return _last_input

# https://gameaccessibilityguidelines.com/include-toggle-slider-for-any-haptics/
func start_joy_vibration(device: int, weak_magnitude: float, strong_magnitude: float, duration: float = 0) -> void:
	Input.start_joy_vibration(device, weak_magnitude * GASConfig.vibration_scale, strong_magnitude * GASConfig.vibration_scale, duration)
func vibrate_handheld(duration_ms: int = 500, amplitude: float = -1.0) -> void:
	Input.vibrate_handheld(duration_ms, amplitude * GASConfig.vibration_scale)

func is_click(i: InputEvent, button := MOUSE_BUTTON_LEFT) -> bool:
	var iemb := i as InputEventMouseButton
	if iemb == null:
		return false
	return iemb.button_index == button && iemb.pressed

func emit_signal_if_click(s: Signal, i: InputEvent, button := MOUSE_BUTTON_LEFT) -> void:
	if is_click(i, button):
		s.emit()

func get_vector2i(event: InputEvent) -> Vector2i:
	return Vector2i(
		_bool_to_int(event.is_action_pressed("ui_right")) - _bool_to_int(event.is_action_pressed("ui_left")),
		_bool_to_int(event.is_action_pressed("ui_down")) - _bool_to_int(event.is_action_pressed("ui_up"))
	)
func _bool_to_int(b: bool) -> int: return 1 if b else 0

# https://gameaccessibilityguidelines.com/allow-controls-to-be-remapped-reconfigured/
func remap_action(action: String, event: InputEvent) -> bool:
	var existing_mappings := InputMap.action_get_events(action)
	if existing_mappings == null || existing_mappings.size() == 0:
		return false
	var is_button := event is InputEventJoypadButton
	var is_motion := event is InputEventJoypadMotion
	for mapping in existing_mappings:
		var is_mapping_button_or_joy := mapping is InputEventJoypadMotion || mapping is InputEventJoypadButton
		if is_motion && is_mapping_button_or_joy:
			InputMap.action_erase_event(action, mapping)
			event.axis_value = 1 if event.axis_value > 0 else -1
			InputMap.action_add_event(action, event)
			return true
		elif is_button && is_mapping_button_or_joy:
			InputMap.action_erase_event(action, mapping)
			InputMap.action_add_event(action, event)
			return true
		elif mapping is InputEventKey && event is InputEventKey:
			InputMap.action_erase_event(action, mapping)
			InputMap.action_add_event(action, event)
			return true
	return false

# https://gameaccessibilityguidelines.com/include-a-cool-down-period-post-acceptance-delay-of-0-5-seconds-between-inputs/
var active_input_cooldowns := {}
func is_action_just_pressed(s: String) -> bool:
	if !Input.is_action_just_pressed(s):
		return false
	if !GASConfig.input_cooldown_enabled:
		return true
	if active_input_cooldowns.has(s):
		return false
	active_input_cooldowns[s] = GASConfig.input_cooldown_length
	return true

func is_event_action_just_pressed(input_event: InputEvent, action_name: String) -> bool:
	if !input_event.is_action_pressed(action_name, false):
		return false
	if !GASConfig.input_cooldown_enabled:
		return true
	if active_input_cooldowns.has(action_name):
		return false
	active_input_cooldowns[action_name] = GASConfig.input_cooldown_length
	return true

var active_toggle_actions := []
func _process(delta: float) -> void:
#	_handle_virtual_mouse(delta)

	# https://gameaccessibilityguidelines.com/include-a-cool-down-period-post-acceptance-delay-of-0-5-seconds-between-inputs/
	for action in active_input_cooldowns.keys():
		active_input_cooldowns[action] -= delta
		if active_input_cooldowns[action] <= 0:
			active_input_cooldowns.erase(action)

	# https://gameaccessibilityguidelines.com/avoid-provide-alternatives-to-requiring-buttons-to-be-held-down/
	for action in GASConfig.input_toggle_actions:
		var idx := active_toggle_actions.find(action)
		if Input.is_action_just_pressed(action) && idx < 0:
			active_toggle_actions.append(action)
		elif Input.is_action_just_released(action) && idx >= 0:
			Input.action_press(action) # TODO: how to prevent this from returning true checked another is_action_just_pressed?
			#get_tree().set_input_as_handled()

	#if is_action_just_pressed("action_virtual_mouse_toggle"):
		#using_virtual_cursor = !using_virtual_cursor

func _input(event: InputEvent):
	if event is InputEventKey:
		_try_change_input_type(InputMethodType.Keyboard)
	elif event is InputEventJoypadButton || event is InputEventJoypadMotion:
		_try_change_input_type(InputMethodType.Joypad)
	# https://gameaccessibilityguidelines.com/avoid-provide-alternatives-to-requiring-buttons-to-be-held-down/
	for action in active_toggle_actions:
		if event.is_action_pressed(action):
			active_toggle_actions.erase(action)
			Input.action_release(action)
			#get_tree().set_input_as_handled()
			return

### TODO: this is still broken
#func _handle_virtual_mouse(delta: float) -> void:
	#if !using_virtual_cursor:
		#return
	#var dir := Vector2.ZERO
	#if Input.is_action_pressed("action_virtual_mouse_up"):
		#dir.y = -1.0
	#elif Input.is_action_pressed("action_virtual_mouse_down"):
		#dir.y = 1.0
	#if Input.is_action_pressed("action_virtual_mouse_left"):
		#dir.x = -1.0
	#elif Input.is_action_pressed("action_virtual_mouse_right"):
		#dir.x = 1.0
	#if dir == Vector2.ZERO:
		#return
	#var vp := get_viewport()
	#var root := get_tree().root
	#var screen_size := root.size
	#var scale_size := root.content_scale_size
	#var ratio := Vector2(float(screen_size.x) / scale_size.x, float(screen_size.y) / scale_size.y)
	#var curr_pos := vp.get_mouse_position()
	#var transform := (vp.get_canvas_transform() * vp.get_screen_transform()).affine_inverse()
	#var new_pos := Vector2(
		#curr_pos.x,
		#curr_pos.y
		##(curr_pos.x + dir.x * delta * 10.0) * ratio.x,
		##(curr_pos.y + dir.y * delta * 10.0) * ratio.y
	#)
	#new_pos = curr_pos * transform
	##var t := vp.get_screen_transform() * vp.get_canvas_transform() * curr_pos
	##var canvas_pos := curr_pos * _canvas_item.get_global_transform()
	##var local_pos := _canvas_item.get_global_transform().affine_inverse() * canvas_pos
	##new_pos = vp.get_screen_transform() * _canvas_item.get_global_transform_with_canvas() * local_pos
	##new_pos += dir * delta * 10.0 # TODO: const
	##print(curr_pos)
	##print(new_pos)
	##print("---")
	#vp.warp_mouse(new_pos)# + dir * delta * 10.0) # TODO: const

func get_actions_as_json() -> String:
	return JSON.new().stringify(get_actions_as_dictionary())

func get_actions_as_dictionary() -> Dictionary[String, Array]:
	var actions: Dictionary[String, Array] = {}
	var action_list := InputMap.get_actions()
	for action_name in action_list:
		var action_inputs: Array[String] = []
		for action in InputMap.action_get_events(action_name):
			if action is InputEventKey:
				action_inputs.append("InputEventKey,%s" % action.keycode)
			elif action is InputEventMouseButton:
				var b: InputEventMouseButton = action
				action_inputs.append("InputEventMouseButton,%s" % b.button_index)
			elif action is InputEventJoypadButton:
				var b: InputEventJoypadButton = action
				action_inputs.append("InputEventJoypadButton,%s" % b.button_index)
			elif action is InputEventJoypadMotion:
				var b: InputEventJoypadMotion = action
				action_inputs.append("InputEventJoypadMotion,%s,%s" % [b.axis, b.axis_value])
		actions[action_name] = action_inputs
	return actions

func restore_actions_from_json(json: String) -> void:
	var test_json_conv := JSON.new()
	test_json_conv.parse(json)
	restore_actions_from_dictionary(test_json_conv.get_data())

func restore_actions_from_dictionary(actions: Dictionary) -> void:
	for action_name: String in actions.keys():
		InputMap.action_erase_events(action_name)
		for input_type: String in actions[action_name]:
			var split_type := input_type.split(",")
			match split_type[0]:
				"InputEventKey":
					var event := InputEventKey.new()
					event.pressed = true
					event.keycode = int(split_type[1])
					InputMap.action_add_event(action_name, event)
				"InputEventMouseButton":
					var event := InputEventMouseButton.new()
					event.pressed = true
					event.button_index = int(split_type[1])
					InputMap.action_add_event(action_name, event)
				"InputEventJoypadButton":
					var event := InputEventJoypadButton.new()
					event.pressed = true
					event.button_index = int(split_type[1])
					InputMap.action_add_event(action_name, event)
				"InputEventJoypadMotion":
					var event := InputEventJoypadMotion.new()
					event.axis = int(split_type[1])
					event.axis_value = float(split_type[2])
					InputMap.action_add_event(action_name, event)

func _on_joypads_changed(_device: int, connected: bool) -> void:
	if connected || Input.get_connected_joypads().size() > 0:
		_try_change_input_type(InputMethodType.Joypad)
	else:
		_try_change_input_type(InputMethodType.Keyboard)

func _try_change_input_type(i: InputMethodType) -> void:
	if _last_input == i:
		return
	_last_input = i
	input_method_changed.emit(i)
