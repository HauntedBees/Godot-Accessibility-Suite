extends CanvasLayer

@onready var _primary_caption: RichTextLabel = %PrimaryCaption

func _ready() -> void:
	_primary_caption.visible = false

func register_caption(data: GASAudioCaption,  priority := 0) -> GASActiveCaption:
	var label := _get_label(priority)
	var caption := GASActiveCaption.new(label, data)
	return caption

func show_placeholder_message(priority := 0, message := "Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit.") -> void:
	var label := _get_label(priority)
	label.visible = true
	label.text = "[center]%s[/center]" % message

func _get_label(priority := 0) -> RichTextLabel:
	match priority:
		0: return _primary_caption
	return _primary_caption
