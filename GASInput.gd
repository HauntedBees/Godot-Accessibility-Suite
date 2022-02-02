extends Node

const COOLDOWN_LENGTH := 0.5
var cooldowns := {}

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

func is_action_just_pressed(s:String) -> bool:
	if !Input.is_action_just_pressed(s): return false
	if cooldowns.has(s): return false
	cooldowns[s] = COOLDOWN_LENGTH
	return true

func _process(delta:float) -> void:
	for key in cooldowns:
		cooldowns[key] -= delta
		if cooldowns[key] <= 0:
			cooldowns.erase(key)
