extends Node

# https://gameaccessibilityguidelines.com/allow-controls-to-be-remapped-reconfigured/
func remap_action(action: String, event: InputEvent):
	var existing_mappings := InputMap.action_get_events(action)
	var is_button:bool = event is InputEventJoypadButton
	var is_motion:bool = event is InputEventJoypadMotion
	for mapping in existing_mappings:
		var is_mapping_button_or_joy:bool = mapping is InputEventJoypadMotion || mapping is InputEventJoypadButton
		if is_motion && is_mapping_button_or_joy:
			InputMap.action_erase_event(action, mapping)
			event.axis_value = 1 if event.axis_value > 0 else -1
			InputMap.action_add_event(action, event)
		elif is_button && is_mapping_button_or_joy:
			InputMap.action_erase_event(action, mapping)
			InputMap.action_add_event(action, event)
		elif !is_button && !is_motion && mapping is InputEventKey:
			InputMap.action_erase_event(action, mapping)
			InputMap.action_add_event(action, event)

# https://gameaccessibilityguidelines.com/include-a-cool-down-period-post-acceptance-delay-of-0-5-seconds-between-inputs/
var active_input_cooldowns := {}
func is_action_just_pressed(s: String) -> bool:
	if !Input.is_action_just_pressed(s): return false
	if !GASConfig.input_cooldown_enabled: return true
	if active_input_cooldowns.has(s): return false
	active_input_cooldowns[s] = GASConfig.input_cooldown_length
	return true

var active_toggle_actions := []
func _process(delta: float) -> void:
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

func _input(event: InputEvent):
	# https://gameaccessibilityguidelines.com/avoid-provide-alternatives-to-requiring-buttons-to-be-held-down/
	for action in active_toggle_actions:
		if event.is_action_pressed(action):
			active_toggle_actions.erase(action)
			Input.action_release(action)
			#get_tree().set_input_as_handled()
			return

func get_actions_as_json() -> String:
	return JSON.new().stringify(get_actions_as_dictionary())
func get_actions_as_dictionary() -> Dictionary:
	var actions := {}
	var action_list := InputMap.get_actions()
	for action_name in action_list:
		var action_inputs := []
		for action in InputMap.action_get_events(action_name):
			if action is InputEventKey:
				action_inputs.append("InputEventKey,%s" % action.scancode)
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

func restore_actions_from_json(json: String):
	var test_json_conv = JSON.new()
	test_json_conv.parse(json)
	restore_actions_from_dictionary(test_json_conv.get_data())
func restore_actions_from_dictionary(actions: Dictionary):
	for action_name in actions.keys():
		InputMap.action_erase_events(action_name)
		var split_type: Array = String(actions[action_name]).split(",")
		match split_type[0]:
			"InputEventKey":
				var event := InputEventKey.new()
				event.button_pressed = true
				event.scancode = int(split_type[1])
				InputMap.action_add_event(action_name, event)
			"InputEventMouseButton":
				var event := InputEventMouseButton.new()
				event.button_pressed = true
				event.button_index = int(split_type[1])
				InputMap.action_add_event(action_name, event)
			"InputEventJoypadButton":
				var event := InputEventJoypadButton.new()
				event.button_pressed = true
				event.button_index = int(split_type[1])
				InputMap.action_add_event(action_name, event)
			"InputEventJoypadMotion":
				var event := InputEventJoypadMotion.new()
				event.button_pressed = true
				event.axis = int(split_type[1])
				event.axis_value = float(split_type[2])
				InputMap.action_add_event(action_name, event)
