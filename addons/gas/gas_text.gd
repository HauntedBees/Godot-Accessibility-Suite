extends Node

signal font_scale_changed()

var override_font_scale := 1.0:
	set(value):
		override_font_scale = value
		font_scale_changed.emit()
		GASConfig.try_autosave()

var _label_settings_cache: Dictionary[LabelSettings, LabelSettingsInfo] = {}

func register_label_settings(l: LabelSettings) -> void:
	if !_label_settings_cache.has(l):
		_label_settings_cache[l] = LabelSettingsInfo.new(l)

func get_adjusted_label_settings(l: LabelSettings) -> LabelSettings:
	if override_font_scale == 1.0:
		return l
	register_label_settings(l)
	return _label_settings_cache[l].get_size(override_font_scale)

func get_adjusted_theme_override_font_size(orig_size: int) -> int:
	if override_font_scale == 1.0:
		return orig_size
	return roundi(orig_size * override_font_scale)

class LabelSettingsInfo:
	var adjusted_scales: Dictionary[float, LabelSettings] = {}
	var _base_label_settings: LabelSettings

	func _init(l: LabelSettings) -> void:
		_base_label_settings = l

	func get_size(scale: float) -> LabelSettings:
		if !adjusted_scales.has(scale):
			var split: LabelSettings = _base_label_settings.duplicate()
			split.font_size = roundi(_base_label_settings.font_size * scale)
			adjusted_scales[scale] = split
		return adjusted_scales[scale]
