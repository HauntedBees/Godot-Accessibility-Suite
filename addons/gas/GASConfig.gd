extends Node

 # https://gameaccessibilityguidelines.com/include-a-cool-down-period-post-acceptance-delay-of-0-5-seconds-between-inputs/
var input_cooldown_enabled := true
var input_cooldown_length := 0.5

# https://gameaccessibilityguidelines.com/use-an-easily-readable-default-font-size/
var vision_minimum_font_size := 28

# https://gameaccessibilityguidelines.com/avoid-provide-alternatives-to-requiring-buttons-to-be-held-down/
var input_toggle_actions := ["ui_end"]
func set_toggle_action(action:String, is_toggle:bool):
	var idx := input_toggle_actions.find(action)
	if (is_toggle && idx >= 0) || (!is_toggle && idx < 0): return
	if is_toggle: input_toggle_actions.append(action)
	else: input_toggle_actions.remove(idx)

# https://gameaccessibilityguidelines.com/include-an-option-to-adjust-the-game-speed/
var core_game_speed := 1.0 setget _set_core_game_speed
func _set_core_game_speed(s:float):
	core_game_speed = s
	Engine.time_scale = s

func _ready():
	if !_load():
		_set_core_game_speed(core_game_speed)
func _load(profile := "") -> bool:
	var config := ConfigFile.new()
	var err := config.load("user://gas%s.cfg" % profile)
	if err != OK: return false # nothing to load!
	core_game_speed = config.get_value("core", "core_game_speed", 1.0)
	input_cooldown_length = config.get_value("input", "input_cooldown_length", 0.5)
	input_cooldown_enabled = config.get_value("input", "input_cooldown_enabled", true)
	input_toggle_actions = config.get_value("input", "input_toggle_actions", ["ui_end"])
	vision_minimum_font_size = config.get_value("vision", "vision_minimum_font_size", 28)
	return true
func _save(profile := ""):
	var config := ConfigFile.new()
	config.set_value("core", "core_game_speed", core_game_speed)
	config.set_value("input", "input_cooldown_length", input_cooldown_length)
	config.set_value("input", "input_cooldown_enabled", input_cooldown_enabled)
	config.set_value("input", "input_toggle_actions", input_toggle_actions)
	config.set_value("vision", "vision_minimum_font_size", vision_minimum_font_size)
	config.save("user://gas%s.cfg" % profile)
