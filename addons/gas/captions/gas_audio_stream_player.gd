@tool
class_name CaptionedAudioStreamPlayer extends AudioStreamPlayer

enum Priority { Main, Secondary, Tertiary }

const CaptionLayer := preload("res://addons/gas/captions/caption_layer.gd")

@export var priority := Priority.Main

@export var stream_with_captions: GASAudioCaption:
	set(value):
		stream_with_captions = value
		stream = value.audio

var _active: GASActiveCaption

@onready var _c: CaptionLayer = get_tree().root.get_node("/root/GASCaptions")

func _ready() -> void:
	if Engine.is_editor_hint():
		set_process_mode(Node.PROCESS_MODE_DISABLED)
	else:
		finished.connect(_clean_up)

func play_captioned(from_position := 0.0) -> void:
	play(from_position)
	_active = _c.register_caption(stream_with_captions, priority)

func _clean_up() -> void:
	if _active:
		_active.set_text()
		_active = null

func _process(_delta: float) -> void:
	if _active:
		_active.update(get_playback_position() + AudioServer.get_time_since_last_mix())
