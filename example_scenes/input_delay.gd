extends ExampleSceneRoot

@onready var _log: AccessibleRichTextLabel = %Log

func _ready() -> void:
	GASInput.input_cooldown_enabled = true
	GASInput.input_cooldown_length = 0.5

func clean_up() -> void:
	GASInput.input_cooldown_enabled = false

func _input(event: InputEvent) -> void:
	for i in ["ui_down", "ui_left", "ui_right", "ui_up"]:
		if GASInput.is_event_action_just_pressed(event, i):
			_log.text = "%s just pressed.\n%s" % [i, _log.text]

func _on_enabled_toggled(toggled_on: bool) -> void:
	GASInput.input_cooldown_enabled = toggled_on

func _on_value_value_changed(value: float) -> void:
	GASInput.input_cooldown_length = value
