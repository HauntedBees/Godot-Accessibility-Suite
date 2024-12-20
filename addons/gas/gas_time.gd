# https://gameaccessibilityguidelines.com/include-an-option-to-adjust-the-game-speed/
extends Node

signal process(delta: float)
signal physics_process(delta: float)

var group_time_scale := 1.0:
	set(value):
		group_time_scale = value
		_update_group_time_scale()
		GASConfig.try_autosave()

var signal_time_scale := 1.0:
	set(value):
		signal_time_scale = value
		GASConfig.try_autosave()

var _group_time_scale_enabled := false

func _ready() -> void:
	if !ProjectSettings.get_setting(GASConstant.USE_GAS_TIME, true):
		queue_free()
	else:
		_update_group_time_scale()

## TODO: how to set this on GASTime nodes added to the scene after this has been called
func _update_group_time_scale() -> void:
	if group_time_scale == 1.0:
		_group_time_scale_enabled = false
		get_tree().call_group("GASTime", "set_process", true)
		get_tree().call_group("GASTime", "set_physics_process", true)
	else:
		_group_time_scale_enabled = true
		get_tree().call_group("GASTime", "set_process", false)
		get_tree().call_group("GASTime", "set_physics_process", false)

func _process(delta: float) -> void:
	if _group_time_scale_enabled:
		get_tree().call_group("GASTime", "_process", delta * group_time_scale)
	process.emit(delta * signal_time_scale)

func _physics_process(delta: float) -> void:
	if _group_time_scale_enabled:
		get_tree().call_group("GASTime", "_physics_process", delta * group_time_scale)
	physics_process.emit(delta * signal_time_scale)
