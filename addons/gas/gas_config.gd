extends Node

enum AppMode { Light, Dark }
var themes: Dictionary[AppMode, Theme] = {
	AppMode.Light: null,
	AppMode.Dark: null
}

# https://gameaccessibilityguidelines.com/use-an-easily-readable-default-font-size/
var warn_on_font_too_small := false

 # https://gameaccessibilityguidelines.com/include-a-cool-down-period-post-acceptance-delay-of-0-5-seconds-between-inputs/
var input_cooldown_enabled := false
var input_cooldown_length := 0.5

# https://gameaccessibilityguidelines.com/include-toggle-slider-for-any-haptics/
var vibration_scale := 1.0

# https://gameaccessibilityguidelines.com/avoid-provide-alternatives-to-requiring-buttons-to-be-held-down/
var input_toggle_actions := []
func set_toggle_action(action: String, is_toggle: bool) -> void:
	var idx := input_toggle_actions.find(action)
	if (is_toggle && idx >= 0) || (!is_toggle && idx < 0):
		return
	if is_toggle:
		input_toggle_actions.append(action)
	else:
		input_toggle_actions.remove_at(idx)

# https://gameaccessibilityguidelines.com/include-an-option-to-adjust-the-game-speed/
var core_game_speed := 1.0:
	set(s):
		core_game_speed = s
		Engine.time_scale = s

func _ready() -> void:
	if !_load():
		Engine.time_scale = core_game_speed

func _load(profile := "") -> bool:
	var config := ConfigFile.new()
	if config.load("user://gas%s.cfg" % profile) != OK: # nothing to load!
		return false
	core_game_speed = config.get_value("core", "core_game_speed", 1.0)
	input_cooldown_length = config.get_value("input", "input_cooldown_length", 0.5)
	input_cooldown_enabled = config.get_value("input", "input_cooldown_enabled", true)
	input_toggle_actions = config.get_value("input", "input_toggle_actions", ["ui_end"])
	return true

func _save(profile := "") -> void:
	var config := ConfigFile.new()
	config.set_value("core", "core_game_speed", core_game_speed)
	config.set_value("input", "input_cooldown_length", input_cooldown_length)
	config.set_value("input", "input_cooldown_enabled", input_cooldown_enabled)
	config.set_value("input", "input_toggle_actions", input_toggle_actions)
	config.save("user://gas%s.cfg" % profile)
