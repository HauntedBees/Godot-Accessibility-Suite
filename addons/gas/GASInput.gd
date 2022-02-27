extends Node

# https://gameaccessibilityguidelines.com/allow-controls-to-be-remapped-reconfigured/
func remap_action(action:String, event:InputEvent):
	var existing_mappings := InputMap.get_action_list(action)
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
func is_action_just_pressed(s:String) -> bool:
	if !Input.is_action_just_pressed(s): return false
	if !GASConfig.input_cooldown_enabled: return true
	if active_input_cooldowns.has(s): return false
	active_input_cooldowns[s] = GASConfig.input_cooldown_length
	return true

var active_toggle_actions := []
func _process(delta:float) -> void:
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
			Input.action_press(action) # TODO: how to prevent this from returning true on another is_action_just_pressed?
			get_tree().set_input_as_handled()

func _input(event:InputEvent):
	# https://gameaccessibilityguidelines.com/avoid-provide-alternatives-to-requiring-buttons-to-be-held-down/
	for action in active_toggle_actions:
		if event.is_action_pressed(action):
			active_toggle_actions.erase(action)
			Input.action_release(action)
			get_tree().set_input_as_handled()
			return
