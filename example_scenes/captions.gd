extends Control

@onready var _base_player: CaptionedAudioStreamPlayer = %BasePlayer

@onready var _font_color: ColorPickerButton = %FontColor
@onready var _outline_color: ColorPickerButton = %OutlineColor
@onready var _bg_color: ColorPickerButton = %BGColor
@onready var _outline_thickness: SpinBox = %OutlineThickness
@onready var _font_size: SpinBox = %FontSize
@onready var _screen_margin: SpinBox = %ScreenMargin
@onready var _bg_margin: SpinBox = %BGMargin

func _ready() -> void:
	GASCaptions.duplicate_theme_to_custom()
	GASCaptions.show_placeholder_message()
	_bind_color_input(_font_color, "default_color", "Primary")
	_bind_color_input(_outline_color, "font_outline_color", "Primary")
	var style_box: StyleBoxFlat = GASCaptions.custom_theme.get_stylebox("normal", "Primary")
	_bg_color.color = style_box.bg_color
	_bg_color.color_changed.connect(func(c: Color) -> void:
		style_box.bg_color = c
		style_box.border_color = c
	)
	_outline_thickness.value = GASCaptions.custom_theme.get_constant("outline_size", "Primary")
	_outline_thickness.value_changed.connect(func(v: float) -> void:
		GASCaptions.custom_theme.set_constant("outline_size", "Primary", roundi(v))
	)
	_font_size.value = GASCaptions.custom_theme.get_font_size("normal_font_size", "Primary")
	_font_size.value_changed.connect(func(v: float) -> void:
		var vv: int = roundi(v)
		GASCaptions.custom_theme.set_font_size("bold_font_size", "Primary", vv)
		GASCaptions.custom_theme.set_font_size("bold_italics_font_size", "Primary", vv)
		GASCaptions.custom_theme.set_font_size("italics_font_size", "Primary", vv)
		GASCaptions.custom_theme.set_font_size("mono_font_size", "Primary", vv)
		GASCaptions.custom_theme.set_font_size("normal_font_size", "Primary", vv)
	)
	_screen_margin.value = GASCaptions.custom_theme.get_constant("margin_bottom", "MarginContainer")
	_screen_margin.value_changed.connect(func(v: float) -> void:
		var vv: int = roundi(v)
		GASCaptions.custom_theme.set_constant("margin_bottom", "MarginContainer", vv)
		GASCaptions.custom_theme.set_constant("margin_left", "MarginContainer", vv)
		GASCaptions.custom_theme.set_constant("margin_right", "MarginContainer", vv)
		GASCaptions.custom_theme.set_constant("margin_top", "MarginContainer", vv)
	)
	_bg_margin.value = style_box.border_width_bottom
	_bg_margin.value_changed.connect(func(v: float) -> void:
		var vv: int = roundi(v)
		style_box.border_width_bottom = vv
		style_box.border_width_left = vv
		style_box.border_width_right = vv
		style_box.border_width_top = vv
	)

func _on_play_button_pressed() -> void:
	_base_player.play_captioned()

func _bind_color_input(picker: ColorPickerButton, element_name: String, theme_type: String) -> void:
	picker.color = GASCaptions.custom_theme.get_color(element_name, theme_type)
	picker.color_changed.connect(func(c: Color) -> void: GASCaptions.custom_theme.set_color(element_name, theme_type, c))
