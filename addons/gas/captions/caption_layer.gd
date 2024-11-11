extends CanvasLayer

var custom_theme: Theme:
	set(value):
		custom_theme = value
		if !is_inside_tree():
			await ready
		_primary_caption.theme = custom_theme
		_margin_container.theme = custom_theme

@onready var _primary_caption: RichTextLabel = %PrimaryCaption
@onready var _margin_container: MarginContainer = %MarginContainer

func _ready() -> void:
	_primary_caption.visible = false

func duplicate_theme_to_custom() -> void:
	custom_theme = _primary_caption.theme.duplicate(true)

func register_caption(data: GASAudioCaption,  priority := 0) -> GASActiveCaption:
	return GASActiveCaption.new(_get_label(priority), data)

func show_placeholder_message(priority := 0, message := "Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit.") -> void:
	var label := _get_label(priority)
	label.visible = true
	label.text = "[center]%s[/center]" % message

func _get_label(priority := 0) -> RichTextLabel:
	match priority:
		0: return _primary_caption
	return _primary_caption
