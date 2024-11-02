@icon("icons/gas_rich_text_label.svg")
class_name AccessibleRichTextLabel extends RichTextLabel

const _FONT_SIZE_KEYS: Array[String] = [
	"normal_font_size", "bold_font_size", "bold_italics_font_size", "italics_font_size", "mono_font_size"
]

@export var scroll_speed := 1000.0
@export var action_scroll_enabled := true
@export_multiline var raw_highlight_text := "":
	set(value):
		raw_highlight_text = value
		_set_highlighted_text()

var _colors: Dictionary[String, Color] = {}
var _original_font_sizes: Dictionary[String, int] = {}
var _current_line_no := 0:
	set(value):
		_current_line_no = value
		scroll_to_line(_current_line_no)

func _set(name: StringName, _value: Variant) -> bool:
	if name == "text":
		_current_line_no = 0
	return false

func _set_highlighted_text() -> void:
	if _colors.size() == 0 || !bbcode_enabled || raw_highlight_text == "":
		return
	var fixed_val := raw_highlight_text
	for color_key: String in _colors.keys():
		fixed_val = fixed_val \
						.replace("[%s]" % color_key, "[color=%s]" % _colors[color_key].to_html()) \
						.replace("[/%s]" % color_key, "[/color]")
	text = fixed_val

func _ready() -> void:
	for f in _FONT_SIZE_KEYS:
		_original_font_sizes[f] = get_theme_font_size(f)
	GASText.font_scale_changed.connect(_on_font_scale_changed)
	_on_font_scale_changed() # initialize
	_on_theme_changed()

func _on_theme_changed() -> void:
	_colors.clear()
	for color_key: String in ProjectSettings.get_setting(GASConstant.TEXT_HIGHLIGHT_KEYS, []):
		var color := get_theme_color(color_key, "RichTextHighlights")
		if color:
			_colors[color_key] = color
	_set_highlighted_text()

func _on_font_scale_changed() -> void:
	for f in _FONT_SIZE_KEYS:
		var new_font_size := GASText.get_adjusted_theme_override_font_size(_original_font_sizes[f])
		add_theme_font_size_override(f, new_font_size)
		if _warn_on_font_too_small() && new_font_size < 28:
			printerr("RichTextLabel \"%s\" has a %s of %d, when the recommended minimum is 28 (see https://gameaccessibilityguidelines.com/use-an-easily-readable-default-font-size/)." % [
				get_path(), f, new_font_size
			])
	_current_line_no = 0

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if !action_scroll_enabled:
		return
	if GASInput.is_action_just_pressed("gas_scroll_down"):
		_current_line_no = min(_current_line_no + 1, get_line_count())
	elif GASInput.is_action_just_pressed("gas_scroll_up"):
		_current_line_no = maxi(_current_line_no - 1, 0)

func _warn_on_font_too_small() -> bool:
	return ProjectSettings.get_setting(GASConstant.WARN_ON_FONT_SIZE, true)
