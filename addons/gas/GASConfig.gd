extends Node

 # https://gameaccessibilityguidelines.com/include-a-cool-down-period-post-acceptance-delay-of-0-5-seconds-between-inputs/
var input_cooldown_enabled := false
var input_cooldown_length := 0.5

func _ready(): _load()
func _load():
	var config := ConfigFile.new()
	var err := config.load("user://gas.cfg")
	if err != OK: return # nothing to load!
	input_cooldown_length = config.get_value("input", "input_cooldown_length")
	input_cooldown_enabled = config.get_value("input", "input_cooldown_enabled")
func _save():
	var config := ConfigFile.new()
	config.set_value("input", "input_cooldown_length", input_cooldown_length)
	config.set_value("input", "input_cooldown_enabled", input_cooldown_enabled)
	config.save("user://gas.cfg")
