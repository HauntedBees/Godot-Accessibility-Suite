@tool
@icon("icons/gas_rich_text_label.svg")
class_name AccessibleRichTextLabel extends RichTextLabel

const _FONT_SIZE_KEYS: Array[String] = [
	"normal_font_size", "bold_font_size", "bold_italics_font_size", "italics_font_size", "mono_font_size"
]

@export var scroll_speed := 1000.0
@export var action_scroll_enabled := true
@export_multiline var accessible_text := "":
	set(value):
		accessible_text = value
		_refresh_text()

var _regex := RegEx.new()
var _colors: Dictionary[String, Color] = {}
var _original_font_sizes: Dictionary[String, int] = {}
var _current_line_no := 0:
	set(value):
		_current_line_no = value
		scroll_to_line(_current_line_no)

func _ready() -> void:
	_regex.compile("\\[(font_size=\\d+)")
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
	_refresh_text()

func _on_font_scale_changed() -> void:
	for f in _FONT_SIZE_KEYS:
		var new_font_size := GASText.get_adjusted_theme_override_font_size(_original_font_sizes[f])
		add_theme_font_size_override(f, new_font_size)
		if _warn_on_font_too_small() && new_font_size < 28:
			printerr("RichTextLabel \"%s\" has a %s of %d, when the recommended minimum is 28 (see https://gameaccessibilityguidelines.com/use-an-easily-readable-default-font-size/)." % [
				get_path(), f, new_font_size
			])
	if bbcode_enabled:
		_refresh_text()
	_current_line_no = 0

func _refresh_text() -> void:
	if !is_inside_tree():
		await ready
	if !bbcode_enabled:
		text = accessible_text
		return
	var new_text := accessible_text
	if _colors.size():
		for color_key: String in _colors.keys():
			new_text = new_text \
						.replace("[%s]" % color_key, "[color=%s]" % _colors[color_key].to_html()) \
						.replace("[/%s]" % color_key, "[/color]")
	if !Engine.is_editor_hint():
		for result in _regex.search_all(accessible_text):
			var res_str := result.get_string()
			var res_val := int(res_str.split("=")[1])
			new_text = new_text.replace(res_str, "[font_size=%d" % roundi(res_val * GASText.override_font_scale))
	text = new_text

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
