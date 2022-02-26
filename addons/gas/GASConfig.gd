extends Node

 # https://gameaccessibilityguidelines.com/include-a-cool-down-period-post-acceptance-delay-of-0-5-seconds-between-inputs/
var input_cooldown_enabled := false
var input_cooldown_length := 0.5

# https://gameaccessibilityguidelines.com/include-an-option-to-adjust-the-game-speed/
var core_game_speed := 1.0 setget _set_core_game_speed
func _set_core_game_speed(s:float):
	core_game_speed = s
	Engine.time_scale = s

func _ready():
	if !_load():
		_set_core_game_speed(core_game_speed)
func _load() -> bool:
	var config := ConfigFile.new()
	var err := config.load("user://gas.cfg")
	if err != OK: return false # nothing to load!
	core_game_speed = config.get_value("core", "core_game_speed")
	input_cooldown_length = config.get_value("input", "input_cooldown_length")
	input_cooldown_enabled = config.get_value("input", "input_cooldown_enabled")
	return true
func _save():
	var config := ConfigFile.new()
	config.set_value("core", "core_game_speed", core_game_speed)
	config.set_value("input", "input_cooldown_length", input_cooldown_length)
	config.set_value("input", "input_cooldown_enabled", input_cooldown_enabled)
	config.save("user://gas.cfg")
