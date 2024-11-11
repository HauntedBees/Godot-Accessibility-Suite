extends Control

@onready var _base_player: CaptionedAudioStreamPlayer = %BasePlayer

func _ready() -> void:
	GASCaptions.show_placeholder_message()

func _on_play_button_pressed() -> void:
	_base_player.play_captioned()
