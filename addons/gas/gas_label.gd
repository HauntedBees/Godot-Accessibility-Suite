@icon("icons/gas_label.svg")
class_name AccessibleLabel extends Label

var _original_font_size := 0
var _original_label_settings: LabelSettings

func _ready() -> void:
	if label_settings == null:
		_original_font_size = get_theme_font_size("font_size")
	else:
		_original_label_settings = label_settings
		GASText.register_label_settings(label_settings)
	GASText.font_scale_changed.connect(_on_font_scale_changed)
	_on_font_scale_changed() # initialize

func _on_font_scale_changed() -> void:
	var new_font_size := 0
	if _original_label_settings:
		label_settings = GASText.get_adjusted_label_settings(_original_label_settings)
		new_font_size = label_settings.font_size
	else:
		new_font_size = GASText.get_adjusted_theme_override_font_size(_original_font_size)
		add_theme_font_size_override("font_size", new_font_size)
	if _warn_on_font_too_small() && new_font_size < 28:
		printerr("Label \"%s\" has a font size of %d, when the recommended minimum is 28 (see https://gameaccessibilityguidelines.com/use-an-easily-readable-default-font-size/)." % [
			get_path(), new_font_size
		])

func _warn_on_font_too_small() -> bool:
	return ProjectSettings.get_setting(GASConstant.WARN_ON_FONT_SIZE, true)
