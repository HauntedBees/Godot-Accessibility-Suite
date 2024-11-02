extends Node

enum AppMode { Light, Dark }
var themes: Dictionary[AppMode, Theme] = {
	AppMode.Light: null,
	AppMode.Dark: null
}

var _use_default_profile := true
var _is_loading := false
var _custom_settings: Dictionary[String, Variant] = {}

func _ready() -> void:
	_use_default_profile = ProjectSettings.get_setting("addons/godot_accessibility_suite/autosave_settings_changes_to_default_profile", true)
	if _use_default_profile:
		load_settings.call_deferred()

func get_custom_setting(key: String) -> Variant:
	return _custom_settings[key] if _custom_settings.has(key) else null

func set_custom_setting(key: String, value: Variant) -> void:
	_custom_settings[key] = value
	try_autosave()

func load_settings(profile := "default") -> bool:
	var config := ConfigFile.new()
	if config.load("user://gas-%s.cfg" % profile) != OK: # nothing to load!
		return false
	_is_loading = true
	GASInput.vibration_scale = config.get_value("input", "vibration_scale", 1.0)
	GASInput.input_cooldown_length = config.get_value("input", "input_cooldown_length", 0.5)
	GASInput.input_cooldown_enabled = config.get_value("input", "input_cooldown_enabled", true)
	GASInput.input_toggle_actions = config.get_value("input", "input_toggle_actions", ["ui_end"])
	var default_custom_settings: Dictionary[String, Variant] = {}
	_custom_settings = config.get_value("core", "custom_settings", default_custom_settings)
	GASText.override_font_scale = config.get_value("text", "override_font_scale", 1.0)
	Engine.time_scale = config.get_value("time", "engine_time_scale", 1.0)
	if is_instance_valid(GASTime):
		GASTime.group_time_scale = config.get_value("time", "group_time_scale", 1.0)
		GASTime.signal_time_scale = config.get_value("time", "signal_time_scale", 1.0)
	_is_loading = false
	return true

func try_autosave() -> void:
	if !_is_loading && _use_default_profile:
		save_settings()

func save_settings(profile := "default") -> void:
	var config := ConfigFile.new()
	config.set_value("input", "input_cooldown_length", GASInput.input_cooldown_length)
	config.set_value("input", "input_cooldown_enabled", GASInput.input_cooldown_enabled)
	config.set_value("input", "input_toggle_actions", GASInput.input_toggle_actions)
	config.set_value("input", "vibration_scale", GASInput.vibration_scale)
	config.set_value("text", "override_font_scale", GASText.override_font_scale)
	config.set_value("time", "engine_time_scale", Engine.time_scale)
	config.set_value("core", "custom_settings", _custom_settings)
	if is_instance_valid(GASTime):
		config.set_value("time", "group_time_scale", GASTime.group_time_scale)
		config.set_value("time", "signal_time_scale", GASTime.signal_time_scale)
	config.save("user://gas-%s.cfg" % profile)
